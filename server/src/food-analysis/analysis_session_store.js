const { FoodAnalysisError, providerObservationSchema } = require('./contracts');

const WORKFLOW_STATUSES = new Set([
  'NEEDS_SECOND_IMAGE',
  'NEEDS_CONFIRMATION',
  'UNRECOGNIZED',
]);

function unavailable() {
  return new FoodAnalysisError(
    'ANALYSIS_UNAVAILABLE',
    'Phiên phân tích không khả dụng.',
    404,
  );
}

function expired() {
  return new FoodAnalysisError(
    'ANALYSIS_EXPIRED',
    'Phiên phân tích đã hết hạn.',
    410,
  );
}

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

class AnalysisSessionStore {
  constructor({
    now = () => Date.now(),
    ttlMs = 15 * 60 * 1000,
    idFactory = () => require('node:crypto').randomUUID(),
    maxSessions = 1_000,
  } = {}) {
    if (!Number.isFinite(ttlMs) || ttlMs <= 0) throw new TypeError('ttlMs must be positive');
    if (!Number.isSafeInteger(maxSessions) || maxSessions <= 0) {
      throw new TypeError('maxSessions must be a positive integer');
    }
    this.now = now;
    this.ttlMs = ttlMs;
    this.idFactory = idFactory;
    this.maxSessions = maxSessions;
    this.sessions = new Map();
    this.expiredIds = new Set();
  }

  create({ imageType, status, observation, usedSecondImage }) {
    this.sweepExpired();
    if (this.sessions.size >= this.maxSessions) throw unavailable();
    const parsedObservation = this.#parseObservation(observation);
    if (parsedObservation.imageType !== imageType
      || !WORKFLOW_STATUSES.has(status)
      || typeof usedSecondImage !== 'boolean') {
      throw new FoodAnalysisError(
        'INVALID_PROVIDER_RESPONSE',
        'Dữ liệu quan sát không hợp lệ.',
        502,
      );
    }
    const id = this.#nextId();
    const expiresAtMs = this.now() + this.ttlMs;
    const session = {
      id,
      imageType,
      status,
      observation: clone(parsedObservation),
      usedSecondImage,
      expiresAt: new Date(expiresAtMs).toISOString(),
      expiresAtMs,
    };
    this.sessions.set(id, session);
    return this.#publicSession(session);
  }

  get(id) {
    if (typeof id !== 'string' || !id.trim()) throw unavailable();
    if (this.expiredIds.has(id)) throw expired();
    const session = this.sessions.get(id);
    if (!session) throw unavailable();
    if (this.now() >= session.expiresAtMs) {
      this.sessions.delete(id);
      this.#rememberExpired(id);
      throw expired();
    }
    return this.#publicSession(session);
  }

  update(id, next) {
    const current = this.get(id);
    const observation = next.observation === undefined
      ? current.observation
      : this.#parseObservation(next.observation);
    const imageType = next.imageType === undefined ? current.imageType : next.imageType;
    const status = next.status === undefined ? current.status : next.status;
    const usedSecondImage = next.usedSecondImage === undefined
      ? current.usedSecondImage
      : next.usedSecondImage;
    if (observation.imageType !== imageType
      || !WORKFLOW_STATUSES.has(status)
      || typeof usedSecondImage !== 'boolean') {
      throw new FoodAnalysisError(
        'INVALID_PROVIDER_RESPONSE',
        'Dữ liệu quan sát không hợp lệ.',
        502,
      );
    }
    const session = this.sessions.get(id);
    session.imageType = imageType;
    session.status = status;
    session.observation = clone(observation);
    session.usedSecondImage = usedSecondImage;
    return this.#publicSession(session);
  }

  delete(id) {
    this.expiredIds.delete(id);
    return this.sessions.delete(id);
  }

  sweepExpired() {
    const now = this.now();
    let swept = 0;
    for (const [id, session] of this.sessions) {
      if (now >= session.expiresAtMs) {
        this.sessions.delete(id);
        this.#rememberExpired(id);
        swept += 1;
      }
    }
    return swept;
  }

  #parseObservation(observation) {
    const parsed = providerObservationSchema.safeParse(observation);
    if (!parsed.success) {
      throw new FoodAnalysisError(
        'INVALID_PROVIDER_RESPONSE',
        'Dữ liệu quan sát không hợp lệ.',
        502,
      );
    }
    return parsed.data;
  }

  #rememberExpired(id) {
    this.expiredIds.add(id);
    while (this.expiredIds.size > this.maxSessions) {
      this.expiredIds.delete(this.expiredIds.values().next().value);
    }
  }

  #nextId() {
    for (let attempt = 0; attempt < 10; attempt += 1) {
      const id = this.idFactory();
      if (typeof id === 'string'
        && id.trim()
        && !this.sessions.has(id)
        && !this.expiredIds.has(id)) {
        return id;
      }
    }
    throw unavailable();
  }

  #publicSession(session) {
    return clone({
      id: session.id,
      imageType: session.imageType,
      status: session.status,
      observation: session.observation,
      usedSecondImage: session.usedSecondImage,
      expiresAt: session.expiresAt,
    });
  }
}

module.exports = { AnalysisSessionStore };

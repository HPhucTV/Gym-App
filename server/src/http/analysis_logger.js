const EVENT_NAMES = new Set([
  'food_analysis_completed',
  'food_analysis_failed',
  'food_analysis_confirmation_completed',
]);
const ENUM_FIELDS = {
  imageType: new Set(['MEAL', 'NUTRITION_LABEL', 'UNKNOWN']),
  status: new Set(['NEEDS_SECOND_IMAGE', 'NEEDS_CONFIRMATION', 'READY', 'UNRECOGNIZED']),
  confidenceBucket: new Set(['LOW', 'MEDIUM', 'HIGH']),
  errorCode: new Set([
    'INVALID_IMAGE',
    'IMAGE_TOO_LARGE',
    'INVALID_UPLOAD',
    'INVALID_CONFIRMATION',
    'ANALYSIS_EXPIRED',
    'ANALYSIS_UNAVAILABLE',
    'INVALID_PROVIDER_RESPONSE',
    'DATABASE_NO_MATCH',
    'UNSUPPORTED_FOOD_DATA',
    'UNSUPPORTED_PORTION',
    'RATE_LIMITED',
    'INTERNAL_ERROR',
  ]),
  componentCorrectionBucket: new Set(['NONE', 'ONE', 'MULTIPLE']),
  portionCorrectionBucket: new Set(['NONE', 'ONE', 'MULTIPLE']),
  rangeWidthBucket: new Set(['NARROW', 'MEDIUM', 'WIDE']),
  durationBucket: new Set(['FAST', 'NORMAL', 'SLOW']),
};

function countBucket(count) {
  if (count <= 0) return 'NONE';
  return count === 1 ? 'ONE' : 'MULTIPLE';
}

function confirmationCorrectionBuckets(observation, confirmation) {
  const observed = new Map(
    (Array.isArray(observation?.components) ? observation.components : [])
      .map((component) => [component.id, component]),
  );
  const confirmedComponents = Array.isArray(confirmation?.components) ? confirmation.components : [];
  const confirmedIds = new Set(confirmedComponents.map((component) => component?.observationId));
  let componentCorrections = [...observed.keys()]
    .filter((observationId) => !confirmedIds.has(observationId))
    .length;
  let portionCorrections = 0;
  for (const component of confirmedComponents) {
    const original = observed.get(component?.observationId);
    if (!original) {
      componentCorrections += 1;
      portionCorrections += 1;
      continue;
    }
    if (component.nameVi !== original.nameVi) componentCorrections += 1;
    if (JSON.stringify(component.portion) !== JSON.stringify(original.suggestedPortion)) {
      portionCorrections += 1;
    }
  }
  return {
    componentCorrectionBucket: countBucket(componentCorrections),
    portionCorrectionBucket: countBucket(portionCorrections),
  };
}

function confidenceBucket(confidence) {
  if (!Number.isFinite(confidence)) return undefined;
  if (confidence >= 0.8) return 'HIGH';
  if (confidence >= 0.55) return 'MEDIUM';
  return 'LOW';
}

function durationBucket(durationMs) {
  if (!Number.isFinite(durationMs) || durationMs < 0) return undefined;
  if (durationMs < 1_000) return 'FAST';
  if (durationMs < 10_000) return 'NORMAL';
  return 'SLOW';
}

function rangeWidthBucket(estimate) {
  const range = estimate?.calories;
  if (!range || !Number.isFinite(range.min) || !Number.isFinite(range.mid) || !Number.isFinite(range.max)) {
    return undefined;
  }
  const widthRatio = range.mid > 0 ? (range.max - range.min) / range.mid : 0;
  if (widthRatio <= 0.15) return 'NARROW';
  if (widthRatio <= 0.35) return 'MEDIUM';
  return 'WIDE';
}

class AnalysisLogger {
  constructor({ writeLine = (line) => process.stdout.write(`${line}\n`) } = {}) {
    this.writeLine = writeLine;
  }

  event(name, fields = {}) {
    const record = {};
    if (EVENT_NAMES.has(name)) record.event = name;
    if (typeof fields.requestId === 'string' && fields.requestId.length > 0 && fields.requestId.length <= 128) {
      record.requestId = fields.requestId;
    }
    for (const [field, values] of Object.entries(ENUM_FIELDS)) {
      if (values.has(fields[field])) record[field] = fields[field];
    }
    if (typeof fields.usedSecondImage === 'boolean') {
      record.usedSecondImage = fields.usedSecondImage;
    }
    this.writeLine(JSON.stringify(record));
  }
}

module.exports = {
  AnalysisLogger,
  confidenceBucket,
  confirmationCorrectionBuckets,
  durationBucket,
  rangeWidthBucket,
};

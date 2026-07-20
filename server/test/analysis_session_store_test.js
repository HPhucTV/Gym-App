const test = require('node:test');
const assert = require('node:assert/strict');
const { AnalysisSessionStore } = require('../src/food-analysis/analysis_session_store');

function mealObservation(confidence = 0.8) {
  return {
    imageType: 'MEAL',
    confidence,
    uncertaintyReasons: [],
    components: [{
      id: 'component-1',
      nameVi: 'Cơm trắng',
      confidence,
      isMajor: true,
      suggestedPortion: {
        kind: 'HOUSEHOLD',
        unit: 'BOWL',
        quantity: 1,
        size: 'MEDIUM',
      },
    }],
    labelFacts: null,
  };
}

test('creates an isolated structured session with a 15-minute ISO expiry', () => {
  let now = Date.parse('2026-07-20T10:00:00.000Z');
  const store = new AnalysisSessionStore({
    now: () => now,
    idFactory: () => 'analysis-1',
  });
  const observation = mealObservation();

  const created = store.create({
    imageType: 'MEAL',
    status: 'NEEDS_CONFIRMATION',
    observation,
    usedSecondImage: false,
  });
  observation.components[0].nameVi = 'mutated';

  assert.equal(created.id, 'analysis-1');
  assert.equal(created.expiresAt, '2026-07-20T10:15:00.000Z');
  assert.equal(store.get(created.id).observation.components[0].nameVi, 'Cơm trắng');
  assert.equal(JSON.stringify(store.get(created.id)).includes('Buffer'), false);
});

test('updates only structured session fields and deletes sessions', () => {
  const store = new AnalysisSessionStore({ idFactory: () => 'analysis-1' });
  store.create({
    imageType: 'MEAL',
    status: 'NEEDS_SECOND_IMAGE',
    observation: mealObservation(0.4),
    usedSecondImage: false,
  });

  const updated = store.update('analysis-1', {
    status: 'NEEDS_CONFIRMATION',
    observation: mealObservation(0.7),
    usedSecondImage: true,
    imageBytes: Buffer.from('forbidden'),
    prompt: 'forbidden',
    rawProviderResponse: 'forbidden',
  });

  assert.equal(updated.status, 'NEEDS_CONFIRMATION');
  assert.equal(updated.usedSecondImage, true);
  assert.equal(updated.imageBytes, undefined);
  assert.equal(updated.prompt, undefined);
  assert.equal(updated.rawProviderResponse, undefined);
  store.delete('analysis-1');
  assert.throws(() => store.get('analysis-1'), (error) => error.code === 'ANALYSIS_UNAVAILABLE');
});

test('distinguishes expired known sessions from malformed and unknown IDs', () => {
  let now = 1_000;
  const store = new AnalysisSessionStore({
    now: () => now,
    ttlMs: 100,
    idFactory: () => 'analysis-1',
  });
  store.create({
    imageType: 'MEAL',
    status: 'NEEDS_CONFIRMATION',
    observation: mealObservation(),
    usedSecondImage: false,
  });

  now = 1_101;

  assert.throws(() => store.get('analysis-1'), (error) => error.code === 'ANALYSIS_EXPIRED');
  assert.throws(() => store.get(''), (error) => error.code === 'ANALYSIS_UNAVAILABLE');
  assert.throws(() => store.get('unguessable-but-unknown'), (error) => error.code === 'ANALYSIS_UNAVAILABLE');
});

test('sweeps expired sessions before enforcing the configured capacity', () => {
  let now = 1_000;
  let id = 0;
  const store = new AnalysisSessionStore({
    now: () => now,
    ttlMs: 100,
    maxSessions: 1,
    idFactory: () => `analysis-${++id}`,
  });
  store.create({
    imageType: 'MEAL',
    status: 'NEEDS_CONFIRMATION',
    observation: mealObservation(),
    usedSecondImage: false,
  });
  assert.throws(
    () => store.create({
      imageType: 'MEAL',
      status: 'NEEDS_CONFIRMATION',
      observation: mealObservation(),
      usedSecondImage: false,
    }),
    (error) => error.code === 'ANALYSIS_UNAVAILABLE',
  );

  now = 1_101;
  const replacement = store.create({
    imageType: 'MEAL',
    status: 'NEEDS_CONFIRMATION',
    observation: mealObservation(),
    usedSecondImage: false,
  });

  assert.equal(replacement.id, 'analysis-2');
});

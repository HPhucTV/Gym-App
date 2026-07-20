const test = require('node:test');
const assert = require('node:assert/strict');
const {
  AnalysisLogger,
  confirmationCorrectionBuckets,
} = require('../src/http/analysis_logger');

test('writes one JSON line containing only allowlisted bounded telemetry', () => {
  const lines = [];
  const logger = new AnalysisLogger({ writeLine: (line) => lines.push(line) });

  logger.event('food_analysis_completed', {
    requestId: 'request-1',
    imageType: 'MEAL',
    status: 'NEEDS_CONFIRMATION',
    confidenceBucket: 'HIGH',
    usedSecondImage: false,
    componentCorrectionBucket: 'ONE',
    portionCorrectionBucket: 'MULTIPLE',
    rangeWidthBucket: 'NARROW',
    durationBucket: 'FAST',
    nameVi: 'Không được ghi',
    image: Buffer.from('private'),
    prompt: 'private prompt',
    history: [{ calories: 123 }],
    arbitrary: 'discard me',
  });

  assert.equal(lines.length, 1);
  assert.equal(lines[0].endsWith('\n'), false);
  assert.deepEqual(JSON.parse(lines[0]), {
    requestId: 'request-1',
    event: 'food_analysis_completed',
    imageType: 'MEAL',
    status: 'NEEDS_CONFIRMATION',
    confidenceBucket: 'HIGH',
    usedSecondImage: false,
    componentCorrectionBucket: 'ONE',
    portionCorrectionBucket: 'MULTIPLE',
    rangeWidthBucket: 'NARROW',
    durationBucket: 'FAST',
  });
});

test('drops invalid event names, enum values, and non-boolean flags', () => {
  const lines = [];
  const logger = new AnalysisLogger({ writeLine: (line) => lines.push(line) });

  logger.event('attacker_event', {
    imageType: 'RAW_LABEL',
    status: 'admin',
    confidenceBucket: '0.92345',
    errorCode: 'provider response and secret',
    usedSecondImage: 'yes',
    componentCorrectionBucket: '7',
    portionCorrectionBucket: 'all',
    rangeWidthBucket: '99.1',
    durationBucket: '1234ms',
  });

  assert.deepEqual(JSON.parse(lines[0]), {});
});

test('buckets component and portion corrections without returning labels or values', () => {
  const observation = {
    components: [
      {
        id: 'one',
        nameVi: 'Cơm',
        suggestedPortion: { kind: 'HOUSEHOLD', unit: 'BOWL', quantity: 1, size: 'MEDIUM' },
      },
      {
        id: 'two',
        nameVi: 'Gà',
        suggestedPortion: { kind: 'GRAMS', grams: 100 },
      },
    ],
  };

  assert.deepEqual(confirmationCorrectionBuckets(observation, {
    components: [
      {
        observationId: 'one',
        nameVi: 'Cơm',
        portion: { kind: 'HOUSEHOLD', unit: 'BOWL', quantity: 1, size: 'MEDIUM' },
      },
      {
        observationId: 'two',
        nameVi: 'Ức gà',
        portion: { kind: 'GRAMS', grams: 150 },
      },
    ],
  }), {
    componentCorrectionBucket: 'ONE',
    portionCorrectionBucket: 'ONE',
  });

  assert.deepEqual(confirmationCorrectionBuckets(observation, {
    components: [
      { observationId: 'one', nameVi: 'Khác 1', portion: { kind: 'GRAMS', grams: 1 } },
      { observationId: 'two', nameVi: 'Khác 2', portion: { kind: 'GRAMS', grams: 2 } },
    ],
  }), {
    componentCorrectionBucket: 'MULTIPLE',
    portionCorrectionBucket: 'MULTIPLE',
  });
});

test('counts an omitted observed component as a component correction', () => {
  const observation = {
    components: [
      { id: 'one', nameVi: 'Cơm', suggestedPortion: { kind: 'GRAMS', grams: 100 } },
      { id: 'two', nameVi: 'Gà', suggestedPortion: { kind: 'GRAMS', grams: 100 } },
    ],
  };

  assert.deepEqual(confirmationCorrectionBuckets(observation, {
    components: [
      { observationId: 'one', nameVi: 'Cơm', portion: { kind: 'GRAMS', grams: 100 } },
    ],
  }), {
    componentCorrectionBucket: 'ONE',
    portionCorrectionBucket: 'NONE',
  });
});

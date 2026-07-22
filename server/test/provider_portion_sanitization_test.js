const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const { AnalysisSessionStore } = require('../src/food-analysis/analysis_session_store');
const { FoodAnalysisService } = require('../src/food-analysis/food_analysis_service');
const { FoodDatabase } = require('../src/food-analysis/food_database');
const { NutritionEstimator } = require('../src/food-analysis/nutrition_estimator');

const records = JSON.parse(fs.readFileSync(
  path.join(__dirname, '..', 'data', 'vietnamese_foods.json'),
  'utf8',
));

function observation(portion) {
  return {
    imageType: 'MEAL',
    confidence: 0.9,
    uncertaintyReasons: [],
    components: [{
      id: 'component-rice',
      nameVi: 'Cơm trắng',
      confidence: 0.9,
      isMajor: true,
      suggestedPortion: portion,
    }],
    labelFacts: null,
  };
}

function serviceFor(primary, secondary = primary) {
  let id = 0;
  return new FoodAnalysisService({
    observer: {
      observePrimary: async () => primary,
      observeSecondary: async () => secondary,
    },
    estimator: new NutritionEstimator({ database: new FoodDatabase(records) }),
    sessionStore: new AnalysisSessionStore({
      now: () => 0,
      idFactory: () => `analysis-${++id}`,
    }),
    logger: { event() {} },
  });
}

test('provider cannot bypass food capabilities with an unsupported suggestion', async () => {
  const service = serviceFor(observation({
    kind: 'HOUSEHOLD',
    unit: 'PIECE',
    quantity: 1,
    size: 'MEDIUM',
  }));

  const review = await service.start({ bytes: Buffer.alloc(1), mimeType: 'image/jpeg' });

  assert.equal(review.status, 'NEEDS_SECOND_IMAGE');
  assert.equal(review.components[0].suggestedPortion, null);
});

test('unsupported secondary suggestion is returned as a manual correction', async () => {
  const service = serviceFor(
    observation(null),
    observation({
      kind: 'HOUSEHOLD',
      unit: 'PIECE',
      quantity: 1,
      size: 'MEDIUM',
    }),
  );
  const first = await service.start({ bytes: Buffer.alloc(1), mimeType: 'image/jpeg' });

  const review = await service.addSecondaryImage(first.analysisId, {
    bytes: Buffer.alloc(1),
    mimeType: 'image/jpeg',
  });

  assert.equal(review.status, 'NEEDS_CONFIRMATION');
  assert.equal(review.components[0].suggestedPortion, null);
  assert.equal(review.components[0].requiresManualPortion, true);
});

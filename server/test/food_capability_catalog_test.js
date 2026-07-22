const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const { FoodDatabase } = require('../src/food-analysis/food_database');
const { NutritionEstimator } = require('../src/food-analysis/nutrition_estimator');

const records = JSON.parse(fs.readFileSync(
  path.join(__dirname, '..', 'data', 'vietnamese_foods.json'),
  'utf8',
));

test('public catalog exposes only bounded capabilities without nutrition or aliases', () => {
  const database = new FoodDatabase(records);
  const catalog = database.publicCatalog();

  assert.ok(catalog.length > 0 && catalog.length <= 100);
  for (const food of catalog) {
    assert.deepEqual(Object.keys(food).sort(), [
      'foodId',
      'nameVi',
      'portionOptions',
      'supportsGrams',
    ]);
    assert.equal(typeof food.foodId, 'string');
    assert.equal(typeof food.nameVi, 'string');
    assert.equal(typeof food.supportsGrams, 'boolean');
    assert.ok(Array.isArray(food.portionOptions));
    assert.equal(JSON.stringify(food).includes('nutrient'), false);
    assert.equal(JSON.stringify(food).includes('aliases'), false);
  }
});

test('every advertised portion capability succeeds in the estimator', () => {
  const database = new FoodDatabase(records);
  const estimator = new NutritionEstimator({ database });

  for (const food of database.publicCatalog()) {
    if (food.supportsGrams) {
      assert.doesNotThrow(() => estimator.estimateMeal({
        nameVi: food.nameVi,
        uncertaintyReasons: [],
        components: [{
          observationId: `grams-${food.foodId}`,
          foodId: food.foodId,
          nameVi: food.nameVi,
          portion: { kind: 'GRAMS', grams: 100 },
        }],
      }));
    }
    for (const option of food.portionOptions) {
      for (const size of option.sizes) {
        assert.doesNotThrow(() => estimator.estimateMeal({
          nameVi: food.nameVi,
          uncertaintyReasons: [],
          components: [{
            observationId: `${option.unit}-${size}`,
            foodId: food.foodId,
            nameVi: food.nameVi,
            portion: {
              kind: 'HOUSEHOLD',
              unit: option.unit,
              quantity: 1,
              size,
            },
          }],
        }), `${food.foodId} ${option.unit} ${size} was advertised but rejected`);
      }
    }
  }
});

test('direct-unit foods advertise only their real medium unit and no unsupported choices', () => {
  const catalog = new Map(new FoodDatabase(records).publicCatalog()
    .map((food) => [food.foodId, food]));

  for (const id of ['fried-egg', 'boiled-egg', 'chicken-egg', 'fried-egg-sunny-side']) {
    assert.deepEqual(catalog.get(id).portionOptions, [{ unit: 'PIECE', sizes: ['MEDIUM'] }]);
    assert.equal(catalog.get(id).supportsGrams, false);
  }
  for (const id of ['beef-pho', 'bun-bo-hue', 'meat-banh-mi', 'instant-noodles']) {
    assert.deepEqual(catalog.get(id).portionOptions, [{ unit: 'SERVING', sizes: ['MEDIUM'] }]);
    assert.equal(catalog.get(id).supportsGrams, false);
  }
});

test('reviewed common foods advertise familiar capabilities backed by shipped data', () => {
  const catalog = new Map(new FoodDatabase(records).publicCatalog()
    .map((food) => [food.foodId, food]));

  assert.deepEqual(catalog.get('white-rice').portionOptions, [{
    unit: 'BOWL',
    sizes: ['SMALL', 'MEDIUM', 'LARGE'],
  }]);
  for (const id of ['chicken-breast', 'braised-pork', 'fried-fish']) {
    assert.deepEqual(catalog.get(id).portionOptions, [{
      unit: 'PIECE',
      sizes: ['SMALL', 'MEDIUM', 'LARGE'],
    }]);
  }
  assert.deepEqual(catalog.get('boiled-vegetables').portionOptions, [{
    unit: 'SERVING',
    sizes: ['SMALL', 'MEDIUM', 'LARGE'],
  }]);
});

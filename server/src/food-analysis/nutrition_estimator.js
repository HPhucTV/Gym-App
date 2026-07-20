const {
  FoodAnalysisError,
  labelConfirmationSchema,
  mealConfirmationSchema,
  parseConfirmation,
} = require('./contracts');

const NUTRIENTS = ['calories', 'proteinGrams', 'carbsGrams', 'fatGrams'];
const RANGE_MULTIPLIERS = {
  HIDDEN_OIL: { min: 0.85, max: 1.2 },
  SAUCE: { min: 0.9, max: 1.15 },
  OVERLAP: { min: 0.9, max: 1.1 },
  WEAK_DATABASE_MATCH: { min: 0.85, max: 1.15 },
};

function rounded(value, nutrient) {
  return nutrient === 'calories' ? Math.round(value) : Math.round(value * 10) / 10;
}

function zeroRange() {
  return { min: 0, mid: 0, max: 0 };
}

function addRange(left, right) {
  return { min: left.min + right.min, mid: left.mid + right.mid, max: left.max + right.max };
}

function toEstimate(values) {
  return Object.fromEntries(NUTRIENTS.map((nutrient) => [nutrient, {
    min: rounded(values[nutrient].min, nutrient),
    mid: rounded(values[nutrient].mid, nutrient),
    max: rounded(values[nutrient].max, nutrient),
  }]));
}

class NutritionEstimator {
  constructor({ database }) {
    this.database = database;
  }

  estimateMeal(input) {
    const confirmation = parseConfirmation(mealConfirmationSchema, input);
    const total = Object.fromEntries(NUTRIENTS.map((nutrient) => [nutrient, zeroRange()]));
    for (const component of confirmation.components) {
      const record = this.database.require(component);
      const grams = this.#gramsForPortion(record, component.portion);
      for (const nutrient of NUTRIENTS) {
        const range = this.#nutrientRange(record, nutrient, grams);
        total[nutrient] = addRange(total[nutrient], range);
      }
    }
    this.#widen(total, confirmation.uncertaintyReasons);
    return {
      estimate: toEstimate(total),
      confidenceLevel: confirmation.uncertaintyReasons.length === 0 ? 'HIGH' : confirmation.uncertaintyReasons.length === 1 ? 'MEDIUM' : 'LOW',
      calculationSummaryVi: `Ước tính từ ${confirmation.components.length} thành phần đã xác nhận.`,
    };
  }

  estimateLabel(input) {
    const confirmation = parseConfirmation(labelConfirmationSchema, input);
    this.#assertPlausibleFacts(confirmation.facts);
    const multiplier = confirmation.basis === 'PER_100G'
      ? confirmation.consumed.amount / 100
      : confirmation.consumed.kind === 'SERVINGS'
        ? confirmation.consumed.amount
        : confirmation.consumed.amount / confirmation.servingSizeGrams;
    const estimate = {};
    for (const nutrient of NUTRIENTS) {
      const value = rounded(confirmation.facts[nutrient] * multiplier, nutrient);
      estimate[nutrient] = { min: value, mid: value, max: value };
    }
    const consumedGrams = confirmation.basis === 'PER_100G'
      ? confirmation.consumed.amount
      : confirmation.consumed.kind === 'GRAMS'
        ? confirmation.consumed.amount
        : confirmation.consumed.amount * confirmation.servingSizeGrams;
    return {
      estimate,
      consumedGrams: rounded(consumedGrams, 'proteinGrams'),
      confidenceLevel: 'HIGH',
      calculationSummaryVi: `Tính theo nhãn đã xác nhận cho ${rounded(consumedGrams, 'proteinGrams')} g.`,
    };
  }

  #gramsForPortion(record, portion) {
    if (portion.kind === 'GRAMS') return { min: portion.grams, mid: portion.grams, max: portion.grams };
    const weights = record.householdPortions?.[portion.unit]?.[portion.size];
    if (!weights) {
      throw new FoodAnalysisError('UNSUPPORTED_PORTION', 'Khẩu phần gia dụng chưa được hỗ trợ cho thực phẩm này.', 422, { unit: portion.unit });
    }
    return Object.fromEntries(['min', 'mid', 'max'].map((bound) => [`${bound}`, weights[`${bound}Grams`] * portion.quantity]));
  }

  #nutrientRange(record, nutrient, grams) {
    if (!record.nutrientsPer100g) {
      throw new FoodAnalysisError('UNSUPPORTED_FOOD_DATA', 'Thực phẩm chưa có dữ liệu theo gram để ước tính.', 422, { foodId: record.id });
    }
    return Object.fromEntries(['min', 'mid', 'max'].map((bound) => [bound, record.nutrientsPer100g[nutrient] * grams[bound] / 100]));
  }

  #widen(total, reasons) {
    for (const reason of reasons) {
      const multiplier = RANGE_MULTIPLIERS[reason];
      for (const nutrient of NUTRIENTS) {
        total[nutrient].min *= multiplier.min;
        total[nutrient].max *= multiplier.max;
      }
    }
  }

  #assertPlausibleFacts(facts) {
    const macroCalories = facts.proteinGrams * 4 + facts.carbsGrams * 4 + facts.fatGrams * 9;
    // Labels are accepted within 25% or 40 kcal (whichever is greater) for fibre and rounding differences.
    const tolerance = Math.max(40, macroCalories * 0.25);
    if (Math.abs(facts.calories - macroCalories) > tolerance) {
      throw new FoodAnalysisError('INVALID_CONFIRMATION', 'Năng lượng trên nhãn không phù hợp với các chất đa lượng.', 400, { field: 'facts.calories' });
    }
  }
}

module.exports = { NutritionEstimator };

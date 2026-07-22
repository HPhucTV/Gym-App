const { FoodAnalysisError } = require('./contracts');

function normalizeVietnamese(value) {
  return String(value || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'd')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();
}

class FoodDatabase {
  constructor(records) {
    this.records = new Map();
    this.aliases = new Map();
    for (const record of records) {
      this.records.set(record.id, record);
      for (const name of [record.nameVi, ...(record.aliases || [])]) {
        this.aliases.set(normalizeVietnamese(name), record);
      }
    }
  }

  findById(id) {
    return this.records.get(id) || null;
  }

  publicCatalog() {
    const sizeOrder = ['SMALL', 'MEDIUM', 'LARGE'];
    const unitOrder = ['BOWL', 'PIECE', 'SPOON', 'SERVING'];
    return [...this.records.values()].slice(0, 100).map((record) => {
      const byUnit = new Map();
      if (record.directUnit && unitOrder.includes(record.directUnit)) {
        byUnit.set(record.directUnit, new Set(['MEDIUM']));
      }
      for (const [unit, portions] of Object.entries(record.householdPortions || {})) {
        if (!unitOrder.includes(unit) || !portions || typeof portions !== 'object') continue;
        const sizes = byUnit.get(unit) || new Set();
        for (const size of sizeOrder) {
          const range = portions[size];
          if (range && Number.isFinite(range.minGrams)
            && Number.isFinite(range.midGrams)
            && Number.isFinite(range.maxGrams)
            && range.minGrams > 0
            && range.minGrams <= range.midGrams
            && range.midGrams <= range.maxGrams) {
            sizes.add(size);
          }
        }
        if (sizes.size > 0) byUnit.set(unit, sizes);
      }
      return {
        foodId: record.id,
        nameVi: record.nameVi,
        supportsGrams: Boolean(record.nutrientsPer100g),
        portionOptions: unitOrder
          .filter((unit) => byUnit.has(unit))
          .map((unit) => ({
            unit,
            sizes: sizeOrder.filter((size) => byUnit.get(unit).has(size)),
          })),
      };
    });
  }

  supportsPortion(record, portion) {
    if (!record || !portion) return false;
    if (portion.kind === 'GRAMS') return Boolean(record.nutrientsPer100g);
    if (portion.kind !== 'HOUSEHOLD') return false;
    if (record.nutrientsPerUnit
      && record.directUnit === portion.unit
      && portion.size === 'MEDIUM') {
      return true;
    }
    const weights = record.householdPortions?.[portion.unit]?.[portion.size];
    return Boolean(record.nutrientsPer100g
      && weights
      && Number.isFinite(weights.minGrams)
      && Number.isFinite(weights.midGrams)
      && Number.isFinite(weights.maxGrams)
      && weights.minGrams > 0
      && weights.minGrams <= weights.midGrams
      && weights.midGrams <= weights.maxGrams);
  }

  match(name) {
    const normalized = normalizeVietnamese(name);
    const exact = this.aliases.get(normalized);
    if (exact) return exact;
    if (['thit', 'ca', 'trung'].includes(normalized)) return null;
    if (!normalized || normalized.length < 4) return null;
    for (const [alias, record] of this.aliases) {
      if (alias.length >= 4 && (normalized.includes(alias) || alias.includes(normalized))) return record;
    }
    return null;
  }

  require(component) {
    const record = component.foodId ? this.findById(component.foodId) : this.match(component.nameVi);
    if (!record) {
      throw new FoodAnalysisError(
        'DATABASE_NO_MATCH',
        'Không tìm thấy thực phẩm phù hợp trong dữ liệu đã duyệt.',
        422,
        {
          foodId: component.foodId || 'unknown',
          observationId: component.observationId,
        },
      );
    }
    return record;
  }
}

module.exports = { FoodDatabase, normalizeVietnamese };

const { z } = require('zod');

const finiteNonNegative = z.number().finite().min(0);
const portionSchema = z.discriminatedUnion('kind', [
  z.object({
    kind: z.literal('HOUSEHOLD'),
    unit: z.enum(['BOWL', 'PIECE', 'SPOON', 'SERVING']),
    quantity: z.number().finite().positive().max(20),
    size: z.enum(['SMALL', 'MEDIUM', 'LARGE']),
  }).strict(),
  z.object({
    kind: z.literal('GRAMS'),
    grams: z.number().finite().positive().max(5000),
  }).strict(),
]);

const nutrientFactsSchema = z.object({
  calories: finiteNonNegative.max(1000),
  proteinGrams: finiteNonNegative.max(100),
  carbsGrams: finiteNonNegative.max(100),
  fatGrams: finiteNonNegative.max(100),
}).strict();

const uncertaintyReasonSchema = z.enum(['HIDDEN_OIL', 'SAUCE', 'OVERLAP', 'WEAK_DATABASE_MATCH']);
const mealComponentSchema = z.object({
  observationId: z.string().trim().min(1).max(100),
  foodId: z.string().trim().min(1).max(100).optional(),
  nameVi: z.string().trim().min(1).max(160),
  portion: portionSchema,
}).strict();
const mealConfirmationSchema = z.object({
  nameVi: z.string().trim().min(1).max(160),
  components: z.array(mealComponentSchema).min(1).max(20),
  uncertaintyReasons: z.array(uncertaintyReasonSchema).max(4),
}).strict();

const consumedSchema = z.discriminatedUnion('kind', [
  z.object({ kind: z.literal('GRAMS'), amount: z.number().finite().positive().max(5000) }).strict(),
  z.object({ kind: z.literal('SERVINGS'), amount: z.number().finite().positive().max(20) }).strict(),
]);
const labelConfirmationSchema = z.object({
  nameVi: z.string().trim().min(1).max(160),
  basis: z.enum(['PER_100G', 'PER_SERVING']),
  facts: nutrientFactsSchema,
  servingSizeGrams: z.number().finite().positive().max(5000).optional(),
  consumed: consumedSchema,
}).strict().superRefine((value, context) => {
  if (value.basis === 'PER_SERVING' && value.servingSizeGrams === undefined) {
    context.addIssue({ code: z.ZodIssueCode.custom, path: ['servingSizeGrams'], message: 'Bắt buộc với PER_SERVING' });
  }
  if (value.basis === 'PER_100G' && value.consumed.kind === 'SERVINGS') {
    context.addIssue({ code: z.ZodIssueCode.custom, path: ['consumed'], message: 'PER_100G cần lượng gram' });
  }
});

const providerObservationSchema = z.object({
  observationId: z.string().trim().min(1).max(100),
  nameVi: z.string().trim().min(1).max(160),
  confidence: z.number().finite().min(0).max(1),
}).strict();
const analysisStatusSchema = z.enum(['PENDING_CONFIRMATION', 'CONFIRMED', 'REJECTED']);
const rangeSchema = z.object({ min: finiteNonNegative, mid: finiteNonNegative, max: finiteNonNegative }).strict()
  .refine((range) => range.min <= range.mid && range.mid <= range.max, 'Khoảng ước tính không hợp lệ');
const nutritionEstimateSchema = z.object({
  calories: rangeSchema,
  proteinGrams: rangeSchema,
  carbsGrams: rangeSchema,
  fatGrams: rangeSchema,
}).strict();

class FoodAnalysisError extends Error {
  constructor(code, message, httpStatus = 400, details) {
    super(message);
    this.name = 'FoodAnalysisError';
    this.code = code;
    this.httpStatus = httpStatus;
    this.details = details && typeof details === 'object'
      ? Object.fromEntries(Object.entries(details).slice(0, 4).map(([key, value]) => [key, String(value).slice(0, 120)]))
      : undefined;
  }
}

function parseConfirmation(schema, value) {
  const parsed = schema.safeParse(value);
  if (parsed.success) return parsed.data;
  const field = parsed.error.issues[0]?.path.join('.') || 'confirmation';
  throw new FoodAnalysisError('INVALID_CONFIRMATION', 'Xác nhận dinh dưỡng không hợp lệ.', 400, { field });
}

module.exports = {
  FoodAnalysisError,
  analysisStatusSchema,
  labelConfirmationSchema,
  mealConfirmationSchema,
  nutrientFactsSchema,
  nutritionEstimateSchema,
  portionSchema,
  providerObservationSchema,
  rangeSchema,
  parseConfirmation,
};

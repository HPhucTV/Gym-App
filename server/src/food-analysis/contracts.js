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

const providerConfidenceSchema = z.number().finite().min(0).max(1);
const providerComponentSchema = z.object({
  id: z.string().trim().min(1).max(100),
  nameVi: z.string().trim().min(1).max(160),
  confidence: providerConfidenceSchema,
  isMajor: z.boolean(),
  suggestedPortion: portionSchema.nullable(),
}).strict();
const providerMissingFieldSchema = z.enum([
  'BASIS',
  'CALORIES',
  'PROTEIN_GRAMS',
  'CARBS_GRAMS',
  'FAT_GRAMS',
  'SERVING_SIZE_GRAMS',
  'SERVINGS_PER_CONTAINER',
  'NET_WEIGHT_GRAMS',
  'CONSUMED_AMOUNT',
]);
const providerNullableFactsSchema = z.object({
  calories: finiteNonNegative.max(1000).nullable(),
  proteinGrams: finiteNonNegative.max(100).nullable(),
  carbsGrams: finiteNonNegative.max(100).nullable(),
  fatGrams: finiteNonNegative.max(100).nullable(),
}).strict();
const providerLabelFactsSchema = z.object({
  nameVi: z.string().trim().min(1).max(160),
  basis: z.enum(['PER_100G', 'PER_SERVING', 'UNKNOWN']),
  facts: providerNullableFactsSchema,
  servingSizeGrams: z.number().finite().positive().max(5000).nullable(),
  servingsPerContainer: z.number().finite().positive().max(100).nullable(),
  netWeightGrams: z.number().finite().positive().max(5000).nullable(),
  confidence: providerConfidenceSchema,
  missingFields: z.array(providerMissingFieldSchema).max(9),
}).strict().superRefine((value, context) => {
  const requiredMissingFields = [
    [value.basis === 'UNKNOWN', 'BASIS', 'basis'],
    [value.facts.calories === null, 'CALORIES', 'facts.calories'],
    [value.facts.proteinGrams === null, 'PROTEIN_GRAMS', 'facts.proteinGrams'],
    [value.facts.carbsGrams === null, 'CARBS_GRAMS', 'facts.carbsGrams'],
    [value.facts.fatGrams === null, 'FAT_GRAMS', 'facts.fatGrams'],
    [value.netWeightGrams === null, 'CONSUMED_AMOUNT', 'netWeightGrams'],
  ];
  for (const [isMissing, code, path] of requiredMissingFields) {
    if (isMissing && !value.missingFields.includes(code)) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        path: path.split('.'),
        message: `${code} must be named in missingFields`,
      });
    }
  }
});
const providerObservationBase = {
  confidence: providerConfidenceSchema,
  uncertaintyReasons: z.array(uncertaintyReasonSchema).max(4),
};
const providerObservationSchema = z.discriminatedUnion('imageType', [
  z.object({
    imageType: z.literal('MEAL'),
    ...providerObservationBase,
    components: z.array(providerComponentSchema).min(1).max(20),
    labelFacts: z.null(),
  }).strict(),
  z.object({
    imageType: z.literal('NUTRITION_LABEL'),
    ...providerObservationBase,
    components: z.null(),
    labelFacts: providerLabelFactsSchema,
  }).strict(),
  z.object({
    imageType: z.literal('UNKNOWN'),
    ...providerObservationBase,
    components: z.null(),
    labelFacts: z.null(),
  }).strict(),
]);
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
  providerComponentSchema,
  providerLabelFactsSchema,
  providerObservationSchema,
  rangeSchema,
  parseConfirmation,
};

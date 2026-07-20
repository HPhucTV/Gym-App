const {
  FoodAnalysisError,
  providerObservationSchema,
} = require('./contracts');

const OUTPUT_INSTRUCTIONS = `Return a food image observation only as one JSON object.
You must not calculate or return final calories or macros. Printed nutrient facts read from a nutrition label are observations, not calculated totals.
Use exactly one imageType: MEAL, NUTRITION_LABEL, or UNKNOWN.
For MEAL return confidence, bounded uncertaintyReasons, components, and labelFacts null. Each component has id, nameVi, confidence, isMajor, and nullable suggestedPortion.
For NUTRITION_LABEL return confidence, bounded uncertaintyReasons, components null, and labelFacts with nameVi, basis, nullable printed facts, nullable servingSizeGrams, nullable servingsPerContainer, nullable netWeightGrams, confidence, and bounded missingFields.
For UNKNOWN return confidence, uncertaintyReasons, components null, and labelFacts null.
Allowed uncertaintyReasons: HIDDEN_OIL, SAUCE, OVERLAP, WEAK_DATABASE_MATCH.
Allowed missingFields: BASIS, CALORIES, PROTEIN_GRAMS, CARBS_GRAMS, FAT_GRAMS, SERVING_SIZE_GRAMS, SERVINGS_PER_CONTAINER, NET_WEIGHT_GRAMS, CONSUMED_AMOUNT.
Return plain JSON without commentary.`;

function unavailable() {
  return new FoodAnalysisError(
    'ANALYSIS_UNAVAILABLE',
    'Không thể phân tích ảnh lúc này.',
    503,
  );
}

function invalidProviderResponse() {
  return new FoodAnalysisError(
    'INVALID_PROVIDER_RESPONSE',
    'Phản hồi phân tích ảnh không hợp lệ.',
    502,
  );
}

class GeminiFoodObserver {
  constructor({ apiKey, model, fetchImpl = fetch, timeoutMs = 30_000 }) {
    this.apiKey = apiKey;
    this.model = model;
    this.fetchImpl = fetchImpl;
    this.timeoutMs = timeoutMs;
  }

  async observePrimary({ bytes, mimeType }) {
    return this.#observe({
      bytes,
      mimeType,
      prompt: OUTPUT_INSTRUCTIONS,
    });
  }

  async observeSecondary({ bytes, mimeType, previousObservation }) {
    const parsedPrevious = providerObservationSchema.safeParse(previousObservation);
    if (!parsedPrevious.success) throw invalidProviderResponse();
    return this.#observe({
      bytes,
      mimeType,
      prompt: `${OUTPUT_INSTRUCTIONS}
This is a secondary image of the same food. Reconcile it with this previous validated observation:
${JSON.stringify(parsedPrevious.data)}`,
    });
  }

  async #observe({ bytes, mimeType, prompt }) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), this.timeoutMs);
    try {
      const response = await this.fetchImpl(
        `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(this.model)}:generateContent?key=${encodeURIComponent(this.apiKey)}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          signal: controller.signal,
          body: JSON.stringify({
            contents: [{
              role: 'user',
              parts: [
                { text: prompt },
                {
                  inlineData: {
                    mimeType,
                    data: Buffer.from(bytes).toString('base64'),
                  },
                },
              ],
            }],
            generationConfig: {
              responseMimeType: 'application/json',
              temperature: 0,
            },
          }),
        },
      );
      if (!response?.ok) throw unavailable();

      let payload;
      try {
        payload = await response.json();
      } catch {
        throw invalidProviderResponse();
      }
      const text = payload?.candidates?.[0]?.content?.parts
        ?.map((part) => part.text)
        .filter((part) => typeof part === 'string')
        .join('');
      if (!text) throw invalidProviderResponse();

      let decoded;
      try {
        decoded = JSON.parse(this.#unwrapJson(text));
      } catch {
        throw invalidProviderResponse();
      }
      const parsed = providerObservationSchema.safeParse(decoded);
      if (!parsed.success) throw invalidProviderResponse();
      return parsed.data;
    } catch (error) {
      if (error instanceof FoodAnalysisError) throw error;
      throw unavailable();
    } finally {
      clearTimeout(timeout);
    }
  }

  #unwrapJson(text) {
    const trimmed = text.trim();
    const fenced = trimmed.match(/^```(?:json)?\s*([\s\S]*?)\s*```$/i);
    return fenced ? fenced[1] : trimmed;
  }
}

module.exports = { GeminiFoodObserver };

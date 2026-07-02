# Gym Companion

This context describes the user's fitness intent, personal wellness inputs, and the controlled changes the companion may recommend or apply.

## Language

**Fitness Goal**:
The outcome that selects the authoritative workout program, such as muscle gain, fat-loss conditioning, endurance, or general fitness.
_Avoid_: Objective, workout type

**Personal Profile**:
The consented wellness inputs used to calculate nutrition targets and evaluate personalization rules.
_Avoid_: Account, medical record

**Metabolic Sex**:
The formula input selected for estimating basal energy needs; it is not a gender identity or medical diagnosis.
_Avoid_: Gender

**Nutrition Target**:
The estimated daily calories and macronutrients associated with a personal profile and fitness goal.
_Avoid_: Diet prescription, meal plan

**Adaptation Decision**:
A recorded proposal to change a future nutrition or training target without altering completed history.
_Avoid_: AI command, generated workout

**Automatic Adaptation**:
A small, reversible adaptation decision that stays within the approved safety cap and may be applied without another confirmation.
_Avoid_: Silent plan rewrite

**Confirmation-required Adaptation**:
A material adaptation decision that remains proposed until the user explicitly accepts or rejects it.
_Avoid_: Forced change

**Cloud AI Explanation**:
An optional, consent-gated Vietnamese explanation of a local adaptation decision; it is never the source of that decision.
_Avoid_: AI coach decision, AI-generated plan

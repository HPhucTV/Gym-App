package com.example.myapplication.core.adaptation

enum class AdaptationMode {
    AUTO_APPLY,
    REQUIRES_CONFIRMATION,
}

enum class AdaptationStatus {
    PROPOSED,
    APPLIED,
    REJECTED,
    UNDONE,
}

enum class AdaptationKind {
    CALORIE_TARGET,
    MACRO_TARGET,
    RECOVERY_DAY,
    WORKOUT_VOLUME,
    PROGRAM_CHANGE,
    DELOAD_WEEK,
}

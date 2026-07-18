// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingDraft {
  FitnessGoal? get goal;
  List<FitnessGoal> get goals;
  Gender? get gender;
  BodyType? get bodyType;
  ExperienceLevel? get level;
  EquipmentProfile? get equipment;
  int? get sessionsPerWeek;
  int? get durationWeeks;
  RestDayMode? get restDayMode;
  Set<WeekDay> get trainingDays;
  int? get sessionDurationMinutes;

  /// Create a copy of OnboardingDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OnboardingDraftCopyWith<OnboardingDraft> get copyWith =>
      _$OnboardingDraftCopyWithImpl<OnboardingDraft>(
          this as OnboardingDraft, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnboardingDraft &&
            (identical(other.goal, goal) || other.goal == goal) &&
            const DeepCollectionEquality().equals(other.goals, goals) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.bodyType, bodyType) ||
                other.bodyType == bodyType) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.equipment, equipment) ||
                other.equipment == equipment) &&
            (identical(other.sessionsPerWeek, sessionsPerWeek) ||
                other.sessionsPerWeek == sessionsPerWeek) &&
            (identical(other.durationWeeks, durationWeeks) ||
                other.durationWeeks == durationWeeks) &&
            (identical(other.restDayMode, restDayMode) ||
                other.restDayMode == restDayMode) &&
            const DeepCollectionEquality()
                .equals(other.trainingDays, trainingDays) &&
            (identical(other.sessionDurationMinutes, sessionDurationMinutes) ||
                other.sessionDurationMinutes == sessionDurationMinutes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      goal,
      const DeepCollectionEquality().hash(goals),
      gender,
      bodyType,
      level,
      equipment,
      sessionsPerWeek,
      durationWeeks,
      restDayMode,
      const DeepCollectionEquality().hash(trainingDays),
      sessionDurationMinutes);

  @override
  String toString() {
    return 'OnboardingDraft(goal: $goal, goals: $goals, gender: $gender, bodyType: $bodyType, level: $level, equipment: $equipment, sessionsPerWeek: $sessionsPerWeek, durationWeeks: $durationWeeks, restDayMode: $restDayMode, trainingDays: $trainingDays, sessionDurationMinutes: $sessionDurationMinutes)';
  }
}

/// @nodoc
abstract mixin class $OnboardingDraftCopyWith<$Res> {
  factory $OnboardingDraftCopyWith(
          OnboardingDraft value, $Res Function(OnboardingDraft) _then) =
      _$OnboardingDraftCopyWithImpl;
  @useResult
  $Res call(
      {FitnessGoal? goal,
      List<FitnessGoal> goals,
      Gender? gender,
      BodyType? bodyType,
      ExperienceLevel? level,
      EquipmentProfile? equipment,
      int? sessionsPerWeek,
      int? durationWeeks,
      RestDayMode? restDayMode,
      Set<WeekDay> trainingDays,
      int? sessionDurationMinutes});
}

/// @nodoc
class _$OnboardingDraftCopyWithImpl<$Res>
    implements $OnboardingDraftCopyWith<$Res> {
  _$OnboardingDraftCopyWithImpl(this._self, this._then);

  final OnboardingDraft _self;
  final $Res Function(OnboardingDraft) _then;

  /// Create a copy of OnboardingDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goal = freezed,
    Object? goals = null,
    Object? gender = freezed,
    Object? bodyType = freezed,
    Object? level = freezed,
    Object? equipment = freezed,
    Object? sessionsPerWeek = freezed,
    Object? durationWeeks = freezed,
    Object? restDayMode = freezed,
    Object? trainingDays = null,
    Object? sessionDurationMinutes = freezed,
  }) {
    return _then(_self.copyWith(
      goal: freezed == goal
          ? _self.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as FitnessGoal?,
      goals: null == goals
          ? _self.goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<FitnessGoal>,
      gender: freezed == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender?,
      bodyType: freezed == bodyType
          ? _self.bodyType
          : bodyType // ignore: cast_nullable_to_non_nullable
              as BodyType?,
      level: freezed == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as ExperienceLevel?,
      equipment: freezed == equipment
          ? _self.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as EquipmentProfile?,
      sessionsPerWeek: freezed == sessionsPerWeek
          ? _self.sessionsPerWeek
          : sessionsPerWeek // ignore: cast_nullable_to_non_nullable
              as int?,
      durationWeeks: freezed == durationWeeks
          ? _self.durationWeeks
          : durationWeeks // ignore: cast_nullable_to_non_nullable
              as int?,
      restDayMode: freezed == restDayMode
          ? _self.restDayMode
          : restDayMode // ignore: cast_nullable_to_non_nullable
              as RestDayMode?,
      trainingDays: null == trainingDays
          ? _self.trainingDays
          : trainingDays // ignore: cast_nullable_to_non_nullable
              as Set<WeekDay>,
      sessionDurationMinutes: freezed == sessionDurationMinutes
          ? _self.sessionDurationMinutes
          : sessionDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [OnboardingDraft].
extension OnboardingDraftPatterns on OnboardingDraft {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OnboardingDraft value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OnboardingDraft() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OnboardingDraft value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingDraft():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OnboardingDraft value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingDraft() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            FitnessGoal? goal,
            List<FitnessGoal> goals,
            Gender? gender,
            BodyType? bodyType,
            ExperienceLevel? level,
            EquipmentProfile? equipment,
            int? sessionsPerWeek,
            int? durationWeeks,
            RestDayMode? restDayMode,
            Set<WeekDay> trainingDays,
            int? sessionDurationMinutes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OnboardingDraft() when $default != null:
        return $default(
            _that.goal,
            _that.goals,
            _that.gender,
            _that.bodyType,
            _that.level,
            _that.equipment,
            _that.sessionsPerWeek,
            _that.durationWeeks,
            _that.restDayMode,
            _that.trainingDays,
            _that.sessionDurationMinutes);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            FitnessGoal? goal,
            List<FitnessGoal> goals,
            Gender? gender,
            BodyType? bodyType,
            ExperienceLevel? level,
            EquipmentProfile? equipment,
            int? sessionsPerWeek,
            int? durationWeeks,
            RestDayMode? restDayMode,
            Set<WeekDay> trainingDays,
            int? sessionDurationMinutes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingDraft():
        return $default(
            _that.goal,
            _that.goals,
            _that.gender,
            _that.bodyType,
            _that.level,
            _that.equipment,
            _that.sessionsPerWeek,
            _that.durationWeeks,
            _that.restDayMode,
            _that.trainingDays,
            _that.sessionDurationMinutes);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            FitnessGoal? goal,
            List<FitnessGoal> goals,
            Gender? gender,
            BodyType? bodyType,
            ExperienceLevel? level,
            EquipmentProfile? equipment,
            int? sessionsPerWeek,
            int? durationWeeks,
            RestDayMode? restDayMode,
            Set<WeekDay> trainingDays,
            int? sessionDurationMinutes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingDraft() when $default != null:
        return $default(
            _that.goal,
            _that.goals,
            _that.gender,
            _that.bodyType,
            _that.level,
            _that.equipment,
            _that.sessionsPerWeek,
            _that.durationWeeks,
            _that.restDayMode,
            _that.trainingDays,
            _that.sessionDurationMinutes);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OnboardingDraft implements OnboardingDraft {
  const _OnboardingDraft(
      {this.goal,
      final List<FitnessGoal> goals = const [],
      this.gender,
      this.bodyType,
      this.level,
      this.equipment,
      this.sessionsPerWeek,
      this.durationWeeks,
      this.restDayMode,
      final Set<WeekDay> trainingDays = const {},
      this.sessionDurationMinutes})
      : _goals = goals,
        _trainingDays = trainingDays;

  @override
  final FitnessGoal? goal;
  final List<FitnessGoal> _goals;
  @override
  @JsonKey()
  List<FitnessGoal> get goals {
    if (_goals is EqualUnmodifiableListView) return _goals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_goals);
  }

  @override
  final Gender? gender;
  @override
  final BodyType? bodyType;
  @override
  final ExperienceLevel? level;
  @override
  final EquipmentProfile? equipment;
  @override
  final int? sessionsPerWeek;
  @override
  final int? durationWeeks;
  @override
  final RestDayMode? restDayMode;
  final Set<WeekDay> _trainingDays;
  @override
  @JsonKey()
  Set<WeekDay> get trainingDays {
    if (_trainingDays is EqualUnmodifiableSetView) return _trainingDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_trainingDays);
  }

  @override
  final int? sessionDurationMinutes;

  /// Create a copy of OnboardingDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OnboardingDraftCopyWith<_OnboardingDraft> get copyWith =>
      __$OnboardingDraftCopyWithImpl<_OnboardingDraft>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OnboardingDraft &&
            (identical(other.goal, goal) || other.goal == goal) &&
            const DeepCollectionEquality().equals(other._goals, _goals) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.bodyType, bodyType) ||
                other.bodyType == bodyType) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.equipment, equipment) ||
                other.equipment == equipment) &&
            (identical(other.sessionsPerWeek, sessionsPerWeek) ||
                other.sessionsPerWeek == sessionsPerWeek) &&
            (identical(other.durationWeeks, durationWeeks) ||
                other.durationWeeks == durationWeeks) &&
            (identical(other.restDayMode, restDayMode) ||
                other.restDayMode == restDayMode) &&
            const DeepCollectionEquality()
                .equals(other._trainingDays, _trainingDays) &&
            (identical(other.sessionDurationMinutes, sessionDurationMinutes) ||
                other.sessionDurationMinutes == sessionDurationMinutes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      goal,
      const DeepCollectionEquality().hash(_goals),
      gender,
      bodyType,
      level,
      equipment,
      sessionsPerWeek,
      durationWeeks,
      restDayMode,
      const DeepCollectionEquality().hash(_trainingDays),
      sessionDurationMinutes);

  @override
  String toString() {
    return 'OnboardingDraft(goal: $goal, goals: $goals, gender: $gender, bodyType: $bodyType, level: $level, equipment: $equipment, sessionsPerWeek: $sessionsPerWeek, durationWeeks: $durationWeeks, restDayMode: $restDayMode, trainingDays: $trainingDays, sessionDurationMinutes: $sessionDurationMinutes)';
  }
}

/// @nodoc
abstract mixin class _$OnboardingDraftCopyWith<$Res>
    implements $OnboardingDraftCopyWith<$Res> {
  factory _$OnboardingDraftCopyWith(
          _OnboardingDraft value, $Res Function(_OnboardingDraft) _then) =
      __$OnboardingDraftCopyWithImpl;
  @override
  @useResult
  $Res call(
      {FitnessGoal? goal,
      List<FitnessGoal> goals,
      Gender? gender,
      BodyType? bodyType,
      ExperienceLevel? level,
      EquipmentProfile? equipment,
      int? sessionsPerWeek,
      int? durationWeeks,
      RestDayMode? restDayMode,
      Set<WeekDay> trainingDays,
      int? sessionDurationMinutes});
}

/// @nodoc
class __$OnboardingDraftCopyWithImpl<$Res>
    implements _$OnboardingDraftCopyWith<$Res> {
  __$OnboardingDraftCopyWithImpl(this._self, this._then);

  final _OnboardingDraft _self;
  final $Res Function(_OnboardingDraft) _then;

  /// Create a copy of OnboardingDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? goal = freezed,
    Object? goals = null,
    Object? gender = freezed,
    Object? bodyType = freezed,
    Object? level = freezed,
    Object? equipment = freezed,
    Object? sessionsPerWeek = freezed,
    Object? durationWeeks = freezed,
    Object? restDayMode = freezed,
    Object? trainingDays = null,
    Object? sessionDurationMinutes = freezed,
  }) {
    return _then(_OnboardingDraft(
      goal: freezed == goal
          ? _self.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as FitnessGoal?,
      goals: null == goals
          ? _self._goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<FitnessGoal>,
      gender: freezed == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender?,
      bodyType: freezed == bodyType
          ? _self.bodyType
          : bodyType // ignore: cast_nullable_to_non_nullable
              as BodyType?,
      level: freezed == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as ExperienceLevel?,
      equipment: freezed == equipment
          ? _self.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as EquipmentProfile?,
      sessionsPerWeek: freezed == sessionsPerWeek
          ? _self.sessionsPerWeek
          : sessionsPerWeek // ignore: cast_nullable_to_non_nullable
              as int?,
      durationWeeks: freezed == durationWeeks
          ? _self.durationWeeks
          : durationWeeks // ignore: cast_nullable_to_non_nullable
              as int?,
      restDayMode: freezed == restDayMode
          ? _self.restDayMode
          : restDayMode // ignore: cast_nullable_to_non_nullable
              as RestDayMode?,
      trainingDays: null == trainingDays
          ? _self._trainingDays
          : trainingDays // ignore: cast_nullable_to_non_nullable
              as Set<WeekDay>,
      sessionDurationMinutes: freezed == sessionDurationMinutes
          ? _self.sessionDurationMinutes
          : sessionDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
mixin _$OnboardingOptions {
  Set<FitnessGoal> get goals;
  Set<ExperienceLevel> get levels;
  Set<EquipmentProfile> get equipment;
  Set<WorkoutCommitment> get commitments;
  Set<RestDayMode> get restDayModes;

  /// Create a copy of OnboardingOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OnboardingOptionsCopyWith<OnboardingOptions> get copyWith =>
      _$OnboardingOptionsCopyWithImpl<OnboardingOptions>(
          this as OnboardingOptions, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnboardingOptions &&
            const DeepCollectionEquality().equals(other.goals, goals) &&
            const DeepCollectionEquality().equals(other.levels, levels) &&
            const DeepCollectionEquality().equals(other.equipment, equipment) &&
            const DeepCollectionEquality()
                .equals(other.commitments, commitments) &&
            const DeepCollectionEquality()
                .equals(other.restDayModes, restDayModes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(goals),
      const DeepCollectionEquality().hash(levels),
      const DeepCollectionEquality().hash(equipment),
      const DeepCollectionEquality().hash(commitments),
      const DeepCollectionEquality().hash(restDayModes));

  @override
  String toString() {
    return 'OnboardingOptions(goals: $goals, levels: $levels, equipment: $equipment, commitments: $commitments, restDayModes: $restDayModes)';
  }
}

/// @nodoc
abstract mixin class $OnboardingOptionsCopyWith<$Res> {
  factory $OnboardingOptionsCopyWith(
          OnboardingOptions value, $Res Function(OnboardingOptions) _then) =
      _$OnboardingOptionsCopyWithImpl;
  @useResult
  $Res call(
      {Set<FitnessGoal> goals,
      Set<ExperienceLevel> levels,
      Set<EquipmentProfile> equipment,
      Set<WorkoutCommitment> commitments,
      Set<RestDayMode> restDayModes});
}

/// @nodoc
class _$OnboardingOptionsCopyWithImpl<$Res>
    implements $OnboardingOptionsCopyWith<$Res> {
  _$OnboardingOptionsCopyWithImpl(this._self, this._then);

  final OnboardingOptions _self;
  final $Res Function(OnboardingOptions) _then;

  /// Create a copy of OnboardingOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goals = null,
    Object? levels = null,
    Object? equipment = null,
    Object? commitments = null,
    Object? restDayModes = null,
  }) {
    return _then(_self.copyWith(
      goals: null == goals
          ? _self.goals
          : goals // ignore: cast_nullable_to_non_nullable
              as Set<FitnessGoal>,
      levels: null == levels
          ? _self.levels
          : levels // ignore: cast_nullable_to_non_nullable
              as Set<ExperienceLevel>,
      equipment: null == equipment
          ? _self.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as Set<EquipmentProfile>,
      commitments: null == commitments
          ? _self.commitments
          : commitments // ignore: cast_nullable_to_non_nullable
              as Set<WorkoutCommitment>,
      restDayModes: null == restDayModes
          ? _self.restDayModes
          : restDayModes // ignore: cast_nullable_to_non_nullable
              as Set<RestDayMode>,
    ));
  }
}

/// Adds pattern-matching-related methods to [OnboardingOptions].
extension OnboardingOptionsPatterns on OnboardingOptions {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OnboardingOptions value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OnboardingOptions() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OnboardingOptions value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingOptions():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OnboardingOptions value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingOptions() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            Set<FitnessGoal> goals,
            Set<ExperienceLevel> levels,
            Set<EquipmentProfile> equipment,
            Set<WorkoutCommitment> commitments,
            Set<RestDayMode> restDayModes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OnboardingOptions() when $default != null:
        return $default(_that.goals, _that.levels, _that.equipment,
            _that.commitments, _that.restDayModes);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            Set<FitnessGoal> goals,
            Set<ExperienceLevel> levels,
            Set<EquipmentProfile> equipment,
            Set<WorkoutCommitment> commitments,
            Set<RestDayMode> restDayModes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingOptions():
        return $default(_that.goals, _that.levels, _that.equipment,
            _that.commitments, _that.restDayModes);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            Set<FitnessGoal> goals,
            Set<ExperienceLevel> levels,
            Set<EquipmentProfile> equipment,
            Set<WorkoutCommitment> commitments,
            Set<RestDayMode> restDayModes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingOptions() when $default != null:
        return $default(_that.goals, _that.levels, _that.equipment,
            _that.commitments, _that.restDayModes);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OnboardingOptions implements OnboardingOptions {
  const _OnboardingOptions(
      {required final Set<FitnessGoal> goals,
      required final Set<ExperienceLevel> levels,
      required final Set<EquipmentProfile> equipment,
      required final Set<WorkoutCommitment> commitments,
      required final Set<RestDayMode> restDayModes})
      : _goals = goals,
        _levels = levels,
        _equipment = equipment,
        _commitments = commitments,
        _restDayModes = restDayModes;

  final Set<FitnessGoal> _goals;
  @override
  Set<FitnessGoal> get goals {
    if (_goals is EqualUnmodifiableSetView) return _goals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_goals);
  }

  final Set<ExperienceLevel> _levels;
  @override
  Set<ExperienceLevel> get levels {
    if (_levels is EqualUnmodifiableSetView) return _levels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_levels);
  }

  final Set<EquipmentProfile> _equipment;
  @override
  Set<EquipmentProfile> get equipment {
    if (_equipment is EqualUnmodifiableSetView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_equipment);
  }

  final Set<WorkoutCommitment> _commitments;
  @override
  Set<WorkoutCommitment> get commitments {
    if (_commitments is EqualUnmodifiableSetView) return _commitments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_commitments);
  }

  final Set<RestDayMode> _restDayModes;
  @override
  Set<RestDayMode> get restDayModes {
    if (_restDayModes is EqualUnmodifiableSetView) return _restDayModes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_restDayModes);
  }

  /// Create a copy of OnboardingOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OnboardingOptionsCopyWith<_OnboardingOptions> get copyWith =>
      __$OnboardingOptionsCopyWithImpl<_OnboardingOptions>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OnboardingOptions &&
            const DeepCollectionEquality().equals(other._goals, _goals) &&
            const DeepCollectionEquality().equals(other._levels, _levels) &&
            const DeepCollectionEquality()
                .equals(other._equipment, _equipment) &&
            const DeepCollectionEquality()
                .equals(other._commitments, _commitments) &&
            const DeepCollectionEquality()
                .equals(other._restDayModes, _restDayModes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_goals),
      const DeepCollectionEquality().hash(_levels),
      const DeepCollectionEquality().hash(_equipment),
      const DeepCollectionEquality().hash(_commitments),
      const DeepCollectionEquality().hash(_restDayModes));

  @override
  String toString() {
    return 'OnboardingOptions(goals: $goals, levels: $levels, equipment: $equipment, commitments: $commitments, restDayModes: $restDayModes)';
  }
}

/// @nodoc
abstract mixin class _$OnboardingOptionsCopyWith<$Res>
    implements $OnboardingOptionsCopyWith<$Res> {
  factory _$OnboardingOptionsCopyWith(
          _OnboardingOptions value, $Res Function(_OnboardingOptions) _then) =
      __$OnboardingOptionsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Set<FitnessGoal> goals,
      Set<ExperienceLevel> levels,
      Set<EquipmentProfile> equipment,
      Set<WorkoutCommitment> commitments,
      Set<RestDayMode> restDayModes});
}

/// @nodoc
class __$OnboardingOptionsCopyWithImpl<$Res>
    implements _$OnboardingOptionsCopyWith<$Res> {
  __$OnboardingOptionsCopyWithImpl(this._self, this._then);

  final _OnboardingOptions _self;
  final $Res Function(_OnboardingOptions) _then;

  /// Create a copy of OnboardingOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? goals = null,
    Object? levels = null,
    Object? equipment = null,
    Object? commitments = null,
    Object? restDayModes = null,
  }) {
    return _then(_OnboardingOptions(
      goals: null == goals
          ? _self._goals
          : goals // ignore: cast_nullable_to_non_nullable
              as Set<FitnessGoal>,
      levels: null == levels
          ? _self._levels
          : levels // ignore: cast_nullable_to_non_nullable
              as Set<ExperienceLevel>,
      equipment: null == equipment
          ? _self._equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as Set<EquipmentProfile>,
      commitments: null == commitments
          ? _self._commitments
          : commitments // ignore: cast_nullable_to_non_nullable
              as Set<WorkoutCommitment>,
      restDayModes: null == restDayModes
          ? _self._restDayModes
          : restDayModes // ignore: cast_nullable_to_non_nullable
              as Set<RestDayMode>,
    ));
  }
}

/// @nodoc
mixin _$OnboardingUiState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is OnboardingUiState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'OnboardingUiState()';
  }
}

/// @nodoc
class $OnboardingUiStateCopyWith<$Res> {
  $OnboardingUiStateCopyWith(
      OnboardingUiState _, $Res Function(OnboardingUiState) __);
}

/// Adds pattern-matching-related methods to [OnboardingUiState].
extension OnboardingUiStatePatterns on OnboardingUiState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Editing value)? editing,
    TResult Function(_Unsupported value)? unsupported,
    TResult Function(_Created value)? created,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Editing() when editing != null:
        return editing(_that);
      case _Unsupported() when unsupported != null:
        return unsupported(_that);
      case _Created() when created != null:
        return created(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Editing value) editing,
    required TResult Function(_Unsupported value) unsupported,
    required TResult Function(_Created value) created,
  }) {
    final _that = this;
    switch (_that) {
      case _Editing():
        return editing(_that);
      case _Unsupported():
        return unsupported(_that);
      case _Created():
        return created(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Editing value)? editing,
    TResult? Function(_Unsupported value)? unsupported,
    TResult? Function(_Created value)? created,
  }) {
    final _that = this;
    switch (_that) {
      case _Editing() when editing != null:
        return editing(_that);
      case _Unsupported() when unsupported != null:
        return unsupported(_that);
      case _Created() when created != null:
        return created(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(OnboardingStep step, OnboardingDraft draft,
            OnboardingOptions options, bool isSaving, String? saveError)?
        editing,
    TResult Function(OnboardingDraft draft, String explanation,
            List<String> alternatives)?
        unsupported,
    TResult Function()? created,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Editing() when editing != null:
        return editing(_that.step, _that.draft, _that.options, _that.isSaving,
            _that.saveError);
      case _Unsupported() when unsupported != null:
        return unsupported(_that.draft, _that.explanation, _that.alternatives);
      case _Created() when created != null:
        return created();
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(OnboardingStep step, OnboardingDraft draft,
            OnboardingOptions options, bool isSaving, String? saveError)
        editing,
    required TResult Function(OnboardingDraft draft, String explanation,
            List<String> alternatives)
        unsupported,
    required TResult Function() created,
  }) {
    final _that = this;
    switch (_that) {
      case _Editing():
        return editing(_that.step, _that.draft, _that.options, _that.isSaving,
            _that.saveError);
      case _Unsupported():
        return unsupported(_that.draft, _that.explanation, _that.alternatives);
      case _Created():
        return created();
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(OnboardingStep step, OnboardingDraft draft,
            OnboardingOptions options, bool isSaving, String? saveError)?
        editing,
    TResult? Function(OnboardingDraft draft, String explanation,
            List<String> alternatives)?
        unsupported,
    TResult? Function()? created,
  }) {
    final _that = this;
    switch (_that) {
      case _Editing() when editing != null:
        return editing(_that.step, _that.draft, _that.options, _that.isSaving,
            _that.saveError);
      case _Unsupported() when unsupported != null:
        return unsupported(_that.draft, _that.explanation, _that.alternatives);
      case _Created() when created != null:
        return created();
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Editing implements OnboardingUiState {
  const _Editing(
      {required this.step,
      required this.draft,
      required this.options,
      this.isSaving = false,
      this.saveError});

  final OnboardingStep step;
  final OnboardingDraft draft;
  final OnboardingOptions options;
  @JsonKey()
  final bool isSaving;
  final String? saveError;

  /// Create a copy of OnboardingUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EditingCopyWith<_Editing> get copyWith =>
      __$EditingCopyWithImpl<_Editing>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Editing &&
            (identical(other.step, step) || other.step == step) &&
            (identical(other.draft, draft) || other.draft == draft) &&
            (identical(other.options, options) || other.options == options) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.saveError, saveError) ||
                other.saveError == saveError));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, step, draft, options, isSaving, saveError);

  @override
  String toString() {
    return 'OnboardingUiState.editing(step: $step, draft: $draft, options: $options, isSaving: $isSaving, saveError: $saveError)';
  }
}

/// @nodoc
abstract mixin class _$EditingCopyWith<$Res>
    implements $OnboardingUiStateCopyWith<$Res> {
  factory _$EditingCopyWith(_Editing value, $Res Function(_Editing) _then) =
      __$EditingCopyWithImpl;
  @useResult
  $Res call(
      {OnboardingStep step,
      OnboardingDraft draft,
      OnboardingOptions options,
      bool isSaving,
      String? saveError});

  $OnboardingDraftCopyWith<$Res> get draft;
  $OnboardingOptionsCopyWith<$Res> get options;
}

/// @nodoc
class __$EditingCopyWithImpl<$Res> implements _$EditingCopyWith<$Res> {
  __$EditingCopyWithImpl(this._self, this._then);

  final _Editing _self;
  final $Res Function(_Editing) _then;

  /// Create a copy of OnboardingUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? step = null,
    Object? draft = null,
    Object? options = null,
    Object? isSaving = null,
    Object? saveError = freezed,
  }) {
    return _then(_Editing(
      step: null == step
          ? _self.step
          : step // ignore: cast_nullable_to_non_nullable
              as OnboardingStep,
      draft: null == draft
          ? _self.draft
          : draft // ignore: cast_nullable_to_non_nullable
              as OnboardingDraft,
      options: null == options
          ? _self.options
          : options // ignore: cast_nullable_to_non_nullable
              as OnboardingOptions,
      isSaving: null == isSaving
          ? _self.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      saveError: freezed == saveError
          ? _self.saveError
          : saveError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of OnboardingUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OnboardingDraftCopyWith<$Res> get draft {
    return $OnboardingDraftCopyWith<$Res>(_self.draft, (value) {
      return _then(_self.copyWith(draft: value));
    });
  }

  /// Create a copy of OnboardingUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OnboardingOptionsCopyWith<$Res> get options {
    return $OnboardingOptionsCopyWith<$Res>(_self.options, (value) {
      return _then(_self.copyWith(options: value));
    });
  }
}

/// @nodoc

class _Unsupported implements OnboardingUiState {
  const _Unsupported(
      {required this.draft,
      required this.explanation,
      required final List<String> alternatives})
      : _alternatives = alternatives;

  final OnboardingDraft draft;
  final String explanation;
  final List<String> _alternatives;
  List<String> get alternatives {
    if (_alternatives is EqualUnmodifiableListView) return _alternatives;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alternatives);
  }

  /// Create a copy of OnboardingUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UnsupportedCopyWith<_Unsupported> get copyWith =>
      __$UnsupportedCopyWithImpl<_Unsupported>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Unsupported &&
            (identical(other.draft, draft) || other.draft == draft) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            const DeepCollectionEquality()
                .equals(other._alternatives, _alternatives));
  }

  @override
  int get hashCode => Object.hash(runtimeType, draft, explanation,
      const DeepCollectionEquality().hash(_alternatives));

  @override
  String toString() {
    return 'OnboardingUiState.unsupported(draft: $draft, explanation: $explanation, alternatives: $alternatives)';
  }
}

/// @nodoc
abstract mixin class _$UnsupportedCopyWith<$Res>
    implements $OnboardingUiStateCopyWith<$Res> {
  factory _$UnsupportedCopyWith(
          _Unsupported value, $Res Function(_Unsupported) _then) =
      __$UnsupportedCopyWithImpl;
  @useResult
  $Res call(
      {OnboardingDraft draft, String explanation, List<String> alternatives});

  $OnboardingDraftCopyWith<$Res> get draft;
}

/// @nodoc
class __$UnsupportedCopyWithImpl<$Res> implements _$UnsupportedCopyWith<$Res> {
  __$UnsupportedCopyWithImpl(this._self, this._then);

  final _Unsupported _self;
  final $Res Function(_Unsupported) _then;

  /// Create a copy of OnboardingUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? draft = null,
    Object? explanation = null,
    Object? alternatives = null,
  }) {
    return _then(_Unsupported(
      draft: null == draft
          ? _self.draft
          : draft // ignore: cast_nullable_to_non_nullable
              as OnboardingDraft,
      explanation: null == explanation
          ? _self.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      alternatives: null == alternatives
          ? _self._alternatives
          : alternatives // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }

  /// Create a copy of OnboardingUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OnboardingDraftCopyWith<$Res> get draft {
    return $OnboardingDraftCopyWith<$Res>(_self.draft, (value) {
      return _then(_self.copyWith(draft: value));
    });
  }
}

/// @nodoc

class _Created implements OnboardingUiState {
  const _Created();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Created);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'OnboardingUiState.created()';
  }
}

// dart format on

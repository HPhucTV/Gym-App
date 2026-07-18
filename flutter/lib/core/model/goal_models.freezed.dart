// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoalConfig {
  FitnessGoal get goal;
  ExperienceLevel get level;
  EquipmentProfile get equipmentProfile;
  int get sessionsPerWeek;
  int get durationWeeks;
  RestDayMode get restDayMode;
  Set<WeekDay> get trainingDays;
  int get sessionDurationMinutes;
  List<FitnessGoal> get goals;
  Gender get gender;
  BodyType get bodyType;

  /// Create a copy of GoalConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GoalConfigCopyWith<GoalConfig> get copyWith =>
      _$GoalConfigCopyWithImpl<GoalConfig>(this as GoalConfig, _$identity);

  /// Serializes this GoalConfig to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GoalConfig &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.equipmentProfile, equipmentProfile) ||
                other.equipmentProfile == equipmentProfile) &&
            (identical(other.sessionsPerWeek, sessionsPerWeek) ||
                other.sessionsPerWeek == sessionsPerWeek) &&
            (identical(other.durationWeeks, durationWeeks) ||
                other.durationWeeks == durationWeeks) &&
            (identical(other.restDayMode, restDayMode) ||
                other.restDayMode == restDayMode) &&
            const DeepCollectionEquality()
                .equals(other.trainingDays, trainingDays) &&
            (identical(other.sessionDurationMinutes, sessionDurationMinutes) ||
                other.sessionDurationMinutes == sessionDurationMinutes) &&
            const DeepCollectionEquality().equals(other.goals, goals) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.bodyType, bodyType) ||
                other.bodyType == bodyType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      goal,
      level,
      equipmentProfile,
      sessionsPerWeek,
      durationWeeks,
      restDayMode,
      const DeepCollectionEquality().hash(trainingDays),
      sessionDurationMinutes,
      const DeepCollectionEquality().hash(goals),
      gender,
      bodyType);

  @override
  String toString() {
    return 'GoalConfig(goal: $goal, level: $level, equipmentProfile: $equipmentProfile, sessionsPerWeek: $sessionsPerWeek, durationWeeks: $durationWeeks, restDayMode: $restDayMode, trainingDays: $trainingDays, sessionDurationMinutes: $sessionDurationMinutes, goals: $goals, gender: $gender, bodyType: $bodyType)';
  }
}

/// @nodoc
abstract mixin class $GoalConfigCopyWith<$Res> {
  factory $GoalConfigCopyWith(
          GoalConfig value, $Res Function(GoalConfig) _then) =
      _$GoalConfigCopyWithImpl;
  @useResult
  $Res call(
      {FitnessGoal goal,
      ExperienceLevel level,
      EquipmentProfile equipmentProfile,
      int sessionsPerWeek,
      int durationWeeks,
      RestDayMode restDayMode,
      Set<WeekDay> trainingDays,
      int sessionDurationMinutes,
      List<FitnessGoal> goals,
      Gender gender,
      BodyType bodyType});
}

/// @nodoc
class _$GoalConfigCopyWithImpl<$Res> implements $GoalConfigCopyWith<$Res> {
  _$GoalConfigCopyWithImpl(this._self, this._then);

  final GoalConfig _self;
  final $Res Function(GoalConfig) _then;

  /// Create a copy of GoalConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goal = null,
    Object? level = null,
    Object? equipmentProfile = null,
    Object? sessionsPerWeek = null,
    Object? durationWeeks = null,
    Object? restDayMode = null,
    Object? trainingDays = null,
    Object? sessionDurationMinutes = null,
    Object? goals = null,
    Object? gender = null,
    Object? bodyType = null,
  }) {
    return _then(_self.copyWith(
      goal: null == goal
          ? _self.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as FitnessGoal,
      level: null == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as ExperienceLevel,
      equipmentProfile: null == equipmentProfile
          ? _self.equipmentProfile
          : equipmentProfile // ignore: cast_nullable_to_non_nullable
              as EquipmentProfile,
      sessionsPerWeek: null == sessionsPerWeek
          ? _self.sessionsPerWeek
          : sessionsPerWeek // ignore: cast_nullable_to_non_nullable
              as int,
      durationWeeks: null == durationWeeks
          ? _self.durationWeeks
          : durationWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      restDayMode: null == restDayMode
          ? _self.restDayMode
          : restDayMode // ignore: cast_nullable_to_non_nullable
              as RestDayMode,
      trainingDays: null == trainingDays
          ? _self.trainingDays
          : trainingDays // ignore: cast_nullable_to_non_nullable
              as Set<WeekDay>,
      sessionDurationMinutes: null == sessionDurationMinutes
          ? _self.sessionDurationMinutes
          : sessionDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      goals: null == goals
          ? _self.goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<FitnessGoal>,
      gender: null == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      bodyType: null == bodyType
          ? _self.bodyType
          : bodyType // ignore: cast_nullable_to_non_nullable
              as BodyType,
    ));
  }
}

/// Adds pattern-matching-related methods to [GoalConfig].
extension GoalConfigPatterns on GoalConfig {
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
    TResult Function(_GoalConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GoalConfig() when $default != null:
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
    TResult Function(_GoalConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GoalConfig():
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
    TResult? Function(_GoalConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GoalConfig() when $default != null:
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
            FitnessGoal goal,
            ExperienceLevel level,
            EquipmentProfile equipmentProfile,
            int sessionsPerWeek,
            int durationWeeks,
            RestDayMode restDayMode,
            Set<WeekDay> trainingDays,
            int sessionDurationMinutes,
            List<FitnessGoal> goals,
            Gender gender,
            BodyType bodyType)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GoalConfig() when $default != null:
        return $default(
            _that.goal,
            _that.level,
            _that.equipmentProfile,
            _that.sessionsPerWeek,
            _that.durationWeeks,
            _that.restDayMode,
            _that.trainingDays,
            _that.sessionDurationMinutes,
            _that.goals,
            _that.gender,
            _that.bodyType);
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
            FitnessGoal goal,
            ExperienceLevel level,
            EquipmentProfile equipmentProfile,
            int sessionsPerWeek,
            int durationWeeks,
            RestDayMode restDayMode,
            Set<WeekDay> trainingDays,
            int sessionDurationMinutes,
            List<FitnessGoal> goals,
            Gender gender,
            BodyType bodyType)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GoalConfig():
        return $default(
            _that.goal,
            _that.level,
            _that.equipmentProfile,
            _that.sessionsPerWeek,
            _that.durationWeeks,
            _that.restDayMode,
            _that.trainingDays,
            _that.sessionDurationMinutes,
            _that.goals,
            _that.gender,
            _that.bodyType);
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
            FitnessGoal goal,
            ExperienceLevel level,
            EquipmentProfile equipmentProfile,
            int sessionsPerWeek,
            int durationWeeks,
            RestDayMode restDayMode,
            Set<WeekDay> trainingDays,
            int sessionDurationMinutes,
            List<FitnessGoal> goals,
            Gender gender,
            BodyType bodyType)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GoalConfig() when $default != null:
        return $default(
            _that.goal,
            _that.level,
            _that.equipmentProfile,
            _that.sessionsPerWeek,
            _that.durationWeeks,
            _that.restDayMode,
            _that.trainingDays,
            _that.sessionDurationMinutes,
            _that.goals,
            _that.gender,
            _that.bodyType);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GoalConfig implements GoalConfig {
  const _GoalConfig(
      {required this.goal,
      required this.level,
      required this.equipmentProfile,
      required this.sessionsPerWeek,
      required this.durationWeeks,
      required this.restDayMode,
      required final Set<WeekDay> trainingDays,
      this.sessionDurationMinutes = 45,
      required final List<FitnessGoal> goals,
      this.gender = Gender.male,
      this.bodyType = BodyType.mesomorph})
      : _trainingDays = trainingDays,
        _goals = goals;
  factory _GoalConfig.fromJson(Map<String, dynamic> json) =>
      _$GoalConfigFromJson(json);

  @override
  final FitnessGoal goal;
  @override
  final ExperienceLevel level;
  @override
  final EquipmentProfile equipmentProfile;
  @override
  final int sessionsPerWeek;
  @override
  final int durationWeeks;
  @override
  final RestDayMode restDayMode;
  final Set<WeekDay> _trainingDays;
  @override
  Set<WeekDay> get trainingDays {
    if (_trainingDays is EqualUnmodifiableSetView) return _trainingDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_trainingDays);
  }

  @override
  @JsonKey()
  final int sessionDurationMinutes;
  final List<FitnessGoal> _goals;
  @override
  List<FitnessGoal> get goals {
    if (_goals is EqualUnmodifiableListView) return _goals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_goals);
  }

  @override
  @JsonKey()
  final Gender gender;
  @override
  @JsonKey()
  final BodyType bodyType;

  /// Create a copy of GoalConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GoalConfigCopyWith<_GoalConfig> get copyWith =>
      __$GoalConfigCopyWithImpl<_GoalConfig>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GoalConfigToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GoalConfig &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.equipmentProfile, equipmentProfile) ||
                other.equipmentProfile == equipmentProfile) &&
            (identical(other.sessionsPerWeek, sessionsPerWeek) ||
                other.sessionsPerWeek == sessionsPerWeek) &&
            (identical(other.durationWeeks, durationWeeks) ||
                other.durationWeeks == durationWeeks) &&
            (identical(other.restDayMode, restDayMode) ||
                other.restDayMode == restDayMode) &&
            const DeepCollectionEquality()
                .equals(other._trainingDays, _trainingDays) &&
            (identical(other.sessionDurationMinutes, sessionDurationMinutes) ||
                other.sessionDurationMinutes == sessionDurationMinutes) &&
            const DeepCollectionEquality().equals(other._goals, _goals) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.bodyType, bodyType) ||
                other.bodyType == bodyType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      goal,
      level,
      equipmentProfile,
      sessionsPerWeek,
      durationWeeks,
      restDayMode,
      const DeepCollectionEquality().hash(_trainingDays),
      sessionDurationMinutes,
      const DeepCollectionEquality().hash(_goals),
      gender,
      bodyType);

  @override
  String toString() {
    return 'GoalConfig(goal: $goal, level: $level, equipmentProfile: $equipmentProfile, sessionsPerWeek: $sessionsPerWeek, durationWeeks: $durationWeeks, restDayMode: $restDayMode, trainingDays: $trainingDays, sessionDurationMinutes: $sessionDurationMinutes, goals: $goals, gender: $gender, bodyType: $bodyType)';
  }
}

/// @nodoc
abstract mixin class _$GoalConfigCopyWith<$Res>
    implements $GoalConfigCopyWith<$Res> {
  factory _$GoalConfigCopyWith(
          _GoalConfig value, $Res Function(_GoalConfig) _then) =
      __$GoalConfigCopyWithImpl;
  @override
  @useResult
  $Res call(
      {FitnessGoal goal,
      ExperienceLevel level,
      EquipmentProfile equipmentProfile,
      int sessionsPerWeek,
      int durationWeeks,
      RestDayMode restDayMode,
      Set<WeekDay> trainingDays,
      int sessionDurationMinutes,
      List<FitnessGoal> goals,
      Gender gender,
      BodyType bodyType});
}

/// @nodoc
class __$GoalConfigCopyWithImpl<$Res> implements _$GoalConfigCopyWith<$Res> {
  __$GoalConfigCopyWithImpl(this._self, this._then);

  final _GoalConfig _self;
  final $Res Function(_GoalConfig) _then;

  /// Create a copy of GoalConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? goal = null,
    Object? level = null,
    Object? equipmentProfile = null,
    Object? sessionsPerWeek = null,
    Object? durationWeeks = null,
    Object? restDayMode = null,
    Object? trainingDays = null,
    Object? sessionDurationMinutes = null,
    Object? goals = null,
    Object? gender = null,
    Object? bodyType = null,
  }) {
    return _then(_GoalConfig(
      goal: null == goal
          ? _self.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as FitnessGoal,
      level: null == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as ExperienceLevel,
      equipmentProfile: null == equipmentProfile
          ? _self.equipmentProfile
          : equipmentProfile // ignore: cast_nullable_to_non_nullable
              as EquipmentProfile,
      sessionsPerWeek: null == sessionsPerWeek
          ? _self.sessionsPerWeek
          : sessionsPerWeek // ignore: cast_nullable_to_non_nullable
              as int,
      durationWeeks: null == durationWeeks
          ? _self.durationWeeks
          : durationWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      restDayMode: null == restDayMode
          ? _self.restDayMode
          : restDayMode // ignore: cast_nullable_to_non_nullable
              as RestDayMode,
      trainingDays: null == trainingDays
          ? _self._trainingDays
          : trainingDays // ignore: cast_nullable_to_non_nullable
              as Set<WeekDay>,
      sessionDurationMinutes: null == sessionDurationMinutes
          ? _self.sessionDurationMinutes
          : sessionDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      goals: null == goals
          ? _self._goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<FitnessGoal>,
      gender: null == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      bodyType: null == bodyType
          ? _self.bodyType
          : bodyType // ignore: cast_nullable_to_non_nullable
              as BodyType,
    ));
  }
}

// dart format on

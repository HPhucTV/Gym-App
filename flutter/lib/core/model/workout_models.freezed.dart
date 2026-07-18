// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActiveGoal {
  int get id;
  GoalConfig get config;
  int get totalWorkouts;

  /// Create a copy of ActiveGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ActiveGoalCopyWith<ActiveGoal> get copyWith =>
      _$ActiveGoalCopyWithImpl<ActiveGoal>(this as ActiveGoal, _$identity);

  /// Serializes this ActiveGoal to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ActiveGoal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.config, config) || other.config == config) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, config, totalWorkouts);

  @override
  String toString() {
    return 'ActiveGoal(id: $id, config: $config, totalWorkouts: $totalWorkouts)';
  }
}

/// @nodoc
abstract mixin class $ActiveGoalCopyWith<$Res> {
  factory $ActiveGoalCopyWith(
          ActiveGoal value, $Res Function(ActiveGoal) _then) =
      _$ActiveGoalCopyWithImpl;
  @useResult
  $Res call({int id, GoalConfig config, int totalWorkouts});

  $GoalConfigCopyWith<$Res> get config;
}

/// @nodoc
class _$ActiveGoalCopyWithImpl<$Res> implements $ActiveGoalCopyWith<$Res> {
  _$ActiveGoalCopyWithImpl(this._self, this._then);

  final ActiveGoal _self;
  final $Res Function(ActiveGoal) _then;

  /// Create a copy of ActiveGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? config = null,
    Object? totalWorkouts = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      config: null == config
          ? _self.config
          : config // ignore: cast_nullable_to_non_nullable
              as GoalConfig,
      totalWorkouts: null == totalWorkouts
          ? _self.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of ActiveGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GoalConfigCopyWith<$Res> get config {
    return $GoalConfigCopyWith<$Res>(_self.config, (value) {
      return _then(_self.copyWith(config: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ActiveGoal].
extension ActiveGoalPatterns on ActiveGoal {
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
    TResult Function(_ActiveGoal value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActiveGoal() when $default != null:
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
    TResult Function(_ActiveGoal value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActiveGoal():
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
    TResult? Function(_ActiveGoal value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActiveGoal() when $default != null:
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
    TResult Function(int id, GoalConfig config, int totalWorkouts)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActiveGoal() when $default != null:
        return $default(_that.id, _that.config, _that.totalWorkouts);
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
    TResult Function(int id, GoalConfig config, int totalWorkouts) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActiveGoal():
        return $default(_that.id, _that.config, _that.totalWorkouts);
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
    TResult? Function(int id, GoalConfig config, int totalWorkouts)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActiveGoal() when $default != null:
        return $default(_that.id, _that.config, _that.totalWorkouts);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ActiveGoal implements ActiveGoal {
  const _ActiveGoal(
      {required this.id, required this.config, required this.totalWorkouts});
  factory _ActiveGoal.fromJson(Map<String, dynamic> json) =>
      _$ActiveGoalFromJson(json);

  @override
  final int id;
  @override
  final GoalConfig config;
  @override
  final int totalWorkouts;

  /// Create a copy of ActiveGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ActiveGoalCopyWith<_ActiveGoal> get copyWith =>
      __$ActiveGoalCopyWithImpl<_ActiveGoal>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ActiveGoalToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ActiveGoal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.config, config) || other.config == config) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, config, totalWorkouts);

  @override
  String toString() {
    return 'ActiveGoal(id: $id, config: $config, totalWorkouts: $totalWorkouts)';
  }
}

/// @nodoc
abstract mixin class _$ActiveGoalCopyWith<$Res>
    implements $ActiveGoalCopyWith<$Res> {
  factory _$ActiveGoalCopyWith(
          _ActiveGoal value, $Res Function(_ActiveGoal) _then) =
      __$ActiveGoalCopyWithImpl;
  @override
  @useResult
  $Res call({int id, GoalConfig config, int totalWorkouts});

  @override
  $GoalConfigCopyWith<$Res> get config;
}

/// @nodoc
class __$ActiveGoalCopyWithImpl<$Res> implements _$ActiveGoalCopyWith<$Res> {
  __$ActiveGoalCopyWithImpl(this._self, this._then);

  final _ActiveGoal _self;
  final $Res Function(_ActiveGoal) _then;

  /// Create a copy of ActiveGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? config = null,
    Object? totalWorkouts = null,
  }) {
    return _then(_ActiveGoal(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      config: null == config
          ? _self.config
          : config // ignore: cast_nullable_to_non_nullable
              as GoalConfig,
      totalWorkouts: null == totalWorkouts
          ? _self.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of ActiveGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GoalConfigCopyWith<$Res> get config {
    return $GoalConfigCopyWith<$Res>(_self.config, (value) {
      return _then(_self.copyWith(config: value));
    });
  }
}

/// @nodoc
mixin _$WorkoutSession {
  int get id;
  int get goalId;
  int get sequenceIndex;
  String get titleVi;
  String get focusVi;
  int get estimatedMinutes;
  int get dueEpochDay;
  List<WorkoutExercise> get exercises;
  int? get selectedTimeBudgetMinutes;
  int get omittedExerciseCount;

  /// Create a copy of WorkoutSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WorkoutSessionCopyWith<WorkoutSession> get copyWith =>
      _$WorkoutSessionCopyWithImpl<WorkoutSession>(
          this as WorkoutSession, _$identity);

  /// Serializes this WorkoutSession to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WorkoutSession &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.sequenceIndex, sequenceIndex) ||
                other.sequenceIndex == sequenceIndex) &&
            (identical(other.titleVi, titleVi) || other.titleVi == titleVi) &&
            (identical(other.focusVi, focusVi) || other.focusVi == focusVi) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            (identical(other.dueEpochDay, dueEpochDay) ||
                other.dueEpochDay == dueEpochDay) &&
            const DeepCollectionEquality().equals(other.exercises, exercises) &&
            (identical(other.selectedTimeBudgetMinutes,
                    selectedTimeBudgetMinutes) ||
                other.selectedTimeBudgetMinutes == selectedTimeBudgetMinutes) &&
            (identical(other.omittedExerciseCount, omittedExerciseCount) ||
                other.omittedExerciseCount == omittedExerciseCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      goalId,
      sequenceIndex,
      titleVi,
      focusVi,
      estimatedMinutes,
      dueEpochDay,
      const DeepCollectionEquality().hash(exercises),
      selectedTimeBudgetMinutes,
      omittedExerciseCount);

  @override
  String toString() {
    return 'WorkoutSession(id: $id, goalId: $goalId, sequenceIndex: $sequenceIndex, titleVi: $titleVi, focusVi: $focusVi, estimatedMinutes: $estimatedMinutes, dueEpochDay: $dueEpochDay, exercises: $exercises, selectedTimeBudgetMinutes: $selectedTimeBudgetMinutes, omittedExerciseCount: $omittedExerciseCount)';
  }
}

/// @nodoc
abstract mixin class $WorkoutSessionCopyWith<$Res> {
  factory $WorkoutSessionCopyWith(
          WorkoutSession value, $Res Function(WorkoutSession) _then) =
      _$WorkoutSessionCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      int goalId,
      int sequenceIndex,
      String titleVi,
      String focusVi,
      int estimatedMinutes,
      int dueEpochDay,
      List<WorkoutExercise> exercises,
      int? selectedTimeBudgetMinutes,
      int omittedExerciseCount});
}

/// @nodoc
class _$WorkoutSessionCopyWithImpl<$Res>
    implements $WorkoutSessionCopyWith<$Res> {
  _$WorkoutSessionCopyWithImpl(this._self, this._then);

  final WorkoutSession _self;
  final $Res Function(WorkoutSession) _then;

  /// Create a copy of WorkoutSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? goalId = null,
    Object? sequenceIndex = null,
    Object? titleVi = null,
    Object? focusVi = null,
    Object? estimatedMinutes = null,
    Object? dueEpochDay = null,
    Object? exercises = null,
    Object? selectedTimeBudgetMinutes = freezed,
    Object? omittedExerciseCount = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      goalId: null == goalId
          ? _self.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int,
      sequenceIndex: null == sequenceIndex
          ? _self.sequenceIndex
          : sequenceIndex // ignore: cast_nullable_to_non_nullable
              as int,
      titleVi: null == titleVi
          ? _self.titleVi
          : titleVi // ignore: cast_nullable_to_non_nullable
              as String,
      focusVi: null == focusVi
          ? _self.focusVi
          : focusVi // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedMinutes: null == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      dueEpochDay: null == dueEpochDay
          ? _self.dueEpochDay
          : dueEpochDay // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _self.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<WorkoutExercise>,
      selectedTimeBudgetMinutes: freezed == selectedTimeBudgetMinutes
          ? _self.selectedTimeBudgetMinutes
          : selectedTimeBudgetMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      omittedExerciseCount: null == omittedExerciseCount
          ? _self.omittedExerciseCount
          : omittedExerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [WorkoutSession].
extension WorkoutSessionPatterns on WorkoutSession {
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
    TResult Function(_WorkoutSession value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WorkoutSession() when $default != null:
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
    TResult Function(_WorkoutSession value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutSession():
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
    TResult? Function(_WorkoutSession value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutSession() when $default != null:
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
            int id,
            int goalId,
            int sequenceIndex,
            String titleVi,
            String focusVi,
            int estimatedMinutes,
            int dueEpochDay,
            List<WorkoutExercise> exercises,
            int? selectedTimeBudgetMinutes,
            int omittedExerciseCount)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WorkoutSession() when $default != null:
        return $default(
            _that.id,
            _that.goalId,
            _that.sequenceIndex,
            _that.titleVi,
            _that.focusVi,
            _that.estimatedMinutes,
            _that.dueEpochDay,
            _that.exercises,
            _that.selectedTimeBudgetMinutes,
            _that.omittedExerciseCount);
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
            int id,
            int goalId,
            int sequenceIndex,
            String titleVi,
            String focusVi,
            int estimatedMinutes,
            int dueEpochDay,
            List<WorkoutExercise> exercises,
            int? selectedTimeBudgetMinutes,
            int omittedExerciseCount)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutSession():
        return $default(
            _that.id,
            _that.goalId,
            _that.sequenceIndex,
            _that.titleVi,
            _that.focusVi,
            _that.estimatedMinutes,
            _that.dueEpochDay,
            _that.exercises,
            _that.selectedTimeBudgetMinutes,
            _that.omittedExerciseCount);
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
            int id,
            int goalId,
            int sequenceIndex,
            String titleVi,
            String focusVi,
            int estimatedMinutes,
            int dueEpochDay,
            List<WorkoutExercise> exercises,
            int? selectedTimeBudgetMinutes,
            int omittedExerciseCount)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutSession() when $default != null:
        return $default(
            _that.id,
            _that.goalId,
            _that.sequenceIndex,
            _that.titleVi,
            _that.focusVi,
            _that.estimatedMinutes,
            _that.dueEpochDay,
            _that.exercises,
            _that.selectedTimeBudgetMinutes,
            _that.omittedExerciseCount);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WorkoutSession implements WorkoutSession {
  const _WorkoutSession(
      {required this.id,
      required this.goalId,
      required this.sequenceIndex,
      required this.titleVi,
      required this.focusVi,
      required this.estimatedMinutes,
      required this.dueEpochDay,
      required final List<WorkoutExercise> exercises,
      this.selectedTimeBudgetMinutes,
      this.omittedExerciseCount = 0})
      : _exercises = exercises;
  factory _WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);

  @override
  final int id;
  @override
  final int goalId;
  @override
  final int sequenceIndex;
  @override
  final String titleVi;
  @override
  final String focusVi;
  @override
  final int estimatedMinutes;
  @override
  final int dueEpochDay;
  final List<WorkoutExercise> _exercises;
  @override
  List<WorkoutExercise> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  final int? selectedTimeBudgetMinutes;
  @override
  @JsonKey()
  final int omittedExerciseCount;

  /// Create a copy of WorkoutSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WorkoutSessionCopyWith<_WorkoutSession> get copyWith =>
      __$WorkoutSessionCopyWithImpl<_WorkoutSession>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WorkoutSessionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WorkoutSession &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.sequenceIndex, sequenceIndex) ||
                other.sequenceIndex == sequenceIndex) &&
            (identical(other.titleVi, titleVi) || other.titleVi == titleVi) &&
            (identical(other.focusVi, focusVi) || other.focusVi == focusVi) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            (identical(other.dueEpochDay, dueEpochDay) ||
                other.dueEpochDay == dueEpochDay) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            (identical(other.selectedTimeBudgetMinutes,
                    selectedTimeBudgetMinutes) ||
                other.selectedTimeBudgetMinutes == selectedTimeBudgetMinutes) &&
            (identical(other.omittedExerciseCount, omittedExerciseCount) ||
                other.omittedExerciseCount == omittedExerciseCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      goalId,
      sequenceIndex,
      titleVi,
      focusVi,
      estimatedMinutes,
      dueEpochDay,
      const DeepCollectionEquality().hash(_exercises),
      selectedTimeBudgetMinutes,
      omittedExerciseCount);

  @override
  String toString() {
    return 'WorkoutSession(id: $id, goalId: $goalId, sequenceIndex: $sequenceIndex, titleVi: $titleVi, focusVi: $focusVi, estimatedMinutes: $estimatedMinutes, dueEpochDay: $dueEpochDay, exercises: $exercises, selectedTimeBudgetMinutes: $selectedTimeBudgetMinutes, omittedExerciseCount: $omittedExerciseCount)';
  }
}

/// @nodoc
abstract mixin class _$WorkoutSessionCopyWith<$Res>
    implements $WorkoutSessionCopyWith<$Res> {
  factory _$WorkoutSessionCopyWith(
          _WorkoutSession value, $Res Function(_WorkoutSession) _then) =
      __$WorkoutSessionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      int goalId,
      int sequenceIndex,
      String titleVi,
      String focusVi,
      int estimatedMinutes,
      int dueEpochDay,
      List<WorkoutExercise> exercises,
      int? selectedTimeBudgetMinutes,
      int omittedExerciseCount});
}

/// @nodoc
class __$WorkoutSessionCopyWithImpl<$Res>
    implements _$WorkoutSessionCopyWith<$Res> {
  __$WorkoutSessionCopyWithImpl(this._self, this._then);

  final _WorkoutSession _self;
  final $Res Function(_WorkoutSession) _then;

  /// Create a copy of WorkoutSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? goalId = null,
    Object? sequenceIndex = null,
    Object? titleVi = null,
    Object? focusVi = null,
    Object? estimatedMinutes = null,
    Object? dueEpochDay = null,
    Object? exercises = null,
    Object? selectedTimeBudgetMinutes = freezed,
    Object? omittedExerciseCount = null,
  }) {
    return _then(_WorkoutSession(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      goalId: null == goalId
          ? _self.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int,
      sequenceIndex: null == sequenceIndex
          ? _self.sequenceIndex
          : sequenceIndex // ignore: cast_nullable_to_non_nullable
              as int,
      titleVi: null == titleVi
          ? _self.titleVi
          : titleVi // ignore: cast_nullable_to_non_nullable
              as String,
      focusVi: null == focusVi
          ? _self.focusVi
          : focusVi // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedMinutes: null == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      dueEpochDay: null == dueEpochDay
          ? _self.dueEpochDay
          : dueEpochDay // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _self._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<WorkoutExercise>,
      selectedTimeBudgetMinutes: freezed == selectedTimeBudgetMinutes
          ? _self.selectedTimeBudgetMinutes
          : selectedTimeBudgetMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      omittedExerciseCount: null == omittedExerciseCount
          ? _self.omittedExerciseCount
          : omittedExerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$WorkoutExercise {
  int get orderIndex;
  String get exerciseId;
  ExercisePrescription get prescription;
  bool get isChecked;
  String? get originalExerciseId;
  bool get isLightWorkout;

  /// Create a copy of WorkoutExercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WorkoutExerciseCopyWith<WorkoutExercise> get copyWith =>
      _$WorkoutExerciseCopyWithImpl<WorkoutExercise>(
          this as WorkoutExercise, _$identity);

  /// Serializes this WorkoutExercise to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WorkoutExercise &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.prescription, prescription) ||
                other.prescription == prescription) &&
            (identical(other.isChecked, isChecked) ||
                other.isChecked == isChecked) &&
            (identical(other.originalExerciseId, originalExerciseId) ||
                other.originalExerciseId == originalExerciseId) &&
            (identical(other.isLightWorkout, isLightWorkout) ||
                other.isLightWorkout == isLightWorkout));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, orderIndex, exerciseId,
      prescription, isChecked, originalExerciseId, isLightWorkout);

  @override
  String toString() {
    return 'WorkoutExercise(orderIndex: $orderIndex, exerciseId: $exerciseId, prescription: $prescription, isChecked: $isChecked, originalExerciseId: $originalExerciseId, isLightWorkout: $isLightWorkout)';
  }
}

/// @nodoc
abstract mixin class $WorkoutExerciseCopyWith<$Res> {
  factory $WorkoutExerciseCopyWith(
          WorkoutExercise value, $Res Function(WorkoutExercise) _then) =
      _$WorkoutExerciseCopyWithImpl;
  @useResult
  $Res call(
      {int orderIndex,
      String exerciseId,
      ExercisePrescription prescription,
      bool isChecked,
      String? originalExerciseId,
      bool isLightWorkout});

  $ExercisePrescriptionCopyWith<$Res> get prescription;
}

/// @nodoc
class _$WorkoutExerciseCopyWithImpl<$Res>
    implements $WorkoutExerciseCopyWith<$Res> {
  _$WorkoutExerciseCopyWithImpl(this._self, this._then);

  final WorkoutExercise _self;
  final $Res Function(WorkoutExercise) _then;

  /// Create a copy of WorkoutExercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderIndex = null,
    Object? exerciseId = null,
    Object? prescription = null,
    Object? isChecked = null,
    Object? originalExerciseId = freezed,
    Object? isLightWorkout = null,
  }) {
    return _then(_self.copyWith(
      orderIndex: null == orderIndex
          ? _self.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseId: null == exerciseId
          ? _self.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      prescription: null == prescription
          ? _self.prescription
          : prescription // ignore: cast_nullable_to_non_nullable
              as ExercisePrescription,
      isChecked: null == isChecked
          ? _self.isChecked
          : isChecked // ignore: cast_nullable_to_non_nullable
              as bool,
      originalExerciseId: freezed == originalExerciseId
          ? _self.originalExerciseId
          : originalExerciseId // ignore: cast_nullable_to_non_nullable
              as String?,
      isLightWorkout: null == isLightWorkout
          ? _self.isLightWorkout
          : isLightWorkout // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of WorkoutExercise
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExercisePrescriptionCopyWith<$Res> get prescription {
    return $ExercisePrescriptionCopyWith<$Res>(_self.prescription, (value) {
      return _then(_self.copyWith(prescription: value));
    });
  }
}

/// Adds pattern-matching-related methods to [WorkoutExercise].
extension WorkoutExercisePatterns on WorkoutExercise {
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
    TResult Function(_WorkoutExercise value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WorkoutExercise() when $default != null:
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
    TResult Function(_WorkoutExercise value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutExercise():
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
    TResult? Function(_WorkoutExercise value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutExercise() when $default != null:
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
            int orderIndex,
            String exerciseId,
            ExercisePrescription prescription,
            bool isChecked,
            String? originalExerciseId,
            bool isLightWorkout)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WorkoutExercise() when $default != null:
        return $default(_that.orderIndex, _that.exerciseId, _that.prescription,
            _that.isChecked, _that.originalExerciseId, _that.isLightWorkout);
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
            int orderIndex,
            String exerciseId,
            ExercisePrescription prescription,
            bool isChecked,
            String? originalExerciseId,
            bool isLightWorkout)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutExercise():
        return $default(_that.orderIndex, _that.exerciseId, _that.prescription,
            _that.isChecked, _that.originalExerciseId, _that.isLightWorkout);
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
            int orderIndex,
            String exerciseId,
            ExercisePrescription prescription,
            bool isChecked,
            String? originalExerciseId,
            bool isLightWorkout)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutExercise() when $default != null:
        return $default(_that.orderIndex, _that.exerciseId, _that.prescription,
            _that.isChecked, _that.originalExerciseId, _that.isLightWorkout);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WorkoutExercise implements WorkoutExercise {
  const _WorkoutExercise(
      {required this.orderIndex,
      required this.exerciseId,
      required this.prescription,
      required this.isChecked,
      this.originalExerciseId,
      this.isLightWorkout = false});
  factory _WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseFromJson(json);

  @override
  final int orderIndex;
  @override
  final String exerciseId;
  @override
  final ExercisePrescription prescription;
  @override
  final bool isChecked;
  @override
  final String? originalExerciseId;
  @override
  @JsonKey()
  final bool isLightWorkout;

  /// Create a copy of WorkoutExercise
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WorkoutExerciseCopyWith<_WorkoutExercise> get copyWith =>
      __$WorkoutExerciseCopyWithImpl<_WorkoutExercise>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WorkoutExerciseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WorkoutExercise &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.prescription, prescription) ||
                other.prescription == prescription) &&
            (identical(other.isChecked, isChecked) ||
                other.isChecked == isChecked) &&
            (identical(other.originalExerciseId, originalExerciseId) ||
                other.originalExerciseId == originalExerciseId) &&
            (identical(other.isLightWorkout, isLightWorkout) ||
                other.isLightWorkout == isLightWorkout));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, orderIndex, exerciseId,
      prescription, isChecked, originalExerciseId, isLightWorkout);

  @override
  String toString() {
    return 'WorkoutExercise(orderIndex: $orderIndex, exerciseId: $exerciseId, prescription: $prescription, isChecked: $isChecked, originalExerciseId: $originalExerciseId, isLightWorkout: $isLightWorkout)';
  }
}

/// @nodoc
abstract mixin class _$WorkoutExerciseCopyWith<$Res>
    implements $WorkoutExerciseCopyWith<$Res> {
  factory _$WorkoutExerciseCopyWith(
          _WorkoutExercise value, $Res Function(_WorkoutExercise) _then) =
      __$WorkoutExerciseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int orderIndex,
      String exerciseId,
      ExercisePrescription prescription,
      bool isChecked,
      String? originalExerciseId,
      bool isLightWorkout});

  @override
  $ExercisePrescriptionCopyWith<$Res> get prescription;
}

/// @nodoc
class __$WorkoutExerciseCopyWithImpl<$Res>
    implements _$WorkoutExerciseCopyWith<$Res> {
  __$WorkoutExerciseCopyWithImpl(this._self, this._then);

  final _WorkoutExercise _self;
  final $Res Function(_WorkoutExercise) _then;

  /// Create a copy of WorkoutExercise
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? orderIndex = null,
    Object? exerciseId = null,
    Object? prescription = null,
    Object? isChecked = null,
    Object? originalExerciseId = freezed,
    Object? isLightWorkout = null,
  }) {
    return _then(_WorkoutExercise(
      orderIndex: null == orderIndex
          ? _self.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseId: null == exerciseId
          ? _self.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      prescription: null == prescription
          ? _self.prescription
          : prescription // ignore: cast_nullable_to_non_nullable
              as ExercisePrescription,
      isChecked: null == isChecked
          ? _self.isChecked
          : isChecked // ignore: cast_nullable_to_non_nullable
              as bool,
      originalExerciseId: freezed == originalExerciseId
          ? _self.originalExerciseId
          : originalExerciseId // ignore: cast_nullable_to_non_nullable
              as String?,
      isLightWorkout: null == isLightWorkout
          ? _self.isLightWorkout
          : isLightWorkout // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of WorkoutExercise
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExercisePrescriptionCopyWith<$Res> get prescription {
    return $ExercisePrescriptionCopyWith<$Res>(_self.prescription, (value) {
      return _then(_self.copyWith(prescription: value));
    });
  }
}

/// @nodoc
mixin _$CompletedWorkout {
  int get goalId;
  int get completedEpochDay;

  /// Create a copy of CompletedWorkout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CompletedWorkoutCopyWith<CompletedWorkout> get copyWith =>
      _$CompletedWorkoutCopyWithImpl<CompletedWorkout>(
          this as CompletedWorkout, _$identity);

  /// Serializes this CompletedWorkout to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CompletedWorkout &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.completedEpochDay, completedEpochDay) ||
                other.completedEpochDay == completedEpochDay));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, goalId, completedEpochDay);

  @override
  String toString() {
    return 'CompletedWorkout(goalId: $goalId, completedEpochDay: $completedEpochDay)';
  }
}

/// @nodoc
abstract mixin class $CompletedWorkoutCopyWith<$Res> {
  factory $CompletedWorkoutCopyWith(
          CompletedWorkout value, $Res Function(CompletedWorkout) _then) =
      _$CompletedWorkoutCopyWithImpl;
  @useResult
  $Res call({int goalId, int completedEpochDay});
}

/// @nodoc
class _$CompletedWorkoutCopyWithImpl<$Res>
    implements $CompletedWorkoutCopyWith<$Res> {
  _$CompletedWorkoutCopyWithImpl(this._self, this._then);

  final CompletedWorkout _self;
  final $Res Function(CompletedWorkout) _then;

  /// Create a copy of CompletedWorkout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goalId = null,
    Object? completedEpochDay = null,
  }) {
    return _then(_self.copyWith(
      goalId: null == goalId
          ? _self.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int,
      completedEpochDay: null == completedEpochDay
          ? _self.completedEpochDay
          : completedEpochDay // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [CompletedWorkout].
extension CompletedWorkoutPatterns on CompletedWorkout {
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
    TResult Function(_CompletedWorkout value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CompletedWorkout() when $default != null:
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
    TResult Function(_CompletedWorkout value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompletedWorkout():
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
    TResult? Function(_CompletedWorkout value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompletedWorkout() when $default != null:
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
    TResult Function(int goalId, int completedEpochDay)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CompletedWorkout() when $default != null:
        return $default(_that.goalId, _that.completedEpochDay);
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
    TResult Function(int goalId, int completedEpochDay) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompletedWorkout():
        return $default(_that.goalId, _that.completedEpochDay);
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
    TResult? Function(int goalId, int completedEpochDay)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompletedWorkout() when $default != null:
        return $default(_that.goalId, _that.completedEpochDay);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CompletedWorkout implements CompletedWorkout {
  const _CompletedWorkout(
      {required this.goalId, required this.completedEpochDay});
  factory _CompletedWorkout.fromJson(Map<String, dynamic> json) =>
      _$CompletedWorkoutFromJson(json);

  @override
  final int goalId;
  @override
  final int completedEpochDay;

  /// Create a copy of CompletedWorkout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CompletedWorkoutCopyWith<_CompletedWorkout> get copyWith =>
      __$CompletedWorkoutCopyWithImpl<_CompletedWorkout>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CompletedWorkoutToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CompletedWorkout &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.completedEpochDay, completedEpochDay) ||
                other.completedEpochDay == completedEpochDay));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, goalId, completedEpochDay);

  @override
  String toString() {
    return 'CompletedWorkout(goalId: $goalId, completedEpochDay: $completedEpochDay)';
  }
}

/// @nodoc
abstract mixin class _$CompletedWorkoutCopyWith<$Res>
    implements $CompletedWorkoutCopyWith<$Res> {
  factory _$CompletedWorkoutCopyWith(
          _CompletedWorkout value, $Res Function(_CompletedWorkout) _then) =
      __$CompletedWorkoutCopyWithImpl;
  @override
  @useResult
  $Res call({int goalId, int completedEpochDay});
}

/// @nodoc
class __$CompletedWorkoutCopyWithImpl<$Res>
    implements _$CompletedWorkoutCopyWith<$Res> {
  __$CompletedWorkoutCopyWithImpl(this._self, this._then);

  final _CompletedWorkout _self;
  final $Res Function(_CompletedWorkout) _then;

  /// Create a copy of CompletedWorkout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? goalId = null,
    Object? completedEpochDay = null,
  }) {
    return _then(_CompletedWorkout(
      goalId: null == goalId
          ? _self.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int,
      completedEpochDay: null == completedEpochDay
          ? _self.completedEpochDay
          : completedEpochDay // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$WorkoutHistoryEntry {
  int get sessionId;
  int get goalId;
  int get sequenceIndex;
  int get dueEpochDay;
  int? get completedEpochDay;
  int get estimatedMinutes;
  int? get selectedTimeBudgetMinutes;

  /// Create a copy of WorkoutHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WorkoutHistoryEntryCopyWith<WorkoutHistoryEntry> get copyWith =>
      _$WorkoutHistoryEntryCopyWithImpl<WorkoutHistoryEntry>(
          this as WorkoutHistoryEntry, _$identity);

  /// Serializes this WorkoutHistoryEntry to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WorkoutHistoryEntry &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.sequenceIndex, sequenceIndex) ||
                other.sequenceIndex == sequenceIndex) &&
            (identical(other.dueEpochDay, dueEpochDay) ||
                other.dueEpochDay == dueEpochDay) &&
            (identical(other.completedEpochDay, completedEpochDay) ||
                other.completedEpochDay == completedEpochDay) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            (identical(other.selectedTimeBudgetMinutes,
                    selectedTimeBudgetMinutes) ||
                other.selectedTimeBudgetMinutes == selectedTimeBudgetMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      sessionId,
      goalId,
      sequenceIndex,
      dueEpochDay,
      completedEpochDay,
      estimatedMinutes,
      selectedTimeBudgetMinutes);

  @override
  String toString() {
    return 'WorkoutHistoryEntry(sessionId: $sessionId, goalId: $goalId, sequenceIndex: $sequenceIndex, dueEpochDay: $dueEpochDay, completedEpochDay: $completedEpochDay, estimatedMinutes: $estimatedMinutes, selectedTimeBudgetMinutes: $selectedTimeBudgetMinutes)';
  }
}

/// @nodoc
abstract mixin class $WorkoutHistoryEntryCopyWith<$Res> {
  factory $WorkoutHistoryEntryCopyWith(
          WorkoutHistoryEntry value, $Res Function(WorkoutHistoryEntry) _then) =
      _$WorkoutHistoryEntryCopyWithImpl;
  @useResult
  $Res call(
      {int sessionId,
      int goalId,
      int sequenceIndex,
      int dueEpochDay,
      int? completedEpochDay,
      int estimatedMinutes,
      int? selectedTimeBudgetMinutes});
}

/// @nodoc
class _$WorkoutHistoryEntryCopyWithImpl<$Res>
    implements $WorkoutHistoryEntryCopyWith<$Res> {
  _$WorkoutHistoryEntryCopyWithImpl(this._self, this._then);

  final WorkoutHistoryEntry _self;
  final $Res Function(WorkoutHistoryEntry) _then;

  /// Create a copy of WorkoutHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? goalId = null,
    Object? sequenceIndex = null,
    Object? dueEpochDay = null,
    Object? completedEpochDay = freezed,
    Object? estimatedMinutes = null,
    Object? selectedTimeBudgetMinutes = freezed,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      goalId: null == goalId
          ? _self.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int,
      sequenceIndex: null == sequenceIndex
          ? _self.sequenceIndex
          : sequenceIndex // ignore: cast_nullable_to_non_nullable
              as int,
      dueEpochDay: null == dueEpochDay
          ? _self.dueEpochDay
          : dueEpochDay // ignore: cast_nullable_to_non_nullable
              as int,
      completedEpochDay: freezed == completedEpochDay
          ? _self.completedEpochDay
          : completedEpochDay // ignore: cast_nullable_to_non_nullable
              as int?,
      estimatedMinutes: null == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      selectedTimeBudgetMinutes: freezed == selectedTimeBudgetMinutes
          ? _self.selectedTimeBudgetMinutes
          : selectedTimeBudgetMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [WorkoutHistoryEntry].
extension WorkoutHistoryEntryPatterns on WorkoutHistoryEntry {
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
    TResult Function(_WorkoutHistoryEntry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WorkoutHistoryEntry() when $default != null:
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
    TResult Function(_WorkoutHistoryEntry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutHistoryEntry():
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
    TResult? Function(_WorkoutHistoryEntry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutHistoryEntry() when $default != null:
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
            int sessionId,
            int goalId,
            int sequenceIndex,
            int dueEpochDay,
            int? completedEpochDay,
            int estimatedMinutes,
            int? selectedTimeBudgetMinutes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WorkoutHistoryEntry() when $default != null:
        return $default(
            _that.sessionId,
            _that.goalId,
            _that.sequenceIndex,
            _that.dueEpochDay,
            _that.completedEpochDay,
            _that.estimatedMinutes,
            _that.selectedTimeBudgetMinutes);
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
            int sessionId,
            int goalId,
            int sequenceIndex,
            int dueEpochDay,
            int? completedEpochDay,
            int estimatedMinutes,
            int? selectedTimeBudgetMinutes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutHistoryEntry():
        return $default(
            _that.sessionId,
            _that.goalId,
            _that.sequenceIndex,
            _that.dueEpochDay,
            _that.completedEpochDay,
            _that.estimatedMinutes,
            _that.selectedTimeBudgetMinutes);
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
            int sessionId,
            int goalId,
            int sequenceIndex,
            int dueEpochDay,
            int? completedEpochDay,
            int estimatedMinutes,
            int? selectedTimeBudgetMinutes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutHistoryEntry() when $default != null:
        return $default(
            _that.sessionId,
            _that.goalId,
            _that.sequenceIndex,
            _that.dueEpochDay,
            _that.completedEpochDay,
            _that.estimatedMinutes,
            _that.selectedTimeBudgetMinutes);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WorkoutHistoryEntry implements WorkoutHistoryEntry {
  const _WorkoutHistoryEntry(
      {required this.sessionId,
      required this.goalId,
      required this.sequenceIndex,
      required this.dueEpochDay,
      this.completedEpochDay,
      required this.estimatedMinutes,
      this.selectedTimeBudgetMinutes});
  factory _WorkoutHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$WorkoutHistoryEntryFromJson(json);

  @override
  final int sessionId;
  @override
  final int goalId;
  @override
  final int sequenceIndex;
  @override
  final int dueEpochDay;
  @override
  final int? completedEpochDay;
  @override
  final int estimatedMinutes;
  @override
  final int? selectedTimeBudgetMinutes;

  /// Create a copy of WorkoutHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WorkoutHistoryEntryCopyWith<_WorkoutHistoryEntry> get copyWith =>
      __$WorkoutHistoryEntryCopyWithImpl<_WorkoutHistoryEntry>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WorkoutHistoryEntryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WorkoutHistoryEntry &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.sequenceIndex, sequenceIndex) ||
                other.sequenceIndex == sequenceIndex) &&
            (identical(other.dueEpochDay, dueEpochDay) ||
                other.dueEpochDay == dueEpochDay) &&
            (identical(other.completedEpochDay, completedEpochDay) ||
                other.completedEpochDay == completedEpochDay) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            (identical(other.selectedTimeBudgetMinutes,
                    selectedTimeBudgetMinutes) ||
                other.selectedTimeBudgetMinutes == selectedTimeBudgetMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      sessionId,
      goalId,
      sequenceIndex,
      dueEpochDay,
      completedEpochDay,
      estimatedMinutes,
      selectedTimeBudgetMinutes);

  @override
  String toString() {
    return 'WorkoutHistoryEntry(sessionId: $sessionId, goalId: $goalId, sequenceIndex: $sequenceIndex, dueEpochDay: $dueEpochDay, completedEpochDay: $completedEpochDay, estimatedMinutes: $estimatedMinutes, selectedTimeBudgetMinutes: $selectedTimeBudgetMinutes)';
  }
}

/// @nodoc
abstract mixin class _$WorkoutHistoryEntryCopyWith<$Res>
    implements $WorkoutHistoryEntryCopyWith<$Res> {
  factory _$WorkoutHistoryEntryCopyWith(_WorkoutHistoryEntry value,
          $Res Function(_WorkoutHistoryEntry) _then) =
      __$WorkoutHistoryEntryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int sessionId,
      int goalId,
      int sequenceIndex,
      int dueEpochDay,
      int? completedEpochDay,
      int estimatedMinutes,
      int? selectedTimeBudgetMinutes});
}

/// @nodoc
class __$WorkoutHistoryEntryCopyWithImpl<$Res>
    implements _$WorkoutHistoryEntryCopyWith<$Res> {
  __$WorkoutHistoryEntryCopyWithImpl(this._self, this._then);

  final _WorkoutHistoryEntry _self;
  final $Res Function(_WorkoutHistoryEntry) _then;

  /// Create a copy of WorkoutHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = null,
    Object? goalId = null,
    Object? sequenceIndex = null,
    Object? dueEpochDay = null,
    Object? completedEpochDay = freezed,
    Object? estimatedMinutes = null,
    Object? selectedTimeBudgetMinutes = freezed,
  }) {
    return _then(_WorkoutHistoryEntry(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      goalId: null == goalId
          ? _self.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int,
      sequenceIndex: null == sequenceIndex
          ? _self.sequenceIndex
          : sequenceIndex // ignore: cast_nullable_to_non_nullable
              as int,
      dueEpochDay: null == dueEpochDay
          ? _self.dueEpochDay
          : dueEpochDay // ignore: cast_nullable_to_non_nullable
              as int,
      completedEpochDay: freezed == completedEpochDay
          ? _self.completedEpochDay
          : completedEpochDay // ignore: cast_nullable_to_non_nullable
              as int?,
      estimatedMinutes: null == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      selectedTimeBudgetMinutes: freezed == selectedTimeBudgetMinutes
          ? _self.selectedTimeBudgetMinutes
          : selectedTimeBudgetMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on

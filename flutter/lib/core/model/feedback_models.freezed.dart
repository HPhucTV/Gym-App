// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutFeedback {
  int get sessionId;
  int get goalId;
  int get completedEpochDay;
  WorkoutDifficulty get difficulty;
  int get recordedAtEpochMillis;

  /// Create a copy of WorkoutFeedback
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WorkoutFeedbackCopyWith<WorkoutFeedback> get copyWith =>
      _$WorkoutFeedbackCopyWithImpl<WorkoutFeedback>(
          this as WorkoutFeedback, _$identity);

  /// Serializes this WorkoutFeedback to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WorkoutFeedback &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.completedEpochDay, completedEpochDay) ||
                other.completedEpochDay == completedEpochDay) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.recordedAtEpochMillis, recordedAtEpochMillis) ||
                other.recordedAtEpochMillis == recordedAtEpochMillis));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sessionId, goalId,
      completedEpochDay, difficulty, recordedAtEpochMillis);

  @override
  String toString() {
    return 'WorkoutFeedback(sessionId: $sessionId, goalId: $goalId, completedEpochDay: $completedEpochDay, difficulty: $difficulty, recordedAtEpochMillis: $recordedAtEpochMillis)';
  }
}

/// @nodoc
abstract mixin class $WorkoutFeedbackCopyWith<$Res> {
  factory $WorkoutFeedbackCopyWith(
          WorkoutFeedback value, $Res Function(WorkoutFeedback) _then) =
      _$WorkoutFeedbackCopyWithImpl;
  @useResult
  $Res call(
      {int sessionId,
      int goalId,
      int completedEpochDay,
      WorkoutDifficulty difficulty,
      int recordedAtEpochMillis});
}

/// @nodoc
class _$WorkoutFeedbackCopyWithImpl<$Res>
    implements $WorkoutFeedbackCopyWith<$Res> {
  _$WorkoutFeedbackCopyWithImpl(this._self, this._then);

  final WorkoutFeedback _self;
  final $Res Function(WorkoutFeedback) _then;

  /// Create a copy of WorkoutFeedback
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? goalId = null,
    Object? completedEpochDay = null,
    Object? difficulty = null,
    Object? recordedAtEpochMillis = null,
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
      completedEpochDay: null == completedEpochDay
          ? _self.completedEpochDay
          : completedEpochDay // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _self.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as WorkoutDifficulty,
      recordedAtEpochMillis: null == recordedAtEpochMillis
          ? _self.recordedAtEpochMillis
          : recordedAtEpochMillis // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [WorkoutFeedback].
extension WorkoutFeedbackPatterns on WorkoutFeedback {
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
    TResult Function(_WorkoutFeedback value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WorkoutFeedback() when $default != null:
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
    TResult Function(_WorkoutFeedback value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutFeedback():
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
    TResult? Function(_WorkoutFeedback value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutFeedback() when $default != null:
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
    TResult Function(int sessionId, int goalId, int completedEpochDay,
            WorkoutDifficulty difficulty, int recordedAtEpochMillis)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WorkoutFeedback() when $default != null:
        return $default(_that.sessionId, _that.goalId, _that.completedEpochDay,
            _that.difficulty, _that.recordedAtEpochMillis);
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
    TResult Function(int sessionId, int goalId, int completedEpochDay,
            WorkoutDifficulty difficulty, int recordedAtEpochMillis)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutFeedback():
        return $default(_that.sessionId, _that.goalId, _that.completedEpochDay,
            _that.difficulty, _that.recordedAtEpochMillis);
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
    TResult? Function(int sessionId, int goalId, int completedEpochDay,
            WorkoutDifficulty difficulty, int recordedAtEpochMillis)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutFeedback() when $default != null:
        return $default(_that.sessionId, _that.goalId, _that.completedEpochDay,
            _that.difficulty, _that.recordedAtEpochMillis);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WorkoutFeedback implements WorkoutFeedback {
  const _WorkoutFeedback(
      {required this.sessionId,
      required this.goalId,
      required this.completedEpochDay,
      required this.difficulty,
      required this.recordedAtEpochMillis});
  factory _WorkoutFeedback.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFeedbackFromJson(json);

  @override
  final int sessionId;
  @override
  final int goalId;
  @override
  final int completedEpochDay;
  @override
  final WorkoutDifficulty difficulty;
  @override
  final int recordedAtEpochMillis;

  /// Create a copy of WorkoutFeedback
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WorkoutFeedbackCopyWith<_WorkoutFeedback> get copyWith =>
      __$WorkoutFeedbackCopyWithImpl<_WorkoutFeedback>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WorkoutFeedbackToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WorkoutFeedback &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.completedEpochDay, completedEpochDay) ||
                other.completedEpochDay == completedEpochDay) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.recordedAtEpochMillis, recordedAtEpochMillis) ||
                other.recordedAtEpochMillis == recordedAtEpochMillis));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sessionId, goalId,
      completedEpochDay, difficulty, recordedAtEpochMillis);

  @override
  String toString() {
    return 'WorkoutFeedback(sessionId: $sessionId, goalId: $goalId, completedEpochDay: $completedEpochDay, difficulty: $difficulty, recordedAtEpochMillis: $recordedAtEpochMillis)';
  }
}

/// @nodoc
abstract mixin class _$WorkoutFeedbackCopyWith<$Res>
    implements $WorkoutFeedbackCopyWith<$Res> {
  factory _$WorkoutFeedbackCopyWith(
          _WorkoutFeedback value, $Res Function(_WorkoutFeedback) _then) =
      __$WorkoutFeedbackCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int sessionId,
      int goalId,
      int completedEpochDay,
      WorkoutDifficulty difficulty,
      int recordedAtEpochMillis});
}

/// @nodoc
class __$WorkoutFeedbackCopyWithImpl<$Res>
    implements _$WorkoutFeedbackCopyWith<$Res> {
  __$WorkoutFeedbackCopyWithImpl(this._self, this._then);

  final _WorkoutFeedback _self;
  final $Res Function(_WorkoutFeedback) _then;

  /// Create a copy of WorkoutFeedback
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = null,
    Object? goalId = null,
    Object? completedEpochDay = null,
    Object? difficulty = null,
    Object? recordedAtEpochMillis = null,
  }) {
    return _then(_WorkoutFeedback(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      goalId: null == goalId
          ? _self.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int,
      completedEpochDay: null == completedEpochDay
          ? _self.completedEpochDay
          : completedEpochDay // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _self.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as WorkoutDifficulty,
      recordedAtEpochMillis: null == recordedAtEpochMillis
          ? _self.recordedAtEpochMillis
          : recordedAtEpochMillis // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Achievement {
  AchievementType get type;
  int get unlockedAtEpochMillis;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AchievementCopyWith<Achievement> get copyWith =>
      _$AchievementCopyWithImpl<Achievement>(this as Achievement, _$identity);

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Achievement &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.unlockedAtEpochMillis, unlockedAtEpochMillis) ||
                other.unlockedAtEpochMillis == unlockedAtEpochMillis));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, unlockedAtEpochMillis);

  @override
  String toString() {
    return 'Achievement(type: $type, unlockedAtEpochMillis: $unlockedAtEpochMillis)';
  }
}

/// @nodoc
abstract mixin class $AchievementCopyWith<$Res> {
  factory $AchievementCopyWith(
          Achievement value, $Res Function(Achievement) _then) =
      _$AchievementCopyWithImpl;
  @useResult
  $Res call({AchievementType type, int unlockedAtEpochMillis});
}

/// @nodoc
class _$AchievementCopyWithImpl<$Res> implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._self, this._then);

  final Achievement _self;
  final $Res Function(Achievement) _then;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? unlockedAtEpochMillis = null,
  }) {
    return _then(_self.copyWith(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as AchievementType,
      unlockedAtEpochMillis: null == unlockedAtEpochMillis
          ? _self.unlockedAtEpochMillis
          : unlockedAtEpochMillis // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [Achievement].
extension AchievementPatterns on Achievement {
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
    TResult Function(_Achievement value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Achievement() when $default != null:
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
    TResult Function(_Achievement value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Achievement():
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
    TResult? Function(_Achievement value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Achievement() when $default != null:
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
    TResult Function(AchievementType type, int unlockedAtEpochMillis)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Achievement() when $default != null:
        return $default(_that.type, _that.unlockedAtEpochMillis);
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
    TResult Function(AchievementType type, int unlockedAtEpochMillis) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Achievement():
        return $default(_that.type, _that.unlockedAtEpochMillis);
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
    TResult? Function(AchievementType type, int unlockedAtEpochMillis)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Achievement() when $default != null:
        return $default(_that.type, _that.unlockedAtEpochMillis);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Achievement implements Achievement {
  const _Achievement({required this.type, required this.unlockedAtEpochMillis});
  factory _Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  @override
  final AchievementType type;
  @override
  final int unlockedAtEpochMillis;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AchievementCopyWith<_Achievement> get copyWith =>
      __$AchievementCopyWithImpl<_Achievement>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AchievementToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Achievement &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.unlockedAtEpochMillis, unlockedAtEpochMillis) ||
                other.unlockedAtEpochMillis == unlockedAtEpochMillis));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, unlockedAtEpochMillis);

  @override
  String toString() {
    return 'Achievement(type: $type, unlockedAtEpochMillis: $unlockedAtEpochMillis)';
  }
}

/// @nodoc
abstract mixin class _$AchievementCopyWith<$Res>
    implements $AchievementCopyWith<$Res> {
  factory _$AchievementCopyWith(
          _Achievement value, $Res Function(_Achievement) _then) =
      __$AchievementCopyWithImpl;
  @override
  @useResult
  $Res call({AchievementType type, int unlockedAtEpochMillis});
}

/// @nodoc
class __$AchievementCopyWithImpl<$Res> implements _$AchievementCopyWith<$Res> {
  __$AchievementCopyWithImpl(this._self, this._then);

  final _Achievement _self;
  final $Res Function(_Achievement) _then;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? type = null,
    Object? unlockedAtEpochMillis = null,
  }) {
    return _then(_Achievement(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as AchievementType,
      unlockedAtEpochMillis: null == unlockedAtEpochMillis
          ? _self.unlockedAtEpochMillis
          : unlockedAtEpochMillis // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on

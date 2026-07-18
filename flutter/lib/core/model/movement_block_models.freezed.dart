// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movement_block_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MovementBlock {
  String get id;
  MovementBlockKind get kind;
  Set<MovementPattern> get movementPatterns;
  String get titleVi;
  List<String> get stepsVi;
  int get estimatedMinutes;

  /// Create a copy of MovementBlock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MovementBlockCopyWith<MovementBlock> get copyWith =>
      _$MovementBlockCopyWithImpl<MovementBlock>(
          this as MovementBlock, _$identity);

  /// Serializes this MovementBlock to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MovementBlock &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            const DeepCollectionEquality()
                .equals(other.movementPatterns, movementPatterns) &&
            (identical(other.titleVi, titleVi) || other.titleVi == titleVi) &&
            const DeepCollectionEquality().equals(other.stepsVi, stepsVi) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      kind,
      const DeepCollectionEquality().hash(movementPatterns),
      titleVi,
      const DeepCollectionEquality().hash(stepsVi),
      estimatedMinutes);

  @override
  String toString() {
    return 'MovementBlock(id: $id, kind: $kind, movementPatterns: $movementPatterns, titleVi: $titleVi, stepsVi: $stepsVi, estimatedMinutes: $estimatedMinutes)';
  }
}

/// @nodoc
abstract mixin class $MovementBlockCopyWith<$Res> {
  factory $MovementBlockCopyWith(
          MovementBlock value, $Res Function(MovementBlock) _then) =
      _$MovementBlockCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      MovementBlockKind kind,
      Set<MovementPattern> movementPatterns,
      String titleVi,
      List<String> stepsVi,
      int estimatedMinutes});
}

/// @nodoc
class _$MovementBlockCopyWithImpl<$Res>
    implements $MovementBlockCopyWith<$Res> {
  _$MovementBlockCopyWithImpl(this._self, this._then);

  final MovementBlock _self;
  final $Res Function(MovementBlock) _then;

  /// Create a copy of MovementBlock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? kind = null,
    Object? movementPatterns = null,
    Object? titleVi = null,
    Object? stepsVi = null,
    Object? estimatedMinutes = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      kind: null == kind
          ? _self.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as MovementBlockKind,
      movementPatterns: null == movementPatterns
          ? _self.movementPatterns
          : movementPatterns // ignore: cast_nullable_to_non_nullable
              as Set<MovementPattern>,
      titleVi: null == titleVi
          ? _self.titleVi
          : titleVi // ignore: cast_nullable_to_non_nullable
              as String,
      stepsVi: null == stepsVi
          ? _self.stepsVi
          : stepsVi // ignore: cast_nullable_to_non_nullable
              as List<String>,
      estimatedMinutes: null == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [MovementBlock].
extension MovementBlockPatterns on MovementBlock {
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
    TResult Function(_MovementBlock value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MovementBlock() when $default != null:
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
    TResult Function(_MovementBlock value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MovementBlock():
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
    TResult? Function(_MovementBlock value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MovementBlock() when $default != null:
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
            String id,
            MovementBlockKind kind,
            Set<MovementPattern> movementPatterns,
            String titleVi,
            List<String> stepsVi,
            int estimatedMinutes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MovementBlock() when $default != null:
        return $default(_that.id, _that.kind, _that.movementPatterns,
            _that.titleVi, _that.stepsVi, _that.estimatedMinutes);
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
            String id,
            MovementBlockKind kind,
            Set<MovementPattern> movementPatterns,
            String titleVi,
            List<String> stepsVi,
            int estimatedMinutes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MovementBlock():
        return $default(_that.id, _that.kind, _that.movementPatterns,
            _that.titleVi, _that.stepsVi, _that.estimatedMinutes);
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
            String id,
            MovementBlockKind kind,
            Set<MovementPattern> movementPatterns,
            String titleVi,
            List<String> stepsVi,
            int estimatedMinutes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MovementBlock() when $default != null:
        return $default(_that.id, _that.kind, _that.movementPatterns,
            _that.titleVi, _that.stepsVi, _that.estimatedMinutes);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MovementBlock implements MovementBlock {
  const _MovementBlock(
      {required this.id,
      required this.kind,
      required final Set<MovementPattern> movementPatterns,
      required this.titleVi,
      required final List<String> stepsVi,
      required this.estimatedMinutes})
      : _movementPatterns = movementPatterns,
        _stepsVi = stepsVi;
  factory _MovementBlock.fromJson(Map<String, dynamic> json) =>
      _$MovementBlockFromJson(json);

  @override
  final String id;
  @override
  final MovementBlockKind kind;
  final Set<MovementPattern> _movementPatterns;
  @override
  Set<MovementPattern> get movementPatterns {
    if (_movementPatterns is EqualUnmodifiableSetView) return _movementPatterns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_movementPatterns);
  }

  @override
  final String titleVi;
  final List<String> _stepsVi;
  @override
  List<String> get stepsVi {
    if (_stepsVi is EqualUnmodifiableListView) return _stepsVi;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stepsVi);
  }

  @override
  final int estimatedMinutes;

  /// Create a copy of MovementBlock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MovementBlockCopyWith<_MovementBlock> get copyWith =>
      __$MovementBlockCopyWithImpl<_MovementBlock>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MovementBlockToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MovementBlock &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            const DeepCollectionEquality()
                .equals(other._movementPatterns, _movementPatterns) &&
            (identical(other.titleVi, titleVi) || other.titleVi == titleVi) &&
            const DeepCollectionEquality().equals(other._stepsVi, _stepsVi) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      kind,
      const DeepCollectionEquality().hash(_movementPatterns),
      titleVi,
      const DeepCollectionEquality().hash(_stepsVi),
      estimatedMinutes);

  @override
  String toString() {
    return 'MovementBlock(id: $id, kind: $kind, movementPatterns: $movementPatterns, titleVi: $titleVi, stepsVi: $stepsVi, estimatedMinutes: $estimatedMinutes)';
  }
}

/// @nodoc
abstract mixin class _$MovementBlockCopyWith<$Res>
    implements $MovementBlockCopyWith<$Res> {
  factory _$MovementBlockCopyWith(
          _MovementBlock value, $Res Function(_MovementBlock) _then) =
      __$MovementBlockCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      MovementBlockKind kind,
      Set<MovementPattern> movementPatterns,
      String titleVi,
      List<String> stepsVi,
      int estimatedMinutes});
}

/// @nodoc
class __$MovementBlockCopyWithImpl<$Res>
    implements _$MovementBlockCopyWith<$Res> {
  __$MovementBlockCopyWithImpl(this._self, this._then);

  final _MovementBlock _self;
  final $Res Function(_MovementBlock) _then;

  /// Create a copy of MovementBlock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? kind = null,
    Object? movementPatterns = null,
    Object? titleVi = null,
    Object? stepsVi = null,
    Object? estimatedMinutes = null,
  }) {
    return _then(_MovementBlock(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      kind: null == kind
          ? _self.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as MovementBlockKind,
      movementPatterns: null == movementPatterns
          ? _self._movementPatterns
          : movementPatterns // ignore: cast_nullable_to_non_nullable
              as Set<MovementPattern>,
      titleVi: null == titleVi
          ? _self.titleVi
          : titleVi // ignore: cast_nullable_to_non_nullable
              as String,
      stepsVi: null == stepsVi
          ? _self._stepsVi
          : stepsVi // ignore: cast_nullable_to_non_nullable
              as List<String>,
      estimatedMinutes: null == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on

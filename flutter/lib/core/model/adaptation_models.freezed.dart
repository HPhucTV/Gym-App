// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adaptation_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdaptationDecision {
  AdaptationKind get kind;
  AdaptationMode get mode;
  String get reasonVi;
  String get beforeValue;
  String get afterValue;
  String get undoPayload;

  /// Create a copy of AdaptationDecision
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AdaptationDecisionCopyWith<AdaptationDecision> get copyWith =>
      _$AdaptationDecisionCopyWithImpl<AdaptationDecision>(
          this as AdaptationDecision, _$identity);

  /// Serializes this AdaptationDecision to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AdaptationDecision &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.reasonVi, reasonVi) ||
                other.reasonVi == reasonVi) &&
            (identical(other.beforeValue, beforeValue) ||
                other.beforeValue == beforeValue) &&
            (identical(other.afterValue, afterValue) ||
                other.afterValue == afterValue) &&
            (identical(other.undoPayload, undoPayload) ||
                other.undoPayload == undoPayload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, kind, mode, reasonVi, beforeValue, afterValue, undoPayload);

  @override
  String toString() {
    return 'AdaptationDecision(kind: $kind, mode: $mode, reasonVi: $reasonVi, beforeValue: $beforeValue, afterValue: $afterValue, undoPayload: $undoPayload)';
  }
}

/// @nodoc
abstract mixin class $AdaptationDecisionCopyWith<$Res> {
  factory $AdaptationDecisionCopyWith(
          AdaptationDecision value, $Res Function(AdaptationDecision) _then) =
      _$AdaptationDecisionCopyWithImpl;
  @useResult
  $Res call(
      {AdaptationKind kind,
      AdaptationMode mode,
      String reasonVi,
      String beforeValue,
      String afterValue,
      String undoPayload});
}

/// @nodoc
class _$AdaptationDecisionCopyWithImpl<$Res>
    implements $AdaptationDecisionCopyWith<$Res> {
  _$AdaptationDecisionCopyWithImpl(this._self, this._then);

  final AdaptationDecision _self;
  final $Res Function(AdaptationDecision) _then;

  /// Create a copy of AdaptationDecision
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? mode = null,
    Object? reasonVi = null,
    Object? beforeValue = null,
    Object? afterValue = null,
    Object? undoPayload = null,
  }) {
    return _then(_self.copyWith(
      kind: null == kind
          ? _self.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as AdaptationKind,
      mode: null == mode
          ? _self.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as AdaptationMode,
      reasonVi: null == reasonVi
          ? _self.reasonVi
          : reasonVi // ignore: cast_nullable_to_non_nullable
              as String,
      beforeValue: null == beforeValue
          ? _self.beforeValue
          : beforeValue // ignore: cast_nullable_to_non_nullable
              as String,
      afterValue: null == afterValue
          ? _self.afterValue
          : afterValue // ignore: cast_nullable_to_non_nullable
              as String,
      undoPayload: null == undoPayload
          ? _self.undoPayload
          : undoPayload // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [AdaptationDecision].
extension AdaptationDecisionPatterns on AdaptationDecision {
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
    TResult Function(_AdaptationDecision value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AdaptationDecision() when $default != null:
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
    TResult Function(_AdaptationDecision value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AdaptationDecision():
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
    TResult? Function(_AdaptationDecision value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AdaptationDecision() when $default != null:
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
    TResult Function(AdaptationKind kind, AdaptationMode mode, String reasonVi,
            String beforeValue, String afterValue, String undoPayload)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AdaptationDecision() when $default != null:
        return $default(_that.kind, _that.mode, _that.reasonVi,
            _that.beforeValue, _that.afterValue, _that.undoPayload);
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
    TResult Function(AdaptationKind kind, AdaptationMode mode, String reasonVi,
            String beforeValue, String afterValue, String undoPayload)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AdaptationDecision():
        return $default(_that.kind, _that.mode, _that.reasonVi,
            _that.beforeValue, _that.afterValue, _that.undoPayload);
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
    TResult? Function(AdaptationKind kind, AdaptationMode mode, String reasonVi,
            String beforeValue, String afterValue, String undoPayload)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AdaptationDecision() when $default != null:
        return $default(_that.kind, _that.mode, _that.reasonVi,
            _that.beforeValue, _that.afterValue, _that.undoPayload);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AdaptationDecision implements AdaptationDecision {
  const _AdaptationDecision(
      {required this.kind,
      required this.mode,
      required this.reasonVi,
      required this.beforeValue,
      required this.afterValue,
      required this.undoPayload});
  factory _AdaptationDecision.fromJson(Map<String, dynamic> json) =>
      _$AdaptationDecisionFromJson(json);

  @override
  final AdaptationKind kind;
  @override
  final AdaptationMode mode;
  @override
  final String reasonVi;
  @override
  final String beforeValue;
  @override
  final String afterValue;
  @override
  final String undoPayload;

  /// Create a copy of AdaptationDecision
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AdaptationDecisionCopyWith<_AdaptationDecision> get copyWith =>
      __$AdaptationDecisionCopyWithImpl<_AdaptationDecision>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AdaptationDecisionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AdaptationDecision &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.reasonVi, reasonVi) ||
                other.reasonVi == reasonVi) &&
            (identical(other.beforeValue, beforeValue) ||
                other.beforeValue == beforeValue) &&
            (identical(other.afterValue, afterValue) ||
                other.afterValue == afterValue) &&
            (identical(other.undoPayload, undoPayload) ||
                other.undoPayload == undoPayload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, kind, mode, reasonVi, beforeValue, afterValue, undoPayload);

  @override
  String toString() {
    return 'AdaptationDecision(kind: $kind, mode: $mode, reasonVi: $reasonVi, beforeValue: $beforeValue, afterValue: $afterValue, undoPayload: $undoPayload)';
  }
}

/// @nodoc
abstract mixin class _$AdaptationDecisionCopyWith<$Res>
    implements $AdaptationDecisionCopyWith<$Res> {
  factory _$AdaptationDecisionCopyWith(
          _AdaptationDecision value, $Res Function(_AdaptationDecision) _then) =
      __$AdaptationDecisionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {AdaptationKind kind,
      AdaptationMode mode,
      String reasonVi,
      String beforeValue,
      String afterValue,
      String undoPayload});
}

/// @nodoc
class __$AdaptationDecisionCopyWithImpl<$Res>
    implements _$AdaptationDecisionCopyWith<$Res> {
  __$AdaptationDecisionCopyWithImpl(this._self, this._then);

  final _AdaptationDecision _self;
  final $Res Function(_AdaptationDecision) _then;

  /// Create a copy of AdaptationDecision
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? kind = null,
    Object? mode = null,
    Object? reasonVi = null,
    Object? beforeValue = null,
    Object? afterValue = null,
    Object? undoPayload = null,
  }) {
    return _then(_AdaptationDecision(
      kind: null == kind
          ? _self.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as AdaptationKind,
      mode: null == mode
          ? _self.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as AdaptationMode,
      reasonVi: null == reasonVi
          ? _self.reasonVi
          : reasonVi // ignore: cast_nullable_to_non_nullable
              as String,
      beforeValue: null == beforeValue
          ? _self.beforeValue
          : beforeValue // ignore: cast_nullable_to_non_nullable
              as String,
      afterValue: null == afterValue
          ? _self.afterValue
          : afterValue // ignore: cast_nullable_to_non_nullable
              as String,
      undoPayload: null == undoPayload
          ? _self.undoPayload
          : undoPayload // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on

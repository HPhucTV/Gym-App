// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NutritionTargetAudit {
  double get rawBasalCalories;
  double get rawMaintenanceCalories;
  double get rawTargetCalories;
  double get rawProteinGrams;
  double get rawCarbsGrams;
  double get rawFatGrams;

  /// Create a copy of NutritionTargetAudit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NutritionTargetAuditCopyWith<NutritionTargetAudit> get copyWith =>
      _$NutritionTargetAuditCopyWithImpl<NutritionTargetAudit>(
          this as NutritionTargetAudit, _$identity);

  /// Serializes this NutritionTargetAudit to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NutritionTargetAudit &&
            (identical(other.rawBasalCalories, rawBasalCalories) ||
                other.rawBasalCalories == rawBasalCalories) &&
            (identical(other.rawMaintenanceCalories, rawMaintenanceCalories) ||
                other.rawMaintenanceCalories == rawMaintenanceCalories) &&
            (identical(other.rawTargetCalories, rawTargetCalories) ||
                other.rawTargetCalories == rawTargetCalories) &&
            (identical(other.rawProteinGrams, rawProteinGrams) ||
                other.rawProteinGrams == rawProteinGrams) &&
            (identical(other.rawCarbsGrams, rawCarbsGrams) ||
                other.rawCarbsGrams == rawCarbsGrams) &&
            (identical(other.rawFatGrams, rawFatGrams) ||
                other.rawFatGrams == rawFatGrams));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      rawBasalCalories,
      rawMaintenanceCalories,
      rawTargetCalories,
      rawProteinGrams,
      rawCarbsGrams,
      rawFatGrams);

  @override
  String toString() {
    return 'NutritionTargetAudit(rawBasalCalories: $rawBasalCalories, rawMaintenanceCalories: $rawMaintenanceCalories, rawTargetCalories: $rawTargetCalories, rawProteinGrams: $rawProteinGrams, rawCarbsGrams: $rawCarbsGrams, rawFatGrams: $rawFatGrams)';
  }
}

/// @nodoc
abstract mixin class $NutritionTargetAuditCopyWith<$Res> {
  factory $NutritionTargetAuditCopyWith(NutritionTargetAudit value,
          $Res Function(NutritionTargetAudit) _then) =
      _$NutritionTargetAuditCopyWithImpl;
  @useResult
  $Res call(
      {double rawBasalCalories,
      double rawMaintenanceCalories,
      double rawTargetCalories,
      double rawProteinGrams,
      double rawCarbsGrams,
      double rawFatGrams});
}

/// @nodoc
class _$NutritionTargetAuditCopyWithImpl<$Res>
    implements $NutritionTargetAuditCopyWith<$Res> {
  _$NutritionTargetAuditCopyWithImpl(this._self, this._then);

  final NutritionTargetAudit _self;
  final $Res Function(NutritionTargetAudit) _then;

  /// Create a copy of NutritionTargetAudit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rawBasalCalories = null,
    Object? rawMaintenanceCalories = null,
    Object? rawTargetCalories = null,
    Object? rawProteinGrams = null,
    Object? rawCarbsGrams = null,
    Object? rawFatGrams = null,
  }) {
    return _then(_self.copyWith(
      rawBasalCalories: null == rawBasalCalories
          ? _self.rawBasalCalories
          : rawBasalCalories // ignore: cast_nullable_to_non_nullable
              as double,
      rawMaintenanceCalories: null == rawMaintenanceCalories
          ? _self.rawMaintenanceCalories
          : rawMaintenanceCalories // ignore: cast_nullable_to_non_nullable
              as double,
      rawTargetCalories: null == rawTargetCalories
          ? _self.rawTargetCalories
          : rawTargetCalories // ignore: cast_nullable_to_non_nullable
              as double,
      rawProteinGrams: null == rawProteinGrams
          ? _self.rawProteinGrams
          : rawProteinGrams // ignore: cast_nullable_to_non_nullable
              as double,
      rawCarbsGrams: null == rawCarbsGrams
          ? _self.rawCarbsGrams
          : rawCarbsGrams // ignore: cast_nullable_to_non_nullable
              as double,
      rawFatGrams: null == rawFatGrams
          ? _self.rawFatGrams
          : rawFatGrams // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [NutritionTargetAudit].
extension NutritionTargetAuditPatterns on NutritionTargetAudit {
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
    TResult Function(_NutritionTargetAudit value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NutritionTargetAudit() when $default != null:
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
    TResult Function(_NutritionTargetAudit value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NutritionTargetAudit():
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
    TResult? Function(_NutritionTargetAudit value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NutritionTargetAudit() when $default != null:
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
            double rawBasalCalories,
            double rawMaintenanceCalories,
            double rawTargetCalories,
            double rawProteinGrams,
            double rawCarbsGrams,
            double rawFatGrams)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NutritionTargetAudit() when $default != null:
        return $default(
            _that.rawBasalCalories,
            _that.rawMaintenanceCalories,
            _that.rawTargetCalories,
            _that.rawProteinGrams,
            _that.rawCarbsGrams,
            _that.rawFatGrams);
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
            double rawBasalCalories,
            double rawMaintenanceCalories,
            double rawTargetCalories,
            double rawProteinGrams,
            double rawCarbsGrams,
            double rawFatGrams)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NutritionTargetAudit():
        return $default(
            _that.rawBasalCalories,
            _that.rawMaintenanceCalories,
            _that.rawTargetCalories,
            _that.rawProteinGrams,
            _that.rawCarbsGrams,
            _that.rawFatGrams);
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
            double rawBasalCalories,
            double rawMaintenanceCalories,
            double rawTargetCalories,
            double rawProteinGrams,
            double rawCarbsGrams,
            double rawFatGrams)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NutritionTargetAudit() when $default != null:
        return $default(
            _that.rawBasalCalories,
            _that.rawMaintenanceCalories,
            _that.rawTargetCalories,
            _that.rawProteinGrams,
            _that.rawCarbsGrams,
            _that.rawFatGrams);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _NutritionTargetAudit implements NutritionTargetAudit {
  const _NutritionTargetAudit(
      {required this.rawBasalCalories,
      required this.rawMaintenanceCalories,
      required this.rawTargetCalories,
      required this.rawProteinGrams,
      required this.rawCarbsGrams,
      required this.rawFatGrams});
  factory _NutritionTargetAudit.fromJson(Map<String, dynamic> json) =>
      _$NutritionTargetAuditFromJson(json);

  @override
  final double rawBasalCalories;
  @override
  final double rawMaintenanceCalories;
  @override
  final double rawTargetCalories;
  @override
  final double rawProteinGrams;
  @override
  final double rawCarbsGrams;
  @override
  final double rawFatGrams;

  /// Create a copy of NutritionTargetAudit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NutritionTargetAuditCopyWith<_NutritionTargetAudit> get copyWith =>
      __$NutritionTargetAuditCopyWithImpl<_NutritionTargetAudit>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NutritionTargetAuditToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NutritionTargetAudit &&
            (identical(other.rawBasalCalories, rawBasalCalories) ||
                other.rawBasalCalories == rawBasalCalories) &&
            (identical(other.rawMaintenanceCalories, rawMaintenanceCalories) ||
                other.rawMaintenanceCalories == rawMaintenanceCalories) &&
            (identical(other.rawTargetCalories, rawTargetCalories) ||
                other.rawTargetCalories == rawTargetCalories) &&
            (identical(other.rawProteinGrams, rawProteinGrams) ||
                other.rawProteinGrams == rawProteinGrams) &&
            (identical(other.rawCarbsGrams, rawCarbsGrams) ||
                other.rawCarbsGrams == rawCarbsGrams) &&
            (identical(other.rawFatGrams, rawFatGrams) ||
                other.rawFatGrams == rawFatGrams));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      rawBasalCalories,
      rawMaintenanceCalories,
      rawTargetCalories,
      rawProteinGrams,
      rawCarbsGrams,
      rawFatGrams);

  @override
  String toString() {
    return 'NutritionTargetAudit(rawBasalCalories: $rawBasalCalories, rawMaintenanceCalories: $rawMaintenanceCalories, rawTargetCalories: $rawTargetCalories, rawProteinGrams: $rawProteinGrams, rawCarbsGrams: $rawCarbsGrams, rawFatGrams: $rawFatGrams)';
  }
}

/// @nodoc
abstract mixin class _$NutritionTargetAuditCopyWith<$Res>
    implements $NutritionTargetAuditCopyWith<$Res> {
  factory _$NutritionTargetAuditCopyWith(_NutritionTargetAudit value,
          $Res Function(_NutritionTargetAudit) _then) =
      __$NutritionTargetAuditCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double rawBasalCalories,
      double rawMaintenanceCalories,
      double rawTargetCalories,
      double rawProteinGrams,
      double rawCarbsGrams,
      double rawFatGrams});
}

/// @nodoc
class __$NutritionTargetAuditCopyWithImpl<$Res>
    implements _$NutritionTargetAuditCopyWith<$Res> {
  __$NutritionTargetAuditCopyWithImpl(this._self, this._then);

  final _NutritionTargetAudit _self;
  final $Res Function(_NutritionTargetAudit) _then;

  /// Create a copy of NutritionTargetAudit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? rawBasalCalories = null,
    Object? rawMaintenanceCalories = null,
    Object? rawTargetCalories = null,
    Object? rawProteinGrams = null,
    Object? rawCarbsGrams = null,
    Object? rawFatGrams = null,
  }) {
    return _then(_NutritionTargetAudit(
      rawBasalCalories: null == rawBasalCalories
          ? _self.rawBasalCalories
          : rawBasalCalories // ignore: cast_nullable_to_non_nullable
              as double,
      rawMaintenanceCalories: null == rawMaintenanceCalories
          ? _self.rawMaintenanceCalories
          : rawMaintenanceCalories // ignore: cast_nullable_to_non_nullable
              as double,
      rawTargetCalories: null == rawTargetCalories
          ? _self.rawTargetCalories
          : rawTargetCalories // ignore: cast_nullable_to_non_nullable
              as double,
      rawProteinGrams: null == rawProteinGrams
          ? _self.rawProteinGrams
          : rawProteinGrams // ignore: cast_nullable_to_non_nullable
              as double,
      rawCarbsGrams: null == rawCarbsGrams
          ? _self.rawCarbsGrams
          : rawCarbsGrams // ignore: cast_nullable_to_non_nullable
              as double,
      rawFatGrams: null == rawFatGrams
          ? _self.rawFatGrams
          : rawFatGrams // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$NutritionTarget {
  int get basalCalories;
  int get maintenanceCalories;
  int get calories;
  int get proteinGrams;
  int get carbsGrams;
  int get fatGrams;
  NutritionTargetAudit get audit;

  /// Create a copy of NutritionTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NutritionTargetCopyWith<NutritionTarget> get copyWith =>
      _$NutritionTargetCopyWithImpl<NutritionTarget>(
          this as NutritionTarget, _$identity);

  /// Serializes this NutritionTarget to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NutritionTarget &&
            (identical(other.basalCalories, basalCalories) ||
                other.basalCalories == basalCalories) &&
            (identical(other.maintenanceCalories, maintenanceCalories) ||
                other.maintenanceCalories == maintenanceCalories) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.proteinGrams, proteinGrams) ||
                other.proteinGrams == proteinGrams) &&
            (identical(other.carbsGrams, carbsGrams) ||
                other.carbsGrams == carbsGrams) &&
            (identical(other.fatGrams, fatGrams) ||
                other.fatGrams == fatGrams) &&
            (identical(other.audit, audit) || other.audit == audit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, basalCalories,
      maintenanceCalories, calories, proteinGrams, carbsGrams, fatGrams, audit);

  @override
  String toString() {
    return 'NutritionTarget(basalCalories: $basalCalories, maintenanceCalories: $maintenanceCalories, calories: $calories, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, audit: $audit)';
  }
}

/// @nodoc
abstract mixin class $NutritionTargetCopyWith<$Res> {
  factory $NutritionTargetCopyWith(
          NutritionTarget value, $Res Function(NutritionTarget) _then) =
      _$NutritionTargetCopyWithImpl;
  @useResult
  $Res call(
      {int basalCalories,
      int maintenanceCalories,
      int calories,
      int proteinGrams,
      int carbsGrams,
      int fatGrams,
      NutritionTargetAudit audit});

  $NutritionTargetAuditCopyWith<$Res> get audit;
}

/// @nodoc
class _$NutritionTargetCopyWithImpl<$Res>
    implements $NutritionTargetCopyWith<$Res> {
  _$NutritionTargetCopyWithImpl(this._self, this._then);

  final NutritionTarget _self;
  final $Res Function(NutritionTarget) _then;

  /// Create a copy of NutritionTarget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? basalCalories = null,
    Object? maintenanceCalories = null,
    Object? calories = null,
    Object? proteinGrams = null,
    Object? carbsGrams = null,
    Object? fatGrams = null,
    Object? audit = null,
  }) {
    return _then(_self.copyWith(
      basalCalories: null == basalCalories
          ? _self.basalCalories
          : basalCalories // ignore: cast_nullable_to_non_nullable
              as int,
      maintenanceCalories: null == maintenanceCalories
          ? _self.maintenanceCalories
          : maintenanceCalories // ignore: cast_nullable_to_non_nullable
              as int,
      calories: null == calories
          ? _self.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      proteinGrams: null == proteinGrams
          ? _self.proteinGrams
          : proteinGrams // ignore: cast_nullable_to_non_nullable
              as int,
      carbsGrams: null == carbsGrams
          ? _self.carbsGrams
          : carbsGrams // ignore: cast_nullable_to_non_nullable
              as int,
      fatGrams: null == fatGrams
          ? _self.fatGrams
          : fatGrams // ignore: cast_nullable_to_non_nullable
              as int,
      audit: null == audit
          ? _self.audit
          : audit // ignore: cast_nullable_to_non_nullable
              as NutritionTargetAudit,
    ));
  }

  /// Create a copy of NutritionTarget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutritionTargetAuditCopyWith<$Res> get audit {
    return $NutritionTargetAuditCopyWith<$Res>(_self.audit, (value) {
      return _then(_self.copyWith(audit: value));
    });
  }
}

/// Adds pattern-matching-related methods to [NutritionTarget].
extension NutritionTargetPatterns on NutritionTarget {
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
    TResult Function(_NutritionTarget value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NutritionTarget() when $default != null:
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
    TResult Function(_NutritionTarget value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NutritionTarget():
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
    TResult? Function(_NutritionTarget value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NutritionTarget() when $default != null:
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
            int basalCalories,
            int maintenanceCalories,
            int calories,
            int proteinGrams,
            int carbsGrams,
            int fatGrams,
            NutritionTargetAudit audit)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NutritionTarget() when $default != null:
        return $default(
            _that.basalCalories,
            _that.maintenanceCalories,
            _that.calories,
            _that.proteinGrams,
            _that.carbsGrams,
            _that.fatGrams,
            _that.audit);
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
            int basalCalories,
            int maintenanceCalories,
            int calories,
            int proteinGrams,
            int carbsGrams,
            int fatGrams,
            NutritionTargetAudit audit)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NutritionTarget():
        return $default(
            _that.basalCalories,
            _that.maintenanceCalories,
            _that.calories,
            _that.proteinGrams,
            _that.carbsGrams,
            _that.fatGrams,
            _that.audit);
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
            int basalCalories,
            int maintenanceCalories,
            int calories,
            int proteinGrams,
            int carbsGrams,
            int fatGrams,
            NutritionTargetAudit audit)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NutritionTarget() when $default != null:
        return $default(
            _that.basalCalories,
            _that.maintenanceCalories,
            _that.calories,
            _that.proteinGrams,
            _that.carbsGrams,
            _that.fatGrams,
            _that.audit);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _NutritionTarget implements NutritionTarget {
  const _NutritionTarget(
      {required this.basalCalories,
      required this.maintenanceCalories,
      required this.calories,
      required this.proteinGrams,
      required this.carbsGrams,
      required this.fatGrams,
      required this.audit});
  factory _NutritionTarget.fromJson(Map<String, dynamic> json) =>
      _$NutritionTargetFromJson(json);

  @override
  final int basalCalories;
  @override
  final int maintenanceCalories;
  @override
  final int calories;
  @override
  final int proteinGrams;
  @override
  final int carbsGrams;
  @override
  final int fatGrams;
  @override
  final NutritionTargetAudit audit;

  /// Create a copy of NutritionTarget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NutritionTargetCopyWith<_NutritionTarget> get copyWith =>
      __$NutritionTargetCopyWithImpl<_NutritionTarget>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NutritionTargetToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NutritionTarget &&
            (identical(other.basalCalories, basalCalories) ||
                other.basalCalories == basalCalories) &&
            (identical(other.maintenanceCalories, maintenanceCalories) ||
                other.maintenanceCalories == maintenanceCalories) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.proteinGrams, proteinGrams) ||
                other.proteinGrams == proteinGrams) &&
            (identical(other.carbsGrams, carbsGrams) ||
                other.carbsGrams == carbsGrams) &&
            (identical(other.fatGrams, fatGrams) ||
                other.fatGrams == fatGrams) &&
            (identical(other.audit, audit) || other.audit == audit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, basalCalories,
      maintenanceCalories, calories, proteinGrams, carbsGrams, fatGrams, audit);

  @override
  String toString() {
    return 'NutritionTarget(basalCalories: $basalCalories, maintenanceCalories: $maintenanceCalories, calories: $calories, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, audit: $audit)';
  }
}

/// @nodoc
abstract mixin class _$NutritionTargetCopyWith<$Res>
    implements $NutritionTargetCopyWith<$Res> {
  factory _$NutritionTargetCopyWith(
          _NutritionTarget value, $Res Function(_NutritionTarget) _then) =
      __$NutritionTargetCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int basalCalories,
      int maintenanceCalories,
      int calories,
      int proteinGrams,
      int carbsGrams,
      int fatGrams,
      NutritionTargetAudit audit});

  @override
  $NutritionTargetAuditCopyWith<$Res> get audit;
}

/// @nodoc
class __$NutritionTargetCopyWithImpl<$Res>
    implements _$NutritionTargetCopyWith<$Res> {
  __$NutritionTargetCopyWithImpl(this._self, this._then);

  final _NutritionTarget _self;
  final $Res Function(_NutritionTarget) _then;

  /// Create a copy of NutritionTarget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? basalCalories = null,
    Object? maintenanceCalories = null,
    Object? calories = null,
    Object? proteinGrams = null,
    Object? carbsGrams = null,
    Object? fatGrams = null,
    Object? audit = null,
  }) {
    return _then(_NutritionTarget(
      basalCalories: null == basalCalories
          ? _self.basalCalories
          : basalCalories // ignore: cast_nullable_to_non_nullable
              as int,
      maintenanceCalories: null == maintenanceCalories
          ? _self.maintenanceCalories
          : maintenanceCalories // ignore: cast_nullable_to_non_nullable
              as int,
      calories: null == calories
          ? _self.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      proteinGrams: null == proteinGrams
          ? _self.proteinGrams
          : proteinGrams // ignore: cast_nullable_to_non_nullable
              as int,
      carbsGrams: null == carbsGrams
          ? _self.carbsGrams
          : carbsGrams // ignore: cast_nullable_to_non_nullable
              as int,
      fatGrams: null == fatGrams
          ? _self.fatGrams
          : fatGrams // ignore: cast_nullable_to_non_nullable
              as int,
      audit: null == audit
          ? _self.audit
          : audit // ignore: cast_nullable_to_non_nullable
              as NutritionTargetAudit,
    ));
  }

  /// Create a copy of NutritionTarget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutritionTargetAuditCopyWith<$Res> get audit {
    return $NutritionTargetAuditCopyWith<$Res>(_self.audit, (value) {
      return _then(_self.copyWith(audit: value));
    });
  }
}

/// @nodoc
mixin _$TargetTimeline {
  int get todayEpochDay;
  int get targetDateEpochDay;

  /// Create a copy of TargetTimeline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TargetTimelineCopyWith<TargetTimeline> get copyWith =>
      _$TargetTimelineCopyWithImpl<TargetTimeline>(
          this as TargetTimeline, _$identity);

  /// Serializes this TargetTimeline to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TargetTimeline &&
            (identical(other.todayEpochDay, todayEpochDay) ||
                other.todayEpochDay == todayEpochDay) &&
            (identical(other.targetDateEpochDay, targetDateEpochDay) ||
                other.targetDateEpochDay == targetDateEpochDay));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, todayEpochDay, targetDateEpochDay);

  @override
  String toString() {
    return 'TargetTimeline(todayEpochDay: $todayEpochDay, targetDateEpochDay: $targetDateEpochDay)';
  }
}

/// @nodoc
abstract mixin class $TargetTimelineCopyWith<$Res> {
  factory $TargetTimelineCopyWith(
          TargetTimeline value, $Res Function(TargetTimeline) _then) =
      _$TargetTimelineCopyWithImpl;
  @useResult
  $Res call({int todayEpochDay, int targetDateEpochDay});
}

/// @nodoc
class _$TargetTimelineCopyWithImpl<$Res>
    implements $TargetTimelineCopyWith<$Res> {
  _$TargetTimelineCopyWithImpl(this._self, this._then);

  final TargetTimeline _self;
  final $Res Function(TargetTimeline) _then;

  /// Create a copy of TargetTimeline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todayEpochDay = null,
    Object? targetDateEpochDay = null,
  }) {
    return _then(_self.copyWith(
      todayEpochDay: null == todayEpochDay
          ? _self.todayEpochDay
          : todayEpochDay // ignore: cast_nullable_to_non_nullable
              as int,
      targetDateEpochDay: null == targetDateEpochDay
          ? _self.targetDateEpochDay
          : targetDateEpochDay // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [TargetTimeline].
extension TargetTimelinePatterns on TargetTimeline {
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
    TResult Function(_TargetTimeline value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TargetTimeline() when $default != null:
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
    TResult Function(_TargetTimeline value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TargetTimeline():
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
    TResult? Function(_TargetTimeline value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TargetTimeline() when $default != null:
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
    TResult Function(int todayEpochDay, int targetDateEpochDay)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TargetTimeline() when $default != null:
        return $default(_that.todayEpochDay, _that.targetDateEpochDay);
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
    TResult Function(int todayEpochDay, int targetDateEpochDay) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TargetTimeline():
        return $default(_that.todayEpochDay, _that.targetDateEpochDay);
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
    TResult? Function(int todayEpochDay, int targetDateEpochDay)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TargetTimeline() when $default != null:
        return $default(_that.todayEpochDay, _that.targetDateEpochDay);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TargetTimeline implements TargetTimeline {
  const _TargetTimeline(
      {required this.todayEpochDay, required this.targetDateEpochDay});
  factory _TargetTimeline.fromJson(Map<String, dynamic> json) =>
      _$TargetTimelineFromJson(json);

  @override
  final int todayEpochDay;
  @override
  final int targetDateEpochDay;

  /// Create a copy of TargetTimeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TargetTimelineCopyWith<_TargetTimeline> get copyWith =>
      __$TargetTimelineCopyWithImpl<_TargetTimeline>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TargetTimelineToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TargetTimeline &&
            (identical(other.todayEpochDay, todayEpochDay) ||
                other.todayEpochDay == todayEpochDay) &&
            (identical(other.targetDateEpochDay, targetDateEpochDay) ||
                other.targetDateEpochDay == targetDateEpochDay));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, todayEpochDay, targetDateEpochDay);

  @override
  String toString() {
    return 'TargetTimeline(todayEpochDay: $todayEpochDay, targetDateEpochDay: $targetDateEpochDay)';
  }
}

/// @nodoc
abstract mixin class _$TargetTimelineCopyWith<$Res>
    implements $TargetTimelineCopyWith<$Res> {
  factory _$TargetTimelineCopyWith(
          _TargetTimeline value, $Res Function(_TargetTimeline) _then) =
      __$TargetTimelineCopyWithImpl;
  @override
  @useResult
  $Res call({int todayEpochDay, int targetDateEpochDay});
}

/// @nodoc
class __$TargetTimelineCopyWithImpl<$Res>
    implements _$TargetTimelineCopyWith<$Res> {
  __$TargetTimelineCopyWithImpl(this._self, this._then);

  final _TargetTimeline _self;
  final $Res Function(_TargetTimeline) _then;

  /// Create a copy of TargetTimeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? todayEpochDay = null,
    Object? targetDateEpochDay = null,
  }) {
    return _then(_TargetTimeline(
      todayEpochDay: null == todayEpochDay
          ? _self.todayEpochDay
          : todayEpochDay // ignore: cast_nullable_to_non_nullable
              as int,
      targetDateEpochDay: null == targetDateEpochDay
          ? _self.targetDateEpochDay
          : targetDateEpochDay // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

CalculationResult _$CalculationResultFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'target':
      return _CalculationResultTarget.fromJson(json);
    case 'needsProfessionalReview':
      return _CalculationResultNeedsProfessionalReview.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'CalculationResult',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$CalculationResult {
  /// Serializes this CalculationResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CalculationResult);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CalculationResult()';
  }
}

/// @nodoc
class $CalculationResultCopyWith<$Res> {
  $CalculationResultCopyWith(
      CalculationResult _, $Res Function(CalculationResult) __);
}

/// Adds pattern-matching-related methods to [CalculationResult].
extension CalculationResultPatterns on CalculationResult {
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
    TResult Function(_CalculationResultTarget value)? target,
    TResult Function(_CalculationResultNeedsProfessionalReview value)?
        needsProfessionalReview,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CalculationResultTarget() when target != null:
        return target(_that);
      case _CalculationResultNeedsProfessionalReview()
          when needsProfessionalReview != null:
        return needsProfessionalReview(_that);
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
    required TResult Function(_CalculationResultTarget value) target,
    required TResult Function(_CalculationResultNeedsProfessionalReview value)
        needsProfessionalReview,
  }) {
    final _that = this;
    switch (_that) {
      case _CalculationResultTarget():
        return target(_that);
      case _CalculationResultNeedsProfessionalReview():
        return needsProfessionalReview(_that);
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
    TResult? Function(_CalculationResultTarget value)? target,
    TResult? Function(_CalculationResultNeedsProfessionalReview value)?
        needsProfessionalReview,
  }) {
    final _that = this;
    switch (_that) {
      case _CalculationResultTarget() when target != null:
        return target(_that);
      case _CalculationResultNeedsProfessionalReview()
          when needsProfessionalReview != null:
        return needsProfessionalReview(_that);
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
    TResult Function(NutritionTarget value)? target,
    TResult Function(String reason)? needsProfessionalReview,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CalculationResultTarget() when target != null:
        return target(_that.value);
      case _CalculationResultNeedsProfessionalReview()
          when needsProfessionalReview != null:
        return needsProfessionalReview(_that.reason);
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
    required TResult Function(NutritionTarget value) target,
    required TResult Function(String reason) needsProfessionalReview,
  }) {
    final _that = this;
    switch (_that) {
      case _CalculationResultTarget():
        return target(_that.value);
      case _CalculationResultNeedsProfessionalReview():
        return needsProfessionalReview(_that.reason);
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
    TResult? Function(NutritionTarget value)? target,
    TResult? Function(String reason)? needsProfessionalReview,
  }) {
    final _that = this;
    switch (_that) {
      case _CalculationResultTarget() when target != null:
        return target(_that.value);
      case _CalculationResultNeedsProfessionalReview()
          when needsProfessionalReview != null:
        return needsProfessionalReview(_that.reason);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CalculationResultTarget implements CalculationResult {
  const _CalculationResultTarget(this.value, {final String? $type})
      : $type = $type ?? 'target';
  factory _CalculationResultTarget.fromJson(Map<String, dynamic> json) =>
      _$CalculationResultTargetFromJson(json);

  final NutritionTarget value;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of CalculationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CalculationResultTargetCopyWith<_CalculationResultTarget> get copyWith =>
      __$CalculationResultTargetCopyWithImpl<_CalculationResultTarget>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CalculationResultTargetToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CalculationResultTarget &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() {
    return 'CalculationResult.target(value: $value)';
  }
}

/// @nodoc
abstract mixin class _$CalculationResultTargetCopyWith<$Res>
    implements $CalculationResultCopyWith<$Res> {
  factory _$CalculationResultTargetCopyWith(_CalculationResultTarget value,
          $Res Function(_CalculationResultTarget) _then) =
      __$CalculationResultTargetCopyWithImpl;
  @useResult
  $Res call({NutritionTarget value});

  $NutritionTargetCopyWith<$Res> get value;
}

/// @nodoc
class __$CalculationResultTargetCopyWithImpl<$Res>
    implements _$CalculationResultTargetCopyWith<$Res> {
  __$CalculationResultTargetCopyWithImpl(this._self, this._then);

  final _CalculationResultTarget _self;
  final $Res Function(_CalculationResultTarget) _then;

  /// Create a copy of CalculationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? value = null,
  }) {
    return _then(_CalculationResultTarget(
      null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as NutritionTarget,
    ));
  }

  /// Create a copy of CalculationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutritionTargetCopyWith<$Res> get value {
    return $NutritionTargetCopyWith<$Res>(_self.value, (value) {
      return _then(_self.copyWith(value: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _CalculationResultNeedsProfessionalReview implements CalculationResult {
  const _CalculationResultNeedsProfessionalReview(this.reason,
      {final String? $type})
      : $type = $type ?? 'needsProfessionalReview';
  factory _CalculationResultNeedsProfessionalReview.fromJson(
          Map<String, dynamic> json) =>
      _$CalculationResultNeedsProfessionalReviewFromJson(json);

  final String reason;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of CalculationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CalculationResultNeedsProfessionalReviewCopyWith<
          _CalculationResultNeedsProfessionalReview>
      get copyWith => __$CalculationResultNeedsProfessionalReviewCopyWithImpl<
          _CalculationResultNeedsProfessionalReview>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CalculationResultNeedsProfessionalReviewToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CalculationResultNeedsProfessionalReview &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, reason);

  @override
  String toString() {
    return 'CalculationResult.needsProfessionalReview(reason: $reason)';
  }
}

/// @nodoc
abstract mixin class _$CalculationResultNeedsProfessionalReviewCopyWith<$Res>
    implements $CalculationResultCopyWith<$Res> {
  factory _$CalculationResultNeedsProfessionalReviewCopyWith(
          _CalculationResultNeedsProfessionalReview value,
          $Res Function(_CalculationResultNeedsProfessionalReview) _then) =
      __$CalculationResultNeedsProfessionalReviewCopyWithImpl;
  @useResult
  $Res call({String reason});
}

/// @nodoc
class __$CalculationResultNeedsProfessionalReviewCopyWithImpl<$Res>
    implements _$CalculationResultNeedsProfessionalReviewCopyWith<$Res> {
  __$CalculationResultNeedsProfessionalReviewCopyWithImpl(
      this._self, this._then);

  final _CalculationResultNeedsProfessionalReview _self;
  final $Res Function(_CalculationResultNeedsProfessionalReview) _then;

  /// Create a copy of CalculationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? reason = null,
  }) {
    return _then(_CalculationResultNeedsProfessionalReview(
      null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$Nutrients {
  int get calories;
  int get proteinGrams;
  int get carbsGrams;
  int get fatGrams;
  int get fiberGrams;

  /// Create a copy of Nutrients
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NutrientsCopyWith<Nutrients> get copyWith =>
      _$NutrientsCopyWithImpl<Nutrients>(this as Nutrients, _$identity);

  /// Serializes this Nutrients to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Nutrients &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.proteinGrams, proteinGrams) ||
                other.proteinGrams == proteinGrams) &&
            (identical(other.carbsGrams, carbsGrams) ||
                other.carbsGrams == carbsGrams) &&
            (identical(other.fatGrams, fatGrams) ||
                other.fatGrams == fatGrams) &&
            (identical(other.fiberGrams, fiberGrams) ||
                other.fiberGrams == fiberGrams));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, calories, proteinGrams, carbsGrams, fatGrams, fiberGrams);

  @override
  String toString() {
    return 'Nutrients(calories: $calories, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, fiberGrams: $fiberGrams)';
  }
}

/// @nodoc
abstract mixin class $NutrientsCopyWith<$Res> {
  factory $NutrientsCopyWith(Nutrients value, $Res Function(Nutrients) _then) =
      _$NutrientsCopyWithImpl;
  @useResult
  $Res call(
      {int calories,
      int proteinGrams,
      int carbsGrams,
      int fatGrams,
      int fiberGrams});
}

/// @nodoc
class _$NutrientsCopyWithImpl<$Res> implements $NutrientsCopyWith<$Res> {
  _$NutrientsCopyWithImpl(this._self, this._then);

  final Nutrients _self;
  final $Res Function(Nutrients) _then;

  /// Create a copy of Nutrients
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calories = null,
    Object? proteinGrams = null,
    Object? carbsGrams = null,
    Object? fatGrams = null,
    Object? fiberGrams = null,
  }) {
    return _then(_self.copyWith(
      calories: null == calories
          ? _self.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      proteinGrams: null == proteinGrams
          ? _self.proteinGrams
          : proteinGrams // ignore: cast_nullable_to_non_nullable
              as int,
      carbsGrams: null == carbsGrams
          ? _self.carbsGrams
          : carbsGrams // ignore: cast_nullable_to_non_nullable
              as int,
      fatGrams: null == fatGrams
          ? _self.fatGrams
          : fatGrams // ignore: cast_nullable_to_non_nullable
              as int,
      fiberGrams: null == fiberGrams
          ? _self.fiberGrams
          : fiberGrams // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [Nutrients].
extension NutrientsPatterns on Nutrients {
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
    TResult Function(_Nutrients value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Nutrients() when $default != null:
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
    TResult Function(_Nutrients value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Nutrients():
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
    TResult? Function(_Nutrients value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Nutrients() when $default != null:
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
    TResult Function(int calories, int proteinGrams, int carbsGrams,
            int fatGrams, int fiberGrams)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Nutrients() when $default != null:
        return $default(_that.calories, _that.proteinGrams, _that.carbsGrams,
            _that.fatGrams, _that.fiberGrams);
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
    TResult Function(int calories, int proteinGrams, int carbsGrams,
            int fatGrams, int fiberGrams)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Nutrients():
        return $default(_that.calories, _that.proteinGrams, _that.carbsGrams,
            _that.fatGrams, _that.fiberGrams);
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
    TResult? Function(int calories, int proteinGrams, int carbsGrams,
            int fatGrams, int fiberGrams)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Nutrients() when $default != null:
        return $default(_that.calories, _that.proteinGrams, _that.carbsGrams,
            _that.fatGrams, _that.fiberGrams);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Nutrients implements Nutrients {
  const _Nutrients(
      {this.calories = 0,
      this.proteinGrams = 0,
      this.carbsGrams = 0,
      this.fatGrams = 0,
      this.fiberGrams = 0});
  factory _Nutrients.fromJson(Map<String, dynamic> json) =>
      _$NutrientsFromJson(json);

  @override
  @JsonKey()
  final int calories;
  @override
  @JsonKey()
  final int proteinGrams;
  @override
  @JsonKey()
  final int carbsGrams;
  @override
  @JsonKey()
  final int fatGrams;
  @override
  @JsonKey()
  final int fiberGrams;

  /// Create a copy of Nutrients
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NutrientsCopyWith<_Nutrients> get copyWith =>
      __$NutrientsCopyWithImpl<_Nutrients>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NutrientsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Nutrients &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.proteinGrams, proteinGrams) ||
                other.proteinGrams == proteinGrams) &&
            (identical(other.carbsGrams, carbsGrams) ||
                other.carbsGrams == carbsGrams) &&
            (identical(other.fatGrams, fatGrams) ||
                other.fatGrams == fatGrams) &&
            (identical(other.fiberGrams, fiberGrams) ||
                other.fiberGrams == fiberGrams));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, calories, proteinGrams, carbsGrams, fatGrams, fiberGrams);

  @override
  String toString() {
    return 'Nutrients(calories: $calories, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, fiberGrams: $fiberGrams)';
  }
}

/// @nodoc
abstract mixin class _$NutrientsCopyWith<$Res>
    implements $NutrientsCopyWith<$Res> {
  factory _$NutrientsCopyWith(
          _Nutrients value, $Res Function(_Nutrients) _then) =
      __$NutrientsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int calories,
      int proteinGrams,
      int carbsGrams,
      int fatGrams,
      int fiberGrams});
}

/// @nodoc
class __$NutrientsCopyWithImpl<$Res> implements _$NutrientsCopyWith<$Res> {
  __$NutrientsCopyWithImpl(this._self, this._then);

  final _Nutrients _self;
  final $Res Function(_Nutrients) _then;

  /// Create a copy of Nutrients
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? calories = null,
    Object? proteinGrams = null,
    Object? carbsGrams = null,
    Object? fatGrams = null,
    Object? fiberGrams = null,
  }) {
    return _then(_Nutrients(
      calories: null == calories
          ? _self.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      proteinGrams: null == proteinGrams
          ? _self.proteinGrams
          : proteinGrams // ignore: cast_nullable_to_non_nullable
              as int,
      carbsGrams: null == carbsGrams
          ? _self.carbsGrams
          : carbsGrams // ignore: cast_nullable_to_non_nullable
              as int,
      fatGrams: null == fatGrams
          ? _self.fatGrams
          : fatGrams // ignore: cast_nullable_to_non_nullable
              as int,
      fiberGrams: null == fiberGrams
          ? _self.fiberGrams
          : fiberGrams // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$NutritionDay {
  int get epochDay;
  Nutrients get consumed;
  NutritionTarget? get target;
  int get waterIntakeMl;

  /// Create a copy of NutritionDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NutritionDayCopyWith<NutritionDay> get copyWith =>
      _$NutritionDayCopyWithImpl<NutritionDay>(
          this as NutritionDay, _$identity);

  /// Serializes this NutritionDay to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NutritionDay &&
            (identical(other.epochDay, epochDay) ||
                other.epochDay == epochDay) &&
            (identical(other.consumed, consumed) ||
                other.consumed == consumed) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.waterIntakeMl, waterIntakeMl) ||
                other.waterIntakeMl == waterIntakeMl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, epochDay, consumed, target, waterIntakeMl);

  @override
  String toString() {
    return 'NutritionDay(epochDay: $epochDay, consumed: $consumed, target: $target, waterIntakeMl: $waterIntakeMl)';
  }
}

/// @nodoc
abstract mixin class $NutritionDayCopyWith<$Res> {
  factory $NutritionDayCopyWith(
          NutritionDay value, $Res Function(NutritionDay) _then) =
      _$NutritionDayCopyWithImpl;
  @useResult
  $Res call(
      {int epochDay,
      Nutrients consumed,
      NutritionTarget? target,
      int waterIntakeMl});

  $NutrientsCopyWith<$Res> get consumed;
  $NutritionTargetCopyWith<$Res>? get target;
}

/// @nodoc
class _$NutritionDayCopyWithImpl<$Res> implements $NutritionDayCopyWith<$Res> {
  _$NutritionDayCopyWithImpl(this._self, this._then);

  final NutritionDay _self;
  final $Res Function(NutritionDay) _then;

  /// Create a copy of NutritionDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? epochDay = null,
    Object? consumed = null,
    Object? target = freezed,
    Object? waterIntakeMl = null,
  }) {
    return _then(_self.copyWith(
      epochDay: null == epochDay
          ? _self.epochDay
          : epochDay // ignore: cast_nullable_to_non_nullable
              as int,
      consumed: null == consumed
          ? _self.consumed
          : consumed // ignore: cast_nullable_to_non_nullable
              as Nutrients,
      target: freezed == target
          ? _self.target
          : target // ignore: cast_nullable_to_non_nullable
              as NutritionTarget?,
      waterIntakeMl: null == waterIntakeMl
          ? _self.waterIntakeMl
          : waterIntakeMl // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of NutritionDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutrientsCopyWith<$Res> get consumed {
    return $NutrientsCopyWith<$Res>(_self.consumed, (value) {
      return _then(_self.copyWith(consumed: value));
    });
  }

  /// Create a copy of NutritionDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutritionTargetCopyWith<$Res>? get target {
    if (_self.target == null) {
      return null;
    }

    return $NutritionTargetCopyWith<$Res>(_self.target!, (value) {
      return _then(_self.copyWith(target: value));
    });
  }
}

/// Adds pattern-matching-related methods to [NutritionDay].
extension NutritionDayPatterns on NutritionDay {
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
    TResult Function(_NutritionDay value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NutritionDay() when $default != null:
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
    TResult Function(_NutritionDay value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NutritionDay():
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
    TResult? Function(_NutritionDay value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NutritionDay() when $default != null:
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
    TResult Function(int epochDay, Nutrients consumed, NutritionTarget? target,
            int waterIntakeMl)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NutritionDay() when $default != null:
        return $default(
            _that.epochDay, _that.consumed, _that.target, _that.waterIntakeMl);
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
    TResult Function(int epochDay, Nutrients consumed, NutritionTarget? target,
            int waterIntakeMl)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NutritionDay():
        return $default(
            _that.epochDay, _that.consumed, _that.target, _that.waterIntakeMl);
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
    TResult? Function(int epochDay, Nutrients consumed, NutritionTarget? target,
            int waterIntakeMl)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NutritionDay() when $default != null:
        return $default(
            _that.epochDay, _that.consumed, _that.target, _that.waterIntakeMl);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _NutritionDay implements NutritionDay {
  const _NutritionDay(
      {required this.epochDay,
      required this.consumed,
      this.target,
      this.waterIntakeMl = 0});
  factory _NutritionDay.fromJson(Map<String, dynamic> json) =>
      _$NutritionDayFromJson(json);

  @override
  final int epochDay;
  @override
  final Nutrients consumed;
  @override
  final NutritionTarget? target;
  @override
  @JsonKey()
  final int waterIntakeMl;

  /// Create a copy of NutritionDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NutritionDayCopyWith<_NutritionDay> get copyWith =>
      __$NutritionDayCopyWithImpl<_NutritionDay>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NutritionDayToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NutritionDay &&
            (identical(other.epochDay, epochDay) ||
                other.epochDay == epochDay) &&
            (identical(other.consumed, consumed) ||
                other.consumed == consumed) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.waterIntakeMl, waterIntakeMl) ||
                other.waterIntakeMl == waterIntakeMl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, epochDay, consumed, target, waterIntakeMl);

  @override
  String toString() {
    return 'NutritionDay(epochDay: $epochDay, consumed: $consumed, target: $target, waterIntakeMl: $waterIntakeMl)';
  }
}

/// @nodoc
abstract mixin class _$NutritionDayCopyWith<$Res>
    implements $NutritionDayCopyWith<$Res> {
  factory _$NutritionDayCopyWith(
          _NutritionDay value, $Res Function(_NutritionDay) _then) =
      __$NutritionDayCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int epochDay,
      Nutrients consumed,
      NutritionTarget? target,
      int waterIntakeMl});

  @override
  $NutrientsCopyWith<$Res> get consumed;
  @override
  $NutritionTargetCopyWith<$Res>? get target;
}

/// @nodoc
class __$NutritionDayCopyWithImpl<$Res>
    implements _$NutritionDayCopyWith<$Res> {
  __$NutritionDayCopyWithImpl(this._self, this._then);

  final _NutritionDay _self;
  final $Res Function(_NutritionDay) _then;

  /// Create a copy of NutritionDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? epochDay = null,
    Object? consumed = null,
    Object? target = freezed,
    Object? waterIntakeMl = null,
  }) {
    return _then(_NutritionDay(
      epochDay: null == epochDay
          ? _self.epochDay
          : epochDay // ignore: cast_nullable_to_non_nullable
              as int,
      consumed: null == consumed
          ? _self.consumed
          : consumed // ignore: cast_nullable_to_non_nullable
              as Nutrients,
      target: freezed == target
          ? _self.target
          : target // ignore: cast_nullable_to_non_nullable
              as NutritionTarget?,
      waterIntakeMl: null == waterIntakeMl
          ? _self.waterIntakeMl
          : waterIntakeMl // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of NutritionDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutrientsCopyWith<$Res> get consumed {
    return $NutrientsCopyWith<$Res>(_self.consumed, (value) {
      return _then(_self.copyWith(consumed: value));
    });
  }

  /// Create a copy of NutritionDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutritionTargetCopyWith<$Res>? get target {
    if (_self.target == null) {
      return null;
    }

    return $NutritionTargetCopyWith<$Res>(_self.target!, (value) {
      return _then(_self.copyWith(target: value));
    });
  }
}

/// @nodoc
mixin _$MealTemplate {
  int get id;
  String get nameVi;
  Nutrients get nutrients;
  int get updatedAtEpochMillis;

  /// Create a copy of MealTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MealTemplateCopyWith<MealTemplate> get copyWith =>
      _$MealTemplateCopyWithImpl<MealTemplate>(
          this as MealTemplate, _$identity);

  /// Serializes this MealTemplate to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MealTemplate &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameVi, nameVi) || other.nameVi == nameVi) &&
            (identical(other.nutrients, nutrients) ||
                other.nutrients == nutrients) &&
            (identical(other.updatedAtEpochMillis, updatedAtEpochMillis) ||
                other.updatedAtEpochMillis == updatedAtEpochMillis));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nameVi, nutrients, updatedAtEpochMillis);

  @override
  String toString() {
    return 'MealTemplate(id: $id, nameVi: $nameVi, nutrients: $nutrients, updatedAtEpochMillis: $updatedAtEpochMillis)';
  }
}

/// @nodoc
abstract mixin class $MealTemplateCopyWith<$Res> {
  factory $MealTemplateCopyWith(
          MealTemplate value, $Res Function(MealTemplate) _then) =
      _$MealTemplateCopyWithImpl;
  @useResult
  $Res call(
      {int id, String nameVi, Nutrients nutrients, int updatedAtEpochMillis});

  $NutrientsCopyWith<$Res> get nutrients;
}

/// @nodoc
class _$MealTemplateCopyWithImpl<$Res> implements $MealTemplateCopyWith<$Res> {
  _$MealTemplateCopyWithImpl(this._self, this._then);

  final MealTemplate _self;
  final $Res Function(MealTemplate) _then;

  /// Create a copy of MealTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameVi = null,
    Object? nutrients = null,
    Object? updatedAtEpochMillis = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameVi: null == nameVi
          ? _self.nameVi
          : nameVi // ignore: cast_nullable_to_non_nullable
              as String,
      nutrients: null == nutrients
          ? _self.nutrients
          : nutrients // ignore: cast_nullable_to_non_nullable
              as Nutrients,
      updatedAtEpochMillis: null == updatedAtEpochMillis
          ? _self.updatedAtEpochMillis
          : updatedAtEpochMillis // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of MealTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutrientsCopyWith<$Res> get nutrients {
    return $NutrientsCopyWith<$Res>(_self.nutrients, (value) {
      return _then(_self.copyWith(nutrients: value));
    });
  }
}

/// Adds pattern-matching-related methods to [MealTemplate].
extension MealTemplatePatterns on MealTemplate {
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
    TResult Function(_MealTemplate value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MealTemplate() when $default != null:
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
    TResult Function(_MealTemplate value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MealTemplate():
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
    TResult? Function(_MealTemplate value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MealTemplate() when $default != null:
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
    TResult Function(int id, String nameVi, Nutrients nutrients,
            int updatedAtEpochMillis)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MealTemplate() when $default != null:
        return $default(_that.id, _that.nameVi, _that.nutrients,
            _that.updatedAtEpochMillis);
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
    TResult Function(int id, String nameVi, Nutrients nutrients,
            int updatedAtEpochMillis)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MealTemplate():
        return $default(_that.id, _that.nameVi, _that.nutrients,
            _that.updatedAtEpochMillis);
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
    TResult? Function(int id, String nameVi, Nutrients nutrients,
            int updatedAtEpochMillis)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MealTemplate() when $default != null:
        return $default(_that.id, _that.nameVi, _that.nutrients,
            _that.updatedAtEpochMillis);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MealTemplate implements MealTemplate {
  const _MealTemplate(
      {required this.id,
      required this.nameVi,
      required this.nutrients,
      required this.updatedAtEpochMillis});
  factory _MealTemplate.fromJson(Map<String, dynamic> json) =>
      _$MealTemplateFromJson(json);

  @override
  final int id;
  @override
  final String nameVi;
  @override
  final Nutrients nutrients;
  @override
  final int updatedAtEpochMillis;

  /// Create a copy of MealTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MealTemplateCopyWith<_MealTemplate> get copyWith =>
      __$MealTemplateCopyWithImpl<_MealTemplate>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MealTemplateToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MealTemplate &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameVi, nameVi) || other.nameVi == nameVi) &&
            (identical(other.nutrients, nutrients) ||
                other.nutrients == nutrients) &&
            (identical(other.updatedAtEpochMillis, updatedAtEpochMillis) ||
                other.updatedAtEpochMillis == updatedAtEpochMillis));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nameVi, nutrients, updatedAtEpochMillis);

  @override
  String toString() {
    return 'MealTemplate(id: $id, nameVi: $nameVi, nutrients: $nutrients, updatedAtEpochMillis: $updatedAtEpochMillis)';
  }
}

/// @nodoc
abstract mixin class _$MealTemplateCopyWith<$Res>
    implements $MealTemplateCopyWith<$Res> {
  factory _$MealTemplateCopyWith(
          _MealTemplate value, $Res Function(_MealTemplate) _then) =
      __$MealTemplateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id, String nameVi, Nutrients nutrients, int updatedAtEpochMillis});

  @override
  $NutrientsCopyWith<$Res> get nutrients;
}

/// @nodoc
class __$MealTemplateCopyWithImpl<$Res>
    implements _$MealTemplateCopyWith<$Res> {
  __$MealTemplateCopyWithImpl(this._self, this._then);

  final _MealTemplate _self;
  final $Res Function(_MealTemplate) _then;

  /// Create a copy of MealTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? nameVi = null,
    Object? nutrients = null,
    Object? updatedAtEpochMillis = null,
  }) {
    return _then(_MealTemplate(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameVi: null == nameVi
          ? _self.nameVi
          : nameVi // ignore: cast_nullable_to_non_nullable
              as String,
      nutrients: null == nutrients
          ? _self.nutrients
          : nutrients // ignore: cast_nullable_to_non_nullable
              as Nutrients,
      updatedAtEpochMillis: null == updatedAtEpochMillis
          ? _self.updatedAtEpochMillis
          : updatedAtEpochMillis // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of MealTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutrientsCopyWith<$Res> get nutrients {
    return $NutrientsCopyWith<$Res>(_self.nutrients, (value) {
      return _then(_self.copyWith(nutrients: value));
    });
  }
}

/// @nodoc
mixin _$FoodCatalogItem {
  int get id;
  String get name;
  double get gramsPerServing;
  double get caloriesPerServing;
  double get fatPerServing;
  double get carbsPerServing;
  double get proteinPerServing;
  double get potassiumMg;
  double get sodiumMg;
  double get cholesterolMg;
  double get fiberPerServing;
  String get importBatchId;
  bool get isFavorite;

  /// Create a copy of FoodCatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FoodCatalogItemCopyWith<FoodCatalogItem> get copyWith =>
      _$FoodCatalogItemCopyWithImpl<FoodCatalogItem>(
          this as FoodCatalogItem, _$identity);

  /// Serializes this FoodCatalogItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FoodCatalogItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.gramsPerServing, gramsPerServing) ||
                other.gramsPerServing == gramsPerServing) &&
            (identical(other.caloriesPerServing, caloriesPerServing) ||
                other.caloriesPerServing == caloriesPerServing) &&
            (identical(other.fatPerServing, fatPerServing) ||
                other.fatPerServing == fatPerServing) &&
            (identical(other.carbsPerServing, carbsPerServing) ||
                other.carbsPerServing == carbsPerServing) &&
            (identical(other.proteinPerServing, proteinPerServing) ||
                other.proteinPerServing == proteinPerServing) &&
            (identical(other.potassiumMg, potassiumMg) ||
                other.potassiumMg == potassiumMg) &&
            (identical(other.sodiumMg, sodiumMg) ||
                other.sodiumMg == sodiumMg) &&
            (identical(other.cholesterolMg, cholesterolMg) ||
                other.cholesterolMg == cholesterolMg) &&
            (identical(other.fiberPerServing, fiberPerServing) ||
                other.fiberPerServing == fiberPerServing) &&
            (identical(other.importBatchId, importBatchId) ||
                other.importBatchId == importBatchId) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      gramsPerServing,
      caloriesPerServing,
      fatPerServing,
      carbsPerServing,
      proteinPerServing,
      potassiumMg,
      sodiumMg,
      cholesterolMg,
      fiberPerServing,
      importBatchId,
      isFavorite);

  @override
  String toString() {
    return 'FoodCatalogItem(id: $id, name: $name, gramsPerServing: $gramsPerServing, caloriesPerServing: $caloriesPerServing, fatPerServing: $fatPerServing, carbsPerServing: $carbsPerServing, proteinPerServing: $proteinPerServing, potassiumMg: $potassiumMg, sodiumMg: $sodiumMg, cholesterolMg: $cholesterolMg, fiberPerServing: $fiberPerServing, importBatchId: $importBatchId, isFavorite: $isFavorite)';
  }
}

/// @nodoc
abstract mixin class $FoodCatalogItemCopyWith<$Res> {
  factory $FoodCatalogItemCopyWith(
          FoodCatalogItem value, $Res Function(FoodCatalogItem) _then) =
      _$FoodCatalogItemCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String name,
      double gramsPerServing,
      double caloriesPerServing,
      double fatPerServing,
      double carbsPerServing,
      double proteinPerServing,
      double potassiumMg,
      double sodiumMg,
      double cholesterolMg,
      double fiberPerServing,
      String importBatchId,
      bool isFavorite});
}

/// @nodoc
class _$FoodCatalogItemCopyWithImpl<$Res>
    implements $FoodCatalogItemCopyWith<$Res> {
  _$FoodCatalogItemCopyWithImpl(this._self, this._then);

  final FoodCatalogItem _self;
  final $Res Function(FoodCatalogItem) _then;

  /// Create a copy of FoodCatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? gramsPerServing = null,
    Object? caloriesPerServing = null,
    Object? fatPerServing = null,
    Object? carbsPerServing = null,
    Object? proteinPerServing = null,
    Object? potassiumMg = null,
    Object? sodiumMg = null,
    Object? cholesterolMg = null,
    Object? fiberPerServing = null,
    Object? importBatchId = null,
    Object? isFavorite = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      gramsPerServing: null == gramsPerServing
          ? _self.gramsPerServing
          : gramsPerServing // ignore: cast_nullable_to_non_nullable
              as double,
      caloriesPerServing: null == caloriesPerServing
          ? _self.caloriesPerServing
          : caloriesPerServing // ignore: cast_nullable_to_non_nullable
              as double,
      fatPerServing: null == fatPerServing
          ? _self.fatPerServing
          : fatPerServing // ignore: cast_nullable_to_non_nullable
              as double,
      carbsPerServing: null == carbsPerServing
          ? _self.carbsPerServing
          : carbsPerServing // ignore: cast_nullable_to_non_nullable
              as double,
      proteinPerServing: null == proteinPerServing
          ? _self.proteinPerServing
          : proteinPerServing // ignore: cast_nullable_to_non_nullable
              as double,
      potassiumMg: null == potassiumMg
          ? _self.potassiumMg
          : potassiumMg // ignore: cast_nullable_to_non_nullable
              as double,
      sodiumMg: null == sodiumMg
          ? _self.sodiumMg
          : sodiumMg // ignore: cast_nullable_to_non_nullable
              as double,
      cholesterolMg: null == cholesterolMg
          ? _self.cholesterolMg
          : cholesterolMg // ignore: cast_nullable_to_non_nullable
              as double,
      fiberPerServing: null == fiberPerServing
          ? _self.fiberPerServing
          : fiberPerServing // ignore: cast_nullable_to_non_nullable
              as double,
      importBatchId: null == importBatchId
          ? _self.importBatchId
          : importBatchId // ignore: cast_nullable_to_non_nullable
              as String,
      isFavorite: null == isFavorite
          ? _self.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [FoodCatalogItem].
extension FoodCatalogItemPatterns on FoodCatalogItem {
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
    TResult Function(_FoodCatalogItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FoodCatalogItem() when $default != null:
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
    TResult Function(_FoodCatalogItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FoodCatalogItem():
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
    TResult? Function(_FoodCatalogItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FoodCatalogItem() when $default != null:
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
            String name,
            double gramsPerServing,
            double caloriesPerServing,
            double fatPerServing,
            double carbsPerServing,
            double proteinPerServing,
            double potassiumMg,
            double sodiumMg,
            double cholesterolMg,
            double fiberPerServing,
            String importBatchId,
            bool isFavorite)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FoodCatalogItem() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.gramsPerServing,
            _that.caloriesPerServing,
            _that.fatPerServing,
            _that.carbsPerServing,
            _that.proteinPerServing,
            _that.potassiumMg,
            _that.sodiumMg,
            _that.cholesterolMg,
            _that.fiberPerServing,
            _that.importBatchId,
            _that.isFavorite);
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
            String name,
            double gramsPerServing,
            double caloriesPerServing,
            double fatPerServing,
            double carbsPerServing,
            double proteinPerServing,
            double potassiumMg,
            double sodiumMg,
            double cholesterolMg,
            double fiberPerServing,
            String importBatchId,
            bool isFavorite)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FoodCatalogItem():
        return $default(
            _that.id,
            _that.name,
            _that.gramsPerServing,
            _that.caloriesPerServing,
            _that.fatPerServing,
            _that.carbsPerServing,
            _that.proteinPerServing,
            _that.potassiumMg,
            _that.sodiumMg,
            _that.cholesterolMg,
            _that.fiberPerServing,
            _that.importBatchId,
            _that.isFavorite);
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
            String name,
            double gramsPerServing,
            double caloriesPerServing,
            double fatPerServing,
            double carbsPerServing,
            double proteinPerServing,
            double potassiumMg,
            double sodiumMg,
            double cholesterolMg,
            double fiberPerServing,
            String importBatchId,
            bool isFavorite)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FoodCatalogItem() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.gramsPerServing,
            _that.caloriesPerServing,
            _that.fatPerServing,
            _that.carbsPerServing,
            _that.proteinPerServing,
            _that.potassiumMg,
            _that.sodiumMg,
            _that.cholesterolMg,
            _that.fiberPerServing,
            _that.importBatchId,
            _that.isFavorite);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _FoodCatalogItem implements FoodCatalogItem {
  const _FoodCatalogItem(
      {this.id = 0,
      required this.name,
      this.gramsPerServing = 100.0,
      this.caloriesPerServing = 0.0,
      this.fatPerServing = 0.0,
      this.carbsPerServing = 0.0,
      this.proteinPerServing = 0.0,
      this.potassiumMg = 0.0,
      this.sodiumMg = 0.0,
      this.cholesterolMg = 0.0,
      this.fiberPerServing = 0.0,
      this.importBatchId = '',
      this.isFavorite = false});
  factory _FoodCatalogItem.fromJson(Map<String, dynamic> json) =>
      _$FoodCatalogItemFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  final String name;
  @override
  @JsonKey()
  final double gramsPerServing;
  @override
  @JsonKey()
  final double caloriesPerServing;
  @override
  @JsonKey()
  final double fatPerServing;
  @override
  @JsonKey()
  final double carbsPerServing;
  @override
  @JsonKey()
  final double proteinPerServing;
  @override
  @JsonKey()
  final double potassiumMg;
  @override
  @JsonKey()
  final double sodiumMg;
  @override
  @JsonKey()
  final double cholesterolMg;
  @override
  @JsonKey()
  final double fiberPerServing;
  @override
  @JsonKey()
  final String importBatchId;
  @override
  @JsonKey()
  final bool isFavorite;

  /// Create a copy of FoodCatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FoodCatalogItemCopyWith<_FoodCatalogItem> get copyWith =>
      __$FoodCatalogItemCopyWithImpl<_FoodCatalogItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$FoodCatalogItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FoodCatalogItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.gramsPerServing, gramsPerServing) ||
                other.gramsPerServing == gramsPerServing) &&
            (identical(other.caloriesPerServing, caloriesPerServing) ||
                other.caloriesPerServing == caloriesPerServing) &&
            (identical(other.fatPerServing, fatPerServing) ||
                other.fatPerServing == fatPerServing) &&
            (identical(other.carbsPerServing, carbsPerServing) ||
                other.carbsPerServing == carbsPerServing) &&
            (identical(other.proteinPerServing, proteinPerServing) ||
                other.proteinPerServing == proteinPerServing) &&
            (identical(other.potassiumMg, potassiumMg) ||
                other.potassiumMg == potassiumMg) &&
            (identical(other.sodiumMg, sodiumMg) ||
                other.sodiumMg == sodiumMg) &&
            (identical(other.cholesterolMg, cholesterolMg) ||
                other.cholesterolMg == cholesterolMg) &&
            (identical(other.fiberPerServing, fiberPerServing) ||
                other.fiberPerServing == fiberPerServing) &&
            (identical(other.importBatchId, importBatchId) ||
                other.importBatchId == importBatchId) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      gramsPerServing,
      caloriesPerServing,
      fatPerServing,
      carbsPerServing,
      proteinPerServing,
      potassiumMg,
      sodiumMg,
      cholesterolMg,
      fiberPerServing,
      importBatchId,
      isFavorite);

  @override
  String toString() {
    return 'FoodCatalogItem(id: $id, name: $name, gramsPerServing: $gramsPerServing, caloriesPerServing: $caloriesPerServing, fatPerServing: $fatPerServing, carbsPerServing: $carbsPerServing, proteinPerServing: $proteinPerServing, potassiumMg: $potassiumMg, sodiumMg: $sodiumMg, cholesterolMg: $cholesterolMg, fiberPerServing: $fiberPerServing, importBatchId: $importBatchId, isFavorite: $isFavorite)';
  }
}

/// @nodoc
abstract mixin class _$FoodCatalogItemCopyWith<$Res>
    implements $FoodCatalogItemCopyWith<$Res> {
  factory _$FoodCatalogItemCopyWith(
          _FoodCatalogItem value, $Res Function(_FoodCatalogItem) _then) =
      __$FoodCatalogItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      double gramsPerServing,
      double caloriesPerServing,
      double fatPerServing,
      double carbsPerServing,
      double proteinPerServing,
      double potassiumMg,
      double sodiumMg,
      double cholesterolMg,
      double fiberPerServing,
      String importBatchId,
      bool isFavorite});
}

/// @nodoc
class __$FoodCatalogItemCopyWithImpl<$Res>
    implements _$FoodCatalogItemCopyWith<$Res> {
  __$FoodCatalogItemCopyWithImpl(this._self, this._then);

  final _FoodCatalogItem _self;
  final $Res Function(_FoodCatalogItem) _then;

  /// Create a copy of FoodCatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? gramsPerServing = null,
    Object? caloriesPerServing = null,
    Object? fatPerServing = null,
    Object? carbsPerServing = null,
    Object? proteinPerServing = null,
    Object? potassiumMg = null,
    Object? sodiumMg = null,
    Object? cholesterolMg = null,
    Object? fiberPerServing = null,
    Object? importBatchId = null,
    Object? isFavorite = null,
  }) {
    return _then(_FoodCatalogItem(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      gramsPerServing: null == gramsPerServing
          ? _self.gramsPerServing
          : gramsPerServing // ignore: cast_nullable_to_non_nullable
              as double,
      caloriesPerServing: null == caloriesPerServing
          ? _self.caloriesPerServing
          : caloriesPerServing // ignore: cast_nullable_to_non_nullable
              as double,
      fatPerServing: null == fatPerServing
          ? _self.fatPerServing
          : fatPerServing // ignore: cast_nullable_to_non_nullable
              as double,
      carbsPerServing: null == carbsPerServing
          ? _self.carbsPerServing
          : carbsPerServing // ignore: cast_nullable_to_non_nullable
              as double,
      proteinPerServing: null == proteinPerServing
          ? _self.proteinPerServing
          : proteinPerServing // ignore: cast_nullable_to_non_nullable
              as double,
      potassiumMg: null == potassiumMg
          ? _self.potassiumMg
          : potassiumMg // ignore: cast_nullable_to_non_nullable
              as double,
      sodiumMg: null == sodiumMg
          ? _self.sodiumMg
          : sodiumMg // ignore: cast_nullable_to_non_nullable
              as double,
      cholesterolMg: null == cholesterolMg
          ? _self.cholesterolMg
          : cholesterolMg // ignore: cast_nullable_to_non_nullable
              as double,
      fiberPerServing: null == fiberPerServing
          ? _self.fiberPerServing
          : fiberPerServing // ignore: cast_nullable_to_non_nullable
              as double,
      importBatchId: null == importBatchId
          ? _self.importBatchId
          : importBatchId // ignore: cast_nullable_to_non_nullable
              as String,
      isFavorite: null == isFavorite
          ? _self.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$SweatPaymentProposal {
  String get exerciseId;
  String get exerciseName;
  int get extraSets;

  /// Create a copy of SweatPaymentProposal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SweatPaymentProposalCopyWith<SweatPaymentProposal> get copyWith =>
      _$SweatPaymentProposalCopyWithImpl<SweatPaymentProposal>(
          this as SweatPaymentProposal, _$identity);

  /// Serializes this SweatPaymentProposal to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SweatPaymentProposal &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.extraSets, extraSets) ||
                other.extraSets == extraSets));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, exerciseId, exerciseName, extraSets);

  @override
  String toString() {
    return 'SweatPaymentProposal(exerciseId: $exerciseId, exerciseName: $exerciseName, extraSets: $extraSets)';
  }
}

/// @nodoc
abstract mixin class $SweatPaymentProposalCopyWith<$Res> {
  factory $SweatPaymentProposalCopyWith(SweatPaymentProposal value,
          $Res Function(SweatPaymentProposal) _then) =
      _$SweatPaymentProposalCopyWithImpl;
  @useResult
  $Res call({String exerciseId, String exerciseName, int extraSets});
}

/// @nodoc
class _$SweatPaymentProposalCopyWithImpl<$Res>
    implements $SweatPaymentProposalCopyWith<$Res> {
  _$SweatPaymentProposalCopyWithImpl(this._self, this._then);

  final SweatPaymentProposal _self;
  final $Res Function(SweatPaymentProposal) _then;

  /// Create a copy of SweatPaymentProposal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? extraSets = null,
  }) {
    return _then(_self.copyWith(
      exerciseId: null == exerciseId
          ? _self.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _self.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      extraSets: null == extraSets
          ? _self.extraSets
          : extraSets // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [SweatPaymentProposal].
extension SweatPaymentProposalPatterns on SweatPaymentProposal {
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
    TResult Function(_SweatPaymentProposal value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SweatPaymentProposal() when $default != null:
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
    TResult Function(_SweatPaymentProposal value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SweatPaymentProposal():
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
    TResult? Function(_SweatPaymentProposal value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SweatPaymentProposal() when $default != null:
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
    TResult Function(String exerciseId, String exerciseName, int extraSets)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SweatPaymentProposal() when $default != null:
        return $default(_that.exerciseId, _that.exerciseName, _that.extraSets);
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
    TResult Function(String exerciseId, String exerciseName, int extraSets)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SweatPaymentProposal():
        return $default(_that.exerciseId, _that.exerciseName, _that.extraSets);
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
    TResult? Function(String exerciseId, String exerciseName, int extraSets)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SweatPaymentProposal() when $default != null:
        return $default(_that.exerciseId, _that.exerciseName, _that.extraSets);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SweatPaymentProposal implements SweatPaymentProposal {
  const _SweatPaymentProposal(
      {required this.exerciseId,
      required this.exerciseName,
      required this.extraSets});
  factory _SweatPaymentProposal.fromJson(Map<String, dynamic> json) =>
      _$SweatPaymentProposalFromJson(json);

  @override
  final String exerciseId;
  @override
  final String exerciseName;
  @override
  final int extraSets;

  /// Create a copy of SweatPaymentProposal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SweatPaymentProposalCopyWith<_SweatPaymentProposal> get copyWith =>
      __$SweatPaymentProposalCopyWithImpl<_SweatPaymentProposal>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SweatPaymentProposalToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SweatPaymentProposal &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.extraSets, extraSets) ||
                other.extraSets == extraSets));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, exerciseId, exerciseName, extraSets);

  @override
  String toString() {
    return 'SweatPaymentProposal(exerciseId: $exerciseId, exerciseName: $exerciseName, extraSets: $extraSets)';
  }
}

/// @nodoc
abstract mixin class _$SweatPaymentProposalCopyWith<$Res>
    implements $SweatPaymentProposalCopyWith<$Res> {
  factory _$SweatPaymentProposalCopyWith(_SweatPaymentProposal value,
          $Res Function(_SweatPaymentProposal) _then) =
      __$SweatPaymentProposalCopyWithImpl;
  @override
  @useResult
  $Res call({String exerciseId, String exerciseName, int extraSets});
}

/// @nodoc
class __$SweatPaymentProposalCopyWithImpl<$Res>
    implements _$SweatPaymentProposalCopyWith<$Res> {
  __$SweatPaymentProposalCopyWithImpl(this._self, this._then);

  final _SweatPaymentProposal _self;
  final $Res Function(_SweatPaymentProposal) _then;

  /// Create a copy of SweatPaymentProposal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? extraSets = null,
  }) {
    return _then(_SweatPaymentProposal(
      exerciseId: null == exerciseId
          ? _self.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _self.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      extraSets: null == extraSets
          ? _self.extraSets
          : extraSets // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$Constituent {
  String get name;
  int get calories;
  int get protein;
  int get carbs;
  int get fat;

  /// Create a copy of Constituent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ConstituentCopyWith<Constituent> get copyWith =>
      _$ConstituentCopyWithImpl<Constituent>(this as Constituent, _$identity);

  /// Serializes this Constituent to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Constituent &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.protein, protein) || other.protein == protein) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.fat, fat) || other.fat == fat));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, calories, protein, carbs, fat);

  @override
  String toString() {
    return 'Constituent(name: $name, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat)';
  }
}

/// @nodoc
abstract mixin class $ConstituentCopyWith<$Res> {
  factory $ConstituentCopyWith(
          Constituent value, $Res Function(Constituent) _then) =
      _$ConstituentCopyWithImpl;
  @useResult
  $Res call({String name, int calories, int protein, int carbs, int fat});
}

/// @nodoc
class _$ConstituentCopyWithImpl<$Res> implements $ConstituentCopyWith<$Res> {
  _$ConstituentCopyWithImpl(this._self, this._then);

  final Constituent _self;
  final $Res Function(Constituent) _then;

  /// Create a copy of Constituent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? calories = null,
    Object? protein = null,
    Object? carbs = null,
    Object? fat = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      calories: null == calories
          ? _self.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      protein: null == protein
          ? _self.protein
          : protein // ignore: cast_nullable_to_non_nullable
              as int,
      carbs: null == carbs
          ? _self.carbs
          : carbs // ignore: cast_nullable_to_non_nullable
              as int,
      fat: null == fat
          ? _self.fat
          : fat // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [Constituent].
extension ConstituentPatterns on Constituent {
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
    TResult Function(_Constituent value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Constituent() when $default != null:
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
    TResult Function(_Constituent value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Constituent():
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
    TResult? Function(_Constituent value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Constituent() when $default != null:
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
            String name, int calories, int protein, int carbs, int fat)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Constituent() when $default != null:
        return $default(
            _that.name, _that.calories, _that.protein, _that.carbs, _that.fat);
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
    TResult Function(String name, int calories, int protein, int carbs, int fat)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Constituent():
        return $default(
            _that.name, _that.calories, _that.protein, _that.carbs, _that.fat);
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
            String name, int calories, int protein, int carbs, int fat)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Constituent() when $default != null:
        return $default(
            _that.name, _that.calories, _that.protein, _that.carbs, _that.fat);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Constituent implements Constituent {
  const _Constituent(
      {required this.name,
      required this.calories,
      required this.protein,
      required this.carbs,
      required this.fat});
  factory _Constituent.fromJson(Map<String, dynamic> json) =>
      _$ConstituentFromJson(json);

  @override
  final String name;
  @override
  final int calories;
  @override
  final int protein;
  @override
  final int carbs;
  @override
  final int fat;

  /// Create a copy of Constituent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ConstituentCopyWith<_Constituent> get copyWith =>
      __$ConstituentCopyWithImpl<_Constituent>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ConstituentToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Constituent &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.protein, protein) || other.protein == protein) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.fat, fat) || other.fat == fat));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, calories, protein, carbs, fat);

  @override
  String toString() {
    return 'Constituent(name: $name, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat)';
  }
}

/// @nodoc
abstract mixin class _$ConstituentCopyWith<$Res>
    implements $ConstituentCopyWith<$Res> {
  factory _$ConstituentCopyWith(
          _Constituent value, $Res Function(_Constituent) _then) =
      __$ConstituentCopyWithImpl;
  @override
  @useResult
  $Res call({String name, int calories, int protein, int carbs, int fat});
}

/// @nodoc
class __$ConstituentCopyWithImpl<$Res> implements _$ConstituentCopyWith<$Res> {
  __$ConstituentCopyWithImpl(this._self, this._then);

  final _Constituent _self;
  final $Res Function(_Constituent) _then;

  /// Create a copy of Constituent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? calories = null,
    Object? protein = null,
    Object? carbs = null,
    Object? fat = null,
  }) {
    return _then(_Constituent(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      calories: null == calories
          ? _self.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      protein: null == protein
          ? _self.protein
          : protein // ignore: cast_nullable_to_non_nullable
              as int,
      carbs: null == carbs
          ? _self.carbs
          : carbs // ignore: cast_nullable_to_non_nullable
              as int,
      fat: null == fat
          ? _self.fat
          : fat // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$ScanRecommendation {
  String get dishName;
  double get confidence;
  int get calories;
  int get proteinGrams;
  int get carbsGrams;
  int get fatGrams;

  /// Create a copy of ScanRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScanRecommendationCopyWith<ScanRecommendation> get copyWith =>
      _$ScanRecommendationCopyWithImpl<ScanRecommendation>(
          this as ScanRecommendation, _$identity);

  /// Serializes this ScanRecommendation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScanRecommendation &&
            (identical(other.dishName, dishName) ||
                other.dishName == dishName) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.proteinGrams, proteinGrams) ||
                other.proteinGrams == proteinGrams) &&
            (identical(other.carbsGrams, carbsGrams) ||
                other.carbsGrams == carbsGrams) &&
            (identical(other.fatGrams, fatGrams) ||
                other.fatGrams == fatGrams));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, dishName, confidence, calories,
      proteinGrams, carbsGrams, fatGrams);

  @override
  String toString() {
    return 'ScanRecommendation(dishName: $dishName, confidence: $confidence, calories: $calories, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams)';
  }
}

/// @nodoc
abstract mixin class $ScanRecommendationCopyWith<$Res> {
  factory $ScanRecommendationCopyWith(
          ScanRecommendation value, $Res Function(ScanRecommendation) _then) =
      _$ScanRecommendationCopyWithImpl;
  @useResult
  $Res call(
      {String dishName,
      double confidence,
      int calories,
      int proteinGrams,
      int carbsGrams,
      int fatGrams});
}

/// @nodoc
class _$ScanRecommendationCopyWithImpl<$Res>
    implements $ScanRecommendationCopyWith<$Res> {
  _$ScanRecommendationCopyWithImpl(this._self, this._then);

  final ScanRecommendation _self;
  final $Res Function(ScanRecommendation) _then;

  /// Create a copy of ScanRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dishName = null,
    Object? confidence = null,
    Object? calories = null,
    Object? proteinGrams = null,
    Object? carbsGrams = null,
    Object? fatGrams = null,
  }) {
    return _then(_self.copyWith(
      dishName: null == dishName
          ? _self.dishName
          : dishName // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _self.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      calories: null == calories
          ? _self.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      proteinGrams: null == proteinGrams
          ? _self.proteinGrams
          : proteinGrams // ignore: cast_nullable_to_non_nullable
              as int,
      carbsGrams: null == carbsGrams
          ? _self.carbsGrams
          : carbsGrams // ignore: cast_nullable_to_non_nullable
              as int,
      fatGrams: null == fatGrams
          ? _self.fatGrams
          : fatGrams // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [ScanRecommendation].
extension ScanRecommendationPatterns on ScanRecommendation {
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
    TResult Function(_ScanRecommendation value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScanRecommendation() when $default != null:
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
    TResult Function(_ScanRecommendation value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScanRecommendation():
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
    TResult? Function(_ScanRecommendation value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScanRecommendation() when $default != null:
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
    TResult Function(String dishName, double confidence, int calories,
            int proteinGrams, int carbsGrams, int fatGrams)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScanRecommendation() when $default != null:
        return $default(_that.dishName, _that.confidence, _that.calories,
            _that.proteinGrams, _that.carbsGrams, _that.fatGrams);
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
    TResult Function(String dishName, double confidence, int calories,
            int proteinGrams, int carbsGrams, int fatGrams)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScanRecommendation():
        return $default(_that.dishName, _that.confidence, _that.calories,
            _that.proteinGrams, _that.carbsGrams, _that.fatGrams);
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
    TResult? Function(String dishName, double confidence, int calories,
            int proteinGrams, int carbsGrams, int fatGrams)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScanRecommendation() when $default != null:
        return $default(_that.dishName, _that.confidence, _that.calories,
            _that.proteinGrams, _that.carbsGrams, _that.fatGrams);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ScanRecommendation implements ScanRecommendation {
  const _ScanRecommendation(
      {required this.dishName,
      required this.confidence,
      required this.calories,
      required this.proteinGrams,
      required this.carbsGrams,
      required this.fatGrams});
  factory _ScanRecommendation.fromJson(Map<String, dynamic> json) =>
      _$ScanRecommendationFromJson(json);

  @override
  final String dishName;
  @override
  final double confidence;
  @override
  final int calories;
  @override
  final int proteinGrams;
  @override
  final int carbsGrams;
  @override
  final int fatGrams;

  /// Create a copy of ScanRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScanRecommendationCopyWith<_ScanRecommendation> get copyWith =>
      __$ScanRecommendationCopyWithImpl<_ScanRecommendation>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ScanRecommendationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScanRecommendation &&
            (identical(other.dishName, dishName) ||
                other.dishName == dishName) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.proteinGrams, proteinGrams) ||
                other.proteinGrams == proteinGrams) &&
            (identical(other.carbsGrams, carbsGrams) ||
                other.carbsGrams == carbsGrams) &&
            (identical(other.fatGrams, fatGrams) ||
                other.fatGrams == fatGrams));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, dishName, confidence, calories,
      proteinGrams, carbsGrams, fatGrams);

  @override
  String toString() {
    return 'ScanRecommendation(dishName: $dishName, confidence: $confidence, calories: $calories, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams)';
  }
}

/// @nodoc
abstract mixin class _$ScanRecommendationCopyWith<$Res>
    implements $ScanRecommendationCopyWith<$Res> {
  factory _$ScanRecommendationCopyWith(
          _ScanRecommendation value, $Res Function(_ScanRecommendation) _then) =
      __$ScanRecommendationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String dishName,
      double confidence,
      int calories,
      int proteinGrams,
      int carbsGrams,
      int fatGrams});
}

/// @nodoc
class __$ScanRecommendationCopyWithImpl<$Res>
    implements _$ScanRecommendationCopyWith<$Res> {
  __$ScanRecommendationCopyWithImpl(this._self, this._then);

  final _ScanRecommendation _self;
  final $Res Function(_ScanRecommendation) _then;

  /// Create a copy of ScanRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? dishName = null,
    Object? confidence = null,
    Object? calories = null,
    Object? proteinGrams = null,
    Object? carbsGrams = null,
    Object? fatGrams = null,
  }) {
    return _then(_ScanRecommendation(
      dishName: null == dishName
          ? _self.dishName
          : dishName // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _self.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      calories: null == calories
          ? _self.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      proteinGrams: null == proteinGrams
          ? _self.proteinGrams
          : proteinGrams // ignore: cast_nullable_to_non_nullable
              as int,
      carbsGrams: null == carbsGrams
          ? _self.carbsGrams
          : carbsGrams // ignore: cast_nullable_to_non_nullable
              as int,
      fatGrams: null == fatGrams
          ? _self.fatGrams
          : fatGrams // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$ScanResult {
  String get dishName;
  int get totalCalories;
  int get proteinGrams;
  int get carbsGrams;
  int get fatGrams;
  int get fitnessScore;
  String get advice;
  List<Constituent> get constituents;
  SweatPaymentProposal? get sweatPayment;
  String? get calculationProcess;
  double get confidence;
  bool get needsUserConfirmation;
  List<ScanRecommendation> get recommendations;

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScanResultCopyWith<ScanResult> get copyWith =>
      _$ScanResultCopyWithImpl<ScanResult>(this as ScanResult, _$identity);

  /// Serializes this ScanResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScanResult &&
            (identical(other.dishName, dishName) ||
                other.dishName == dishName) &&
            (identical(other.totalCalories, totalCalories) ||
                other.totalCalories == totalCalories) &&
            (identical(other.proteinGrams, proteinGrams) ||
                other.proteinGrams == proteinGrams) &&
            (identical(other.carbsGrams, carbsGrams) ||
                other.carbsGrams == carbsGrams) &&
            (identical(other.fatGrams, fatGrams) ||
                other.fatGrams == fatGrams) &&
            (identical(other.fitnessScore, fitnessScore) ||
                other.fitnessScore == fitnessScore) &&
            (identical(other.advice, advice) || other.advice == advice) &&
            const DeepCollectionEquality()
                .equals(other.constituents, constituents) &&
            (identical(other.sweatPayment, sweatPayment) ||
                other.sweatPayment == sweatPayment) &&
            (identical(other.calculationProcess, calculationProcess) ||
                other.calculationProcess == calculationProcess) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.needsUserConfirmation, needsUserConfirmation) ||
                other.needsUserConfirmation == needsUserConfirmation) &&
            const DeepCollectionEquality()
                .equals(other.recommendations, recommendations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      dishName,
      totalCalories,
      proteinGrams,
      carbsGrams,
      fatGrams,
      fitnessScore,
      advice,
      const DeepCollectionEquality().hash(constituents),
      sweatPayment,
      calculationProcess,
      confidence,
      needsUserConfirmation,
      const DeepCollectionEquality().hash(recommendations));

  @override
  String toString() {
    return 'ScanResult(dishName: $dishName, totalCalories: $totalCalories, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, fitnessScore: $fitnessScore, advice: $advice, constituents: $constituents, sweatPayment: $sweatPayment, calculationProcess: $calculationProcess, confidence: $confidence, needsUserConfirmation: $needsUserConfirmation, recommendations: $recommendations)';
  }
}

/// @nodoc
abstract mixin class $ScanResultCopyWith<$Res> {
  factory $ScanResultCopyWith(
          ScanResult value, $Res Function(ScanResult) _then) =
      _$ScanResultCopyWithImpl;
  @useResult
  $Res call(
      {String dishName,
      int totalCalories,
      int proteinGrams,
      int carbsGrams,
      int fatGrams,
      int fitnessScore,
      String advice,
      List<Constituent> constituents,
      SweatPaymentProposal? sweatPayment,
      String? calculationProcess,
      double confidence,
      bool needsUserConfirmation,
      List<ScanRecommendation> recommendations});

  $SweatPaymentProposalCopyWith<$Res>? get sweatPayment;
}

/// @nodoc
class _$ScanResultCopyWithImpl<$Res> implements $ScanResultCopyWith<$Res> {
  _$ScanResultCopyWithImpl(this._self, this._then);

  final ScanResult _self;
  final $Res Function(ScanResult) _then;

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dishName = null,
    Object? totalCalories = null,
    Object? proteinGrams = null,
    Object? carbsGrams = null,
    Object? fatGrams = null,
    Object? fitnessScore = null,
    Object? advice = null,
    Object? constituents = null,
    Object? sweatPayment = freezed,
    Object? calculationProcess = freezed,
    Object? confidence = null,
    Object? needsUserConfirmation = null,
    Object? recommendations = null,
  }) {
    return _then(_self.copyWith(
      dishName: null == dishName
          ? _self.dishName
          : dishName // ignore: cast_nullable_to_non_nullable
              as String,
      totalCalories: null == totalCalories
          ? _self.totalCalories
          : totalCalories // ignore: cast_nullable_to_non_nullable
              as int,
      proteinGrams: null == proteinGrams
          ? _self.proteinGrams
          : proteinGrams // ignore: cast_nullable_to_non_nullable
              as int,
      carbsGrams: null == carbsGrams
          ? _self.carbsGrams
          : carbsGrams // ignore: cast_nullable_to_non_nullable
              as int,
      fatGrams: null == fatGrams
          ? _self.fatGrams
          : fatGrams // ignore: cast_nullable_to_non_nullable
              as int,
      fitnessScore: null == fitnessScore
          ? _self.fitnessScore
          : fitnessScore // ignore: cast_nullable_to_non_nullable
              as int,
      advice: null == advice
          ? _self.advice
          : advice // ignore: cast_nullable_to_non_nullable
              as String,
      constituents: null == constituents
          ? _self.constituents
          : constituents // ignore: cast_nullable_to_non_nullable
              as List<Constituent>,
      sweatPayment: freezed == sweatPayment
          ? _self.sweatPayment
          : sweatPayment // ignore: cast_nullable_to_non_nullable
              as SweatPaymentProposal?,
      calculationProcess: freezed == calculationProcess
          ? _self.calculationProcess
          : calculationProcess // ignore: cast_nullable_to_non_nullable
              as String?,
      confidence: null == confidence
          ? _self.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      needsUserConfirmation: null == needsUserConfirmation
          ? _self.needsUserConfirmation
          : needsUserConfirmation // ignore: cast_nullable_to_non_nullable
              as bool,
      recommendations: null == recommendations
          ? _self.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<ScanRecommendation>,
    ));
  }

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SweatPaymentProposalCopyWith<$Res>? get sweatPayment {
    if (_self.sweatPayment == null) {
      return null;
    }

    return $SweatPaymentProposalCopyWith<$Res>(_self.sweatPayment!, (value) {
      return _then(_self.copyWith(sweatPayment: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ScanResult].
extension ScanResultPatterns on ScanResult {
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
    TResult Function(_ScanResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScanResult() when $default != null:
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
    TResult Function(_ScanResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScanResult():
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
    TResult? Function(_ScanResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScanResult() when $default != null:
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
            String dishName,
            int totalCalories,
            int proteinGrams,
            int carbsGrams,
            int fatGrams,
            int fitnessScore,
            String advice,
            List<Constituent> constituents,
            SweatPaymentProposal? sweatPayment,
            String? calculationProcess,
            double confidence,
            bool needsUserConfirmation,
            List<ScanRecommendation> recommendations)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScanResult() when $default != null:
        return $default(
            _that.dishName,
            _that.totalCalories,
            _that.proteinGrams,
            _that.carbsGrams,
            _that.fatGrams,
            _that.fitnessScore,
            _that.advice,
            _that.constituents,
            _that.sweatPayment,
            _that.calculationProcess,
            _that.confidence,
            _that.needsUserConfirmation,
            _that.recommendations);
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
            String dishName,
            int totalCalories,
            int proteinGrams,
            int carbsGrams,
            int fatGrams,
            int fitnessScore,
            String advice,
            List<Constituent> constituents,
            SweatPaymentProposal? sweatPayment,
            String? calculationProcess,
            double confidence,
            bool needsUserConfirmation,
            List<ScanRecommendation> recommendations)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScanResult():
        return $default(
            _that.dishName,
            _that.totalCalories,
            _that.proteinGrams,
            _that.carbsGrams,
            _that.fatGrams,
            _that.fitnessScore,
            _that.advice,
            _that.constituents,
            _that.sweatPayment,
            _that.calculationProcess,
            _that.confidence,
            _that.needsUserConfirmation,
            _that.recommendations);
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
            String dishName,
            int totalCalories,
            int proteinGrams,
            int carbsGrams,
            int fatGrams,
            int fitnessScore,
            String advice,
            List<Constituent> constituents,
            SweatPaymentProposal? sweatPayment,
            String? calculationProcess,
            double confidence,
            bool needsUserConfirmation,
            List<ScanRecommendation> recommendations)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScanResult() when $default != null:
        return $default(
            _that.dishName,
            _that.totalCalories,
            _that.proteinGrams,
            _that.carbsGrams,
            _that.fatGrams,
            _that.fitnessScore,
            _that.advice,
            _that.constituents,
            _that.sweatPayment,
            _that.calculationProcess,
            _that.confidence,
            _that.needsUserConfirmation,
            _that.recommendations);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ScanResult implements ScanResult {
  const _ScanResult(
      {required this.dishName,
      required this.totalCalories,
      required this.proteinGrams,
      required this.carbsGrams,
      required this.fatGrams,
      required this.fitnessScore,
      required this.advice,
      required final List<Constituent> constituents,
      this.sweatPayment,
      this.calculationProcess,
      this.confidence = 1.0,
      this.needsUserConfirmation = false,
      final List<ScanRecommendation> recommendations = const []})
      : _constituents = constituents,
        _recommendations = recommendations;
  factory _ScanResult.fromJson(Map<String, dynamic> json) =>
      _$ScanResultFromJson(json);

  @override
  final String dishName;
  @override
  final int totalCalories;
  @override
  final int proteinGrams;
  @override
  final int carbsGrams;
  @override
  final int fatGrams;
  @override
  final int fitnessScore;
  @override
  final String advice;
  final List<Constituent> _constituents;
  @override
  List<Constituent> get constituents {
    if (_constituents is EqualUnmodifiableListView) return _constituents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_constituents);
  }

  @override
  final SweatPaymentProposal? sweatPayment;
  @override
  final String? calculationProcess;
  @override
  @JsonKey()
  final double confidence;
  @override
  @JsonKey()
  final bool needsUserConfirmation;
  final List<ScanRecommendation> _recommendations;
  @override
  @JsonKey()
  List<ScanRecommendation> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScanResultCopyWith<_ScanResult> get copyWith =>
      __$ScanResultCopyWithImpl<_ScanResult>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ScanResultToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScanResult &&
            (identical(other.dishName, dishName) ||
                other.dishName == dishName) &&
            (identical(other.totalCalories, totalCalories) ||
                other.totalCalories == totalCalories) &&
            (identical(other.proteinGrams, proteinGrams) ||
                other.proteinGrams == proteinGrams) &&
            (identical(other.carbsGrams, carbsGrams) ||
                other.carbsGrams == carbsGrams) &&
            (identical(other.fatGrams, fatGrams) ||
                other.fatGrams == fatGrams) &&
            (identical(other.fitnessScore, fitnessScore) ||
                other.fitnessScore == fitnessScore) &&
            (identical(other.advice, advice) || other.advice == advice) &&
            const DeepCollectionEquality()
                .equals(other._constituents, _constituents) &&
            (identical(other.sweatPayment, sweatPayment) ||
                other.sweatPayment == sweatPayment) &&
            (identical(other.calculationProcess, calculationProcess) ||
                other.calculationProcess == calculationProcess) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.needsUserConfirmation, needsUserConfirmation) ||
                other.needsUserConfirmation == needsUserConfirmation) &&
            const DeepCollectionEquality()
                .equals(other._recommendations, _recommendations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      dishName,
      totalCalories,
      proteinGrams,
      carbsGrams,
      fatGrams,
      fitnessScore,
      advice,
      const DeepCollectionEquality().hash(_constituents),
      sweatPayment,
      calculationProcess,
      confidence,
      needsUserConfirmation,
      const DeepCollectionEquality().hash(_recommendations));

  @override
  String toString() {
    return 'ScanResult(dishName: $dishName, totalCalories: $totalCalories, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, fitnessScore: $fitnessScore, advice: $advice, constituents: $constituents, sweatPayment: $sweatPayment, calculationProcess: $calculationProcess, confidence: $confidence, needsUserConfirmation: $needsUserConfirmation, recommendations: $recommendations)';
  }
}

/// @nodoc
abstract mixin class _$ScanResultCopyWith<$Res>
    implements $ScanResultCopyWith<$Res> {
  factory _$ScanResultCopyWith(
          _ScanResult value, $Res Function(_ScanResult) _then) =
      __$ScanResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String dishName,
      int totalCalories,
      int proteinGrams,
      int carbsGrams,
      int fatGrams,
      int fitnessScore,
      String advice,
      List<Constituent> constituents,
      SweatPaymentProposal? sweatPayment,
      String? calculationProcess,
      double confidence,
      bool needsUserConfirmation,
      List<ScanRecommendation> recommendations});

  @override
  $SweatPaymentProposalCopyWith<$Res>? get sweatPayment;
}

/// @nodoc
class __$ScanResultCopyWithImpl<$Res> implements _$ScanResultCopyWith<$Res> {
  __$ScanResultCopyWithImpl(this._self, this._then);

  final _ScanResult _self;
  final $Res Function(_ScanResult) _then;

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? dishName = null,
    Object? totalCalories = null,
    Object? proteinGrams = null,
    Object? carbsGrams = null,
    Object? fatGrams = null,
    Object? fitnessScore = null,
    Object? advice = null,
    Object? constituents = null,
    Object? sweatPayment = freezed,
    Object? calculationProcess = freezed,
    Object? confidence = null,
    Object? needsUserConfirmation = null,
    Object? recommendations = null,
  }) {
    return _then(_ScanResult(
      dishName: null == dishName
          ? _self.dishName
          : dishName // ignore: cast_nullable_to_non_nullable
              as String,
      totalCalories: null == totalCalories
          ? _self.totalCalories
          : totalCalories // ignore: cast_nullable_to_non_nullable
              as int,
      proteinGrams: null == proteinGrams
          ? _self.proteinGrams
          : proteinGrams // ignore: cast_nullable_to_non_nullable
              as int,
      carbsGrams: null == carbsGrams
          ? _self.carbsGrams
          : carbsGrams // ignore: cast_nullable_to_non_nullable
              as int,
      fatGrams: null == fatGrams
          ? _self.fatGrams
          : fatGrams // ignore: cast_nullable_to_non_nullable
              as int,
      fitnessScore: null == fitnessScore
          ? _self.fitnessScore
          : fitnessScore // ignore: cast_nullable_to_non_nullable
              as int,
      advice: null == advice
          ? _self.advice
          : advice // ignore: cast_nullable_to_non_nullable
              as String,
      constituents: null == constituents
          ? _self._constituents
          : constituents // ignore: cast_nullable_to_non_nullable
              as List<Constituent>,
      sweatPayment: freezed == sweatPayment
          ? _self.sweatPayment
          : sweatPayment // ignore: cast_nullable_to_non_nullable
              as SweatPaymentProposal?,
      calculationProcess: freezed == calculationProcess
          ? _self.calculationProcess
          : calculationProcess // ignore: cast_nullable_to_non_nullable
              as String?,
      confidence: null == confidence
          ? _self.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      needsUserConfirmation: null == needsUserConfirmation
          ? _self.needsUserConfirmation
          : needsUserConfirmation // ignore: cast_nullable_to_non_nullable
              as bool,
      recommendations: null == recommendations
          ? _self._recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<ScanRecommendation>,
    ));
  }

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SweatPaymentProposalCopyWith<$Res>? get sweatPayment {
    if (_self.sweatPayment == null) {
      return null;
    }

    return $SweatPaymentProposalCopyWith<$Res>(_self.sweatPayment!, (value) {
      return _then(_self.copyWith(sweatPayment: value));
    });
  }
}

// dart format on

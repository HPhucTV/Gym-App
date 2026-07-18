// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PersonalProfile {
  int get birthDateEpochDay;
  MetabolicSex get metabolicSex;
  double get heightCm;
  double get currentWeightKg;
  double get targetWeightKg;
  ActivityLevel get activityLevel;
  GoalPace get goalPace;
  bool get personalizationConsent;
  bool get cloudAiConsent;

  /// Create a copy of PersonalProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PersonalProfileCopyWith<PersonalProfile> get copyWith =>
      _$PersonalProfileCopyWithImpl<PersonalProfile>(
          this as PersonalProfile, _$identity);

  /// Serializes this PersonalProfile to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PersonalProfile &&
            (identical(other.birthDateEpochDay, birthDateEpochDay) ||
                other.birthDateEpochDay == birthDateEpochDay) &&
            (identical(other.metabolicSex, metabolicSex) ||
                other.metabolicSex == metabolicSex) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.currentWeightKg, currentWeightKg) ||
                other.currentWeightKg == currentWeightKg) &&
            (identical(other.targetWeightKg, targetWeightKg) ||
                other.targetWeightKg == targetWeightKg) &&
            (identical(other.activityLevel, activityLevel) ||
                other.activityLevel == activityLevel) &&
            (identical(other.goalPace, goalPace) ||
                other.goalPace == goalPace) &&
            (identical(other.personalizationConsent, personalizationConsent) ||
                other.personalizationConsent == personalizationConsent) &&
            (identical(other.cloudAiConsent, cloudAiConsent) ||
                other.cloudAiConsent == cloudAiConsent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      birthDateEpochDay,
      metabolicSex,
      heightCm,
      currentWeightKg,
      targetWeightKg,
      activityLevel,
      goalPace,
      personalizationConsent,
      cloudAiConsent);

  @override
  String toString() {
    return 'PersonalProfile(birthDateEpochDay: $birthDateEpochDay, metabolicSex: $metabolicSex, heightCm: $heightCm, currentWeightKg: $currentWeightKg, targetWeightKg: $targetWeightKg, activityLevel: $activityLevel, goalPace: $goalPace, personalizationConsent: $personalizationConsent, cloudAiConsent: $cloudAiConsent)';
  }
}

/// @nodoc
abstract mixin class $PersonalProfileCopyWith<$Res> {
  factory $PersonalProfileCopyWith(
          PersonalProfile value, $Res Function(PersonalProfile) _then) =
      _$PersonalProfileCopyWithImpl;
  @useResult
  $Res call(
      {int birthDateEpochDay,
      MetabolicSex metabolicSex,
      double heightCm,
      double currentWeightKg,
      double targetWeightKg,
      ActivityLevel activityLevel,
      GoalPace goalPace,
      bool personalizationConsent,
      bool cloudAiConsent});
}

/// @nodoc
class _$PersonalProfileCopyWithImpl<$Res>
    implements $PersonalProfileCopyWith<$Res> {
  _$PersonalProfileCopyWithImpl(this._self, this._then);

  final PersonalProfile _self;
  final $Res Function(PersonalProfile) _then;

  /// Create a copy of PersonalProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? birthDateEpochDay = null,
    Object? metabolicSex = null,
    Object? heightCm = null,
    Object? currentWeightKg = null,
    Object? targetWeightKg = null,
    Object? activityLevel = null,
    Object? goalPace = null,
    Object? personalizationConsent = null,
    Object? cloudAiConsent = null,
  }) {
    return _then(_self.copyWith(
      birthDateEpochDay: null == birthDateEpochDay
          ? _self.birthDateEpochDay
          : birthDateEpochDay // ignore: cast_nullable_to_non_nullable
              as int,
      metabolicSex: null == metabolicSex
          ? _self.metabolicSex
          : metabolicSex // ignore: cast_nullable_to_non_nullable
              as MetabolicSex,
      heightCm: null == heightCm
          ? _self.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double,
      currentWeightKg: null == currentWeightKg
          ? _self.currentWeightKg
          : currentWeightKg // ignore: cast_nullable_to_non_nullable
              as double,
      targetWeightKg: null == targetWeightKg
          ? _self.targetWeightKg
          : targetWeightKg // ignore: cast_nullable_to_non_nullable
              as double,
      activityLevel: null == activityLevel
          ? _self.activityLevel
          : activityLevel // ignore: cast_nullable_to_non_nullable
              as ActivityLevel,
      goalPace: null == goalPace
          ? _self.goalPace
          : goalPace // ignore: cast_nullable_to_non_nullable
              as GoalPace,
      personalizationConsent: null == personalizationConsent
          ? _self.personalizationConsent
          : personalizationConsent // ignore: cast_nullable_to_non_nullable
              as bool,
      cloudAiConsent: null == cloudAiConsent
          ? _self.cloudAiConsent
          : cloudAiConsent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [PersonalProfile].
extension PersonalProfilePatterns on PersonalProfile {
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
    TResult Function(_PersonalProfile value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PersonalProfile() when $default != null:
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
    TResult Function(_PersonalProfile value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonalProfile():
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
    TResult? Function(_PersonalProfile value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonalProfile() when $default != null:
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
            int birthDateEpochDay,
            MetabolicSex metabolicSex,
            double heightCm,
            double currentWeightKg,
            double targetWeightKg,
            ActivityLevel activityLevel,
            GoalPace goalPace,
            bool personalizationConsent,
            bool cloudAiConsent)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PersonalProfile() when $default != null:
        return $default(
            _that.birthDateEpochDay,
            _that.metabolicSex,
            _that.heightCm,
            _that.currentWeightKg,
            _that.targetWeightKg,
            _that.activityLevel,
            _that.goalPace,
            _that.personalizationConsent,
            _that.cloudAiConsent);
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
            int birthDateEpochDay,
            MetabolicSex metabolicSex,
            double heightCm,
            double currentWeightKg,
            double targetWeightKg,
            ActivityLevel activityLevel,
            GoalPace goalPace,
            bool personalizationConsent,
            bool cloudAiConsent)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonalProfile():
        return $default(
            _that.birthDateEpochDay,
            _that.metabolicSex,
            _that.heightCm,
            _that.currentWeightKg,
            _that.targetWeightKg,
            _that.activityLevel,
            _that.goalPace,
            _that.personalizationConsent,
            _that.cloudAiConsent);
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
            int birthDateEpochDay,
            MetabolicSex metabolicSex,
            double heightCm,
            double currentWeightKg,
            double targetWeightKg,
            ActivityLevel activityLevel,
            GoalPace goalPace,
            bool personalizationConsent,
            bool cloudAiConsent)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonalProfile() when $default != null:
        return $default(
            _that.birthDateEpochDay,
            _that.metabolicSex,
            _that.heightCm,
            _that.currentWeightKg,
            _that.targetWeightKg,
            _that.activityLevel,
            _that.goalPace,
            _that.personalizationConsent,
            _that.cloudAiConsent);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PersonalProfile extends PersonalProfile {
  const _PersonalProfile(
      {required this.birthDateEpochDay,
      required this.metabolicSex,
      required this.heightCm,
      required this.currentWeightKg,
      required this.targetWeightKg,
      required this.activityLevel,
      required this.goalPace,
      required this.personalizationConsent,
      required this.cloudAiConsent})
      : super._();
  factory _PersonalProfile.fromJson(Map<String, dynamic> json) =>
      _$PersonalProfileFromJson(json);

  @override
  final int birthDateEpochDay;
  @override
  final MetabolicSex metabolicSex;
  @override
  final double heightCm;
  @override
  final double currentWeightKg;
  @override
  final double targetWeightKg;
  @override
  final ActivityLevel activityLevel;
  @override
  final GoalPace goalPace;
  @override
  final bool personalizationConsent;
  @override
  final bool cloudAiConsent;

  /// Create a copy of PersonalProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PersonalProfileCopyWith<_PersonalProfile> get copyWith =>
      __$PersonalProfileCopyWithImpl<_PersonalProfile>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PersonalProfileToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PersonalProfile &&
            (identical(other.birthDateEpochDay, birthDateEpochDay) ||
                other.birthDateEpochDay == birthDateEpochDay) &&
            (identical(other.metabolicSex, metabolicSex) ||
                other.metabolicSex == metabolicSex) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.currentWeightKg, currentWeightKg) ||
                other.currentWeightKg == currentWeightKg) &&
            (identical(other.targetWeightKg, targetWeightKg) ||
                other.targetWeightKg == targetWeightKg) &&
            (identical(other.activityLevel, activityLevel) ||
                other.activityLevel == activityLevel) &&
            (identical(other.goalPace, goalPace) ||
                other.goalPace == goalPace) &&
            (identical(other.personalizationConsent, personalizationConsent) ||
                other.personalizationConsent == personalizationConsent) &&
            (identical(other.cloudAiConsent, cloudAiConsent) ||
                other.cloudAiConsent == cloudAiConsent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      birthDateEpochDay,
      metabolicSex,
      heightCm,
      currentWeightKg,
      targetWeightKg,
      activityLevel,
      goalPace,
      personalizationConsent,
      cloudAiConsent);

  @override
  String toString() {
    return 'PersonalProfile(birthDateEpochDay: $birthDateEpochDay, metabolicSex: $metabolicSex, heightCm: $heightCm, currentWeightKg: $currentWeightKg, targetWeightKg: $targetWeightKg, activityLevel: $activityLevel, goalPace: $goalPace, personalizationConsent: $personalizationConsent, cloudAiConsent: $cloudAiConsent)';
  }
}

/// @nodoc
abstract mixin class _$PersonalProfileCopyWith<$Res>
    implements $PersonalProfileCopyWith<$Res> {
  factory _$PersonalProfileCopyWith(
          _PersonalProfile value, $Res Function(_PersonalProfile) _then) =
      __$PersonalProfileCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int birthDateEpochDay,
      MetabolicSex metabolicSex,
      double heightCm,
      double currentWeightKg,
      double targetWeightKg,
      ActivityLevel activityLevel,
      GoalPace goalPace,
      bool personalizationConsent,
      bool cloudAiConsent});
}

/// @nodoc
class __$PersonalProfileCopyWithImpl<$Res>
    implements _$PersonalProfileCopyWith<$Res> {
  __$PersonalProfileCopyWithImpl(this._self, this._then);

  final _PersonalProfile _self;
  final $Res Function(_PersonalProfile) _then;

  /// Create a copy of PersonalProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? birthDateEpochDay = null,
    Object? metabolicSex = null,
    Object? heightCm = null,
    Object? currentWeightKg = null,
    Object? targetWeightKg = null,
    Object? activityLevel = null,
    Object? goalPace = null,
    Object? personalizationConsent = null,
    Object? cloudAiConsent = null,
  }) {
    return _then(_PersonalProfile(
      birthDateEpochDay: null == birthDateEpochDay
          ? _self.birthDateEpochDay
          : birthDateEpochDay // ignore: cast_nullable_to_non_nullable
              as int,
      metabolicSex: null == metabolicSex
          ? _self.metabolicSex
          : metabolicSex // ignore: cast_nullable_to_non_nullable
              as MetabolicSex,
      heightCm: null == heightCm
          ? _self.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double,
      currentWeightKg: null == currentWeightKg
          ? _self.currentWeightKg
          : currentWeightKg // ignore: cast_nullable_to_non_nullable
              as double,
      targetWeightKg: null == targetWeightKg
          ? _self.targetWeightKg
          : targetWeightKg // ignore: cast_nullable_to_non_nullable
              as double,
      activityLevel: null == activityLevel
          ? _self.activityLevel
          : activityLevel // ignore: cast_nullable_to_non_nullable
              as ActivityLevel,
      goalPace: null == goalPace
          ? _self.goalPace
          : goalPace // ignore: cast_nullable_to_non_nullable
              as GoalPace,
      personalizationConsent: null == personalizationConsent
          ? _self.personalizationConsent
          : personalizationConsent // ignore: cast_nullable_to_non_nullable
              as bool,
      cloudAiConsent: null == cloudAiConsent
          ? _self.cloudAiConsent
          : cloudAiConsent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Value {
  Object get field0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Value &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @override
  String toString() {
    return 'Value(field0: $field0)';
  }
}

/// @nodoc
class $ValueCopyWith<$Res> {
  $ValueCopyWith(Value _, $Res Function(Value) __);
}

/// Adds pattern-matching-related methods to [Value].
extension ValuePatterns on Value {
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
    TResult Function(Value_Int value)? int,
    TResult Function(Value_String value)? string,
    TResult Function(Value_ErrorValue value)? errorValue,
    TResult Function(Value_Error value)? error,
    TResult Function(Value_ConnectionType value)? connectionType,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case Value_Int() when int != null:
        return int(_that);
      case Value_String() when string != null:
        return string(_that);
      case Value_ErrorValue() when errorValue != null:
        return errorValue(_that);
      case Value_Error() when error != null:
        return error(_that);
      case Value_ConnectionType() when connectionType != null:
        return connectionType(_that);
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
    required TResult Function(Value_Int value) int,
    required TResult Function(Value_String value) string,
    required TResult Function(Value_ErrorValue value) errorValue,
    required TResult Function(Value_Error value) error,
    required TResult Function(Value_ConnectionType value) connectionType,
  }) {
    final _that = this;
    switch (_that) {
      case Value_Int():
        return int(_that);
      case Value_String():
        return string(_that);
      case Value_ErrorValue():
        return errorValue(_that);
      case Value_Error():
        return error(_that);
      case Value_ConnectionType():
        return connectionType(_that);
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
    TResult? Function(Value_Int value)? int,
    TResult? Function(Value_String value)? string,
    TResult? Function(Value_ErrorValue value)? errorValue,
    TResult? Function(Value_Error value)? error,
    TResult? Function(Value_ConnectionType value)? connectionType,
  }) {
    final _that = this;
    switch (_that) {
      case Value_Int() when int != null:
        return int(_that);
      case Value_String() when string != null:
        return string(_that);
      case Value_ErrorValue() when errorValue != null:
        return errorValue(_that);
      case Value_Error() when error != null:
        return error(_that);
      case Value_ConnectionType() when connectionType != null:
        return connectionType(_that);
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
    TResult Function(BigInt field0)? int,
    TResult Function(String field0)? string,
    TResult Function(ErrorType field0, String field1)? errorValue,
    TResult Function(ErrorType field0)? error,
    TResult Function(ConnectionType field0, String field1)? connectionType,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case Value_Int() when int != null:
        return int(_that.field0);
      case Value_String() when string != null:
        return string(_that.field0);
      case Value_ErrorValue() when errorValue != null:
        return errorValue(_that.field0, _that.field1);
      case Value_Error() when error != null:
        return error(_that.field0);
      case Value_ConnectionType() when connectionType != null:
        return connectionType(_that.field0, _that.field1);
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
    required TResult Function(BigInt field0) int,
    required TResult Function(String field0) string,
    required TResult Function(ErrorType field0, String field1) errorValue,
    required TResult Function(ErrorType field0) error,
    required TResult Function(ConnectionType field0, String field1)
        connectionType,
  }) {
    final _that = this;
    switch (_that) {
      case Value_Int():
        return int(_that.field0);
      case Value_String():
        return string(_that.field0);
      case Value_ErrorValue():
        return errorValue(_that.field0, _that.field1);
      case Value_Error():
        return error(_that.field0);
      case Value_ConnectionType():
        return connectionType(_that.field0, _that.field1);
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
    TResult? Function(BigInt field0)? int,
    TResult? Function(String field0)? string,
    TResult? Function(ErrorType field0, String field1)? errorValue,
    TResult? Function(ErrorType field0)? error,
    TResult? Function(ConnectionType field0, String field1)? connectionType,
  }) {
    final _that = this;
    switch (_that) {
      case Value_Int() when int != null:
        return int(_that.field0);
      case Value_String() when string != null:
        return string(_that.field0);
      case Value_ErrorValue() when errorValue != null:
        return errorValue(_that.field0, _that.field1);
      case Value_Error() when error != null:
        return error(_that.field0);
      case Value_ConnectionType() when connectionType != null:
        return connectionType(_that.field0, _that.field1);
      case _:
        return null;
    }
  }
}

/// @nodoc

class Value_Int extends Value {
  const Value_Int(this.field0) : super._();

  @override
  final BigInt field0;

  /// Create a copy of Value
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $Value_IntCopyWith<Value_Int> get copyWith =>
      _$Value_IntCopyWithImpl<Value_Int>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Value_Int &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'Value.int(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $Value_IntCopyWith<$Res> implements $ValueCopyWith<$Res> {
  factory $Value_IntCopyWith(Value_Int value, $Res Function(Value_Int) _then) =
      _$Value_IntCopyWithImpl;
  @useResult
  $Res call({BigInt field0});
}

/// @nodoc
class _$Value_IntCopyWithImpl<$Res> implements $Value_IntCopyWith<$Res> {
  _$Value_IntCopyWithImpl(this._self, this._then);

  final Value_Int _self;
  final $Res Function(Value_Int) _then;

  /// Create a copy of Value
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(Value_Int(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BigInt,
    ));
  }
}

/// @nodoc

class Value_String extends Value {
  const Value_String(this.field0) : super._();

  @override
  final String field0;

  /// Create a copy of Value
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $Value_StringCopyWith<Value_String> get copyWith =>
      _$Value_StringCopyWithImpl<Value_String>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Value_String &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'Value.string(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $Value_StringCopyWith<$Res>
    implements $ValueCopyWith<$Res> {
  factory $Value_StringCopyWith(
          Value_String value, $Res Function(Value_String) _then) =
      _$Value_StringCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$Value_StringCopyWithImpl<$Res> implements $Value_StringCopyWith<$Res> {
  _$Value_StringCopyWithImpl(this._self, this._then);

  final Value_String _self;
  final $Res Function(Value_String) _then;

  /// Create a copy of Value
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(Value_String(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class Value_ErrorValue extends Value {
  const Value_ErrorValue(this.field0, this.field1) : super._();

  @override
  final ErrorType field0;
  final String field1;

  /// Create a copy of Value
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $Value_ErrorValueCopyWith<Value_ErrorValue> get copyWith =>
      _$Value_ErrorValueCopyWithImpl<Value_ErrorValue>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Value_ErrorValue &&
            (identical(other.field0, field0) || other.field0 == field0) &&
            (identical(other.field1, field1) || other.field1 == field1));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0, field1);

  @override
  String toString() {
    return 'Value.errorValue(field0: $field0, field1: $field1)';
  }
}

/// @nodoc
abstract mixin class $Value_ErrorValueCopyWith<$Res>
    implements $ValueCopyWith<$Res> {
  factory $Value_ErrorValueCopyWith(
          Value_ErrorValue value, $Res Function(Value_ErrorValue) _then) =
      _$Value_ErrorValueCopyWithImpl;
  @useResult
  $Res call({ErrorType field0, String field1});
}

/// @nodoc
class _$Value_ErrorValueCopyWithImpl<$Res>
    implements $Value_ErrorValueCopyWith<$Res> {
  _$Value_ErrorValueCopyWithImpl(this._self, this._then);

  final Value_ErrorValue _self;
  final $Res Function(Value_ErrorValue) _then;

  /// Create a copy of Value
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
    Object? field1 = null,
  }) {
    return _then(Value_ErrorValue(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ErrorType,
      null == field1
          ? _self.field1
          : field1 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class Value_Error extends Value {
  const Value_Error(this.field0) : super._();

  @override
  final ErrorType field0;

  /// Create a copy of Value
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $Value_ErrorCopyWith<Value_Error> get copyWith =>
      _$Value_ErrorCopyWithImpl<Value_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Value_Error &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'Value.error(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $Value_ErrorCopyWith<$Res>
    implements $ValueCopyWith<$Res> {
  factory $Value_ErrorCopyWith(
          Value_Error value, $Res Function(Value_Error) _then) =
      _$Value_ErrorCopyWithImpl;
  @useResult
  $Res call({ErrorType field0});
}

/// @nodoc
class _$Value_ErrorCopyWithImpl<$Res> implements $Value_ErrorCopyWith<$Res> {
  _$Value_ErrorCopyWithImpl(this._self, this._then);

  final Value_Error _self;
  final $Res Function(Value_Error) _then;

  /// Create a copy of Value
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(Value_Error(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ErrorType,
    ));
  }
}

/// @nodoc

class Value_ConnectionType extends Value {
  const Value_ConnectionType(this.field0, this.field1) : super._();

  @override
  final ConnectionType field0;
  final String field1;

  /// Create a copy of Value
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $Value_ConnectionTypeCopyWith<Value_ConnectionType> get copyWith =>
      _$Value_ConnectionTypeCopyWithImpl<Value_ConnectionType>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Value_ConnectionType &&
            (identical(other.field0, field0) || other.field0 == field0) &&
            (identical(other.field1, field1) || other.field1 == field1));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0, field1);

  @override
  String toString() {
    return 'Value.connectionType(field0: $field0, field1: $field1)';
  }
}

/// @nodoc
abstract mixin class $Value_ConnectionTypeCopyWith<$Res>
    implements $ValueCopyWith<$Res> {
  factory $Value_ConnectionTypeCopyWith(Value_ConnectionType value,
          $Res Function(Value_ConnectionType) _then) =
      _$Value_ConnectionTypeCopyWithImpl;
  @useResult
  $Res call({ConnectionType field0, String field1});
}

/// @nodoc
class _$Value_ConnectionTypeCopyWithImpl<$Res>
    implements $Value_ConnectionTypeCopyWith<$Res> {
  _$Value_ConnectionTypeCopyWithImpl(this._self, this._then);

  final Value_ConnectionType _self;
  final $Res Function(Value_ConnectionType) _then;

  /// Create a copy of Value
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
    Object? field1 = null,
  }) {
    return _then(Value_ConnectionType(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ConnectionType,
      null == field1
          ? _self.field1
          : field1 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on

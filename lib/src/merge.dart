import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:zarainia_utils/src/widgets/exports.dart';

class _IgnoredWidget extends StatelessWidget {
  const _IgnoredWidget();

  @override
  Widget build(BuildContext context) {
    return const EmptyContainer();
  }
}

class IgnoredFuture<T> implements Future<T> {
  const IgnoredFuture();

  @override
  Stream<T> asStream() {
    throw UnimplementedError();
  }

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) {
    throw UnimplementedError();
  }

  @override
  Future<R> then<R>(FutureOr<R> Function(T value) onValue, {Function? onError}) {
    throw UnimplementedError();
  }

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) {
    throw UnimplementedError();
  }

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) {
    throw UnimplementedError();
  }
}

const String IGNORED_STRING_VALUE = "__%IGNORED%__";
const List<int> IGNORED_UINT8LIST_VALUE = [40244];
const Widget IGNORED_WIDGET_VALUE = const _IgnoredWidget();
const FutureOr<bool?> IGNORED_BOOL_VALUE = const IgnoredFuture<bool?>();
const FutureOr<int?> IGNORED_INT_VALUE = const IgnoredFuture<int?>();
const FutureOr<double?> IGNORED_DOUBLE_VALUE = const IgnoredFuture<double?>();

String? ignore_string_parameter(String? param, String? field) => param == IGNORED_STRING_VALUE ? field : param;

int? ignore_positive_int_parameter(int? param, int? field) => param != null && param < 0 ? field : param;

int? ignore_int_parameter(FutureOr<int?> param, int? field) => param is Future ? field : param;

double? ignore_positive_double_parameter(double? param, double? field) => param != null && param < 0 ? field : param;

double? ignore_double_parameter(FutureOr<double?> param, double? field) => param is Future ? field : param;

Uint8List? ignore_uint8list_parameter(List<int>? param, Uint8List? field) => (param != IGNORED_UINT8LIST_VALUE && param is Uint8List?) ? param : field;

bool? ignore_bool_parameter(FutureOr<bool?> param, bool? field) => param is Future ? field : param;

Widget? ignore_widget_parameter(Widget? param, Widget? field) => param is _IgnoredWidget ? field : param;

T? ignore_generic_parameter<T>(FutureOr<T?> param, T? field) => param is Future ? field : param;

Object? ignore_object_parameter(Object? param, Object? field) => param == IGNORED_STRING_VALUE ? field : param;

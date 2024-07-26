import 'dart:async';

import 'package:sqflite/sqflite.dart';

abstract class ExtendedDatabaseMixin implements Database {
  @override
  Future<T> devInvokeMethod<T>(String method, [Object? arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<T> devInvokeSqlMethod<T>(String method, String sql, [List<Object?>? arguments]) {
    throw UnimplementedError();
  }
}

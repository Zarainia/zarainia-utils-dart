import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

enum DatabaseActionType { QUERY, INSERT, UPDATE, DELETE, EXECUTE }

abstract class BaseDatabaseLike {
  Future<void> close();

  Future<T> transaction<T>(Future<T> action(DatabaseExecutor txn), {bool? exclusive});
}

abstract class DatabaseAction<T> {
  final DatabaseActionType type;

  const DatabaseAction(this.type);

  Future<T> apply(DatabaseExecutor database);
}

abstract class RawDatabaseAction<T> extends DatabaseAction<T> {
  final String sql;
  final List<Object?> arguments;

  const RawDatabaseAction(super.type, this.sql, [List<Object?>? arguments]) : arguments = arguments ?? const [];
}

class RawInsertDatabaseAction extends RawDatabaseAction<int> {
  const RawInsertDatabaseAction(String sql, [List<Object?>? arguments]) : super(DatabaseActionType.INSERT, sql, arguments);

  @override
  Future<int> apply(DatabaseExecutor database) {
    return database.rawInsert(sql, arguments);
  }
}

class RawUpdateDatabaseAction extends RawDatabaseAction<int> {
  const RawUpdateDatabaseAction(String sql, [List<Object?>? arguments]) : super(DatabaseActionType.UPDATE, sql, arguments);

  @override
  Future<int> apply(DatabaseExecutor database) {
    return database.rawUpdate(sql, arguments);
  }
}

class RawDeleteDatabaseAction extends RawDatabaseAction<int> {
  const RawDeleteDatabaseAction(String sql, [List<Object?>? arguments]) : super(DatabaseActionType.DELETE, sql, arguments);

  @override
  Future<int> apply(DatabaseExecutor database) {
    return database.rawDelete(sql, arguments);
  }
}

class ExecuteDatabaseAction extends RawDatabaseAction<void> {
  const ExecuteDatabaseAction(String sql, [List<Object?>? arguments]) : super(DatabaseActionType.EXECUTE, sql, arguments);

  @override
  Future<void> apply(DatabaseExecutor database) {
    return database.execute(sql, arguments);
  }
}

class InsertDatabaseAction extends DatabaseAction<int> {
  final String table;
  final Map<String, Object?> values;
  final String? nullColumnHack;
  final ConflictAlgorithm? conflictAlgorithm;

  const InsertDatabaseAction(this.table, this.values, {this.nullColumnHack, this.conflictAlgorithm}) : super(DatabaseActionType.INSERT);

  @override
  Future<int> apply(DatabaseExecutor database) {
    return database.insert(table, values, nullColumnHack: nullColumnHack, conflictAlgorithm: conflictAlgorithm);
  }
}

class UpdateDatabaseAction extends DatabaseAction<int> {
  final String table;
  final Map<String, Object?> values;
  final String? where;
  final List<Object?>? whereArgs;
  final ConflictAlgorithm? conflictAlgorithm;

  const UpdateDatabaseAction(this.table, this.values, {this.where, this.whereArgs, this.conflictAlgorithm}) : super(DatabaseActionType.UPDATE);

  @override
  Future<int> apply(DatabaseExecutor database) {
    return database.update(table, values, where: where, whereArgs: whereArgs, conflictAlgorithm: conflictAlgorithm);
  }
}

class DeleteDatabaseAction extends DatabaseAction<int> {
  final String table;
  final String? where;
  final List<Object?>? whereArgs;

  const DeleteDatabaseAction(this.table, {this.where, this.whereArgs}) : super(DatabaseActionType.DELETE);

  @override
  Future<int> apply(DatabaseExecutor database) {
    return database.delete(table, where: where, whereArgs: whereArgs);
  }
}

abstract class BaseTrackedDatabase extends DatabaseExecutor {
  List<DatabaseAction> actions;
  StreamController<DatabaseAction> action_stream_controller = StreamController();

  DatabaseExecutor get internal_database;

  BaseTrackedDatabase({List<DatabaseAction>? existing_actions}) : actions = existing_actions ?? [];

  @override
  Future<List<Map<String, Object?>>> query(String table,
      {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) {
    return internal_database.query(table, distinct: distinct, columns: columns, where: where, whereArgs: whereArgs, groupBy: groupBy, having: having, orderBy: orderBy, limit: limit, offset: offset);
  }

  @override
  Future<QueryCursor> queryCursor(String table,
      {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset, int? bufferSize}) {
    return internal_database.queryCursor(table,
        distinct: distinct, columns: columns, where: where, whereArgs: whereArgs, groupBy: groupBy, having: having, orderBy: orderBy, limit: limit, offset: offset, bufferSize: bufferSize);
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) {
    return internal_database.rawQuery(sql, arguments);
  }

  @override
  Future<QueryCursor> rawQueryCursor(String sql, List<Object?>? arguments, {int? bufferSize}) {
    return internal_database.rawQueryCursor(sql, arguments);
  }

  void add_action(DatabaseAction action) {
    actions.add(action);
    action_stream_controller.add(action);
  }

  Future<T> add_and_apply<T>(DatabaseAction<T> action) {
    add_action(action);
    return action.apply(internal_database);
  }

  @override
  Future<int> insert(String table, Map<String, Object?> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) {
    return add_and_apply(InsertDatabaseAction(table, values, nullColumnHack: nullColumnHack, conflictAlgorithm: conflictAlgorithm));
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) {
    return add_and_apply(RawInsertDatabaseAction(sql, arguments));
  }

  @override
  Future<int> update(String table, Map<String, Object?> values, {String? where, List<Object?>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) {
    return add_and_apply(UpdateDatabaseAction(table, values, where: where, whereArgs: whereArgs, conflictAlgorithm: conflictAlgorithm));
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) {
    return add_and_apply(RawUpdateDatabaseAction(sql, arguments));
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    return add_and_apply(DeleteDatabaseAction(table, where: where, whereArgs: whereArgs));
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) {
    return add_and_apply(RawDeleteDatabaseAction(sql, arguments));
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) {
    return add_and_apply(ExecuteDatabaseAction(sql, arguments));
  }

  Future reapply_all(DatabaseExecutor target) async {
    for (DatabaseAction action in actions) await action.apply(target);
  }

  @override
  Batch batch() {
    return internal_database.batch();
  }
}

class TrackedDatabase extends BaseTrackedDatabase implements BaseDatabaseLike {
  Database internal_database;

  TrackedDatabase(this.internal_database, {super.existing_actions});

  @override
  Database get database => internal_database;

  @override
  Future<T> transaction<T>(Future<T> Function(TrackedTransaction txn) action, {bool? exclusive}) async {
    TrackedTransaction? tracked_transaction;
    T result = await internal_database.transaction((Transaction transaction) {
      tracked_transaction = TrackedTransaction(transaction);
      return action(tracked_transaction!);
    });
    for (DatabaseAction action in tracked_transaction!.actions) {
      add_action(action);
    }
    return result;
  }

  @override
  Future<void> close() async {
    await internal_database.close();
  }
}

class TrackedTransaction extends BaseTrackedDatabase {
  Transaction internal_database;

  TrackedTransaction(this.internal_database, {super.existing_actions});

  @override
  Database get database => internal_database.database;
}

class SavepointedDatabase extends BaseTrackedDatabase implements BaseDatabaseLike {
  static Uuid _uuid_gen = Uuid();

  Database disk_database;
  List<TrackedDatabase> database_stack = [];
  Future? database_ready;
  StreamController<TrackedDatabase> database_stream_controller = StreamController.broadcast();

  @override
  Database get database => disk_database;

  TrackedDatabase get internal_database => database_stack.last;

  SavepointedDatabase(this.disk_database, {super.existing_actions}) {
    _init_database();
  }

  Future _init_database() async {
    push_savepoint();
  }

  String _get_memory_database_path() => "file:${_uuid_gen.v4()}?mode=memory&cache=shared";

  Future<TrackedDatabase> _copy_db_to_memory(Database db) async {
    Database memory_database = await openDatabase(_get_memory_database_path());
    await memory_database.execute("ATTACH DATABASE ? as prev_database", [db.path]);
    List<Map<String, dynamic>> tables_info =
        await memory_database.query("prev_database.sqlite_master", where: "type = ? AND name != ?", whereArgs: ["table", "sqlite_sequence"], columns: ["name", "sql"]);
    for (Map<String, dynamic> table_info in tables_info) {
      String table_name = table_info["name"]!;
      await memory_database.execute(table_info["sql"]!);
      await memory_database.execute("INSERT INTO main.${table_name} SELECT * FROM prev_database.${table_name}");
    }

    try {
      await memory_database.execute("DELETE FROM main.sqlite_sequence");
      await memory_database.execute("INSERT INTO main.sqlite_sequence SELECT * FROM prev_database.sqlite_sequence");
    } catch (e) {
      log("Could not clone sqlite_sequence; probably didn't exist in original database", error: e);
    }
    await memory_database.execute("DETACH DATABASE prev_database");
    await memory_database.execute("PRAGMA foreign_keys = true");
    return TrackedDatabase(memory_database, existing_actions: database_stack.lastOrNull?.actions ?? []);
  }

  Future _create_savepoint() async {
    database_stack.add(await _copy_db_to_memory(database_stack.isEmpty ? disk_database : internal_database.internal_database));
    database_stream_controller.sink.add(internal_database);
  }

  Future push_savepoint() async {
    if (database_ready != null) await database_ready;
    database_ready = _create_savepoint();
    await database_ready;
  }

  Future _clear_database_stack() async {
    while (database_stack.isNotEmpty) await database_stack.removeLast().close();
  }

  Future persist() async {
    await database_ready;
    await internal_database.reapply_all(disk_database);
  }

  Future _commit_last() async {
    assert(database_stack.length == 1);
    await persist();
    await database_stack.removeLast().close();
    push_savepoint();
  }

  Future commit_savepoint() async {
    await database_ready;
    assert(database_stack.length >= 1);
    if (database_stack.length == 1)
      await _commit_last();
    else {
      await database_stack.removeAt(database_stack.length - 2).close();
    }
  }

  Future commit_all() async {
    await persist();
    await _clear_database_stack();
    await push_savepoint();
  }

  @override
  Future<T> transaction<T>(Future<T> Function(DatabaseExecutor txn) action, {bool? exclusive}) async {
    TrackedTransaction? tracked_transaction;
    T result = await internal_database.transaction((TrackedTransaction transaction) {
      tracked_transaction = transaction;
      return action(tracked_transaction!);
    });
    for (DatabaseAction action in tracked_transaction!.actions) {
      add_action(action);
    }
    return result;
  }

  Future close() async {
    await database_ready;
    await _clear_database_stack();
    await disk_database.close();
  }
}

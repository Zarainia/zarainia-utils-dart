import 'package:sqflite/sqflite.dart';

abstract class PositionedDatabaseManager<DatabaseType extends DatabaseExecutor, IDType> {
  String get positioned_table_;

  String get position_column_;

  String get position_table_id_column_ => "id";

  DatabaseType get database;

  Future make_position_gap_(int position, {DatabaseExecutor? database}) async {
    database = database ?? this.database;
    return await database.rawUpdate("UPDATE ${positioned_table_} SET ${position_column_} = ${position_column_} + 1 WHERE ${position_column_} >= ?", [position]);
  }

  Future remove_position_gap_(int position, {DatabaseExecutor? database}) async {
    database = database ?? this.database;
    return await database.rawUpdate("UPDATE ${positioned_table_} SET ${position_column_} = ${position_column_} - 1 WHERE ${position_column_} >= ?", [position]);
  }

  Future reorder_(IDType id, int from, int to, {required DatabaseExecutor database}) async {
    database = database ?? this.database;
    if (from == to)
      return;
    else if (to > from)
      await database.rawUpdate(
          "UPDATE ${positioned_table_} SET ${position_column_} = ${position_column_} - 1 WHERE ${position_column_} > ? AND ${position_column_} <= ? AND ${position_table_id_column_} != ?",
          [from, to, id]);
    else
      await database.rawUpdate(
          "UPDATE ${positioned_table_} SET ${position_column_} = ${position_column_} + 1 WHERE ${position_column_} >= ? AND ${position_column_} < ? AND ${position_table_id_column_} != ?",
          [to, from, id]);
    await database.update(positioned_table_, {position_column_: to}, where: "${position_table_id_column_} = ?", whereArgs: [id]);
  }
}

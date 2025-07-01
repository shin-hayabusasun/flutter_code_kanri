import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

class DBHelper {
  static late Database _db;

  // 初期化（アプリ起動時に一度だけ呼ぶ）
  static Future<void> init() async {
    final docDir = Directory(
      p.join(
        Platform.environment['USERPROFILE'] ?? '',
        'Documents',
      ), //C:\Users\（あなたのユーザー名）\Documents\file.db
    );
    if (!docDir.existsSync()) {
      docDir.createSync(recursive: true);
    }
    final dbPath = p.join(docDir.path, 'file.db');
    _db = sqlite3.open(dbPath);

    // テーブルがなければ作成　　CREATE TABLE IF NOT EXISTS なので「テーブルがなければ作成」
    _db.execute('''
      CREATE TABLE IF NOT EXISTS file (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT
      );
      CREATE TABLE IF NOT EXISTS code (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT    ,
        fileid INTEGER,
        desprite TEXT
      );
    ''');
  }

  // データの挿入
  static int insertFile(String title) {
    final stmt = _db.prepare('INSERT INTO file (title) VALUES (?);');
    stmt.execute([title]);
    stmt.dispose();
    return _db.getUpdatedRows();
  }

  // データの取得（全件）
  static List<Map<String, Object?>> getFiles() {
    final result = _db.select('SELECT * FROM file;');
    return result.map((row) => Map<String, Object?>.from(row)).toList();
  }

  // データの取得（ID指定）
  static Future<Map<String, dynamic>?> getFileById(int id) async {
    final result = _db.select('SELECT * FROM file WHERE id = ?;', [id]);
    if (result.isNotEmpty) {
      return Map<String, dynamic>.from(result.first);
    }
    return null;
  }

  // データの更新
  static int updateFile(int id, String title) {
    final stmt = _db.prepare('UPDATE file SET title = ? WHERE id = ?;');
    stmt.execute([title, id]);
    stmt.dispose();
    return _db.getUpdatedRows();
  }

  static int insertCode(String title, int fileid, String desprite) {
    final stmt = _db.prepare(
      'INSERT INTO code (title, fileid, desprite) VALUES (?, ?, ?);',
    );
    stmt.execute([title, fileid, desprite]);
    stmt.dispose();
    return _db.getUpdatedRows();
  }

  static Future<List<Map<String, dynamic>?>> getCode(int fileid) async {
    final result = _db.select('SELECT * FROM code WHERE fileid = ?;', [fileid]);
    return result.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  static Future<Map<String, dynamic>?> getOneCode(int id) async {
    final result = _db.select('SELECT * FROM code WHERE id = ?;', [id]);
    return Map<String, dynamic>.from(result.first);
  }

  static int updateCode(int id, String title, String desprite) {
    final stmt = _db.prepare(
      'UPDATE code SET title = ?, desprite = ? WHERE id = ?;',
    );
    stmt.execute([title, desprite, id]);
    stmt.dispose();
    return _db.getUpdatedRows();
  }

  static int deleteCode(int id) {
    final stmt = _db.prepare('DELETE FROM code WHERE id = ?;');
    stmt.execute([id]);
    stmt.dispose();
    return _db.getUpdatedRows();
  }

  static int deleteFile(int id) {
    // まずcodeテーブルの関連データを削除
    final stmtCode = _db.prepare('DELETE FROM code WHERE fileid = ?;');
    stmtCode.execute([id]);
    stmtCode.dispose();

    // 次にfileテーブルのデータを削除
    final stmtFile = _db.prepare('DELETE FROM file WHERE id = ?;');
    stmtFile.execute([id]);
    stmtFile.dispose();

    return _db.getUpdatedRows();
  }
}

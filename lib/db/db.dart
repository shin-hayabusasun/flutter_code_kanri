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
        title TEXT
        fileid INTEGER
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

  static int insertCode(String title, int fileid) {
    final stmt = _db.prepare('INSERT INTO code (title, fileid) VALUES (?, ?);');
    stmt.execute([title, fileid]);
    stmt.dispose();
    return _db.getUpdatedRows();
  }

  static Future<List<Map<String, dynamic>?>> getCode(int fileid) async {
    final result = _db.select('SELECT * FROM code WHERE fileid = ?;', [fileid]);
    return result.map((row) => Map<String, dynamic>.from(row)).toList();
  }
}

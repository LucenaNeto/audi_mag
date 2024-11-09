import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'auditoria.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE auditorias (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE perguntas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            auditoriaId INTEGER,
            pergunta TEXT,
            observacao TEXT,
            imagem TEXT,
            resposta TEXT,
            FOREIGN KEY (auditoriaId) REFERENCES auditorias(id)
          )
        ''');
      },
    );
  }

  Future<int> salvarAuditoria(String nome) async {
    final db = await database;
    return await db.insert('auditorias', {'nome': nome});
  }

  Future<int> salvarPergunta(int auditoriaId, String pergunta,
      String observacao, String? imagem) async {
    final db = await database;
    return await db.insert('perguntas', {
      'auditoriaId': auditoriaId,
      'pergunta': pergunta,
      'observacao': observacao,
      'imagem': imagem,
      'resposta': null
    });
  }

  Future<List<Map<String, dynamic>>> buscarPerguntasDaAuditoria(
      int auditoriaId) async {
    final db = await database;
    return await db.query(
      'perguntas',
      where: 'auditoriaId = ?',
      whereArgs: [auditoriaId],
    );
  }

  // Funções para obter e excluir auditorias/
}

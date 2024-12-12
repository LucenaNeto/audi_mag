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
      version: 8,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE auditorias (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            data_criacao TEXT
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

        await db.execute('''
          CREATE TABLE perguntas_padrao(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pergunta TEXT,
            observacao TEXT,
            imagem TEXT,
            canal TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE imagens_perguntas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            perguntaId INTEGER,
            caminho TEXT,
            FOREIGN KEY (perguntaId) REFERENCES pergunta(id)
          )
        ''');
      },
      onUpgrade: _onUpgrade, // Chamando o método onUpgrade
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Adiciona coluna 'data_criacao' na tabela 'auditorias'
      await db.execute('ALTER TABLE auditorias ADD COLUMN data_criacao TEXT');
    }
    if (oldVersion < 5) {
      // Adiciona coluna 'canal' na tabela 'perguntas_padrao'
      await db.execute('ALTER TABLE perguntas_padrao ADD COLUMN canal TEXT');
    }
    if (oldVersion < 6) {
      // Cria a tabela 'imagens_perguntas'
      await db.execute('''
      CREATE TABLE imagens_perguntas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        perguntaId INTEGER,
        caminho TEXT,
        FOREIGN KEY (perguntaId) REFERENCES perguntas(id)
      )
    ''');
    }
  }

  Future<int> salvarImagemParaPergunta(int perguntaId, String caminho) async {
    final db = await database;
    return await db.insert('imagens_perguntas', {
      'perguntaId': perguntaId,
      'caminho': caminho,
    });
  }

  Future<int> salvarImagem(int perguntaId, String caminho) async {
    final db = await database;
    return await db.insert('imagens', {
      'perguntaId': perguntaId,
      'caminho': caminho,
    });
  }

  // Métodos para manipular auditorias
  Future<int> salvarAuditoria(String nome) async {
    final db = await database;
    final dataCriacao = DateTime.now().toIso8601String();
    return await db.insert('auditorias', {
      'nome': nome,
      'data_criacao': dataCriacao,
    });
  }

  Future<int> criarNovaAuditoria(String nomeAuditoria) async {
    final auditoriaId = await salvarAuditoria(nomeAuditoria);
    return auditoriaId;
  }

  // Métodos para manipular perguntas
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

  Future<int> salvarPerguntaPadrao(
      String pergunta, String? observacao, String canal) async {
    final db = await database;
    return await db.insert('perguntas_padrao', {
      'pergunta': pergunta,
      'observacao': observacao ?? '',
      'imagem': null,
      'canal': canal,
    });
  }

  Future<List<Map<String, dynamic>>> buscarPerguntasPadrao() async {
    final db = await database;
    return await db.query('perguntas_padrao');
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

  Future<Map<String, dynamic>> buscarAuditoriaPorId(int id) async {
    final db = await database;
    final result = await db.query(
      'auditorias',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      throw Exception('Auditoria não encontrada pelo ID: $id');
    }
    return {};
  }

  // Métodos para  perguntas padrão a auditorias
  Future<void> adicionarPerguntasSelecionadasAAuditoria(
      int auditoriaId, List<int> perguntaIds) async {
    final db = await database;
    for (var perguntaId in perguntaIds) {
      final pergunta = await db.query(
        'perguntas_padrao',
        where: 'id = ?',
        whereArgs: [perguntaId],
      );

      if (pergunta.isNotEmpty) {
        await db.insert('perguntas', {
          'auditoriaId': auditoriaId,
          'pergunta': pergunta[0]['pergunta'],
          'observacao': pergunta[0]['observacao'],
          'imagem': pergunta[0]['imagem'],
          'resposta': null,
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> obterPerguntasPadrao() async {
    final db = await database;
    return await db.query('perguntas_padrao');
  }

  Future<int> atualizarPerguntaPadrao(
      int id, String novaPergunta, String novaObservacao) async {
    final db = await database;
    return await db.update(
      'perguntas_padrao',
      {'pergunta': novaPergunta, 'observacao': novaObservacao},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> excluirPerguntaPadrao(int id) async {
    final db = await database;
    return await db.delete(
      'perguntas_padrao',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> excluirImagensPorPergunta(int perguntId) async {
    final db = await database;
    return await db.delete(
      'imagens_perguntas',
      where: 'perguntaId = ?',
      whereArgs: [perguntId],
    );
  }

  // nova função de divisão de vd e loja
  Future<List<Map<String, dynamic>>> buscarPerguntasPorCanal(
      String canal) async {
    final db = await database;
    return await db.query(
      'perguntas_padrao',
      where: 'canal = ?',
      whereArgs: [canal],
    );
  }

  Future<List<Map<String, dynamic>>> buscarImagensPorPergunta(
      int perguntaId) async {
    final db = await database;
    return await db.query(
      'imagens_perguntas',
      where: 'perguntaId = ?',
      whereArgs: [perguntaId],
    );
  }

  Future<Map<String ,dynamic>> exportarDados() async {
    final db = await database;

    final auditorias = await db.query('auditorias');
    final perguntas = await db.query('perguntas');
    final imagens = await db.query('imagens_perguntas');

    return {
      'auditorias': auditorias,
      'perguntas': perguntas,
      'imagens':imagens,
    };
  }
}

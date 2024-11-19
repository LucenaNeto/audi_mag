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
      version: 3,
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

        await db.execute('''
          CREATE TABLE perguntas_padrao(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pergunta TEXT,
            observacao TEXT,
            imagem TEXT,
            dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Adicione a coluna `canal` se estiver atualizando de uma versão anterior
        if (oldVersion < 3) {
          await db
              .execute('ALTER TABLE perguntas_padrao ADD COLUMN canal TEXT');
        }
      },
    );
  }

  // Métodos para manipular auditorias
  Future<int> salvarAuditoria(String nome) async {
    final db = await database;
    return await db.insert('auditorias', {'nome': nome});
  }

  Future<int> criarNovaAuditoria(String nomeAuditoria) async {
    final auditoriaId = await salvarAuditoria(nomeAuditoria);
    await adicionarPerguntasPadraoPreDefinidas(auditoriaId);
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

  // Perguntas predefinidas para adicionar automaticamente a novas auditorias
  List<Map<String, dynamic>> perguntasPadraoPreDefinidas = [
    {
      'pergunta': 'Qual é o estado geral?',
      'observacao': '',
      'imagem': null,
      'resposta': null
    },
    {
      'pergunta': 'O local está limpo?',
      'observacao': '',
      'imagem': null,
      'resposta': null
    },
    {
      'pergunta': 'Produto vencido?',
      'observacao': '',
      'imagem': null,
      'resposta': null
    },
  ];

  Future<void> adicionarPerguntasPadraoPreDefinidas(int auditoriaId) async {
    final db = await database;
    for (var pergunta in perguntasPadraoPreDefinidas) {
      await db.insert('perguntas', {
        'auditoriaId': auditoriaId,
        'pergunta': pergunta['pergunta'],
        'observacao': pergunta['observacao'],
        'imagem': pergunta['imagem'],
        'resposta': pergunta['resposta']
      });
    }
  }

  // Métodos para  perguntas padrão  a  auditorias
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
}

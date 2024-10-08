import 'package:flutter/material.dart';
import 'package:audi_mag/db_helper.dart';
import 'dart:io';

class TelaVisualizarAuditoria extends StatefulWidget {
  final int auditoriaId;
  final String nomeAuditoria;

  TelaVisualizarAuditoria(
      {required this.auditoriaId, required this.nomeAuditoria});

  @override
  _TelaVisualizarAuditoriaState createState() =>
      _TelaVisualizarAuditoriaState();
}

class _TelaVisualizarAuditoriaState extends State<TelaVisualizarAuditoria> {
  List<Map<String, dynamic>> _perguntas = [];

  @override
  void initState() {
    super.initState();
    _carregarPerguntas();
  }

  Future<void> _carregarPerguntas() async {
    final db = await DBHelper().database;
    final perguntas = await db.query(
      'perguntas',
      where: 'auditoriaId = ?',
      whereArgs: [widget.auditoriaId],
    );
    setState(() {
      _perguntas = perguntas;
    });
  }

  Future<void> _excluirPergunta(int perguntaId) async {
    final db = await DBHelper().database;
    await db.delete(
      'perguntas',
      where: 'id = ?',
      whereArgs: [perguntaId],
    );
    _carregarPerguntas();
  }

  Future<void> _editarPergunta(
      int perguntaId, String novaPergunta, String novaObservacao) async {
    final db = await DBHelper().database;
    await db.update(
      'perguntas',
      {
        'pergunta': novaPergunta,
        'observacao': novaObservacao,
      },
      where: 'id = ?',
      whereArgs: [perguntaId],
    );
    _carregarPerguntas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auditoria: ${widget.nomeAuditoria}'),
      ),
      body: ListView.builder(
        itemCount: _perguntas.length,
        itemBuilder: (context, index) {
          final pergunta = _perguntas[index];
          return ListTile(
            title: Text(pergunta['pergunta']),
            subtitle: Text(pergunta['observacao'] ?? ''),
            leading: pergunta['imagem'] != null
                ? Image.file(File(pergunta['imagem']), width: 50, height: 50)
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _mostrarDialogoEditarPergunta(pergunta['id'],
                        pergunta['pergunta'], pergunta['observacao']);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _confirmarExclusaoPergunta(pergunta['id']);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmarExclusaoPergunta(int perguntaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir esta pergunta?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () {
                _excluirPergunta(perguntaId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEditarPergunta(
      int perguntaId, String perguntaAtual, String observacaoAtual) {
    String novaPergunta = perguntaAtual;
    String novaObservacao = observacaoAtual;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Pergunta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Pergunta'),
                controller: TextEditingController(text: perguntaAtual),
                onChanged: (value) {
                  novaPergunta = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Observação'),
                controller: TextEditingController(text: observacaoAtual),
                onChanged: (value) {
                  novaObservacao = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () {
                _editarPergunta(perguntaId, novaPergunta, novaObservacao);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

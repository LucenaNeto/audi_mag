import 'package:flutter/material.dart';
import 'package:audi_mag/db_helper.dart';
import 'dart:io';
import 'package:audi_mag/screens/tela_exibir_imagem.dart';

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

  Future<void> _salvarResposta(int perguntaId, String resposta) async {
    final db = await DBHelper().database;
    await db.update(
      'perguntas',
      {'resposta': resposta},
      where: 'id = ?',
      whereArgs: [perguntaId],
    );
  }

  Future<void> _excluirPergunta(int perguntaId) async {
    final db = await DBHelper().database;
    await db.delete(
      'perguntas',
      where: 'id = ?',
      whereArgs: [perguntaId],
    );
    _carregarPerguntas();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pergunta excluída com sucesso')),
    );
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
          String? resposta = pergunta['resposta'];

          return Card(
            // Adição do Card para melhorar o layout
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pergunta['pergunta'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(pergunta['observacao'] ?? ''),
                  SizedBox(height: 10),
                  pergunta['imagem'] != null
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TelaExibirImagem(
                                  caminhoImagem: pergunta['imagem'],
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              File(pergunta['imagem']),
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Sim'),
                        value: 'Sim',
                        groupValue: resposta,
                        onChanged: (String? value) {
                          setState(() {
                            resposta = value;
                          });
                          Future.microtask(
                              () => _salvarResposta(pergunta['id'], value!));
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Não'),
                        value: 'Não',
                        groupValue: resposta,
                        onChanged: (String? value) {
                          setState(() {
                            resposta = value;
                          });
                          Future.microtask(
                              () => _salvarResposta(pergunta['id'], value!));
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                ],
              ),
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

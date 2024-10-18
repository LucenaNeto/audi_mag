//import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audi_mag/db_helper.dart';

class TelaAdicionarPerguntas extends StatefulWidget {
  final int auditoriaId;

  TelaAdicionarPerguntas({required this.auditoriaId});

  @override
  _TelaAdicionarPerguntasState createState() => _TelaAdicionarPerguntasState();
}

class _TelaAdicionarPerguntasState extends State<TelaAdicionarPerguntas> {
  final List<Map<String, dynamic>> _perguntas = [];
  String novaPergunta = '';
  String observacao = '';

  // controladores de campo

  TextEditingController perguntaController = TextEditingController();
  TextEditingController observacaoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Adicionar Perguntas',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(132, 10, 66, 32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: perguntaController,
                      decoration: InputDecoration(labelText: 'Pergunta'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a pergunta';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: observacaoController,
                      decoration:
                          InputDecoration(labelText: 'Observação (opcional)'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (perguntaController.text.isNotEmpty) {
                  await DBHelper().salvarPergunta(
                    widget.auditoriaId,
                    perguntaController.text,
                    observacaoController.text,
                    null, // Removido campo de imagem
                  );
                  setState(() {
                    _perguntas.add({
                      'pergunta': perguntaController.text,
                      'observacao': observacaoController.text,
                      'resposta': null,
                    });
                    perguntaController.clear();
                    observacaoController.clear();
                  });
                }
              },
              child: Text('Adicionar Pergunta'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _perguntas.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _perguntas[index]['pergunta'] ?? 'Sem pergunta',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10),
                          // Exibe a observação se houver
                          Text(
                            _perguntas[index]['observacao']?.isNotEmpty == true
                                ? _perguntas[index]['observacao']
                                : 'Sem Observação',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _perguntas.removeAt(index);
                                  });
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    //libertar os controladores, para evitar vazar memoria
    perguntaController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

//futuramente vou colocar as funções aqui caso nas minhas pesquisas eu ver que seja interessante
}

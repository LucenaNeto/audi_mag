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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Perguntas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Pergunta'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a pergunta';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        novaPergunta = value;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Observação (opcional)'),
                      onChanged: (value) {
                        observacao = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (novaPergunta.isNotEmpty) {
                  await DBHelper().salvarPergunta(
                    widget.auditoriaId,
                    novaPergunta,
                    observacao,
                    null, // Removido campo de imagem
                  );
                  setState(() {
                    _perguntas.add({
                      'pergunta': novaPergunta,
                      'observacao': observacao,
                      'resposta': null,
                    });
                    novaPergunta = '';
                    observacao = '';
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
                            _perguntas[index]['observacao'] ?? 'Sem observação',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // Função para editar - ainda falta ser implementada
                                },
                              ),
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
}

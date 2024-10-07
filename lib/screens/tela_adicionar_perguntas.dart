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
            TextFormField(
              decoration: InputDecoration(labelText: 'Pergunta'),
              onChanged: (value) {
                novaPergunta = value;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: 'Observação (opcional)'),
              onChanged: (value) {
                observacao = value;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (novaPergunta.isNotEmpty) {
                  await DBHelper().salvarPergunta(
                      widget.auditoriaId, novaPergunta, observacao);
                  setState(() {
                    _perguntas.add({
                      'pergunta': novaPergunta,
                      'observacao': observacao,
                      'imagem': null, // Para imagem futura
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
                  return ListTile(
                    title: Text(_perguntas[index]['pergunta']),
                    subtitle: Text(_perguntas[index]['observacao'] ?? ''),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _perguntas.removeAt(index);
                        });
                      },
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

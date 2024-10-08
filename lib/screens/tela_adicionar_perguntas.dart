import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
  File? imagemSelecionada;

  final ImagePicker _picker = ImagePicker();

  Future<void> _selecionarImagem() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagemSelecionada = File(pickedFile.path);
      });
    }
  }

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
            SizedBox(height: 10),
            imagemSelecionada != null
                ? Image.file(imagemSelecionada!)
                : Container(),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _selecionarImagem,
              child: Text('Anexar Imagem'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (novaPergunta.isNotEmpty) {
                  await DBHelper().salvarPergunta(
                    widget.auditoriaId,
                    novaPergunta,
                    observacao,
                    imagemSelecionada?.path, // Salvando o caminho da imagem
                  );
                  setState(() {
                    _perguntas.add({
                      'pergunta': novaPergunta,
                      'observacao': observacao,
                      'imagem': imagemSelecionada?.path,
                      'resposta': null,
                    });
                    novaPergunta = '';
                    observacao = '';
                    imagemSelecionada = null;
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

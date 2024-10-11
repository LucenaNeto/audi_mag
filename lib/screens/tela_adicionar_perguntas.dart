import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:audi_mag/db_helper.dart';
import 'package:audi_mag/screens/tela_exibir_imagem.dart';

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
                          return 'Por favor, Insira a pergunta';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        novaPergunta = value; // atualiza o valor da pergunta
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Observação (opcional)'),
                      onChanged: (value) {
                        observacao = value; // atualiza o valor da observação
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
                            _perguntas[index]['observação'] ?? 'Sem observação',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          SizedBox(height: 10),
                          _perguntas[index]['imagem'] != null
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TelaExibirImagem(
                                          caminhoImagem: _perguntas[index]
                                              ['imagem'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.file(
                                    File(_perguntas[index]['imagem']),
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Text('Nenhuma Image anexada'),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  //função para editar - ainda falta ser implementada
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

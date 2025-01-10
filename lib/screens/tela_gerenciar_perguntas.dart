import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audi_mag/db_helper.dart';
import 'package:file_picker/file_picker.dart';

class TelaGerenciarPerguntas extends StatefulWidget {
  @override
  _TelaGerenciarPerguntasState createState() => _TelaGerenciarPerguntasState();
}

class _TelaGerenciarPerguntasState extends State<TelaGerenciarPerguntas> {
  final TextEditingController perguntaController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();
  String canalSelecionado = 'Loja';
  List<Map<String, dynamic>> perguntas = [];

  @override
  void initState() {
    super.initState();
    carregarPerguntas();
  }

  Future<void> carregarPerguntas() async {
    final dbHelper = DBHelper();
    final data = await dbHelper.obterPerguntasPadrao();
    setState(() {
      perguntas = data;
    });
  }

  Future<void> importarPerguntas() async {
    try {
      // Seleciona o arquivo .txt
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'], // Apenas arquivos .txt
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final lines = await file.readAsLines();

        // Processa cada linha como uma pergunta
        for (String line in lines) {
          if (line.trim().isEmpty) continue; // Ignora linhas em branco

          final parts = line.split('|');
          final pergunta = parts[0].trim();
          final observacao = parts.length > 1 ? parts[1].trim() : '';
          final canal = parts.length > 2 && parts[2].trim().isNotEmpty
              ? parts[2].trim()
              : 'Loja'; // Canal padrão

          // Salva a pergunta no banco de dados
          await DBHelper().salvarPerguntaPadrao(
            pergunta,
            observacao,
            canal,
          );
        }

        // Atualiza a lista de perguntas após importar
        carregarPerguntas();

        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Perguntas importadas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao importar perguntas: $e')),
      );
    }
  }

  Future<void> editarPergunta(
      int id, String novaPergunta, String novaObservacao) async {
    await DBHelper().atualizarPerguntaPadrao(id, novaPergunta, novaObservacao);
    carregarPerguntas(); // Atualiza a lista após a edição
  }

  Future<void> excluirPergunta(int id) async {
    await DBHelper().excluirPerguntaPadrao(id);
    carregarPerguntas(); // Atualiza a lista após a exclusão
  }

  void mostrarDialogoEdicao(Map<String, dynamic> pergunta) {
    perguntaController.text = pergunta['pergunta'];
    observacaoController.text = pergunta['observacao'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Pergunta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: perguntaController,
                decoration: InputDecoration(labelText: 'Pergunta'),
              ),
              TextField(
                controller: observacaoController,
                decoration: InputDecoration(labelText: 'Observação (opcional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                editarPergunta(
                  pergunta['id'],
                  perguntaController.text,
                  observacaoController.text,
                );
                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gerenciador de Perguntas',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(132, 10, 66, 34),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: perguntaController,
              decoration: InputDecoration(
                  labelText: 'Pergunta',
                  hintText: 'Adicione a pergunta',
                  fillColor: Colors.grey[200],
                  filled: true,
                  prefixIcon: Icon(Icons.ad_units),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  )),
            ),
            SizedBox(height: 10),
            TextField(
              controller: observacaoController,
              decoration: InputDecoration(
                  labelText: 'Observação (opcional)',
                  hintText: 'Informação de apoio',
                  fillColor: Colors.grey[200],
                  filled: true,
                  prefixIcon: Icon(Icons.announcement_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0))),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButton<String>(
                value: canalSelecionado.isEmpty ? null : canalSelecionado,
                hint: Text('Selecione um canal'),
                items: <String>['Loja', 'VD'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(
                          value == 'Loja' ? Icons.store : Icons.local_shipping,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    canalSelecionado = newValue!;
                  });
                },
                underline: SizedBox(),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down_circle, color: Colors.blue),
              ),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (perguntaController.text.isNotEmpty) {
                      await DBHelper().salvarPerguntaPadrao(
                        perguntaController.text,
                        observacaoController.text,
                        canalSelecionado,
                      );

                      perguntaController.clear();
                      observacaoController.clear();
                      carregarPerguntas();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Pergunta salva com sucesso!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('A pergunta não pode estar vazia')),
                      );
                    }
                  },
                  child: Text('Salvar Pergunta'),
                ),
                ElevatedButton.icon(
                  onPressed: importarPerguntas,
                  icon: Icon(Icons.upload_file),
                  label: Text('Importar Perguntas'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: perguntas.length,
                itemBuilder: (context, index) {
                  final pergunta = perguntas[index];

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: pergunta['temImagem'] == true
                          ? Icon(Icons.image,
                              color: Colors
                                  .orange) // Ícone para perguntas com imagem
                          : Icon(Icons.question_mark,
                              color:
                                  Colors.blue), // Ícone padrão para perguntas
                      title: Text(
                        pergunta['pergunta'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: pergunta['respondida'] == true
                              ? Colors.green
                              : Colors
                                  .black, // Destaque para perguntas respondidas
                        ),
                      ),
                      subtitle: pergunta['observacao'] != null &&
                              pergunta['observacao'].isNotEmpty
                          ? Text("Obs: ${pergunta['observacao']}")
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,
                                color:
                                    Colors.blue), // Ícone de edição estilizado
                            onPressed: () {
                              mostrarDialogoEdicao(
                                  pergunta); // Lógica de edição
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color:
                                    Colors.red), // Ícone de exclusão estilizado
                            onPressed: () {
                              excluirPergunta(
                                  pergunta['id']); // Lógica de exclusão
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // Ação ao tocar na pergunta
                        // Exemplo: Navegar para detalhes ou expandir
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

import 'package:flutter/material.dart';
import 'package:audi_mag/db_helper.dart';

class TelaGerenciarPerguntas extends StatefulWidget {
  @override
  _TelaGerenciarPerguntasState createState() => _TelaGerenciarPerguntasState();
}

class _TelaGerenciarPerguntasState extends State<TelaGerenciarPerguntas> {
  final TextEditingController perguntaController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();
  String canalSelecionado = 'Loja'; // inicio do canal
  List<Map<String, dynamic>> perguntas = [];

  @override
  void initState() {
    super.initState();
    carregarPerguntas(); // Carrega as perguntas ao iniciar a tela
  }

  Future<void> carregarPerguntas() async {
    final dbHelper = DBHelper();
    final data = await dbHelper.obterPerguntasPadrao();
    setState(() {
      perguntas = data;
    });
  }
/*
  Future<void> salvarPerguntaPadrao() async {
    await DBHelper().salvarPerguntaPadrao(
      perguntaController.text,
      observacaoController.text,
    );
    perguntaController.clear();
    observacaoController.clear();
    carregarPerguntas(); // Recarrega as perguntas após salvar
  }
  */

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
              decoration: InputDecoration(labelText: 'Pergunta'),
            ),
            TextField(
              controller: observacaoController,
              decoration: InputDecoration(labelText: 'Observação (opcional)'),
            ),
            DropdownButton<String>(
              value: canalSelecionado,
              items: <String>['Loja', 'VD'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  canalSelecionado = newValue!;
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (perguntaController.text.isNotEmpty) {
                  await DBHelper().salvarPerguntaPadrao(
                    perguntaController.text,
                    observacaoController.text,
                    canalSelecionado,
                  );

                  // Limpa os campos de entrada após salvar
                  perguntaController.clear();
                  observacaoController.clear();

                  // Exibe uma mensagem de confirmação
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pergunta salva com sucesso!')),
                  );
                } else {
                  // Exibe uma mensagem de erro se o campo de pergunta estiver vazio
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('A pergunta não pode estar vazia')),
                  );
                }
              },
              child: Text('Salvar Pergunta'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: perguntas.length,
                itemBuilder: (context, index) {
                  final pergunta = perguntas[index];
                  return ListTile(
                    title: Text(pergunta['pergunta']),
                    subtitle: Text(pergunta['observacao'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            mostrarDialogoEdicao(pergunta);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            excluirPergunta(pergunta['id']);
                          },
                        ),
                      ],
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

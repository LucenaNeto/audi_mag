//import 'package:audi_mag/screens/tela_adicionar_perguntas.dart';
import 'package:flutter/material.dart';
import 'package:audi_mag/db_helper.dart';

class TelaCriacaoAuditoria extends StatefulWidget {
  @override
  _TelaCriacaoAuditoriaState createState() => _TelaCriacaoAuditoriaState();
}

class _TelaCriacaoAuditoriaState extends State<TelaCriacaoAuditoria> {
  final TextEditingController nomeAuditoriaController = TextEditingController();
  List<Map<String, dynamic>> perguntasPadrao = [];
  List<int> perguntasSelecionadas = []; // IDs das perguntas selecionadas

  @override
  void initState() {
    super.initState();
    carregarPerguntasPadrao();
  }

  Future<void> carregarPerguntasPadrao() async {
    final dbHelper = DBHelper();
    final data = await dbHelper.obterPerguntasPadrao();
    setState(() {
      perguntasPadrao = data;
    });
  }

  Future<void> criarAuditoria() async {
    final dbHelper = DBHelper();
    int auditoriaId =
        await dbHelper.salvarAuditoria(nomeAuditoriaController.text);

    // Adiciona perguntas padrão selecionadas à auditoria
    for (var perguntaId in perguntasSelecionadas) {
      var pergunta = perguntasPadrao.firstWhere((p) => p['id'] == perguntaId);
      await dbHelper.salvarPergunta(
        auditoriaId,
        pergunta['pergunta'],
        pergunta['observacao'],
        null, // a imagem pode ser adicionada posteriormente, se necessário
      );
    }

    Navigator.pop(context); // Fecha a tela após a criação da auditoria
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Criar Auditoria',
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
              controller: nomeAuditoriaController,
              decoration: InputDecoration(labelText: 'Nome da Auditoria'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: perguntasPadrao.length,
                itemBuilder: (context, index) {
                  final pergunta = perguntasPadrao[index];
                  return CheckboxListTile(
                    title: Text(pergunta['pergunta']),
                    subtitle: Text(pergunta['observacao'] ?? ''),
                    value: perguntasSelecionadas.contains(pergunta['id']),
                    onChanged: (bool? selecionada) {
                      setState(() {
                        if (selecionada == true) {
                          perguntasSelecionadas.add(pergunta['id']);
                        } else {
                          perguntasSelecionadas.remove(pergunta['id']);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: criarAuditoria,
              child: Text('Salvar Auditoria'),
            ),
          ],
        ),
      ),
    );
  }
}

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
  String canalSelecionado = 'Loja';
  List<Map<String, dynamic>> perguntasCanal = [];

  void carregarPerguntasCanal() async {
    perguntasCanal = await DBHelper().buscarPerguntasPorCanal(canalSelecionado);
    setState(() {}); // Atualizar a tela com as perguntas carregadas
  }

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
              decoration: InputDecoration(
                labelText: 'Nome da Auditoria',
                hintText: 'Digite o nome da Auditoria',
                fillColor: Colors.grey[200],
                filled: true,
                prefixIcon: Icon(Icons.assignment),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
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
                value: canalSelecionado.isEmpty
                    ? null
                    : canalSelecionado, // Evita valor inicial vazio
                hint: Text(
                    'Selecione um canal'), // Texto quando nenhum valor é selecionado
                items: <String>['Loja', 'VD'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(
                          value == 'Loja'
                              ? Icons.store
                              : Icons
                                  .local_shipping, // Ícone diferenciado por canal
                          color: Colors.blue,
                        ),
                        SizedBox(width: 5),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    canalSelecionado = newValue!;
                  });
                  carregarPerguntasCanal();
                },
                underline: SizedBox(),
                isExpanded:
                    true, // Permite que o dropdown ocupe toda a largura disponível
                icon: Icon(Icons.arrow_drop_down_circle,
                    color: Colors.blue), // Ícone customizado para o dropdown
              ),
            ),
            SizedBox(height: 10),
            CheckboxListTile(
              title: Text('Selecionar Todas'),
              value: perguntasSelecionadas.length == perguntasCanal.length &&
                  perguntasCanal.isNotEmpty,
              onChanged: (bool? selecionado) {
                setState(() {
                  if (selecionado == true) {
                    perguntasSelecionadas =
                        perguntasCanal.map((p) => p['id'] as int).toList();
                  } else {
                    perguntasSelecionadas.clear();
                  }
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: perguntasCanal.length,
                itemBuilder: (context, index) {
                  final pergunta = perguntasCanal[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: CheckboxListTile(
                      title: Text(perguntasCanal[index]['pergunta']),
                      subtitle: Text(perguntasCanal[index]['observacao'] ?? ''),
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
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: criarAuditoria,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(132, 10, 66, 34),
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
              ),
              child: Text(
                'Salvar Auditoria',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

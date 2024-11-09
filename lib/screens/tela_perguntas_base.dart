/*

// Base de dados para integração de perguntas a determinadas auditorias 
// como irá funcionar com ela poderemos anexar algumas 

import 'package:flutter/material.dart';
import 'package:audi_mag/db_helper.dart';

class TelaPerguntasBase extends StatefulWidget {
  @override
  _TelaPerguntasBaseState createState() => _TelaPerguntasBaseState();
}

class _TelaPerguntasBaseState extends State<TelaPerguntasBase> {
  final List<Map<String, dynamic>> _perguntasBase = [];
  final TextEditingController _controllerPergunta = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarPerguntasBase();
  }

  void _carregarPerguntasBase() async {
    final perguntas = await DBHelper().buscarPerguntasBase();
    setState(() {
      _perguntasBase.addAll(perguntas);
    });
  }

  void _adicionarPergunta() async {
    if (_controllerPergunta.text.isNotEmpty) {
      await DBHelper().salvarPerguntaBase(_controllerPergunta.text);
      setState(() {
        _perguntasBase.add({'texto': _controllerPergunta.text});
        _controllerPergunta.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perguntas Base'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controllerPergunta,
              decoration: InputDecoration(labelText: 'Adicionar Pergunta Base'),
            ),
          ),
          ElevatedButton(
            onPressed: _adicionarPergunta,
            child: Text('Adicionar Pergunta'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _perguntasBase.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_perguntasBase[index]['texto']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
*/
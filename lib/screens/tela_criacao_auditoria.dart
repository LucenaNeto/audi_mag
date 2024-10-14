import 'package:audi_mag/screens/tela_adicionar_perguntas.dart';
import 'package:flutter/material.dart';
import 'package:audi_mag/db_helper.dart';

class TelaCriacaoAuditoria extends StatefulWidget {
  @override
  _TelaCriacaoAuditoriaState createState() => _TelaCriacaoAuditoriaState();
}

class _TelaCriacaoAuditoriaState extends State<TelaCriacaoAuditoria> {
  final _formKey = GlobalKey<FormState>();
  String nomeAuditoria = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Criar Nova Auditoria',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(132, 10, 66, 34),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 4.0, // Elevação do card, adiciona sombra
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Bordas arredondadas
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Minimiza o tamanho do Card
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Nome da Auditoria'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome da auditoria';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        nomeAuditoria = value!;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          int auditoriaId =
                              await DBHelper().salvarAuditoria(nomeAuditoria);
                          // Salvar a auditoria e navegar para a próxima etapa (perguntas)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TelaAdicionarPerguntas(
                                      auditoriaId: auditoriaId,
                                    )),
                          );
                        }
                      },
                      child: Text('Criar Auditoria'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

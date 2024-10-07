import 'package:flutter/material.dart';
import 'package:audi_mag/db_helper.dart';

class TelaListaAuditorias extends StatefulWidget {
  @override
  _TelaListaAuditoriasState createState() => _TelaListaAuditoriasState();
}

class _TelaListaAuditoriasState extends State<TelaListaAuditorias> {
  List<Map<String, dynamic>> _auditorias = [];

  @override
  void initState() {
    super.initState();
    _carregarAuditorias();
  }

  Future<void> _carregarAuditorias() async {
    final db = await DBHelper().database;
    final auditorias = await db.query('auditorias');
    setState(() {
      _auditorias = auditorias;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auditorias Salvas'),
      ),
      body: ListView.builder(
        itemCount: _auditorias.length,
        itemBuilder: (context, index) {
          final auditoria = _auditorias[index];
          return ListTile(
            title: Text(auditoria['nome']),
            onTap: () {
              // Navegar para a tela de visualização/edição da auditoria
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                final db = await DBHelper().database;
                await db.delete('auditorias',
                    where: 'id = ?', whereArgs: [auditoria['id']]);
                _carregarAuditorias(); // Atualiza a lista após exclusão
              },
            ),
          );
        },
      ),
    );
  }
}

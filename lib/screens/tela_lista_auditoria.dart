import 'package:audi_mag/screens/tela_visualizar_auditoria.dart';
import 'package:flutter/material.dart';
import 'package:audi_mag/db_helper.dart';

class TelaListaAuditorias extends StatefulWidget {
  @override
  _TelaListaAuditoriasState createState() => _TelaListaAuditoriasState();
}

class _TelaListaAuditoriasState extends State<TelaListaAuditorias> {
  List<Map<String, dynamic>> _auditorias = [];
  List<Map<String, dynamic>> _auditoriasFiltradas = [];
  final TextEditingController _buscaController = TextEditingController();

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
      _auditoriasFiltradas = List.from(auditorias); // Inicialmente, exibe todas
    });
  }

  String _formatarData(String? data) {
    if (data == null) return 'N/A';
    final dateTime = DateTime.parse(data);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _filtrarAuditorias(String texto) {
    setState(() {
      if (texto.isEmpty) {
        _auditoriasFiltradas = List.from(_auditorias); // Reseta ao original
      } else {
        _auditoriasFiltradas = _auditorias
            .where((auditoria) => auditoria['nome']
                .toLowerCase()
                .contains(texto.toLowerCase())) // Busca case-insensitive
            .toList();
      }
    });
  }

  Future<void> _excluirAuditoria(int id) async {
    final db = await DBHelper().database;
    await db.delete('auditorias', where: 'id = ?', whereArgs: [id]);
    _carregarAuditorias(); // Atualiza a lista após exclusão
  }

  void _confirmarExclusao(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Auditoria'),
          content: Text('Tem certeza que deseja excluir esta auditoria?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () {
                Navigator.of(context).pop();
                _excluirAuditoria(id);
              },
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
          'Auditorias Salvas',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(132, 10, 66, 34),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                labelText: 'Buscar Auditoria',
                hintText: 'Filtrar',
                fillColor: Colors.grey[200],
                filled: true,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              onChanged: _filtrarAuditorias,
            ),
            SizedBox(
                height: 16.0), // Espaçamento entre o campo de busca e a lista
            Expanded(
              child: ListView.builder(
                itemCount: _auditoriasFiltradas.length,
                itemBuilder: (context, index) {
                  final auditoria = _auditoriasFiltradas[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4.0,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Text(
                        auditoria['nome'],
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Criado em: ${_formatarData(auditoria['data_criacao'])}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarExclusao(auditoria['id']),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TelaVisualizarAuditoria(
                              auditoriaId: auditoria['id'],
                              nomeAuditoria: auditoria['nome'],
                            ),
                          ),
                        );
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

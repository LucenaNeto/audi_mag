import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audi_mag/main.dart';

class TelaBackups extends StatefulWidget {
  @override
  _TelaBackupsState createState() => _TelaBackupsState();
}

class _TelaBackupsState extends State<TelaBackups> {
  List<FileSystemEntity> backups = [];

  @override
  void initState() {
    super.initState();
    carregarBackups();
  }

  Future<void> carregarBackups() async {
    final arquivos = await listarBackups();
    setState(() {
      backups = arquivos;
    });
  }

  void abrirBackup(String caminho) async {
    
    final conteudo = await File(caminho).readAsString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Conteúdo do Backup'),
        content: SingleChildScrollView(
          child: Text(conteudo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void excluirBackup(String caminho) async {
    final arquivo = File(caminho);
    await arquivo.delete();
    carregarBackups();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup excluído com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backups Criados'),
        backgroundColor: const Color.fromARGB(132, 10, 66, 34),
      ),
      body: backups.isEmpty
          ? Center(child: Text('Nenhum backup encontrado.'))
          : ListView.builder(
              itemCount: backups.length,
              itemBuilder: (context, index) {
                final arquivo = backups[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      arquivo.path.split('/').last, 
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.visibility, color: Colors.blue),
                          onPressed: () => abrirBackup(arquivo.path),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => excluirBackup(arquivo.path),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

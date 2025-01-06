import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audi_mag/db_helper.dart';
import 'package:audi_mag/screens/tela_criacao_auditoria.dart';
import 'package:audi_mag/screens/tela_gerenciar_perguntas.dart';
import 'package:audi_mag/screens/tela_lista_auditoria.dart';
import 'package:audi_mag/screens/tela_splash.dart';
import 'package:flutter/material.dart';
import 'package:audi_mag/screens/tela_Backup.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audi_mag/screens/tela_pdf.dart';



void main() {
  runApp(AuditoriaApp());
}

class AuditoriaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Auditoria',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TelaSplash(),
    );
  }
}


Future<void> criarBackup(BuildContext context) async {
  try {
    // Exporta os dados do banco
    final dados = await DBHelper().exportarDados();

    // Define o diretório para salvar o backup
    final directory = await getApplicationDocumentsDirectory();
    final backupFile = File('${directory.path}/backup_auditoria.json');

    // Salva os dados em formato JSON
    await backupFile.writeAsString(jsonEncode(dados));

    // Exibe mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup criado com sucesso em ${backupFile.path}')),
    );
  } catch (e) {
    // Exibe mensagem de erro
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao criar backup: $e')),
    );
  }
}

Future<List<FileSystemEntity>> listarBackups() async {
  final directory = await getApplicationDocumentsDirectory();
  final backupDir = Directory(directory.path);


  final backups = backupDir.listSync().where((file) {
    return file.path.endsWith('.json');
  }).toList();

  return backups;
}

Future<String?> selecionarPDF(BuildContext context) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      return result.files.single.path!;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum arquivo selecionado.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao selecionar arquivo: $e')),
    );
  }
  return null;
}

class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Audi+',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(132, 10, 66, 34),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(132, 10, 66, 34),
              ),
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo4.png',
                      height: 93,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Menu+',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            _buildDrawerItem(
              context,
              title: 'Criar Nova Auditoria',
              icon: Icons.add_chart_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TelaCriacaoAuditoria()),
              ),
            ),
            _buildDrawerItem(
              context,
              title: 'Ver Auditorias Salvas',
              icon: Icons.folder_open_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TelaListaAuditorias()),
              ),
            ),
            _buildDrawerItem(
              context,
              title: 'Gerenciar Perguntas',
              icon: Icons.settings_suggest_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TelaGerenciarPerguntas()),
              ),
            ),
            _buildDrawerItem(
              context,
              title: 'Criar Backup',
              icon: Icons.backup,
              onTap: () async => await criarBackup(context),
            ),
            _buildDrawerItem(
              context,
              title: 'Ver Backups',
              icon: Icons.folder,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TelaBackups()),
              ),
            ),
            _buildDrawerItem(
              context,
              title: 'Guia',
              icon: Icons.picture_as_pdf,
              onTap: () async {
                final pdfPath = await selecionarPDF(context);
                if (pdfPath != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TelaVisualizarPDF(caminhoPDF: pdfPath)),
                    );
                }
              }
              )
          ],
        ),
      ),
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          height: 450,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}





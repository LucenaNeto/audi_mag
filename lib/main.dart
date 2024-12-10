import 'package:audi_mag/screens/tela_criacao_auditoria.dart';
import 'package:audi_mag/screens/tela_gerenciar_perguntas.dart';
import 'package:audi_mag/screens/tela_lista_auditoria.dart';
import 'package:audi_mag/screens/tela_splash.dart';
import 'package:flutter/material.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Adiciona a logo no topo
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 500,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 40),
            // Botões estilizados como cartões
            Expanded(
              child: ListView(
                children: [
                  _buildMenuOption(
                    context,
                    title: 'Criar Nova Auditoria',
                    icon: Icons.add_chart_outlined,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TelaCriacaoAuditoria()),
                      );
                    },
                  ),
                  _buildMenuOption(
                    context,
                    title: 'Ver Auditorias Salvas',
                    icon: Icons.folder_open_outlined,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TelaListaAuditorias()),
                      );
                    },
                  ),
                  _buildMenuOption(
                    context,
                    title: 'Gerenciar Perguntas',
                    icon: Icons.settings_suggest_outlined,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TelaGerenciarPerguntas()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

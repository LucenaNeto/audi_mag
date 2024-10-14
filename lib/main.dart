import 'package:audi_mag/screens/tela_criacao_auditoria.dart';
import 'package:audi_mag/screens/tela_lista_auditoria.dart';
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
      home: TelaInicial(),
    );
  }
}

class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gerenciamento de Auditoria',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(132, 10, 66, 34),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /*
            Center(
              child: Text(
                'App de Auditoria',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),*/
            SizedBox(height: 40),
            Center(
              child: Image.asset('assets/images/logo.png'), // Logo da empresa
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela de criação de auditoria
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TelaCriacaoAuditoria()),
                );
              },
              child: Text('Criar Nova Auditoria'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela de auditorias salvas
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TelaListaAuditorias()),
                );
              },
              child: Text('Ver Auditorias Salvas'),
            ),
          ],
        ),
      ),
    );
  }
}

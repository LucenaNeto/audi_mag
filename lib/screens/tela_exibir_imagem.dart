import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audi_mag/db_helper.dart';

class TelaExibirImagem extends StatelessWidget {
  final String caminhoImagem;

  TelaExibirImagem({required this.caminhoImagem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Imagem Anexada',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(132, 10, 66, 34),
      ),
      body: Center(
        child: caminhoImagem.isNotEmpty
            ? Image.file(
                File(caminhoImagem),
                fit: BoxFit.contain,
              )
            : Text('Nenhuma imagem disponível'),
      ),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  Future<List<Map<String, dynamic>>> _carregarImagens(int perguntaId) async {
    return await DBHelper().buscarImagensPorPergunta(perguntaId);
  }

  Widget _exibirImagens(List<Map<String, dynamic>> imagens) {
    return Wrap(
      spacing: 8.0,
      children: imagens.map((imagem) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaExibirImagem(
                  caminhoImagem: imagem['caminho'],
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.file(
              File(imagem['caminho']),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int perguntaId = 1; // Exemplo de ID para carregar as imagens

    return Scaffold(
      appBar: AppBar(
        title: Text('Exibir Imagens'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _carregarImagens(perguntaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar imagens'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma imagem encontrada'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: _exibirImagens(snapshot.data!),
            );
          }
        },
      ),
    );
  }
}

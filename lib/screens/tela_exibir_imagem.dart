import 'dart:io';
import 'package:flutter/material.dart';

class TelaExibirImagem extends StatelessWidget {
  final String caminhoImagem;

  TelaExibirImagem({required this.caminhoImagem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Imagem Anexada'),
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

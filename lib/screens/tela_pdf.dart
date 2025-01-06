import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class TelaVisualizarPDF extends StatelessWidget {
  final String caminhoPDF;

  TelaVisualizarPDF({required this.caminhoPDF});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Guia de ciclo',
          style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          centerTitle: true,
        backgroundColor: const Color.fromARGB(132, 10, 66, 34),
      ),
      body: PDFView(
        filePath: caminhoPDF,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onRender: (_pages) {
          print('Total de páginas: $_pages');
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar PDF: $error')),
          );
        },
        onPageError: (page, error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro na página $page: $error')),
          );
        },
      ),
    );
  }
}

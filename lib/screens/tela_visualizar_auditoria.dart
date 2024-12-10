import 'package:flutter/material.dart';
import 'package:audi_mag/db_helper.dart';
import 'dart:io';
import 'package:audi_mag/screens/tela_exibir_imagem.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class TelaVisualizarAuditoria extends StatefulWidget {
  final int auditoriaId;
  final String nomeAuditoria;

  TelaVisualizarAuditoria(
      {required this.auditoriaId, required this.nomeAuditoria});

  @override
  _TelaVisualizarAuditoriaState createState() =>
      _TelaVisualizarAuditoriaState();
}

class RelatorioService {
  Future<List<pw.Widget>> _obterConteudoAuditoria(int auditoriaId) async {
    final perguntasRespostas =
        await DBHelper().buscarPerguntasDaAuditoria(auditoriaId);
    List<pw.Widget> widgets = [];

    for (var item in perguntasRespostas) {
      // Adiciona texto e informações principais da pergunta
      widgets.add(
        pw.Container(
          margin: pw.EdgeInsets.only(bottom: 10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Pergunta: ${item['pergunta']}",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text("Resposta: ${item['resposta'] ?? 'Não respondido'}",
                  style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 5),
              pw.Text("Observação: ${item['observacao'] ?? 'Sem observação'}",
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              pw.SizedBox(height: 10),
            ],
          ),
        ),
      );

      // Busca imagens associadas à pergunta
      final imagens = await DBHelper().buscarImagensPorPergunta(item['id']);
      if (imagens.isNotEmpty) {
        widgets.add(
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: imagens.map((imagem) {
              return pw.Container(
                margin: pw.EdgeInsets.only(bottom: 10),
                child: pw.Image(
                  pw.MemoryImage(File(imagem['caminho']).readAsBytesSync()),
                  width: 200,
                  height: 150,
                ),
              );
            }).toList(),
          ),
        );
      } else {
        widgets.add(
          pw.Text("Imagens não disponíveis",
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.redAccent,
                fontStyle: pw.FontStyle.italic,
              )),
        );
      }

      widgets.add(pw.Divider(thickness: 0.5, color: PdfColors.grey400));
    }
    return widgets;
  }

  Future<List<pw.Widget>> _obterConteudoEspecifico(int auditoriaId) async {
    final perguntasComNao =
        await DBHelper().buscarPerguntasDaAuditoria(auditoriaId);
    List<pw.Widget> widgets = [];

    for (var item in perguntasComNao) {
      if (item['resposta'] == 'Não') {
        // Adiciona texto e informações principais da pergunta
        widgets.add(
          pw.Container(
            margin: pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Pergunta: ${item['pergunta']}",
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text("Observação: ${item['observacao'] ?? 'Sem observação'}",
                    style:
                        pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                pw.SizedBox(height: 10),
              ],
            ),
          ),
        );

        // Busca as imagens associadas à pergunta
        final imagens = await DBHelper().buscarImagensPorPergunta(item['id']);
        if (imagens.isNotEmpty) {
          // Adiciona as imagens ao relatório
          widgets.add(
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: imagens.map((imagem) {
                return pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 10),
                  child: pw.Image(
                    pw.MemoryImage(File(imagem['caminho']).readAsBytesSync()),
                    width: 200,
                    height: 150,
                  ),
                );
              }).toList(),
            ),
          );
        } else {
          widgets.add(
            pw.Text("Imagens não disponíveis",
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.redAccent,
                  fontStyle: pw.FontStyle.italic,
                )),
          );
        }

        widgets.add(pw.Divider(thickness: 0.5, color: PdfColors.grey400));
      }
    }
    return widgets;
  }

  Future<String> gerarRelatorioEspecificoPDF(
      int auditoriaId, String nomeAuditoria) async {
    final conteudoEspecifico = await _obterConteudoEspecifico(auditoriaId);
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Relatório Específico - Respostas "Não"',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            'Nome da Auditoria: $nomeAuditoria',
            style: pw.TextStyle(fontSize: 18),
          ),
          pw.Text(
            'Data: ${DateTime.now().toLocal().toString().split(" ")[0]}',
            style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),
          ...conteudoEspecifico,
        ],
        footer: (context) {
          final currentPage = context.pageNumber;
          final totalPages = context.pagesCount;

          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              "Página $currentPage de $totalPages",
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final filePath = "${output.path}/relatorio_especifico_$auditoriaId.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  Future<String> gerarRelatorioPDF(
      int auditoriaId, String nomeAuditoria) async {
    final conteudoAuditoria = await _obterConteudoAuditoria(auditoriaId);
    final pdf = pw.Document();

    // Cabeçalho aprimorado e numeração de páginas
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Relatório da Auditoria',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            'Nome da Auditoria: $nomeAuditoria',
            style: pw.TextStyle(fontSize: 18),
          ),
          pw.Text(
            'Data: ${DateTime.now().toLocal().toString().split(" ")[0]}',
            style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Detalhes:',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(thickness: 1, color: PdfColors.black),
          ...conteudoAuditoria,
        ],
        footer: (context) {
          final currentPage = context.pageNumber;
          final totalPages = context.pagesCount;

          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              "Página $currentPage de $totalPages",
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
            ),
          );
        },
      ),
    );

    // Salvar o PDF
    final output = await getTemporaryDirectory();
    final filePath = "${output.path}/relatorio_auditoria_$auditoriaId.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }
}

class _TelaVisualizarAuditoriaState extends State<TelaVisualizarAuditoria> {
  List<Map<String, dynamic>> _perguntas = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _carregarPerguntas();
  }

  void _exibirMensagemErro(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _carregarPerguntas() async {
    final db = await DBHelper().database;
    final perguntas = await db.query(
      'perguntas',
      where: 'auditoriaId = ?',
      whereArgs: [widget.auditoriaId],
    );
    setState(() {
      _perguntas = perguntas;
    });
  }

  Future<void> _salvarResposta(int perguntaId, String resposta) async {
    final db = await DBHelper().database;
    await db.update(
      'perguntas',
      {'resposta': resposta},
      where: 'id = ?',
      whereArgs: [perguntaId],
    );
  }

  Future<void> _excluirPergunta(int perguntaId) async {
    final db = await DBHelper().database;
    await db.delete(
      'perguntas',
      where: 'id = ?',
      whereArgs: [perguntaId],
    );
    _carregarPerguntas();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pergunta excluída com sucesso'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _editarPergunta(
      int perguntaId, String novaPergunta, String novaObservacao) async {
    final db = await DBHelper().database;
    await db.update(
      'perguntas',
      {
        'pergunta': novaPergunta,
        'observacao': novaObservacao,
      },
      where: 'id = ?',
      whereArgs: [perguntaId],
    );
    _carregarPerguntas();
  }

  Future<void> _anexarImagem(int perguntaId) async {
    try {
      // Mostra um diálogo para o usuário escolher entre câmera ou galeria
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Selecionar Imagem'),
            content: Text('Escolha uma opção:'),
            actions: [
              TextButton(
                child: Text('Câmera'),
                onPressed: () async {
                  Navigator.of(context).pop(); // Fecha o diálogo
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    await DBHelper()
                        .salvarImagemParaPergunta(perguntaId, pickedFile.path);
                    setState(() {}); // Atualiza a UI
                  }
                },
              ),
              TextButton(
                child: Text('Galeria'),
                onPressed: () async {
                  Navigator.of(context).pop(); // Fecha o diálogo
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    await DBHelper()
                        .salvarImagemParaPergunta(perguntaId, pickedFile.path);
                    setState(() {}); // Atualiza a UI
                  }
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Erro ao anexar imagem: $e");
    }
  }

  Widget _exibirImagens(int perguntaId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DBHelper().buscarImagensPorPergunta(perguntaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Text('Erro ao carregar Imagens');
        } else if (snapshot.data!.isEmpty) {
          return Text('Nenhuma Imagem anexada');
        } else {
          return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: snapshot.data!.map((imagem) {
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
      },
    );
  }

  Widget _buildRadioOption(
    String title,
    String value,
    int perguntaId,
    String? respostaAtual,
    void Function(String?) atualizarResposta,
  ) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: respostaAtual,
      onChanged: (String? newValue) {
        final respostaAnterior = respostaAtual;

        atualizarResposta(newValue);

        Future.microtask(() async {
          try {
            await _salvarResposta(perguntaId, newValue!);
          } catch (e) {
            // Reverte a alteração se falhar
            atualizarResposta(respostaAnterior);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Erro ao salvar resposta. Tente novamente.')),
            );
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Auditoria: ${widget.nomeAuditoria}',
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: 'Relatório Geral',
            onPressed: () async {
              try {
                final filePath = await RelatorioService().gerarRelatorioPDF(
                    widget.auditoriaId, widget.nomeAuditoria);
                final file = File(filePath);

                if (file.existsSync()) {
                  Share.shareXFiles(
                    [XFile(filePath, mimeType: 'application/pdf')],
                  );
                } else {
                  _exibirMensagemErro(
                      context, "Erro ao localizar o relatório gerado.");
                }
              } catch (e) {
                print("Erro ao compartilhar arquivo: $e");
                _exibirMensagemErro(
                    context, "Erro inesperado ao compartilhar o relatório.");
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_alt),
            tooltip: 'Relatório Específico (Respostas "Não")',
            onPressed: () async {
              try {
                final filePath = await RelatorioService()
                    .gerarRelatorioEspecificoPDF(
                        widget.auditoriaId, widget.nomeAuditoria);
                final file = File(filePath);

                if (file.existsSync()) {
                  Share.shareXFiles(
                    [XFile(filePath, mimeType: 'application/pdf')],
                  );
                } else {
                  _exibirMensagemErro(
                      context, "Erro ao localizar o relatório gerado.");
                }
              } catch (e) {
                print("Erro ao compartilhar arquivo: $e");
                _exibirMensagemErro(
                    context, "Erro inesperado ao compartilhar o relatório.");
              }
            },
          ),
        ],
        centerTitle: false,
        backgroundColor: const Color.fromARGB(132, 10, 66, 34),
      ),
      body: ListView.builder(
        itemCount: _perguntas.length,
        itemBuilder: (context, index) {
          final pergunta = _perguntas[index];
          String? resposta = pergunta['resposta'];

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pergunta['pergunta'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(pergunta['observacao'] ?? ''),
                  SizedBox(height: 10),
                  _exibirImagens(pergunta['id']),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      _buildRadioOption(
                        'Sim',
                        'Sim',
                        pergunta['id'],
                        resposta,
                        (novaResposta) {
                          setState(() {
                            resposta = novaResposta;
                          });
                        },
                      ),
                      _buildRadioOption(
                        'Não',
                        'Não',
                        pergunta['id'],
                        resposta,
                        (novaResposta) {
                          setState(() {
                            resposta = novaResposta;
                          });
                        },
                      ),
                      _buildRadioOption(
                        'Não se aplica',
                        'Não se aplica',
                        pergunta['id'],
                        resposta,
                        (novaResposta) {
                          setState(() {
                            resposta = novaResposta;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _anexarImagem(pergunta['id']);
                    },
                    child: Text('Anexar Imagem'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _mostrarDialogoEditarPergunta(pergunta['id'],
                              pergunta['pergunta'], pergunta['observacao']);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _confirmarExclusaoPergunta(pergunta['id']);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmarExclusaoPergunta(int perguntaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir esta pergunta?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _excluirPergunta(perguntaId);
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEditarPergunta(
      int perguntaId, String perguntaAtual, String observacaoAtual) {
    String novaPergunta = perguntaAtual;
    String novaObservacao = observacaoAtual;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Pergunta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Pergunta'),
                controller: TextEditingController(text: perguntaAtual),
                onChanged: (value) {
                  novaPergunta = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Observação'),
                controller: TextEditingController(text: observacaoAtual),
                onChanged: (value) {
                  novaObservacao = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () {
                _editarPergunta(perguntaId, novaPergunta, novaObservacao);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

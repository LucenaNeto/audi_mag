class ImagemPergunta {
  final int id;
  final int perguntaId;
  final String caminhoImagem;

  ImagemPergunta({
    required this.id,
    required this.perguntaId,
    required this.caminhoImagem,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pergunta_id': perguntaId,
      'caminho_imagem': caminhoImagem,
    };
  }
}

class Transacao {
  int? id;
  String titulo;
  double valor;
  String dataHora;
  String tipo;
  String? descricao;
  String? imagemPath;

Transacao({
    this.id,
    required this.titulo,
    required this.valor,
    required this.dataHora,
    required this.tipo,
    this.descricao,
    this.imagemPath,
  });

  Transacao.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        titulo = map['titulo'],
        valor = (map['valor'] as num).toDouble(),
        dataHora = map['dataHora'],
        tipo = map['tipo'],
        descricao = map['descricao'],
        imagemPath = map['imagemPath'];
}
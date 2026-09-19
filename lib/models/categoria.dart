class Categoria {
  int? id;
  String nome;
  String cor;

  Categoria({
    this.id,
    required this.nome,
    required this.cor,
  });

  Categoria.fromMap(Map<String, dynamic> map)
    : id = map['id'],
    nome = map['nome'],
    cor = map['cor'];

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'nome': nome,
      'cor': cor,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }
}
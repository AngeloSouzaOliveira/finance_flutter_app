import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transacao.dart';

class DBHelper {
  static const String _colecao = 'transacoes';

  // Campo extra usado só para ordenar (equivale ao antigo "ORDER BY id DESC")
  static const String colCriadoEm = 'criadoEm';

  DBHelper._internal();
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      FirebaseFirestore.instance.collection(_colecao);

  Query<Map<String, dynamic>> get _ordenada =>
      _ref.orderBy(colCriadoEm, descending: true);

  Transacao _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Transacao.fromMap(doc.data()!, id: doc.id);

  /// Cria um novo documento e devolve o ID gerado pelo Firestore.
  Future<String> insertTransacao(Transacao transacao) async {
    final doc = await _ref.add({
      ...transacao.toMap(),
      colCriadoEm: Timestamp.now(),
    });
    return doc.id;
  }

  Future<List<Transacao>> getTransacoes() async {
    final snapshot = await _ordenada.get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  Stream<List<Transacao>> streamTransacoes() {
    return _ordenada
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }


  Future<Transacao?> getTransacao(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  Future<void> updateTransacao(Transacao transacao) async {
    if (transacao.id == null) {
      throw ArgumentError('Não é possível atualizar uma transação sem id.');
    }
    await _ref.doc(transacao.id).update(transacao.toMap());
  }

  Future<void> deleteTransacao(String id) async {
    await _ref.doc(id).delete();
  }
}

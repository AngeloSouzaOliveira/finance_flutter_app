import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transacao.dart';

class DBHelper {

    static const String _dbName = 'finance.db';
  static const int _dbVersion = 1;
  static const String _tableName = 'transacoes';

  static const String colId = 'id';
  static const String colTitulo = 'titulo';
  static const String colValor = 'valor';
  static const String colDataHora = 'dataHora';
  static const String colTipo = 'tipo';
  static const String colDescricao = 'descricao';
  static const String colImagemPath = 'imagemPath';

  DBHelper._internal();
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'finance.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colTitulo TEXT NOT NULL,
        $colValor REAL NOT NULL,
        $colDataHora TEXT NOT NULL,
        $colTipo TEXT NOT NULL,
        $colDescricao TEXT,
        $colImagemPath TEXT
      )
    ''');
  }

  Future<int> insertTransacao(Transacao transacao) async {
    final clientDb = await db;
    return await clientDb.insert(_tableName, transacao.toMap());
  }
}

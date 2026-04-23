import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/quote_model.dart';

// Classe para gerenciar o banco de dados (sqflite)

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'quotes_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE quotes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerName TEXT,
        customerCpf TEXT,
        customerAddress TEXT,
        customerPhone TEXT,
        serviceDate TEXT,
        mainGoal TEXT,
        serviceDescription TEXT,
        totalPrice REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Initialize with default values
    await db.insert('settings', {
      'key': 'companyName',
      'value': 'EMPRESA TESTE',
    });
    await db.insert('settings', {
      'key': 'serviceResponsible',
      'value': 'Engenheiro Ambiental',
    });
    await db.insert('settings', {'key': 'cnpj', 'value': '12.345.678/0001-10'});
    await db.insert('settings', {
      'key': 'telephone',
      'value': '(11) 99999-9999',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE settings(
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');

      // Initialize with default values
      await db.insert('settings', {
        'key': 'companyName',
        'value': 'EMPRESA TESTE',
      });
      await db.insert('settings', {
        'key': 'serviceResponsible',
        'value': 'Engenheiro Ambiental',
      });
      await db.insert('settings', {
        'key': 'cnpj',
        'value': '12.345.678/0001-10',
      });
      await db.insert('settings', {
        'key': 'telephone',
        'value': '(11) 99999-9999',
      });
    }
  }

  Future<int> insertQuote(Quote quote) async {
    Database db = await database;
    return await db.insert('quotes', quote.toMap());
  }

  Future<List<Quote>> getQuotes() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'quotes',
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) {
      return Quote.fromMap(maps[i]);
    });
  }

  Future<int> updateQuote(Quote quote) async {
    Database db = await database;
    return await db.update(
      'quotes',
      quote.toMap(),
      where: 'id = ?',
      whereArgs: [quote.id],
    );
  }

  Future<int> deleteQuote(int id) async {
    Database db = await database;
    return await db.delete('quotes', where: 'id = ?', whereArgs: [id]);
  }

  // Settings methods
  Future<Map<String, String>> getSettings() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('settings');
    Map<String, String> settings = {};
    for (var item in maps) {
      settings[item['key']] = item['value'] ?? '';
    }
    return settings;
  }

  Future<void> saveSettings(Map<String, String> settings) async {
    Database db = await database;
    Batch batch = db.batch();
    settings.forEach((key, value) {
      batch.insert('settings', {
        'key': key,
        'value': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
    await batch.commit(noResult: true);
  }
}

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../core/constants.dart';
import 'platform_stub.dart' if (dart.library.io) 'platform_io.dart';

/// Acesso único (singleton) ao SQLite multiplataforma
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;
  bool _factoryReady = false;

  Future<void> ensureFactory() async {
    if (_factoryReady) return;
    // Inicialização por plataforma (web / desktop / celular).
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (isDesktopPlatform) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _factoryReady = true;
  }

  Future<Database> get database async {
    await ensureFactory();
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<String> _dbPath() async {
    if (kIsWeb) return AppConstants.dbName;
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, AppConstants.dbName);
  }

  Future<Database> _open() async {
    final path = await _dbPath();
    return databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: AppConstants.dbVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: _onCreate,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Schema com relacionamentos
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        document TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE technicians (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        specialty TEXT NOT NULL,
        active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE equipment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        serial_number TEXT NOT NULL,
        asset_tag TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients (id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        display_name TEXT NOT NULL,
        role TEXT NOT NULL,
        technician_id INTEGER,
        FOREIGN KEY (technician_id) REFERENCES technicians (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE service_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        client_id INTEGER NOT NULL,
        equipment_id INTEGER NOT NULL,
        technician_id INTEGER,
        problem_description TEXT NOT NULL,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        opened_at TEXT NOT NULL,
        due_date TEXT,
        closed_at TEXT,
        diagnosis TEXT NOT NULL DEFAULT '',
        solution TEXT NOT NULL DEFAULT '',
        labor_cost REAL NOT NULL DEFAULT 0,
        image_path TEXT,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients (id) ON DELETE RESTRICT,
        FOREIGN KEY (equipment_id) REFERENCES equipment (id) ON DELETE RESTRICT,
        FOREIGN KEY (technician_id) REFERENCES technicians (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        description TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES service_orders (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE order_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        details TEXT NOT NULL,
        user_name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES service_orders (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/electrodomestico.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  static const String tablaElectrodomesticos = 'electrodomesticos';
  static const String tablaConfig = 'config';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'ecowatt.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablaElectrodomesticos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        potencia_watts REAL NOT NULL,
        horas_uso_dia REAL NOT NULL,
        categoria TEXT NOT NULL,
        fecha_registro TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaConfig (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tarifa_kwh REAL NOT NULL,
        moneda TEXT NOT NULL
      )
    ''');

    // Tarifa por defecto (puede ajustarse en futuras versiones desde la UI)
    await db.insert(tablaConfig, {'tarifa_kwh': 800.0, 'moneda': 'COP'});
  }

  // ---------- CRUD Electrodomesticos ----------

  Future<int> insertarElectrodomestico(Electrodomestico e) async {
    final db = await database;
    return await db.insert(tablaElectrodomesticos, e.toMap()..remove('id'));
  }

  Future<List<Electrodomestico>> obtenerElectrodomesticos() async {
    final db = await database;
    final result = await db.query(tablaElectrodomesticos, orderBy: 'id DESC');
    return result.map((map) => Electrodomestico.fromMap(map)).toList();
  }

  Future<int> actualizarElectrodomestico(Electrodomestico e) async {
    final db = await database;
    return await db.update(
      tablaElectrodomesticos,
      e.toMap(),
      where: 'id = ?',
      whereArgs: [e.id],
    );
  }

  Future<int> eliminarElectrodomestico(int id) async {
    final db = await database;
    return await db.delete(
      tablaElectrodomesticos,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------- Configuracion (tarifa) ----------

  Future<double> obtenerTarifaKwh() async {
    final db = await database;
    final result = await db.query(tablaConfig, limit: 1);
    if (result.isEmpty) return 800.0;
    return (result.first['tarifa_kwh'] as num).toDouble();
  }

  Future<void> actualizarTarifaKwh(double nuevaTarifa) async {
    final db = await database;
    final result = await db.query(tablaConfig, limit: 1);
    if (result.isEmpty) {
      await db.insert(tablaConfig, {'tarifa_kwh': nuevaTarifa, 'moneda': 'COP'});
    } else {
      await db.update(
        tablaConfig,
        {'tarifa_kwh': nuevaTarifa},
        where: 'id = ?',
        whereArgs: [result.first['id']],
      );
    }
  }
}

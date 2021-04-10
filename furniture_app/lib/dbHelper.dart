import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'product.dart';

class DbHelper {
  Database _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await initializeDb();
    }
    return _db;
  }

  Future<Database> initializeDb() async {
    String dbPath = join(await getDatabasesPath(), "etrade.db");
    var eTradeDb = await openDatabase(dbPath, version: 1, onCreate: createDb);
    return eTradeDb;
  }

  void createDb(Database db, int version) async {
    // You need to  CHANGE this part
    await db.execute(
        "Create  table products(image text, title text, price integer, id integer,sqlId integer primary key AUTOINCREMENT)");

    await db.execute(
        "Create  table favProduct(image text, title text, price integer, id integer,sqlId integer primary key AUTOINCREMENT)");
  }

  Future<List> getProducts() async {
    // getting all products
    Database db = await this.db;
    var result = await db.query("products");
    return List.generate(result.length, (i) {
      return Product.fromObject(result[i]);
    });
    // type of var is list
  }

  Future<List> getProductsFavorite() async {
    // getting all products
    Database db = await this.db;
    var result = await db.query("favProduct");
    return List.generate(result.length, (i) {
      return Product.fromObject(result[i]);
    });
    // type of var is list
  }

  Future<int> insert(Product product) async {
    Database db = await this.db;
    var result = await db.insert("products", product.toMap(),
        conflictAlgorithm:
        ConflictAlgorithm.replace); // 2nd paramater should be MAP
  }

  Future<int> insertFavorite(Product product) async {
    Database db = await this.db;
    var result = await db.insert("favProduct", product.toMap(),
        conflictAlgorithm:
        ConflictAlgorithm.replace); // 2nd paramater should be MAP
  }

  Future<int> delete(int sqlId) async {
    Database db = await this.db;
    var result = await db.rawDelete(
        "delete from products where sqlId=$sqlId"); // table name: products
    return result;
  }

  Future<int> deleteFavorite(int sqlId) async {
    Database db = await this.db;
    var result = await db.rawDelete(
        "delete from favProduct where sqlId=$sqlId"); // table name: products
    return result;
  }
}

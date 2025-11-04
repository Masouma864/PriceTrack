import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DbHelper {
  static Future<Database> db() async {
    return openDatabase(
      join(await getDatabasesPath(), "crud.db"),
      version: 1,
      onCreate: (db, version) async => {
        await db.execute("""CREATE TABLE IF NOT EXISTS price(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          qty REAL,
          unit_price REAL,
          discount REAL,
          total REAL,
          has_discount bool,
          created TEXT
          )"""),
      },
    );
  }

  static Future<int> addPrice({
    required double qty,
    required double unitPrice,
    double? discount,
    required double total,
    bool hasDiscount = false,
  }) async {
    final db = await DbHelper.db();
    return db.insert("price", {
      "qty": qty,
      "unit_price": unitPrice,
      "discount": discount,
      "total": total,
      "has_discount": hasDiscount ? 1 : 0,
      "created": DateTime.now().toString().split(".")[0],
    });
  }

  static Future<List<Map<String, dynamic>>> getAllPrices() async {
    final db = await DbHelper.db();
    return db.query("price");
  }

  static Future<int> deletePrice(int id) async {
    final db = await DbHelper.db();
    return await db.delete("price", where: "id=?", whereArgs: [id]);
  }

  static Future<int> updatePrice({
    required int id,
    required double qty,
    required double unitPrice,
    double? discount,
    required double total,
    bool hasDiscount = false,
  }) async {
    final db = await DbHelper.db();
    return await db.update(
      "price",
      {
        "qty": qty,
        "unit_price": unitPrice,
        "discount": discount,
        "total": total,
        "has_discount": hasDiscount ? 1 : 0,
        "created": DateTime.now().toString().split(".")[0],
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }
}

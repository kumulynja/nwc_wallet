import 'package:nwc_wallet/constants/database_params.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract class DatabaseProvider {
  Future<Database> get database;
  Future close();
}

class DatabaseProviderImpl implements DatabaseProvider {
  static final DatabaseProviderImpl instance = DatabaseProviderImpl._init();
  static Database? _database;

  DatabaseProviderImpl._init();

  @override
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(DatabaseParams.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: DatabaseParams.databaseVersion,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER';

    await db.execute(
      '''
      CREATE TABLE ${DatabaseParams.nwcConnectionsTable} (
        ${DatabaseParams.columnId} $idType,
        ${DatabaseParams.columnName} $textType,
        ${DatabaseParams.columnConnectionPubkey} $textType,
        ${DatabaseParams.columnRelayUrl} $textType,
        ${DatabaseParams.columnPermittedMethods} $textType,
        ${DatabaseParams.columnSecret} $textType,
        ${DatabaseParams.columnMonthlyLimitSat} $intType,
        ${DatabaseParams.columnExpiry} $intType,
        ${DatabaseParams.columnConnectionStatus} $textType,
        ${DatabaseParams.columnIsDeactivated} $intType,
        ${DatabaseParams.columnCreatedAt} $intType,
        ${DatabaseParams.columnUpdatedAt} $intType,
        ${DatabaseParams.columnDeactivatedAt} $intType
        )
      ''',
    );
  }

  @override
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

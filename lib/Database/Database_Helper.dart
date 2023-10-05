import 'dart:math';

import 'package:bneedsoutlet/Modal/accmast_balance_modal.dart';
import 'package:bneedsoutlet/Modal/ledger_balance_modal.dart';
import 'package:bneedsoutlet/Modal/TransactionModal.dart';
import 'package:bneedsoutlet/Modal/sales_data_modal.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Modal/item_data_modal.dart';
import 'package:logger/logger.dart';

class DatabaseConnection {
  final Logger logger = Logger();
  Database? db;
  Future<Database> setDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'NMSADMINDB.db');
      final database =
          await openDatabase(path, version: 4, onCreate: _createDatabase);
      db = database;
      /*logger.i('Database created successfully');*/
      // Fluttertoast.showToast(msg: "Database Created!");
      return database;
    } catch (e) {
      // logger.i('Error creating database: $e');
      Fluttertoast.showToast(msg: "Error: $e");
      rethrow;
    }
  }

  Future<void> _createDatabase(Database database, int version) async {
    try {
      await database.execute('''
      CREATE TABLE IF NOT EXISTS itemMaster (
        Itemid TEXT,
        itemName TEXT,
        Selrate TEXT,
        MRP TEXT,
        cgst TEXT,
        WSSELRATE TEXT,
        PurRate TEXT,
        commCode TEXT,
        Lok TEXT,
        Companyid TEXT
      )
    ''');

      await database.execute('''
  CREATE TABLE IF NOT EXISTS LedgerBalance (
    Companyid TEXT,
    Accode TEXT,
    name TEXT,
    GroupName TEXT,
    MobileNo TEXT,
    Balance TEXT
  )
''');

      await database.execute('''
  CREATE TABLE IF NOT EXISTS AccMast (
    Accode TEXT,
    Name TEXT,
    Groupname TEXT,
    Companyid TEXT,
    Lok TEXT,
    Mobile TEXT
  )
''');

      await database.execute('''
  CREATE TABLE IF NOT EXISTS AccMastDropDownData (
    Accode TEXT,
    Name TEXT,
    Groupname TEXT,
    Companyid TEXT,
    Lok TEXT,
    Mobile TEXT
  )
''');

      logger.i('Table created successfully');
    } catch (e) {
      logger.i('Error creating Table: $e');
      rethrow;
    }
  }

 Future<void> createNewTable() async {
  if (db == null) {
    db = await setDatabase();
  }

  final tableExists = await doesTableExist('companyProfile');

  if (!tableExists) {
    try {
      await db!.execute('''
        CREATE TABLE IF NOT EXISTS companyProfile (
          ComId INTEGER PRIMARY KEY AUTOINCREMENT,
          CompanyId TEXT,
          CompanyName TEXT,
          Add1 TEXT,
          Add2 TEXT,
          Add3 TEXT,
          Add4 TEXT,
          Pincode TEXT,
          MobileNo TEXT,
          Gstin TEXT,
          ItemPre TEXT,
          ItemNo TEXT,
          AccPre TEXT,
          AccNo TEXT,
          BillPre TEXT,
          BillNo TEXT
        )
      ''');
      logger.i('New table created successfully');
    } catch (e) {
      logger.i('Error creating new table: $e');
    }
  }
}

 Future<void> createSalesTable() async {
  if (db == null) {
    db = await setDatabase();
  }

  final tableExists = await doesTableExist('SalesEntry');

  if (!tableExists) {
    try {
      await db!.execute('''
        CREATE TABLE IF NOT EXISTS SalesEntry (
          Entrefno TEXT,
          BillNo TEXT,
          Billdate TEXT,
          Accode TEXT,
          itemid TEXT,
          Qty TEXT,
          Selrate TEXT,
          Amount TEXT,
          Companyid TEXT,
          userid TEXT,
          DiscPer TEXT,
          Discount TEXT,
          gst TEXT,
          gstval TEXT,
          BILLPREFIX TEXT,
          selratenotax TEXT,
          taxtype TEXT
        )
      ''');
      logger.i('Sales table created successfully');
    } catch (e) {
      logger.i('Error creating new table: $e');
    }
  }
}

Future<void> addColumnToTable(String tableName, String columnName, String dataType) async {
  if (db == null) {
    db = await setDatabase();
  }

  try {
    final columns = await db!.rawQuery('PRAGMA table_info($tableName)');
    bool columnExists = columns.any((column) => column['name'] == columnName);

    if (!columnExists) {
      await db!.execute('''
        ALTER TABLE $tableName
        ADD COLUMN $columnName $dataType
      ''');
      logger.i('Added column $columnName to table $tableName successfully');
    } else {
      logger.i('Column $columnName already exists in table $tableName');
    }
  } catch (e) {
    logger.i('Error adding column to table: $e');
  }
}

Future<void> deleteColumnFromTable(String tableName, String columnName) async {
  if (db == null) {
    db = await setDatabase();
  }

  try {
    // Check if the column exists in the table
    final columns = await db!.rawQuery('PRAGMA table_info($tableName)');
    bool columnExists = columns.any((column) => column['name'] == columnName);

    if (columnExists) {
      // Create a temporary table with the desired structure (excluding the column to delete)
      final tempTableName = '$tableName\_temp';
      await db!.execute('''
        CREATE TABLE $tempTableName AS
        SELECT ${columns.where((column) => column['name'] != columnName).map((column) => column['name']).join(', ')}
        FROM $tableName
      ''');

      // Copy data from the old table to the new table
      await db!.execute('''
        INSERT INTO $tempTableName
        SELECT *
        FROM $tableName
      ''');

      // Drop the old table
      await db!.execute('DROP TABLE $tableName');

      // Rename the temporary table to the original table name
      await db!.execute('ALTER TABLE $tempTableName RENAME TO $tableName');

      logger.i('Deleted column $columnName from table $tableName successfully');
    } else {
      logger.i('Column $columnName does not exist in table $tableName');
    }
  } catch (e) {
    logger.i('Error deleting column from table: $e');
  }
}


Future<bool> doesTableExist(String tableName) async {
  final result = await db!.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'",
  );
  return result.isNotEmpty;
}


  Future<void> insertItemData(List<ItemData?> items) async {
    final dbClient = db;
    if (dbClient == null) {
      logger.i('Database is null. Make sure to call setDatabase() first.');
      return;
    }

    Batch batch = dbClient.batch();

    for (var item in items) {
      if (item != null) {
        final existingRecord = await dbClient.query(
          'itemMaster',
          where: 'Companyid = ? AND itemid = ?',
          whereArgs: [item.companyid, item.itemId],
        );

        if (existingRecord.isNotEmpty) {
          await dbClient.delete(
            'itemMaster',
            where: 'Companyid = ? AND itemid = ?',
            whereArgs: [item.companyid, item.itemId],
          );
        }

        batch.insert(
          'itemMaster',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    Fluttertoast.showToast(msg: "Successfully Synced!");
    logger.i("Successfully Synced!");
    await batch.commit();
  }

    Future<void> insertSalesData(List<SalesData?> items) async {
    final dbClient = db;
    if (dbClient == null) {
      logger.i('Database is null. Make sure to call setDatabase() first.');
      return;
    }

    Batch batch = dbClient.batch();

    for (var item in items) {
      if (item != null) {
        final existingRecord = await dbClient.query(
          'SalesEntry',
          where: 'Companyid = ? AND Entrefno  = ?',
          whereArgs: [item.companyId, item.entrefno],
        );

        if (existingRecord.isNotEmpty) {
          await dbClient.delete(
            'SalesEntry',
            where: 'Companyid = ? AND Entrefno = ?',
            whereArgs: [item.companyId, item.entrefno],
          );
        }

        batch.insert(
          'SalesEntry',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    Fluttertoast.showToast(msg: "Successfully Synced!");
    logger.i("Successfully Synced!");
    await batch.commit();
  }


  Future<void> insertTranData(List<TransactionModal?> items) async {
    final dbClient = db;
    if (dbClient == null) {
      logger.i('Database is null. Make sure to call setDatabase() first.');
      return;
    }

    Batch batch = dbClient.batch();

    for (var item in items) {
      if (item != null) {
        final existingRecord = await dbClient.query(
          'AccMast',
          where: 'Companyid = ? AND Accode = ?',
          whereArgs: [item.companyid, item.accode],
        );

        if (existingRecord.isNotEmpty) {
          await dbClient.delete(
            'AccMast',
            where: 'Companyid = ? AND Accode = ?',
            whereArgs: [item.companyid, item.accode],
          );
        }

        batch.insert(
          'AccMast',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit();
    Fluttertoast.showToast(msg: "Successfully Synced!");
  }

  Future<void> insertDropdownData(List<TransactionModal?> items) async {
    final dbClient = db;
    if (dbClient == null) {
      logger.i('Database is null. Make sure to call setDatabase() first.');
      return;
    }

    Batch batch = dbClient.batch();

    for (var item in items) {
      if (item != null) {
        final existingRecord = await dbClient.query(
          'AccMastDropDownData',
          where: 'Companyid = ? AND Accode = ?',
          whereArgs: [item.companyid, item.accode],
        );

        if (existingRecord.isNotEmpty) {
          await dbClient.delete(
            'AccMastDropDownData',
            where: 'Companyid = ? AND Accode = ?',
            whereArgs: [item.companyid, item.accode],
          );
        }

        batch.insert(
          'AccMastDropDownData',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit();
    Fluttertoast.showToast(msg: "Successfully Synced!");
  }

  Future<void> insertLedgerData(List<LedgerBalanceModal?> items) async {
    logger.i('Item Count: ${items.length}');
    final dbClient = db;
    if (dbClient == null) {
      logger.i('Database is null. Make sure to call setDatabase() first.');
      return;
    }

    Batch batch = dbClient.batch();

    for (var item in items) {
      if (item != null) {
        final existingRecord = await dbClient.query(
          'LedgerBalance',
          where: 'Companyid = ? AND Accode = ?',
          whereArgs: [item.companyId, item.accode],
        );

        if (existingRecord.isNotEmpty) {
          await dbClient.delete(
            'LedgerBalance',
            where: 'Companyid = ? AND Accode = ?',
            whereArgs: [item.companyId, item.accode],
          );
        }

        batch.insert(
          'LedgerBalance',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit();
    Fluttertoast.showToast(msg: "Successfully Synced!");
  }

  Future<List<ItemData>> getItems({String? companyId}) async {
    final dbClient = await db;
    if (dbClient == null) {
      logger.i('Database is null. Make sure to call setDatabase() first.');
      return []; // Ensure a non-null value is returned
    }

    String whereClause = companyId != null ? 'Companyid = ?' : '1';
    List<dynamic> whereArgs = companyId != null ? [companyId] : [];

    try {
      final List<Map<String, dynamic>> maps = await dbClient.query('itemMaster',
          where: whereClause, whereArgs: whereArgs);
      logger.i('Item count: $maps');

      return List.generate(maps.length, (i) {
        return ItemData(
          itemId: maps[i]['Itemid'],
          itemName: maps[i]['itemName'],
          selRate: maps[i]['Selrate'],
          mrp: maps[i]['MRP'],
          cgst: maps[i]['cgst'],
          wsSelRate: maps[i]['WSSELRATE'],
          purRate: maps[i]['PurRate'],
          commCode: maps[i]['commCode'],
          lok: maps[i]['Lok'],
          companyid: maps[i]['Companyid'],
        );
      });
    } catch (e) {
      logger.i('Error retrieving items: $e');
      return []; // Ensure a non-null value is returned even in case of error
    }
  }

  Future<List<TransactionModal>> getTran({String? companyId}) async {
    final dbClient = await db;
    if (dbClient == null) {
      logger.i('Database is null. Make sure to call setDatabase() first.');
      return [];
    }
    String whereClause = companyId != null ? 'Companyid = ?' : '1';
    List<dynamic> whereArgs = companyId != null ? [companyId] : [];
    final List<Map<String, dynamic>> maps = await dbClient.query('AccMast',
        where: whereClause, whereArgs: whereArgs);

    /* // logger.i the fetched data
    logger.i('Fetched data from the database:');
    for (var map in maps) {
      logger.i('Accode: ${map['Accode']}');
      logger.i('Name: ${map['Name']}');
      logger.i('GroupName: ${map['Groupname']}');
      logger.i('Companyid: ${map['Companyid']}');
      logger.i('Lok: ${map['Lok']}');
      logger.i('Mobile: ${map['Mobile']}');
    }
*/
    return List.generate(maps.length, (i) {
      return TransactionModal(
        accode: maps[i]['Accode'] ?? '',
        name: maps[i]['Name'] ?? '',
        groupName: maps[i]['Groupname'] ?? '',
        companyid: maps[i]['Companyid'] ?? '',
        lok: maps[i]['Lok'] ?? '',
        mobile: maps[i]['Mobile'] ?? '',
      );
    });
  }

  Future<List<String>> getDropDownTran({String? companyId}) async {
    /*logger.i("+++++++++dfdfdfdfdfdfdfdfdfdfdfdfdfdf++++++++");*/

    try {
      final dbClient = await db;
      if (dbClient == null) {
        logger.i('Database is null. Make sure to call setDatabase() first.');
        return [];
      }

      if (companyId != null) {
        final List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'SELECT DISTINCT Name FROM AccMast WHERE Groupname IN (?, ?) AND Companyid = ?',
          ['BANK ACCOUNT', 'CASH IN HAND', companyId],
        );

        // logger.i the fetched data
        logger.i('Fetched data from the database:');
        for (var map in maps) {
          logger.i('Name: ${map['Name']}');
        }
        return List.generate(maps.length, (i) {
          return maps[i]['Name'] as String;
        });
      } else {
        return [];
      }
    } catch (e) {
      logger.i('Error fetching dropdown data: $e');
      return [];
    }
  }

  Future<List<LedgerBalanceModal>> getLedgerItems({String? companyId}) async {
    final dbClient = await db;
    if (dbClient == null) {
      logger.i('Database is null. Make sure to call setDatabase() first.');
      return [];
    }
    String whereClause = companyId != null ? 'Companyid = ?' : '1';
    List<dynamic> whereArgs = companyId != null ? [companyId] : [];
    final List<Map<String, dynamic>> maps = await dbClient
        .query('LedgerBalance', where: whereClause, whereArgs: whereArgs);
    return List.generate(maps.length, (i) {
      return LedgerBalanceModal(
        companyId: maps[i]['Companyid'],
        accode: maps[i]['Accode'],
        name: maps[i]['name'],
        groupName: maps[i]['GroupName'],
        mobileNo: maps[i]['MobileNo'],
        balance: maps[i]['Balance'],
      );
    });
  }

  Future<int> updateItem(
    String itemId,
    String itemName,
    String Selrate,
    String MRP,
    String cgst,
    String WSSELRATE,
    String? PurRate,
    String? commCode,
    String? Companyid,
    String? Lok,
  ) async {
    try {
      final Database db = await setDatabase();
      final int rowsAffected = await db.update(
        'itemMaster',
        {
          'itemName': itemName,
          'Selrate': Selrate,
          'MRP': MRP,
          'cgst': cgst,
          'WSSELRATE': WSSELRATE,
          'PurRate': PurRate,
          'commCode': commCode,
          'Lok': Lok,
          'Companyid': Companyid,
        },
        where: 'itemId = ?',
        whereArgs: [itemId],
      );
      logger.i('Item updated successfully');
      return rowsAffected;
    } catch (e) {
      logger.i('Error updating item: $e');
      rethrow;
    }
  }

  Future<int> insertCompanyProfile({
    String? companyId,
    String? companyName,
    String? add1,
    String? add2,
    String? add3,
    String? add4,
    String? pincode,
    String? mobileNo,
    String? gstin,
    String? itemPre,
    String? itemNo,
    String? accPre,
    String? accNo,
    String? billPre,
    String? billNo,
    String? TaxType,
  }) async {
    try {
      final dbClient = await setDatabase();
      final int rowsAffected = await dbClient.insert(
        'companyProfile',
        {
          'CompanyId': companyId,
          'CompanyName': companyName,
          'Add1': add1,
          'Add2': add2,
          'Add3': add3,
          'Add4': add4,
          'Pincode': pincode,
          'MobileNo': mobileNo,
          'Gstin': gstin,
          'ItemPre': itemPre,
          'ItemNo': itemNo,
          'AccPre': accPre,
          'AccNo': accNo,
          'BillPre': billPre,
          'BillNo': billNo,
          'TaxType' : TaxType,
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // Replace existing row
      );

      if (rowsAffected > 0) {
        Fluttertoast.showToast(msg: 'Profile Created successfully');
      } else {
        Fluttertoast.showToast(msg: 'Error updating Profile');
      }

      return rowsAffected;
    } catch (e) {
      logger.i('Error inserting company profile: $e');
      return 0; // Return 0 to indicate failure
    }
  }

  Future<int> updateCompanyProfile({
    String? companyId,
    String? companyName,
    String? add1,
    String? add2,
    String? add3,
    String? add4,
    String? pincode,
    String? mobileNo,
    String? gstin,
    String? itemPre,
    String? itemNo,
    String? accPre,
    String? accNo,
    String? billPre,
    String? billNo,
    String? TaxType,
  }) async {
    try {
      final dbClient = await setDatabase();
      final int rowsAffected = await dbClient.update(
        'companyProfile',
        {
          'CompanyName': companyName,
          'Add1': add1,
          'Add2': add2,
          'Add3': add3,
          'Add4': add4,
          'Pincode': pincode,
          'MobileNo': mobileNo,
          'Gstin': gstin,
          'ItemPre': itemPre,
          'ItemNo': itemNo,
          'AccPre': accPre,
          'AccNo': accNo,
          'BillPre': billPre,
          'BillNo': billNo,
          'TaxType' : TaxType,
        },
        where: 'CompanyId = ?',
        whereArgs: [companyId],
      );

      if (rowsAffected > 0) {
        Fluttertoast.showToast(msg: 'Profile Updated successfully');
      } else {
        Fluttertoast.showToast(msg: 'Error updating Profile');
      }

      return rowsAffected;
    } catch (e) {
      logger.i('Error updating company profile: $e');
      return 0; // Return 0 to indicate failure
    }
  }

  Future<Map<String, dynamic>> getCompanyProfile(String companyId) async {
    try {
      final dbClient = await setDatabase();
      final List<Map<String, dynamic>> result = await dbClient.query(
        'companyProfile',
        where: 'CompanyId = ?',
        whereArgs: [companyId],
      );

      if (result.isNotEmpty) {
        logger.i('Get Company Profile: $result');
        return result.first;
      } else {
        return {}; // Return an empty map if no profile is found
      }
    } catch (e) {
      logger.i('Error retrieving company profile: $e');
      rethrow;
    }
  }

Future<Map<String, dynamic>> getBillDetails(String companyId, String billNo) async {
  try {
    Fluttertoast.showToast(msg:"$companyId $billNo");
    final dbClient = await setDatabase();
    final List<Map<String, dynamic>> result = await dbClient.query(
      'SalesEntry',
      where: 'Companyid = ? AND BillNo = ?',
      whereArgs: [companyId, billNo],
    );

    if (result.isNotEmpty) {
      logger.i('Get Bill Detail: $result');
      return result.first;
    } else {
      return {};
    }
  } catch (e) {
    logger.i('Error retrieving Bill Detail: $e');
    rethrow;
  }
}


  Future<void> insertAccmastData(List<AccmastBalanceModal?> items) async {
    logger.i('Item Count: ${items.length}');
    final dbClient = db;
    if (dbClient == null) {
      logger.i('Database is null. Make sure to call setDatabase() first.');
      return;
    }

    Batch batch = dbClient.batch();

    for (var item in items) {
      if (item != null) {
        final existingRecord = await dbClient.query(
          'AccMast',
          where: 'Companyid = ? AND Accode = ?',
          whereArgs: [item.companyid, item.accode],
        );

        if (existingRecord.isNotEmpty) {
          await dbClient.delete(
            'AccMast',
            where: 'Companyid = ? AND Accode = ?',
            whereArgs: [item.companyid, item.accode],
          );
        }

        batch.insert(
          'AccMast',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit();
    Fluttertoast.showToast(msg: "Successfully Synced!");
  
}

Future<List<AccmastBalanceModal>> getAccmastItems({String? companyId}) async {
    try {
      final dbClient = await db;
      if (dbClient == null) {
        logger.i('Database is null. Make sure to call setDatabase() first.');
        return [];
      }
      String whereClause = companyId != null ? 'Companyid = ?' : '1';
      List<dynamic> whereArgs = companyId != null ? [companyId] : [];
      final List<Map<String, dynamic>> maps = await dbClient.query('AccMast',
          where: whereClause, whereArgs: whereArgs);
      
      return List.generate(maps.length, (i) {
        // logger.i('Accounty Mastet count: $maps');
        return AccmastBalanceModal(
          accode: maps[i]['Accode'] ?? '',
          name: maps[i]['Name'] ?? '',
          groupname: maps[i]['Groupname'] ?? '',
          companyid: maps[i]['Companyid'] ?? '',
          lok: maps[i]['Lok'] ?? '',
          mobile: maps[i]['Mobile'] ?? '',
          address1: maps[i]['Address1'] ?? '',
          address2: maps[i]['Address2'] ?? '',
          address3: maps[i]['Address3'] ?? '',
          address4: maps[i]['Address4'] ?? '',
          gstin: maps[i]['Gstin'] ?? '',
          pincode: maps[i]['Pincode'] ?? '',
        );

      });
    } catch (e) {
      logger.i('Error fetching Accmast items: $e');
      return [];
    }
  }

Future<List<AccmastBalanceModal>> getAccmastCustName({String? companyId}) async {
  try {
    final dbClient = await db;
    if (dbClient == null) {
      logger.i('Database is null. Make sure to call setDatabase() first.');
      return [];
    }

    String whereClause = companyId != null ? 'Companyid = ?' : '1';
    List<dynamic> whereArgs = companyId != null ? [companyId] : [];

    final List<Map<String, dynamic>> maps = await dbClient.query(
      'AccMast',
      where: '$whereClause AND GroupName = ?',
      whereArgs: [...whereArgs, 'SUNDRY DEBITORS'],
      orderBy: 'Name', // Order by the 'Name' column
    );

    return List.generate(maps.length, (i) {
      return AccmastBalanceModal(
        accode: maps[i]['Accode'] ?? '',
        name: maps[i]['Name'] ?? '',
        groupname: maps[i]['Groupname'] ?? '',
        companyid: maps[i]['Companyid'] ?? '',
        lok: maps[i]['Lok'] ?? '',
        mobile: maps[i]['Mobile'] ?? '',
        address1: maps[i]['Address1'] ?? '',
        address2: maps[i]['Address2'] ?? '',
        address3: maps[i]['Address3'] ?? '',
        address4: maps[i]['Address4'] ?? '',
        gstin: maps[i]['Gstin'] ?? '',
        pincode: maps[i]['Pincode'] ?? '',
      );
    });
  } catch (e) {
    logger.i('Error fetching Accmast items: $e');
    return [];
  }
}

  Future<void> insertSalesEntryData(Map<String, dynamic> data) async {
    final db = await setDatabase();
    try {
      await db.insert('SalesEntry', data);
      logger.i('Data inserted into SalesEntry table successfully');
    } catch (e) {
      logger.i('Error inserting data into SalesEntry table: $e');
    }
  }

}

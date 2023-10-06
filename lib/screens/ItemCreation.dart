import 'dart:convert';
import 'package:bneedsoutlet/Database/Database_Helper.dart';
import 'package:bneedsoutlet/screens/Drawer.dart';
import 'package:bneedsoutlet/screens/Logout.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Modal/AddCompanyModal.dart';
import '../Modal/item_data_modal.dart';
import '../style/Colors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart' as logger;


class ItemCreation extends StatefulWidget {
  const ItemCreation({super.key});

  @override
  State<ItemCreation> createState() => _ItemCreationState();
}

class _ItemCreationState extends State<ItemCreation> {
  final log = logger.Logger();
  late Future<List<ItemData>> futureItemData = Future.value([]);
  List<ItemData> itemDataList = [];
  late Database _database;
  late Future<List<Company>> _futureCompanies;
  late DatabaseConnection databaseHelper;
  String? _selectedValue;
  String _searchText = '';
  String itemID = '';


  void _updateSearchText(String text) {
    setState(() {
      _searchText = text;
      refreshAlbums();
    });
  }

 

  void _updateItemApi(itemID,itemname,selRate,mrp,cgst,wSselRate,purRate,commcode,companyid,lok){
    var url = Uri.parse(
        'http://bneeds.in/bneedsoutletapi/itemMasterApi.aspx?action=UpdateItemData'
            '&itemID=$itemID'
            '&itemname=$itemname'
            '&selRate=$selRate'
            '&mrp=$mrp'
            '&cgst=$cgst'
            '&wSselRate=$wSselRate'
            '&purRate=$purRate'
            '&commcode=$commcode'
            '&lok=$lok'
            '&companyid=$companyid'
    );
    // // logger.i(url);
    // Make the HTTP request
    http.get(url).then((response) async {
      if (response.statusCode == 200) {
        // Request successful
        if (response.body == 'Successfully updated!') {
          // // logger.i("+++++++++++++++++++++++");
          Fluttertoast.showToast(msg: 'Successfully Updated!');
          // // logger.i("Successfully Updated! in Api");
          refreshAlbums();
        } else {
          Fluttertoast.showToast(msg: 'Not Update Properly');
          // logger.i("Not Update Properly");
        }
      }
    }).catchError((error) {
      // logger.i("+++++++++++++++++++++");
      // logger.i('Error: $error');
      Fluttertoast.showToast(msg: 'Error: $error');
      refreshAlbums();
    });
  }

    void _addItemApi(newitemID,itemname,selRate,mrp,cgst,wSselRate,purRate,commcode,companyid,lok){
    var url = Uri.parse(
        'http://bneeds.in/bneedsoutletapi/itemMasterApi.aspx?action=AddItemData'
            '&itemID=$newitemID'
            '&itemname=$itemname'
            '&selRate=$selRate'
            '&mrp=$mrp'
            '&cgst=$cgst'
            '&wSselRate=$wSselRate'
            '&purRate=$purRate'
            '&commcode=$commcode'
            '&lok=$lok'
            '&companyid=$companyid'
    );
    log.w('Add Item: $url');
    // Make the HTTP request
    http.get(url).then((response) async {
      if (response.statusCode == 200) {
        // Request successful
        if (response.body == 'Successfully updated!') {
          // // logger.i("+++++++++++++++++++++++");
          Fluttertoast.showToast(msg: 'Successfully Updated!');
          // // logger.i("Successfully Updated! in Api");
          refreshAlbums();
        } else {
          Fluttertoast.showToast(msg: 'Not Update Properly');
          // logger.i("Not Update Properly");
        }
      }
    }).catchError((error) {
      // logger.i("+++++++++++++++++++++");
      // logger.i('Error: $error');
      Fluttertoast.showToast(msg: 'Error: $error');
      refreshAlbums();
    });
  }

  final _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    initializeDatabase();
    databaseHelper = DatabaseConnection();
    // !company Dropdown
    _futureCompanies = fetchAlbums(context);
    // !
    _selectedValue = null;

    fetchDataAndInsertIntoSQLite(databaseHelper);
  }

  bool _isSearchVisible = false;

  void _toggleSearchVisibility() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _updateSearchText('');
      }
    });
  }

  Future<void> initializeDatabase() async {
    DatabaseConnection databaseConnection = DatabaseConnection();
    _database = await databaseConnection.setDatabase();
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    await initializeDatabase();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.BodyColor,
          title: const Center(child: const Text('SYNC',style: TextStyle(fontWeight: FontWeight.bold),)),
          content: const SingleChildScrollView(
            child: Column(
              children: [
                Text('Do you Want Sync Data?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, true);
              },
              child: const Text('YES'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == true) {
        fetchDataAndInsertIntoSQLite(databaseHelper);
      }
    });
  }

  Future<void> fetchDataAndInsertIntoSQLite(DatabaseConnection databaseHelper) async {
    try {
      await databaseHelper.setDatabase();
      final items = await fetchData();
      // logger.i("+++++Item+++++++++++++++");
        log.i('Fetch Data Item Count: ${items.length}');

      if(items.length != 0)
      {
        await databaseHelper.insertItemData(items);
        refreshAlbums();
      }
      else
        {
          /*Fluttertoast.showToast(msg: "No New Data Found!");*/
        }
      /*// logger.i('Successfully Fetched');*/
    } catch (e) {
      // logger.i('Error fetchDataAndInsertIntoSQLite : $e');
    }
  }

  Future<void> deleteData() async {
    SharedPreferences loginprefs = await SharedPreferences.getInstance();
    String? username = loginprefs.getString("Username");
    final url = Uri.parse(
      'http://bneeds.in/bneedsoutletapi/ItemMasterApi.aspx?action=DeleteItemData&username=$username',
    );
    log.i('Delete Item: $url');

    try{
      Fluttertoast.showToast(msg: "Successfully Deleted");
    }
    catch(e)
    {
      // logger.i('Error Delete Data: $e');
    }
  }

    Future<List<ItemData>> fetchData() async {
    SharedPreferences loginprefs = await SharedPreferences.getInstance();
    String? username = loginprefs.getString("username");
    String? access = "0";
    final url = Uri.parse(
      'http://bneeds.in/bneedsoutletapi/ItemMasterApi.aspx?action=LoadItemData&username=$username&access=$access',
    );

     log.i('Itemcreation: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        List<ItemData> items = [];
        log.w("Item creation succes Response");

        for (var itemData in jsonData) {
          String itemID = itemData['Itemid'];
          String itemName = itemData['itemName'];
          String selRate = itemData['Selrate'];
          String mrp = itemData['MRP'];
          String cgst = itemData['cgst'];
          String wSselRate = itemData['WSSELRATE'];
          String purRate = itemData['PurRate'];
          String commCode = itemData['commCode'];
          String lok = itemData['Lok'];
          String companyid = itemData['companyid'];

                // log.w('Return Item: $itemID');

          ItemData item = ItemData(
            itemId: itemID,
            itemName: itemName,
            selRate: selRate,
            mrp: mrp,
            cgst: cgst,
            wsSelRate: wSselRate,
            purRate: purRate,
            commCode: commCode,
            lok: lok,
            companyid: companyid,
          );
          items.add(item);
        }

        /*    setState(() {
          dashboardItems = items;
        });*/
        /*deleteData();*/
        // log.w('Return Item: ${items.length}');
        return items;

      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      log.i('Error Fetch Data: $e');
      return [];
    }
  }

  Future<void> refreshAlbums() async {
    try {
      final databaseHelper = DatabaseConnection();
      await databaseHelper.setDatabase();
      List<ItemData> items = await databaseHelper.getItems(companyId: _selectedValue);
      setState(() {
        futureItemData = Future.value(items);
      });
      // logger.i('Successfully Get+++++++++++');
    } catch (e) {
      // logger.i('Error fetching and updating data: $e');
    }
  }

  List<ItemData> _filterItems(List<ItemData> items) {
    return items.where((item) {
      if (_searchText.isEmpty) {
        return item.companyid == _selectedValue;
      } else {
        return item.companyid == _selectedValue &&
            item.itemName.toLowerCase().contains(_searchText.toLowerCase());
      }
    }).toList();
  }

  void _showItemEditDialog(BuildContext context, ItemData album) {
    TextEditingController itemNameController = TextEditingController(text: album.itemName);
    TextEditingController selRateController = TextEditingController(text: album.selRate);
    TextEditingController mrpController = TextEditingController(text: album.mrp);
    TextEditingController cgstController = TextEditingController(text: album.cgst);
    TextEditingController wSselRateController = TextEditingController(text: album.wsSelRate);
    TextEditingController purRateController = TextEditingController(text: album.purRate);
    TextEditingController commcodeController = TextEditingController(text: album.commCode);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.BodyColor,
          title: Center(child: Text('(${album.itemId}) ${album.itemName}', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18))),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: itemNameController,
                  style: const TextStyle(color: AppColors.CommonColor,fontSize: 20,fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: 'itemName',
                    labelStyle: TextStyle(color: AppColors.CommonColor),
                  ),
                 /* onTap: () {
                    itemNameController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: itemNameController.text.length,
                    );
                  },*/
                ),
                const SizedBox(height: 0),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: purRateController,
                        style: const TextStyle(color: AppColors.CommonColor,fontSize: 20,fontWeight: FontWeight.bold),
                        decoration:const  InputDecoration(
                          labelText: 'purRate',
                          labelStyle: TextStyle(color: AppColors.CommonColor),
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        onTap: () {
                          purRateController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: purRateController.text.length,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        controller: mrpController,
                        style: const TextStyle(color: AppColors.CommonColor,fontSize: 20,fontWeight: FontWeight.bold),
                        decoration:const  InputDecoration(
                          labelText: 'mrp',
                          labelStyle: TextStyle(color: AppColors.CommonColor),
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        onTap: () {
                          mrpController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: mrpController.text.length,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: selRateController,
                        style: const TextStyle(color: AppColors.CommonColor,fontSize: 20,fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'selRate',
                          labelStyle: TextStyle(color: AppColors.CommonColor,fontSize: 20),
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        onTap: () {
                          selRateController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: selRateController.text.length,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        controller: wSselRateController,
                        style: const TextStyle(color: AppColors.CommonColor,fontSize: 20,fontWeight: FontWeight.bold),
                        decoration:const  InputDecoration(
                          labelText: 'Wsselrate',
                          labelStyle: TextStyle(color: AppColors.CommonColor,fontSize: 20),
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        onTap: () {
                          wSselRateController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: wSselRateController.text.length,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cgstController,
                        style: const TextStyle(color: AppColors.CommonColor,fontSize: 20,fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'Cgst',
                          labelStyle: TextStyle(color: AppColors.CommonColor,fontSize: 20),
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        onTap: () {
                          cgstController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: cgstController.text.length,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        controller: commcodeController,
                        style: const TextStyle(color: AppColors.CommonColor,fontSize: 20,fontWeight: FontWeight.bold),
                        decoration:const InputDecoration(
                          labelText: 'HSN Code',
                          labelStyle: TextStyle(color: AppColors.CommonColor),
                        ),
                        textAlign: TextAlign.right,
                        onTap: () {
                          commcodeController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: commcodeController.text.length,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.CommonColor,
                foregroundColor: AppColors.BodyColor,
              ),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                itemID =  album.itemId;
                String newItemName = itemNameController.text;
                String newselRate = selRateController.text;
                String newmrp = mrpController.text;
                String newCgst = cgstController.text;
                String newwSselRate = wSselRateController.text;
                String newpurRate = purRateController.text;
                String newCommCode = commcodeController.text;
                String? companyid = _selectedValue;
                String lok ="M";

                    // logger.i("=======================");
                    // logger.i(itemID);
                    // logger.i(newItemName);
                    // logger.i(newselRate);
                    // logger.i(newmrp);
                    // logger.i(newCgst);
                    // logger.i(newwSselRate);
                    // logger.i(newpurRate);
                    // logger.i(newCommCode);
                    // logger.i(companyid);
                int rowsAffected = await DatabaseConnection().updateItem(itemID, newItemName, newselRate,newmrp,newCgst,newwSselRate,newpurRate,newCommCode,companyid,lok);
                if (rowsAffected > 0) {
                  _updateItemApi(itemID,newItemName,newselRate,newmrp,newCgst,newselRate,newpurRate,newCommCode,companyid,lok);
                  /*Fluttertoast.showToast(msg: 'Category updated successfully');*/
                  commcodeController.text="";
                  selRateController.text="";
                  refreshAlbums();
                } else {
                  Fluttertoast.showToast(msg: 'Error updating category');
                }
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.CommonColor,
                foregroundColor: AppColors.BodyColor,
              ),
              child: const Text('UPDATE'),
            ),
          ],
        );
      },
    );
  }
  void _showAddItemDilaog() {
    TextEditingController itemNameController = TextEditingController();
    TextEditingController selRateController = TextEditingController();
    TextEditingController mrpController = TextEditingController();
    TextEditingController cgstController = TextEditingController();
    TextEditingController wSselRateController = TextEditingController();
    TextEditingController purRateController = TextEditingController();
    TextEditingController commcodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.BodyColor,
          title: const Center(child: Text('ADD ITEM', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22))),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: itemNameController,
                  style: const TextStyle(color: AppColors.CommonColor,fontSize: 20,fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: 'itemName',
                    labelStyle: TextStyle(color: AppColors.CommonColor),
                  ),
                  /* onTap: () {
                    itemNameController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: itemNameController.text.length,
                    );
                  },*/
                ),
                const SizedBox(height: 0),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: purRateController,
                        style: const TextStyle(color: AppColors.CommonColor,fontSize: 20,fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'purRate',
                          labelStyle: TextStyle(color: AppColors.CommonColor),
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        onTap: () {
                          purRateController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: purRateController.text.length,
                          );
                        },
                      ),
                    ),
                   const SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        controller: mrpController,
                        style: const TextStyle(color: AppColors.CommonColor,fontSize: 20,fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'mrp',
                          labelStyle: TextStyle(color: AppColors.CommonColor),
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        onTap: () {
                          mrpController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: mrpController.text.length,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: selRateController,
                        style: const TextStyle(color: AppColors.CommonColor,fontSize: 20,fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'selRate',
                          labelStyle: TextStyle(color: AppColors.CommonColor,fontSize: 20),
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        onTap: () {
                          selRateController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: selRateController.text.length,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        controller: wSselRateController,
                        style: const TextStyle(color: AppColors.CommonColor,fontSize: 20,fontWeight: FontWeight.bold),
                        decoration:const  InputDecoration(
                          labelText: 'Wsselrate',
                          labelStyle: TextStyle(color: AppColors.CommonColor,fontSize: 20),
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        onTap: () {
                          wSselRateController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: wSselRateController.text.length,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cgstController,
                        style: const TextStyle(color: AppColors.CommonColor,fontSize: 20,fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'Cgst',
                          labelStyle: TextStyle(color: AppColors.CommonColor,fontSize: 20),
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        onTap: () {
                          cgstController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: cgstController.text.length,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        controller: commcodeController,
                        style: const TextStyle(color: AppColors.CommonColor,fontSize: 20,fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'HSN Code',
                          labelStyle: TextStyle(color: AppColors.CommonColor),
                        ),
                        textAlign: TextAlign.right,
                        onTap: () {
                          commcodeController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: commcodeController.text.length,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.CommonColor,
                foregroundColor: AppColors.BodyColor,
              ),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newItemName = itemNameController.text;
                String newselRate = selRateController.text;
                String newmrp = mrpController.text;
                String newCgst = cgstController.text;
                String newSselRate = wSselRateController.text;
                String newpurRate = purRateController.text;
                String newCommCode = commcodeController.text;
                String? companyid = _selectedValue;
                String lok ="M";

                // SharedPreferences comProfileprefs = await SharedPreferences.getInstance();
                // String? itemPre =  comProfileprefs.getString("itemPre");
                // String? itemString = comProfileprefs.getString("ItemNo");
                // String itemID = "$itemPre$itemString";
                // int? newitemID;

                // if (itemString != null) {
                //   int? itemID = int.tryParse(itemString);
                //   if (itemID != null) {
                //     newitemID = itemID + 1;
                //   }
                // }
                var databaseConnection = DatabaseConnection();
                var database = await databaseConnection.setDatabase();
                var getItemId = await database.rawQuery('SELECT ItemPre,CAST(ItemNo AS INTEGER) + 1 AS NewItemNo FROM companyProfile WHERE Companyid = ?', [_selectedValue]);
                    //  log.w('Fetch Data from Database: $getItemId');
                var itemPre = getItemId.first['ItemPre'] ?? '';
                var itemNo = getItemId.first['NewItemNo'] ?? '';
                  // log.w('New Item No: $itemNo');
                await database.rawUpdate('UPDATE companyProfile SET ItemNo = ? WHERE Companyid = ?',[itemNo, _selectedValue]);
                  var itemID = '$itemPre$itemNo';
                  // log.w('Item Id: $itemID');
                
                try {
                  _addItemApi(itemID,newItemName,newselRate,newmrp,newCgst,newselRate,newpurRate,newCommCode,companyid,lok);
                  commcodeController.text="";
                  selRateController.text="";
                  fetchDataAndInsertIntoSQLite(databaseHelper);
                  Navigator.pop(context, true);
                } catch (e) {
                  log.w('error: $e');
                  Fluttertoast.showToast(msg: "Error Occurred: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.CommonColor,
                foregroundColor: AppColors.BodyColor,
              ),
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: _isSearchVisible
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: _searchController,
            onChanged: _updateSearchText,
            style:const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: const TextStyle(color: Colors.white54),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _updateSearchText('');
                  _toggleSearchVisibility;
                },
                color: Colors.white,
              ),
            ),
          ),
        )
            : const Text(
          "Item Creation",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isSearchVisible)
            IconButton(
              onPressed: () {
                _showConfirmationDialog(context);
              },
              icon: const Icon(Icons.sync),
            ),
          IconButton(
            onPressed: _toggleSearchVisibility,
            icon: const Icon(Icons.search),
          ),
          const Logout(),
        ],
        backgroundColor: AppColors.CommonColor,
        iconTheme:const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: AppColors.BodyColor,
        child: Column(
          children: [
            FutureBuilder<List<Company>>(
              future: _futureCompanies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data != null) {
                  // If data is available, build the dropdown
                  List<Company> companies = snapshot.data!;
                  if (_selectedValue == null && companies.isNotEmpty) {
                    _selectedValue = companies.first.companyid;
                    refreshAlbums();
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedValue,
                        hint: Text(_selectedValue ?? 'Select a company'),
                        items: companies.map((company) {
                          return DropdownMenuItem<String>(
                            value: company.companyid,
                            child:Text(company.companyid),
                          );
                        }).toList(),
                        onChanged: (String? selectedValue) {
                          setState(() {
                            _selectedValue = selectedValue;
                          });
                          // logger.i('Selected company: $selectedValue');
                          refreshAlbums();
                        },
                      ),
                    ),
                  );
                } else {
                  return const Text('No companies available.');
                }
              },
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total NO Of Items",
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.CommonColor, fontSize: 16),
                    ),
                    FutureBuilder<List<ItemData>>(
                      future: futureItemData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData && snapshot.data != null) {
                          List<ItemData> data = snapshot.data!;
                          int totalLength = data.length;
                          // logger.i("+++++++++++++++++++++++++++");
                          // logger.i(data.length);
                          return Text(
                            "$totalLength",
                            style:const TextStyle(fontWeight: FontWeight.bold, color: AppColors.CommonColor, fontSize: 16),
                          );
                        } else {
                          return const Text('No data available.');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Flexible(
              child: RefreshIndicator(
                onRefresh: refreshAlbums,
                child: FutureBuilder<List<ItemData>>(
                  future: futureItemData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData && snapshot.data != null) {
                      itemDataList = snapshot.data!;
                      final filteredItems = _filterItems(itemDataList);
                      return ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          ItemData album = filteredItems[index];
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              /*height: 475,*/
                              padding:const EdgeInsets.symmetric(horizontal: 5),
                              child: Card(
                                elevation: 3,
                                color: AppColors.CommonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text(
                                    album.itemName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.BodyColor,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        'P:${album.purRate}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.BodyColor,
                                        ),
                                      ),
                                    const  SizedBox(width: 10),
                                      Text(
                                        'S:${album.selRate}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.BodyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing:const Icon(
                                    Icons.edit, // Replace this with your desired trailing icon
                                    color: AppColors.BodyColor,
                                    size: 25,
                                  ),
                                  onTap: () {
                                    _showItemEditDialog(context, album);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text('No data available.'));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showAddItemDilaog();
        },
        backgroundColor: AppColors.BodyColor,
        foregroundColor: AppColors.CommonColor,
        child:const Icon(Icons.add),
      ),
    );
  }
}



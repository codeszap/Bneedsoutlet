import 'dart:convert';
import 'package:bneedsoutlet/Database/Database_Helper.dart';
import 'package:bneedsoutlet/screens/Drawer.dart';
import 'package:bneedsoutlet/screens/Logout.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Modal/AddCompanyModal.dart';
import '../Modal/TransactionModal.dart';
import '../style/Colors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart' as logger;
import 'AddExpense.dart';


class Transaction extends StatefulWidget {
  const Transaction({super.key});

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseConnection();
    _futureCompanies = fetchAlbums(context);
    _selectedValue = null;
    fetchDataAndInsertIntoSQLite(context, databaseHelper);
    refreshAlbums();
    loaddropdownData();
  }
  final log = logger.Logger();
  late Future<List<TransactionModal>> futureItemData = Future.value([]);
  List<TransactionModal> itemDataList = [];
  late Future<List<Company>> _futureCompanies;
  late DatabaseConnection databaseHelper;
  String? _selectedValue;
  List<String> transactionList = [];
  String? selectedTransaction;
  String _searchText = '';
  String itemID = '';
  final  _searchController = TextEditingController();
  bool _isSearchVisible = false;
  String? selectedOption = 'Credit';
  late Database _database;


  void _updateSearchText(String text) {
    setState(() {
      _searchText = text;
      refreshAlbums();
    });
  }

  void loaddropdownData() async {
    try {
      final databaseHelper = DatabaseConnection();
      await databaseHelper.setDatabase();
      List<String> data = await databaseHelper.getDropDownTran(companyId: _selectedValue);
      setState(() {
        transactionList = data;
        if (data.isNotEmpty && selectedTransaction == null) {
          selectedTransaction = data.first;
        }
      });


      // logger.i('===========================');
      // logger.i('Loaded Data: $selectedTransaction');
    } catch (e) {
      // logger.i('Error loading dropdown data: $e');
      // Handle the error as needed
    }
  }



  /*void _UpdateItemApi(itemID,itemname,selrate,mrp,cgst,wsselrate,purrate,commcode,companyid,lok){
    var url = Uri.parse(
        'http://bneeds.in/bneedsoutletapi/itemMasterApi.aspx?action=UpdateItemData'
            '&itemID=$itemID'
            '&itemname=$itemname'
            '&selrate=$selrate'
            '&mrp=$mrp'
            '&cgst=$cgst'
            '&wsselrate=$wsselrate'
            '&purrate=$purrate'
            '&commcode=$commcode'
            '&lok=$lok'
            '&companyid=$companyid'
    );
    logger.i(url);
    // Make the HTTP request
    http.get(url).then((response) async {
      if (response.statusCode == 200) {
        // Request successful
        if (response.body == 'Successfully updated!') {
          logger.i("+++++++++++++++++++++++");
          Fluttertoast.showToast(msg: 'Successfully Updated!');
          logger.i("Successfully Updated! in Api");
          refreshAlbums();
        } else {
          Fluttertoast.showToast(msg: 'Not Update Properly');
          logger.i("Not Update Properly");
        }
      }
    }).catchError((error) {
      logger.i("+++++++++++++++++++++");
      logger.i('Error: $error');
      Fluttertoast.showToast(msg: 'Error: $error');
      refreshAlbums();
    });
  }*/

  void _showAddDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            backgroundColor: AppColors.BodyColor,
          title: const  Align(
            alignment: Alignment.topCenter,
            child: Text("ADD ACCOUNT",
              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
            ),
          ),
            content:SingleChildScrollView(
                child: Column(
                  children: [
                    const  TextField(),
                    const  TextField(),
                    const  TextField(),
                    const  TextField(),
                    const  SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.CommonColor,
                              foregroundColor: AppColors.BodyColor,
                            ),
                            child:const  Text("Cancel")
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: (){}, 
                        style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.CommonColor,
                              foregroundColor: AppColors.BodyColor,
                            ),
                        child: const  Text("Add")
                        ),
                      ],
                    ),
                  ],
                )
            ),
          );
        }
    );
  }


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

  /*Future<void> _showConfirmationDialog(BuildContext context) async {
    await initializeDatabase();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.BodyColor,
          title: Center(child: Text('SYNC',style: TextStyle(fontWeight: FontWeight.bold),)),
          content: SingleChildScrollView(
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
              child: Text('NO'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, true);
              },
              child: Text('YES'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == true) {
        fetchDataAndInsertIntoSQLite(context, databaseHelper);
      }
    });
  }*/

  Future<void> fetchDataAndInsertIntoSQLite(BuildContext context, DatabaseConnection databaseHelper) async {
    try {
      await databaseHelper.setDatabase();
      final dropdownData = await fetchdropdownData();
      final items = await fetchData();
      // logger.i("+++++Item+++++++++++++++");
      // logger.i('Item Count: ${items.length}');

      if(items.length != 0)
      {
        await databaseHelper.insertDropdownData(dropdownData);
        await databaseHelper.insertTranData(items);
        refreshAlbums();
        // logger.i('Successfully Fetched');
      }
      else
      {
        /*Fluttertoast.showToast(msg: "No New Data Found!");*/
      }

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
    // logger.i(url);

    try{
      Fluttertoast.showToast(msg: "Successfully Deleted");
    }
    catch(e)
    {
      // logger.i('Error Delete Data: $e');
    }
  }

  Future<List<TransactionModal>> fetchData() async {

    SharedPreferences loginprefs = await SharedPreferences.getInstance();
    String? username = loginprefs.getString("username");
    String? code = '0';
    final url = Uri.parse(
      'http://bneeds.in/bneedsoutletapi/TransactionApi.aspx?action=LoadTranData&username=$username&code=$code',
    );
    log.w(url);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        List<TransactionModal> items = [];
        for (var itemData in jsonData) {
          String accode = itemData['accode'];
          String name = itemData['name'];
          String groupname = itemData['groupname'];
          String companyid = itemData['companyid'];
          String lok = itemData['lok'];
          String mobile = itemData['mobile'];

          TransactionModal item = TransactionModal(
            accode: accode,
            name: name,
            groupName: groupname,
            companyid: companyid,
            lok: lok,
            mobile: mobile,
          );
          items.add(item);
        }

        /*    setState(() {
          dashboardItems = items;
        });*/
        /*deleteData();*/
        return items;

      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // logger.i('Error Fetch Data: $e');
      return [];
    }
  }

  Future<List<TransactionModal>> fetchdropdownData() async {

    SharedPreferences loginprefs = await SharedPreferences.getInstance();
    String? username = loginprefs.getString("Username");
    final url = Uri.parse(
      'http://bneeds.in/bneedsoutletapi/TransactionApi.aspx?action=dropdownData&username=$username',
    );
    // logger.i(url);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        List<TransactionModal> items = [];
        for (var itemData in jsonData) {
          String accode = itemData['accode'];
          String name = itemData['name'];
          String groupname = itemData['groupname'];
          String companyid = itemData['companyid'];
          String lok = itemData['lok'];
          String mobile = itemData['mobile'];

          TransactionModal item = TransactionModal(
            accode: accode,
            name: name,
            groupName: groupname,
            companyid: companyid,
            lok: lok,
            mobile: mobile,
          );
          items.add(item);
        }

        /*    setState(() {
          dashboardItems = items;
        });*/
        /*deleteData();*/
        return items;

      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // logger.i('Error Fetch Data: $e');
      return [];
    }
  }

  Future<void> refreshAlbums() async {
    try {
      final databaseHelper = DatabaseConnection();
      await databaseHelper.setDatabase();
      List<TransactionModal> items = await databaseHelper.getTran(companyId: _selectedValue);
      setState(() {
        futureItemData = Future.value(items);
      });
    } catch (e) {
      // logger.i('Error fetching and updating data: $e');
    }
  }

  void _addTranApi(companyid,billdate,accode,narration,amount, String payBy, String? drCR){
    var url = Uri.parse(
        'http://bneeds.in/bneedsoutletapi/TransactionApi.aspx?action=InsertTransaction'
            '&companyid=$companyid'
            '&billdate=$billdate'
            '&accode=$accode'
            '&amount=$amount'
            '&payBy=$payBy'
            '&drCR=$drCR'
            '&narration=$narration'
    );
    // logger.i(url);
    http.get(url).then((response) async {
      if (response.statusCode == 200) {
        if (response.body == 'Successfully updated!') {
          // logger.i("+++++++++++++++++++++++");
          Fluttertoast.showToast(msg: 'Successfully Updated!');
          // logger.i("Successfully Updated! in Api");
          fetchDataAndInsertIntoSQLite(context, databaseHelper);
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
    // logger.i("+++++++++++++++++++");
    // logger.i("Accmast UpdateApi");
    // logger.i(companyid);
    // logger.i(billdate);
    // logger.i(accode);
    // logger.i(amount);
    // logger.i(narration);
    // logger.i(payBy);
    // logger.i(drCR);
  }

  List<TransactionModal> _filterItems(List<TransactionModal> items) {
    return items.where((item) {
      if (_searchText.isEmpty) {
        return item.companyid == _selectedValue;
      } else {
        return item.companyid == _selectedValue &&
            item.name.toLowerCase().contains(_searchText.toLowerCase());
      }
    }).toList();
  }

  void _showTopSheet(BuildContext context, TransactionModal album) {
    TextEditingController amountController = TextEditingController();
    TextEditingController narrationController = TextEditingController();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutBack,
        );
        return Transform.translate(
          offset: Offset(0.0, -1 * curvedAnimation.value * 10),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center( // Wrap the content with a Center widget
          child: Material(
            color: AppColors.BodyColor,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${album.name} (${album.accode})',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      style: const TextStyle(
                          color: AppColors.CommonColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'amount',
                        labelStyle: TextStyle(
                          color: AppColors.CommonColor,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: narrationController,
                      style: const TextStyle(
                          color: AppColors.CommonColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'narration',
                        labelStyle: TextStyle(
                          color: AppColors.CommonColor,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButton<String>(
                        value: selectedTransaction,
                        onChanged: (newValue) {
                          setState(() {
                            selectedTransaction = newValue;
                          });
                        },
                        items: transactionList.map((transactionname) {
                          return DropdownMenuItem<String>(
                            value: transactionname,
                            child: Text(transactionname),
                          );
                        }).toList(),
                        hint:const  Text('Select a transaction'),
                        isDense: true,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Flexible(
                          child: Radio<String>(
                            value: 'Credit',
                            groupValue: selectedOption,
                            onChanged: (newValue) {
                              setState(() {
                                selectedTransaction = newValue;
                              });
                              _showTopSheet(context, album);
                            },
                          ),
                        ),
                        Flexible(child: Text('Credit')),
                        SizedBox(width: 20),
                        Flexible(
                          child: Radio<String>(
                            value: 'Debit',
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value;
                              });
                            },
                          ),
                        ),
                        Flexible(child: Text('Debit')),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: Text('CANCEL'),
                          style: ElevatedButton.styleFrom(
                            primary: AppColors.CommonColor,
                            foregroundColor: AppColors.BodyColor,
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            String amount = amountController.text;
                            String narration = narrationController.text;
                            String? payBy = selectedTransaction;
                            String? drCR = selectedOption;
                            String? companyid = _selectedValue;
                            String? accode = album.accode;
                            DateTime now = DateTime.now();
                            String formattedDate =
                            DateFormat('yyyy-MM-dd').format(now);

                            _addTranApi(
                                companyid, formattedDate, accode, narration, amount, payBy!, drCR);
                            Navigator.pop(context, true);
                          },
                          child: Text('UPDATE'),
                          style: ElevatedButton.styleFrom(
                            primary: AppColors.CommonColor,
                            foregroundColor: AppColors.BodyColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: _isSearchVisible
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: _searchController,
            onChanged: _updateSearchText,
            style: const TextStyle(color: Colors.white),
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
          "Expense Entry",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isSearchVisible)
            IconButton(
              onPressed: () {
                /*_showConfirmationDialo
                g(context);*/
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
        iconTheme: const IconThemeData(color: Colors.white),
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
                  List<Company> companies = snapshot.data!;
                  if (_selectedValue == null && companies.isNotEmpty) {
                    _selectedValue = companies.first.companyid;
                    refreshAlbums();
                    loaddropdownData();
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
                            child: Text(company.companyid),
                          );
                        }).toList(),
                        onChanged: (String? selectedValue) {
                          setState(() {
                            _selectedValue = selectedValue;
                          });
                          // logger.i('Selected company: $selectedValue');
                          refreshAlbums();
                          loaddropdownData();
                        },
                      ),
                    ),
                  );
                } else {
                  return  const Text('No companies available.');
                }
              },
            ),
           /* SizedBox(height: 5),*/
           /* Container(
              height: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total NO Of Items",
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.CommonColor, fontSize: 16),
                    ),
                    FutureBuilder<List<TransactionModal>>(
                      future: futureItemData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData && snapshot.data != null) {
                          List<TransactionModal> data = snapshot.data!;
                          int TotalLength = data.length;
                          return Text(
                            "$TotalLength",
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.CommonColor, fontSize: 16),
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
            SizedBox(height: 5),*/
            Flexible(
              child: RefreshIndicator(
                onRefresh: refreshAlbums,
                child: FutureBuilder<List<TransactionModal>>(
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
                          TransactionModal album = filteredItems[index];
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              /*height: 475,*/
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Card(
                                elevation: 3,
                                color: AppColors.CommonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          album.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:  Colors.limeAccent,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        album.accode,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.BodyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'GRP:  ${album.groupName}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.BodyColor,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Mob:  ${album.mobile.isNotEmpty ? album.mobile :"0"}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          IconButton(onPressed: (){
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AddExpense(album: album, Companyid: _selectedValue),
                                              ),
                                            );
                                          }, icon: const Icon(Icons.edit),color: AppColors.BodyColor,),
                                        ],
                                      ),
                                    ],
                                  ),
                                 /* trailing: Icon(
                                    Icons.edit, // Replace this with your desired trailing icon
                                    color: AppColors.BodyColor,
                                    size: 25,
                                  ),
                                  onTap: () {
                                    _showItemEditDialog(context, album);
                                  },*/
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     _showAddDialog();
      //   },
      //   backgroundColor: AppColors.BodyColor,
      //   foregroundColor: AppColors.CommonColor,
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}



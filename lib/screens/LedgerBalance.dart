import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import '../Database/Database_Helper.dart';
import '../Modal/AddCompanyModal.dart';
import '../Modal/ledger_balance_modal.dart';
import '../style/Colors.dart';
import 'package:logger/logger.dart' as logger;
import 'Drawer.dart';
import 'Logout.dart';

class Ledgerbalance extends StatefulWidget {
  const Ledgerbalance({super.key});

  @override
  State<Ledgerbalance> createState() => _LedgerbalanceState();
}

class _LedgerbalanceState extends State<Ledgerbalance> {
  bool _isSearchVisible = false;
  final log = logger.Logger();
  final _searchController = TextEditingController();
  String _searchText = '';
  String? _selectedValue;
  late Database _database;
  late Future<List<LedgerBalanceModal>> futureLedgerData = Future.value([]);
  late DatabaseConnection databaseHelper;
  late Future<List<Company>> _futureCompanies;
  List<LedgerBalanceModal> ledgerDataList = [];


  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseConnection();
    _futureCompanies = fetchAlbums(context);
    _selectedValue = null;
    fetchDataAndInsertIntoSQLite(context, databaseHelper);
  }

  void _updateSearchText(String text) {
    setState(() {
      _searchText = text;
      refreshAlbums();
    });
  }

  Future<void> fetchDataAndInsertIntoSQLite(BuildContext context, DatabaseConnection databaseHelper) async {
    try {
      /*logger.i("+++++Item+++++++++++++++");*/
      // await databaseHelper.setDatabase();
      final items = await fetchData();
   /*   logger.i("+++++Item+++++++++++++++");
      logger.i('Item Count: ${items.length}');*/

      if(items.length != 0)
      {
        /*logger.i('Item Count: ${items.length}');*/
        await databaseHelper.insertLedgerData(items);
        refreshAlbums();
        // logger.i("Insert Successfully!");
      }
      else
      {
        /*Fluttertoast.showToast(msg: "No New Data Found!");*/
      }
      /*logger.i('Successfully Fetched');*/
    } catch (e) {
      // logger.i('Error fetchDataAndInsertIntoSQLite : $e');
    }
  }

  Future<List<LedgerBalanceModal>> fetchData() async {

    // SharedPreferences loginprefs = await SharedPreferences.getInstance();
    // String? username = loginprefs.getString("username");
    String? code = '0';
    final url = Uri.parse(
      'http://bneeds.in/bneedsoutletapi/LedgerbalanceApi.aspx?companyid=$_selectedValue&code=$code',
    );
    log.w('Ledger Balance: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        List<LedgerBalanceModal> items = [];

        for (var itemData in jsonData) {
          String companyId = itemData['companyId'];
          String accode = itemData['accode'];
          String name = itemData['name'];
          String groupName = itemData['groupName'];
          String mobileNo = itemData['mobileNo'];
          String balance = itemData['balance'];

          LedgerBalanceModal item = LedgerBalanceModal(
            companyId: companyId,
            accode: accode,
            name: name,
            groupName: groupName,
            mobileNo: mobileNo,
            balance: balance,
          );
          items.add(item);
        }

        /*    setState(() {
          dashboardItems = items;
        });*/
        /*DeleteData();*/
        return items;

      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // logger.i('Error Fetch Data: $e');
      return [];
    }
  }

  List<LedgerBalanceModal> _filterItems(List<LedgerBalanceModal> items) {
    return items.where((item) {
      if (_searchText.isEmpty) {
        return item.companyId == _selectedValue;
      } else {
        return item.companyId == _selectedValue &&
            item.name.toLowerCase().contains(_searchText.toLowerCase());
      }
    }).toList();
  }

  Future<void> refreshAlbums() async {
    try {
      final databaseHelper = DatabaseConnection();
      await databaseHelper.setDatabase();
      List<LedgerBalanceModal> items = await databaseHelper.getLedgerItems(companyId: _selectedValue);
      setState(() {
        futureLedgerData = Future.value(items);
      });
      fetchDataAndInsertIntoSQLite(context, databaseHelper);
      // logger.i('Successfully Get+++++++++++');
    } catch (e) {
      // logger.i('Error fetching and updating data: $e');
    }
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

  Future<void> _showConfirmationDialog(BuildContext context) async {
    await initializeDatabase();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.BodyColor,
          title: const Center(child: Text('SYNC',style: TextStyle(fontWeight: FontWeight.bold),)),
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
        fetchDataAndInsertIntoSQLite(context, databaseHelper);
      }
    });
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
            :const Text(
          "Ledger balance",
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
                            child: Text(company.companyid),
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
                      "Total No Of Items",
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.CommonColor, fontSize: 16),
                    ),
                    FutureBuilder<List<LedgerBalanceModal>>(
                      future: futureLedgerData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData && snapshot.data != null) {
                          List<LedgerBalanceModal> data = snapshot.data!;
                          int totalLength = data.length;
                          return Text(
                            "$totalLength",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.CommonColor, fontSize: 16),
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
                child: FutureBuilder<List<LedgerBalanceModal>>(
                  future: futureLedgerData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData && snapshot.data != null) {
                      ledgerDataList = snapshot.data!;
                      final filteredItems = _filterItems(ledgerDataList);
                      /*logger.i("++++++++++++++++++++++");
                      logger.i(filteredItems.length);*/
                      return ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          LedgerBalanceModal album = filteredItems[index];
                          return GestureDetector(
                            onTap: () {},
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
                                    Text(
                                      album.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.BodyColor,
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
                                subtitle: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Mob: ${album.mobileNo != null && album.mobileNo.isNotEmpty ? album.mobileNo : '0'}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.BodyColor,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Bal: ${album.balance}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.BodyColor,
                                      ),
                                    ),
                                  ],
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
    );
  }
}

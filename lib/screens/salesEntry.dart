import 'dart:convert';

import 'package:bneedsoutlet/Modal/accmast_balance_modal.dart';
import 'package:bneedsoutlet/screens/AddSales.dart';
import 'package:bneedsoutlet/screens/Drawer.dart';
import 'package:bneedsoutlet/screens/_add_account_master.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart' as logger;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../Database/Database_Helper.dart';
import '../Modal/AddCompanyModal.dart';
import '../Modal/item_data_modal.dart';
import '../style/Colors.dart';
import 'Logout.dart';
import 'package:http/http.dart' as http;
class SalesEntry extends StatefulWidget {
  const SalesEntry({super.key});

  @override
  State<SalesEntry> createState() => _SalesEntryState();
}

class _SalesEntryState extends State<SalesEntry> {
  final log = logger.Logger();
  late Future<List<AccmastBalanceModal>> futureItemData = Future.value([]);
  List<AccmastBalanceModal> itemDataList = [];
  late Future<List<Company>> _futureCompanies;
  late DatabaseConnection databaseHelper;
  String? _selectedValue;
  String itemID = '';
   String _searchText = '';
   bool _isSearchVisible = false;
  final _searchController = TextEditingController();
  String? selectedGroupName;
  String? _selectedSheetCompanyValue;
  List<String> transactionList = [];


    @override
  void initState() {
    super.initState();
    initializeDatabase();
    databaseHelper = DatabaseConnection();
    refreshAlbums();
    // !company Dropdown
    _futureCompanies = fetchAlbums(context);
    // !
     _futureCompanies.then((companies) {
      setState(() {
        _selectedValue = determineDefaultCompany(companies);
        fetchDataAndInsertIntoSQLite(databaseHelper);
        loaddropdownData();
      });
    });
  }

   void loaddropdownData() async {
    try {
      final databaseHelper = DatabaseConnection();
      await databaseHelper.setDatabase();
      List<String> data = await databaseHelper.getDropDownTran(companyId: _selectedValue);
      setState(() {
        transactionList = data;
        if (data.isNotEmpty && selectedGroupName == null) {
          selectedGroupName = data.first;
        }
      });
      // logger.i('===========================');
      log.i('Loaded Data: $selectedGroupName');
    } catch (e) {
      log.i('Error loading dropdown data: $e');
      // Handle the error as needed
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

  void _updateSearchText(String text) {
    setState(() {
      _searchText = text;
      refreshAlbums();
    });
  }

    String determineDefaultCompany(List<Company> companies) {
    if (companies.isNotEmpty) {
      return companies.first.companyid;
    } else {
      return '';
    }
  }

Future<void> fetchDataAndInsertIntoSQLite(DatabaseConnection databaseHelper) async {
    try {
      await databaseHelper.setDatabase();
      final items = await fetchData();
      // logger.i("+++++Item+++++++++++++++");
        log.i('Fetch Data Item Count: ${items.length}');

      if(items.length != 0)
      {
        await databaseHelper.insertAccmastData(items);
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

    List<AccmastBalanceModal> _filterItems(List<AccmastBalanceModal> items) {
    return items.where((item) {
      if (_searchText.isEmpty) {
        return item.companyid == _selectedValue;
      } else {
        return item.companyid == _selectedValue &&
            item.name.toLowerCase().contains(_searchText.toLowerCase());
      }
    }).toList();
  }

     Future<List<AccmastBalanceModal>> fetchData() async {
    // SharedPreferences loginprefs = await SharedPreferences.getInstance();
    // String? username = loginprefs.getString("username");
    String? access = "1";
    final url = Uri.parse(
      'http://bneeds.in/bneedsoutletapi/AccountMasterApi.aspx?action=LoadAccountData&companyid=$_selectedValue&access=$access',
    );

     log.i('Account Master: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        List<AccmastBalanceModal> items = [];
        log.w("Item creation succes Response");

        for (var itemData in jsonData) {
          String accode = itemData['Accode']??'';
          String name = itemData['Name']??'';
          String groupname = itemData['Groupname']??'';
          String companyid = itemData['Companyid']??'';
          String lok = itemData['Lok']??'';
          String mobile = itemData['Mobile']??'';
          String address1 = itemData['Address1']??'';
          String address2 = itemData['Address2']??'';
          String address3 = itemData['Address3']??'';
          String address4 = itemData['Address4']??'';
          String gstin = itemData['Gstin']??'';
          String pincode = itemData['Pincode']??'';

                // log.w('Return Item: $itemID');

          AccmastBalanceModal item = AccmastBalanceModal(
            accode: accode,
            name: name,
            groupname: groupname,
            companyid: companyid,
            lok: lok,
            mobile: mobile,
            address1: address1,
            address2: address2,
            address3: address3,
            address4: address4,
            gstin: gstin,
            pincode: pincode,
          );
          items.add(item);
        }


        // if (items.isNotEmpty) {
        //   // Log the first item's properties
        //   final firstItem = items[0];
        //   log.w('First Item - Accode: ${firstItem.accode}');
        //   log.w('First Item - Name: ${firstItem.name}');
        //   log.w('First Item - Groupname: ${firstItem.groupname}');
        //   // Add more properties as needed...

        //   // If you want to log all properties in one log message
        //   log.w('First Item: $firstItem');

        //   // If you want to log a specific property of the first item
        //   log.w('First Item - GSTIN: ${firstItem.gstin}');
        // } else {
        //   log.w('No items in the list');
        // }

        return items;

      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      log.i('Error Fetch Data: $e');
      return [];
    }
  }

  Future<void> initializeDatabase() async {
    DatabaseConnection databaseConnection = DatabaseConnection();
     await databaseConnection.setDatabase();
  }

    Future<void> refreshAlbums() async {
    try {
      final databaseHelper = DatabaseConnection();
      await databaseHelper.setDatabase();
      List<AccmastBalanceModal> items = await databaseHelper.getAccmastCustName(companyId: _selectedValue);
//         log.i('Items: $items');

//         if (items.isNotEmpty) {
//   // Log the first item's properties
//   final firstItem = items[0];
//   log.w('First Item - Accode: ${firstItem.accode}');
//   log.w('First Item - Name: ${firstItem.name}');
//   log.w('First Item - Groupname: ${firstItem.groupname}');
//   // Add more properties as needed...

//   // If you want to log all properties in one log message
//   log.w('First Item: $firstItem');

//   // If you want to log a specific property of the first item
//   log.w('First Item - GSTIN: ${firstItem.gstin}');
// } else {
//   log.w('No items in the list');
// }

      setState(() {
        futureItemData = Future.value(items);
      });
      log.i('Successfully Get+++++++++++');
    } catch (e) {
      // logger.i('Error fetching and updating data: $e');
    }
  }

  void _showBottomSheet(BuildContext context, AccmastBalanceModal album) {

  showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (BuildContext context) {
    return Container(
       color: AppColors.BodyColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12.0),
            color: AppColors.CommonColor, // Customize the app bar color
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      color: AppColors.BodyColor, // Customize the icon color
                    ),
                    const Text(
                      "SALES ENTRY",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.BodyColor, // Customize the text color
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Customer:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          album.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Item Name',
                      ),
                    ),
                    const SizedBox(height: 500),
                  ],
                ),
           ),
          // const SizedBox(height: 50),
        ],
      ),
    );
  },
);

}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BodyColor,
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
          "Sales Entry",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isSearchVisible)
            IconButton(
              onPressed: () {
                // _showConfirmationDialog(context);
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
      body:Column(
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
                          log.i('Selected company: $selectedValue');
                          fetchDataAndInsertIntoSQLite(databaseHelper);
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
          Flexible(
              child: RefreshIndicator(
                onRefresh: refreshAlbums,
                child: FutureBuilder<List<AccmastBalanceModal>>(
                  future: futureItemData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData && snapshot.data != null) {
                      itemDataList = snapshot.data!;
                      log.w(itemDataList.length);              
                      final filteredItems = _filterItems(itemDataList);
                      log.w(filteredItems.length);
                      return ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          AccmastBalanceModal album = filteredItems[index];
                        return GestureDetector(
                          onTap: () {
                             _showBottomSheet(context, album);
                          },
                            child: Container(
                              padding:const EdgeInsets.symmetric(horizontal: 5),
                              child: Card(
                                elevation: 3,
                                color: AppColors.CommonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text(
                                    album.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:AppColors.BodyColor,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mob: ${album.mobile.isNotEmpty ? album.mobile : '0'}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.BodyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                              
                                onTap: () {
                                  // _showBottomSheet(context, album);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>  AddSales(album: album,selectedCompany:_selectedValue ?? "")),
                                  );
                                    // Fluttertoast.showToast(msg: "Hi");
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //      Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const add_account_master(),
      //             ),
      //           );
      //   },
      //   backgroundColor: AppColors.CommonColor,
      //   foregroundColor: AppColors.BodyColor,
      //   child: const Icon(Icons.add,size: 30,),
      // ),
    );
  }
}

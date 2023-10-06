import 'dart:convert';

import 'package:bneedsoutlet/Modal/accmast_balance_modal.dart';
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
class Accmast extends StatefulWidget {
  const Accmast({super.key});

  @override
  State<Accmast> createState() => _AccmastState();
}

class _AccmastState extends State<Accmast> {
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
      List<AccmastBalanceModal> items = await databaseHelper.getAccmastItems(companyId: _selectedValue);
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

    // setState(() {
      _selectedSheetCompanyValue = album.companyid;
      selectedGroupName = album.groupname;
    // });
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _add1Controller = TextEditingController();
  final TextEditingController _add2Controller = TextEditingController();
  final TextEditingController _add3Controller = TextEditingController();
  final TextEditingController _add4Controller = TextEditingController();
  final TextEditingController _mobNoController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

    _nameController.text = album.name;
    _add1Controller.text = album.address1;
    _add2Controller.text = album.address2;
    _add3Controller.text = album.address3;
    _add4Controller.text = album.address4;
    _mobNoController.text = album.mobile;
    _gstinController.text = album.gstin;
    _pincodeController.text = album.pincode;


    void _UpdateAcctApi(NewAcctId,Name,GroupName,companyid,Add1,Add2,Add3,Add4,MobNo,Pincode,Gstin,lok){
    var url = Uri.parse(
        'http://bneeds.in/bneedsoutletapi/AccountMasterApi.aspx?action=UpdateAccountData'
            '&NewAcctId=$NewAcctId'
            '&Name=$Name'
            '&GroupName=$GroupName'
            '&companyid=$companyid'
            '&Add1=$Add1'
            '&Add2=$Add2'
            '&Add3=$Add3'
            '&Add4=$Add4'
            '&MobNo=$MobNo'
            '&Pincode=$Pincode'
            '&Gstin=$Gstin'
            '&lok=$lok'
    );
    log.w('Update Account Data: $url');
    // Make the HTTP request
    http.get(url).then((response) async {
      if (response.statusCode == 200) {
        // Request successful
        if (response.body == 'Successfully updated!') {
          // // logger.i("+++++++++++++++++++++++");
          Fluttertoast.showToast(msg: 'Successfully Updated!');
          // // logger.i("Successfully Updated! in Api");
          Navigator.pop(context);
          fetchDataAndInsertIntoSQLite(databaseHelper);
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
    });
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Container(
          color: AppColors.BodyColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 50),
              const Align(
                alignment: Alignment.topCenter,
                child: const Text("Update Accmast",style: TextStyle(fontWeight:FontWeight.bold,fontSize: 25),)),
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
                    if (_selectedSheetCompanyValue == null && companies.isNotEmpty) {
                      _selectedSheetCompanyValue = companies.first.companyid;
                      
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedSheetCompanyValue,
                          hint: Text(_selectedSheetCompanyValue ?? 'Select a company'),
                          items: companies.map((company) {
                            return DropdownMenuItem<String>(
                              value: company.companyid,
                              child:Text(company.companyid),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedSheetCompanyValue = newValue;
                            });
                            log.i('Selected sheet company: $newValue');
                          },
                        ),
                      ),
                    );
                  } else {
                    return const Text('No companies available.');
                  }
                },
              ),
      
                TextField(
                controller: _nameController,
                  decoration:const InputDecoration(
                    prefixIcon: Icon(Icons.contact_emergency),
                    labelText: "Enter Name"
                  ),
                ),

                const SizedBox(height: 12),
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                        Icons.payment),
                  ),
                  child: DropdownButton<String>(
                    value: selectedGroupName,
                    onChanged: (newValue) {
                      setState(() {
                        selectedGroupName = newValue;
                      });
                    },
                    items: transactionList.map((transactionname) {
                      return DropdownMenuItem<String>(
                        value: transactionname,
                        child: Text(transactionname),
                      );
                    }).toList(),
                    hint: const Text('Select a transaction'),
                    isDense: true,
                  ),
                ),
              ),

                const SizedBox(height: 8),
                 TextField(
                controller: _add1Controller,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.looks_one),
                    labelText: "Enter Add 1"
                  ),
                ),
                TextField(
                  controller: _add2Controller,
                  decoration:const InputDecoration(
                    prefixIcon: Icon(Icons.looks_two),
                    labelText: "Enter Add 2"
                  ),
                ),
                 TextField(
                  controller: _add3Controller,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.looks_3), labelText: "Enter Add 3"),
                ),
                 TextField(
                  controller: _add4Controller,
                  decoration:const InputDecoration(
                      prefixIcon: Icon(Icons.looks_4), labelText: "Enter Add 4"),
                ),
                 TextField(
                  controller: _mobNoController,
                  decoration:const InputDecoration(
                      prefixIcon: Icon(Icons.mobile_friendly),
                      labelText: "Enter Mobile No"),
                      keyboardType: TextInputType.number,
                ),
                 TextField(
                  controller: _pincodeController,
                  decoration:const InputDecoration(
                      prefixIcon: Icon(Icons.add_chart),
                      labelText: "Enter Pincode"),
                      keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _gstinController,
                  decoration:const InputDecoration(
                      prefixIcon: Icon(Icons.numbers), labelText: "Enter Gstin"),
                ),
                const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        _nameController.text ="";
                        _add1Controller.text ="";
                        _add2Controller.text ="";
                        _add3Controller.text ="";
                        _add4Controller.text ="";
                        _mobNoController.text ="";
                        _gstinController.text ="";
                        _pincodeController.text ="";    
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.CommonColor,
                        foregroundColor: AppColors.BodyColor,
                      ),
                      child: const Text('CANCEL')),
                  const SizedBox(width: 20),
                  ElevatedButton(
                      onPressed: () async {
                String Accode = album.accode;
                String Name = _nameController.text;
                String? GroupName = selectedGroupName;
                String? companyid = _selectedValue;
                String Add1 = _add1Controller.text;
                String Add2 = _add2Controller.text;
                String Add3 = _add3Controller.text;
                String Add4 = _add4Controller.text;
                String MobNo = _mobNoController.text;
                String Pincode = _pincodeController.text;
                String Gstin = _gstinController.text;
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
                
                  // log.w('Item Id: $itemID');
                    // Fluttertoast.showToast(msg: NewAcctId);
                
                try {
                  _UpdateAcctApi(Accode,Name,GroupName,companyid,Add1,Add2,Add3,Add4,MobNo,Pincode,Gstin,lok);
                       _nameController.text ="";
                        _add1Controller.text ="";
                        _add2Controller.text ="";
                        _add3Controller.text ="";
                        _add4Controller.text ="";
                        _mobNoController.text ="";
                        _gstinController.text ="";
                        _pincodeController.text ="";  
                        Accode= "";
                } catch (e) {
                  log.w('error: $e');
                  Fluttertoast.showToast(msg: "Error Occurred: $e");
                }
       
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.CommonColor,
                        foregroundColor: AppColors.BodyColor,
                      ),
                      child: const Text('Update')),
                ],
              ),     
              const SizedBox(height: 70),           
            ],
          ),
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
          "Account Master",
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
                       // Log properties of the first item if the list is not empty
                    // if (itemDataList.isNotEmpty) {
                    //   final firstItem = itemDataList[0];
                    //   log.w('First Item - Accode: ${firstItem.accode}');
                    //   log.w('First Item - Name: ${firstItem.name}');
                    //   log.w('First Item - Groupname: ${firstItem.groupname}');
                    //   // Add more properties as needed...
                    // } else {
                    //   log.w('itemDataList is empty');
                    // }
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
                                    album.accode,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.BodyColor,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Name: ${album.name}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.BodyColor,
                                        ),
                                      ),
                                    const  SizedBox(width: 10),
                                      Text(
                                        'Grp: ${album.groupname}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.BodyColor,
                                        ),
                                      ),
                                      const  SizedBox(width: 10),
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
                                  trailing:const Icon(
                                    Icons.edit, // Replace this with your desired trailing icon
                                    color: AppColors.BodyColor,
                                    size: 25,
                                  ),
                                  onTap: () {
                                    _showBottomSheet(context, album);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const add_account_master(),
                  ),
                );
        },
        backgroundColor: AppColors.CommonColor,
        foregroundColor: AppColors.BodyColor,
        child: const Icon(Icons.add,size: 30,),
      ),
    );
  }
}

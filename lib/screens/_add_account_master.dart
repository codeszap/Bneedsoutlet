import 'package:bneedsoutlet/screens/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart' as logger;
import '../Database/Database_Helper.dart';
import '../Modal/AddCompanyModal.dart';
import '../style/Colors.dart';
import 'Logout.dart';
import 'package:http/http.dart' as http;

class add_account_master extends StatefulWidget {
  
  const add_account_master({super.key});

  @override
  State<add_account_master> createState() => _add_account_masterState();
}

class _add_account_masterState extends State<add_account_master> {

  final log = logger.Logger();
  late Future<List<Company>> _futureCompanies;
  late DatabaseConnection databaseHelper;
  String? _selectedValue;
  String itemID = '';
  final String _searchText = '';
  String? selectedGroupName;
  List<String> transactionList = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _add1Controller = TextEditingController();
  final TextEditingController _add2Controller = TextEditingController();
  final TextEditingController _add3Controller = TextEditingController();
  final TextEditingController _add4Controller = TextEditingController();
  final TextEditingController _mobNoController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDatabase();
    databaseHelper = DatabaseConnection();
    // !company Dropdown
    _futureCompanies = fetchAlbums(context);
    // !
     _futureCompanies.then((companies) {
      setState(() {
        _selectedValue = determineDefaultCompany(companies);
        log.i('DropDown Value: $_selectedValue');
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

  Future<void> initializeDatabase() async {
    DatabaseConnection databaseConnection = DatabaseConnection();
     await databaseConnection.setDatabase();
  }


     String determineDefaultCompany(List<Company> companies) {
    if (companies.isNotEmpty) {
      return companies.first.companyid;
    } else {
      return '';
    }
  }

  void _addAcctApi(NewAcctId,Name,GroupName,companyid,Add1,Add2,Add3,Add4,MobNo,Pincode,Gstin,lok){
    var url = Uri.parse(
        'http://bneeds.in/bneedsoutletapi/AccountMasterApi.aspx?action=AddAccountData'
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
    log.w('Add Account Data: $url');
    // Make the HTTP request
    http.get(url).then((response) async {
      if (response.statusCode == 200) {
        // Request successful
        if (response.body == 'Successfully updated!') {
          // // logger.i("+++++++++++++++++++++++");
          Fluttertoast.showToast(msg: 'Successfully Updated!');
          // // logger.i("Successfully Updated! in Api");
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BodyColor,
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "Add Account Master",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: const [
          Logout(),
        ],
        backgroundColor: AppColors.CommonColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
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
                var databaseConnection = DatabaseConnection();
                var database = await databaseConnection.setDatabase();
                var getAcctId = await database.rawQuery('SELECT AccPre,CAST(AccNo AS INTEGER) + 1 AS NewAcctId FROM companyProfile WHERE Companyid = ?', [_selectedValue]);
                    //  log.w('Fetch Data from Database: $getItemId');
                var accPre = getAcctId.first['AccPre'] ?? '';
                var accId = getAcctId.first['NewAcctId'] ?? '';
                  // log.w('New Item No: $itemNo');
                await database.rawUpdate('UPDATE companyProfile SET AccNo = ? WHERE Companyid = ?',[accId, _selectedValue]);
                  var NewAcctId = '$accPre$accId';
                  // log.w('Item Id: $itemID');
                    // Fluttertoast.showToast(msg: NewAcctId);
                
                try {
                  _addAcctApi(NewAcctId,Name,GroupName,companyid,Add1,Add2,Add3,Add4,MobNo,Pincode,Gstin,lok);
                       _nameController.text ="";
                        _add1Controller.text ="";
                        _add2Controller.text ="";
                        _add3Controller.text ="";
                        _add4Controller.text ="";
                        _mobNoController.text ="";
                        _gstinController.text ="";
                        _pincodeController.text ="";    
                } catch (e) {
                  log.w('error: $e');
                  Fluttertoast.showToast(msg: "Error Occurred: $e");
                }
       
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.CommonColor,
                        foregroundColor: AppColors.BodyColor,
                      ),
                      child: const Text('ADD')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../Database/Database_Helper.dart';
import '../Modal/AddCompanyModal.dart';
import '../style/Colors.dart';
import 'Drawer.dart';
import 'Logout.dart';
import 'package:logger/logger.dart' as logger;

class CompanyProfile extends StatefulWidget {
  const CompanyProfile({super.key});

  @override
  State<CompanyProfile> createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<CompanyProfile> {
  final log = logger.Logger();
  String? _selectedValue;
  late Future<List<Company>> _futureCompanies;
  int? comId;
  String? selectedOption = '0';
  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseConnection();
    _futureCompanies = fetchAlbums(context);
    initializeDatabase();
  
    _futureCompanies.then((companies) {
      setState(() {
        _selectedValue = determineDefaultCompany(companies);
        getCompanyProfileData(_selectedValue!);
      });
    });

    
  }

  String determineDefaultCompany(List<Company> companies) {
    if (companies.isNotEmpty) {
      return companies.first.companyid;
    } else {
      return '';
    }
  }

  Future<void> getCompanyProfileData(String companyId) async {    
    try {
      final companyProfile = await databaseHelper.getCompanyProfile(companyId);
      comId = companyProfile['ComId'] as int?;          
      _companyNameController.text = companyProfile['CompanyName'] ?? '';
      _add1Controller.text = companyProfile['Add1'] ?? '';
      _add2Controller.text = companyProfile['Add2'] ?? '';
      _add3Controller.text = companyProfile['Add3'] ?? '';
      _add4Controller.text = companyProfile['Add4'] ?? '';
      _pincodeController.text = companyProfile['Pincode'] ?? '';
      _mobNoController.text = companyProfile['MobileNo'] ?? '';
      _gstinController.text = companyProfile['Gstin'] ?? '';
      _itemPreController.text = companyProfile['ItemPre'] ?? '';
      _itemNoController.text = companyProfile['ItemNo'] ?? '';
      _accPreNameController.text = companyProfile['AccPre'] ?? '';
      _accNoController.text = companyProfile['AccNo'] ?? '';
      _billPreController.text = companyProfile['BillPre'] ?? '';
      _billNoController.text = companyProfile['BillNo'] ?? '';

      setState(() {
        selectedOption = companyProfile['TaxType'] ?? '';
      });

      // log.w("Success!");
      // Fluttertoast.showToast(msg: "$comId");
    } catch (e) { 
      log.w('Error getting company profile data: $e');
    }
  }

  Future<void> initializeDatabase() async {            
    DatabaseConnection databaseConnection = DatabaseConnection();
    _database = await databaseConnection.setDatabase();
    await databaseConnection.createNewTable();
  }


  late Database _database;
  late DatabaseConnection databaseHelper;

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _add1Controller = TextEditingController();
  final TextEditingController _add2Controller = TextEditingController();
  final TextEditingController _add3Controller = TextEditingController();
  final TextEditingController _add4Controller = TextEditingController();
  final TextEditingController _mobNoController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _itemPreController = TextEditingController();
  final TextEditingController _itemNoController = TextEditingController();
  final TextEditingController _accPreNameController = TextEditingController();
  final TextEditingController _accNoController = TextEditingController();
  final TextEditingController _billPreController = TextEditingController();
  final TextEditingController _billNoController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.BodyColor,
        drawer: CustomDrawer(),
        appBar: AppBar(
          title: const Text(
            'Company Profile',
            style: TextStyle(
                color: AppColors.BodyColor, fontWeight: FontWeight.bold),
          ),
          actions: const [
            Logout(),
          ],
          bottom: const TabBar(
            labelColor: AppColors.BodyColor,
            unselectedLabelColor: Colors.grey,
            isScrollable: true,
            tabs: [
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Tab(
                  text: 'Detail 1',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Tab(
                  text: 'Detail 2',
                ),
              ),
            ],
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: AppColors.CommonColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                        FutureBuilder<List<Company>>(
                        future: _futureCompanies,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData &&
                              snapshot.data != null) {
                            List<Company> companies = snapshot.data!;
                            if (_selectedValue == null &&
                                companies.isNotEmpty) {
                              _selectedValue = companies.first.companyid;
                            }
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: _selectedValue,
                                    hint: Text(
                                        _selectedValue ?? 'Select a company'),
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
                                      getCompanyProfileData(selectedValue!);
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
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        prefixIcon: Icon(Icons.wb_shade),
                      ),
                    ),
                    TextField(
                      controller: _add1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address 1',
                        prefixIcon: Icon(Icons.looks_one),
                      ),
                    ),
                    TextField(
                      controller: _add2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address 2',
                        prefixIcon: Icon(Icons.looks_two),
                      ),
                    ),
                    TextField(
                      controller: _add3Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address 3',
                        prefixIcon: Icon(Icons.looks_3),
                      ),
                    ),
                    TextField(
                      controller: _add4Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address 4',
                        prefixIcon: Icon(Icons.looks_4),
                      ),
                    ),
                    TextField(
                      controller: _pincodeController,
                      decoration: const InputDecoration(
                        labelText: 'Pincode',
                        prefixIcon: Icon(Icons.add_chart),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _mobNoController,
                      decoration: const InputDecoration(
                        labelText: 'Mobile No',
                        prefixIcon: Icon(Icons.phone_android),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _gstinController,
                      decoration: const InputDecoration(
                        labelText: 'Gstin',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _itemPreController,
                            decoration: const InputDecoration(
                              labelText: 'Item Prefix',
                              prefixIcon: Icon(Icons.table_restaurant_rounded),
                            ),
                          ),
                        ),
                       const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _itemNoController,
                            decoration: const InputDecoration(
                              labelText: 'Item Number',
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _accPreNameController,
                            decoration: const InputDecoration(
                              labelText: 'Acc Prefix',
                              prefixIcon: Icon(Icons.account_circle),
                            ),
                          ),
                        ),
                       const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _accNoController,
                            decoration: const InputDecoration(
                              labelText: 'Acc Number',
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _billPreController,
                            decoration: const InputDecoration(
                              labelText: 'Bill Prefix',
                              prefixIcon: Icon(Icons.point_of_sale_sharp),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _billNoController,
                            decoration: const InputDecoration(
                              labelText: 'Bill Number',
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                 /*    const SizedBox(height: ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("MODE:",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                  // const SizedBox(width: 10),
                  Flexible(
                    child: Radio<String>(
                      value: '1',
                      groupValue: selectedOption,
                      onChanged: (newValue) {
                        setState(() {
                          selectedOption = newValue;
                        });
                      },
                    ),
                  ),
                 const Flexible(child: Text('No Print',style: TextStyle(fontWeight: FontWeight.bold),)),
                  // const SizedBox(width: 10),
                  Flexible(
                    child: Radio<String>(
                      value: '2',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                  ),
                const  Flexible(child: Text('2inch',style: TextStyle(fontWeight: FontWeight.bold),)),
                //  const SizedBox(width: 10),
                Flexible(
                    child: Radio<String>(
                      value: '3',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                  ),
                const  Flexible(child: Text('3inch',style: TextStyle(fontWeight: FontWeight.bold),)),
                ],
              ),*/
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tax:",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                  // const SizedBox(width: 10),
                  Flexible(
                    child: Radio<String>(
                      value: '0',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                  ),
                  const  Flexible(child: Text('No Tax',style: TextStyle(fontWeight: FontWeight.bold,fontSize:15),)),
                  Flexible(
                    child: Radio<String>(
                      value: '1',
                      groupValue: selectedOption,
                      onChanged: (newValue) {
                        setState(() {
                          selectedOption = newValue;
                        });
                      },
                    ),
                  ),
                 const Flexible(child: Text('Include',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),)),
                  // const SizedBox(width: 10),
                  Flexible(
                    child: Radio<String>(
                      value: '2',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                  ),
                const  Flexible(child: Text('Exclude',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),)),
                ],
              ),
                   const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _companyNameController.text = "";
                            _add1Controller.text = "";
                            _add2Controller.text = "";
                            _add3Controller.text = "";
                            _add4Controller.text = "";
                            _pincodeController.text = "";
                            _mobNoController.text = "";
                            _gstinController.text = "";
                            _itemPreController.text = "";
                            _itemNoController.text = "";
                            _accPreNameController.text = "";
                            _accNoController.text = "";
                            _billPreController.text = "";
                            _billNoController.text = "";
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.CommonColor,
                            foregroundColor: AppColors.BodyColor,
                          ),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 15),
                          ElevatedButton(
                          onPressed: () async {
                            // await databaseHelper.setDatabase();
                            String? companyId = _selectedValue;
                            String companyName = _companyNameController.text;
                            String add1 = _add1Controller.text;
                            String add2 = _add2Controller.text;
                            String add3 = _add3Controller.text;
                            String add4 = _add4Controller.text;
                            String pincode = _pincodeController.text;
                            String mobNo = _mobNoController.text;
                            String gstin = _gstinController.text;
                            String itemPre = _itemPreController.text;
                            String itemNo = _itemNoController.text;
                            String accPre = _accPreNameController.text;
                            String accNo = _accNoController.text;
                            String billPre = _billPreController.text;
                            String billNo = _billNoController.text;
                            
                            // SharedPreferences comProfileprefs =
                            // await SharedPreferences.getInstance();
                            // await comProfileprefs.setString('ItemPre', itemPre);
                            // await comProfileprefs.setString('ItemNo', itemNo);
                            // await comProfileprefs.setString('AccPre', accPre);
                            // await comProfileprefs.setString('BillPre', billPre);
                            /* logger.i("---------------Save Button--------------------");
                            logger.i(companyId);
                            logger.i(companyName);
                            logger.i(add1);
                            logger.i(Add2);
                            logger.i(Add3);
                            logger.i(Add4);
                            logger.i(Pincode);
                            logger.i(MobNo);
                            logger.i(Gstin);
                            logger.i(ItemPre);
                            logger.i(ItemNo);
                            logger.i(AccPre);
                            logger.i(AccNo);
                            logger.i(BillPre);
                            logger.i(BillNo);*/
                            if (comId == null) {
                            
                             try {
                                log.w("Add Profile");
                                await DatabaseConnection().insertCompanyProfile(
                                  companyId: companyId,
                                  companyName: companyName,
                                  add1: add1,
                                  add2: add2,
                                  add3: add3,
                                  add4: add4,
                                  pincode: pincode,
                                  mobileNo: mobNo,
                                  gstin: gstin,
                                  itemPre: itemPre,
                                  itemNo: itemNo,
                                  accPre: accPre,
                                  accNo: accNo,
                                  billPre: billPre,
                                  billNo: billNo,
                                  TaxType : selectedOption,
                                );
                                        //       String debugMessage = """
                                        //   Company ID: $companyId
                                        //   Company Name: $companyName
                                        //   Add1: $add1
                                        //   Add2: $add2
                                        //   Add3: $add3
                                        //   Add4: $add4
                                        //   Pincode: $pincode
                                        //   Mobile No: $mobNo
                                        //   GSTIN: $gstin
                                        //   Item Pre: $itemPre
                                        //   Item No: $itemNo
                                        //   Acc Pre: $accPre
                                        //   Acc No: $accNo
                                        //   Bill Pre: $billPre
                                        //   Bill No: $billNo
                                        // """;
                                        //  log.w(debugMessage);

                                getCompanyProfileData(_selectedValue!);
                              } catch (e) {
                                // logger.i(
                                //     'An error occurred during database operation: $e');
                                Fluttertoast.showToast(msg: 'Error: $e');
                              }

                              getCompanyProfileData(_selectedValue!);
                            } else {
                                    log.w("Update Profile");
                                await DatabaseConnection().updateCompanyProfile(
                                  companyId: companyId,
                                  companyName: companyName,
                                  add1: add1,
                                  add2: add2,
                                  add3: add3,
                                  add4: add4,
                                  pincode: pincode,
                                  mobileNo: mobNo,
                                  gstin: gstin,
                                  itemPre: itemPre,
                                  itemNo: itemNo,
                                  accPre: accPre,
                                  accNo: accNo,
                                  billPre: billPre,
                                  billNo: billNo,
                                  TaxType : selectedOption,
                                );


                                        //   String debugMessage = """
                                        //   Company ID: $companyId
                                        //   Company Name: $companyName
                                        //   Add1: $add1
                                        //   Add2: $add2
                                        //   Add3: $add3
                                        //   Add4: $add4
                                        //   Pincode: $pincode
                                        //   Mobile No: $mobNo
                                        //   GSTIN: $gstin
                                        //   Item Pre: $itemPre
                                        //   Item No: $itemNo
                                        //   Acc Pre: $accPre
                                        //   Acc No: $accNo
                                        //   Bill Pre: $billPre
                                        //   Bill No: $billNo
                                        // """;
                                        //  log.i(debugMessage);
                              
                                getCompanyProfileData(_selectedValue!);
                              } 
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.CommonColor,
                            foregroundColor: AppColors.BodyColor,
                          ),
                          child:const Text('SAVE'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
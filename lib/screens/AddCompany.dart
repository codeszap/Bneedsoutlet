import 'package:bneedsoutlet/screens/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Modal/AddCompanyModal.dart';
import '../style/Colors.dart';
import 'Logout.dart';

class AddCompany extends StatefulWidget {
  const AddCompany({super.key});

  @override
  State<AddCompany> createState() => _AddCompanyState();
}

class _AddCompanyState extends State<AddCompany> {
  final _comapnyIdController = TextEditingController();
  final  _comapnyNameController = TextEditingController();
  bool _validatecompanyId = false;
  bool _validatecompanyname = false;
  String totalNoOfCompany = "";

  late Future<List<Company>> futureTotalCompany;
  List<Company> totalCompany = [];

  Future<void> _onSavePressed() async {
    setState(() {
      _comapnyNameController.text.isEmpty
          ? _validatecompanyname = true
          : _validatecompanyname = false;
      _comapnyIdController.text.isEmpty
          ? _validatecompanyId = true
          : _validatecompanyId = false;
    });

    if (_validatecompanyname == false && _validatecompanyId == false) {
      SharedPreferences loginprefs = await SharedPreferences.getInstance();
      var username = loginprefs.getString('username');
      var companyId = _comapnyIdController.text;
      var companyname = _comapnyNameController.text;

      var url = Uri.parse(
          'http://bneeds.in/bneedsoutletapi/AddCompanyApi.aspx?action=add'
          '&username=$username'
          '&companyId=$companyId'
          '&companyname=$companyname');
      // logger.i(url);
      http.get(url).then((response) async {
        if (response.statusCode == 200) {
          if (response.body == 'SignUp Failed') {
            // logger.i("+++++++++++++++++++++++");
            Fluttertoast.showToast(msg: 'Already Account Created');
            _comapnyNameController.text = '';
          } else {
            Fluttertoast.showToast(msg: 'Company Name Created');
            _comapnyIdController.text = "";
            _comapnyNameController.text = "";
            refreshAlbums();
          }
        }
      }).catchError((error) {
        // logger.i("+++++++++++++++++++++");
        // logger.i('Error: $error');
        Fluttertoast.showToast(msg: 'Error: $error');
        refreshAlbums();
      });
    }
  }

  void _deleteCompany(String companyId) async {
    SharedPreferences loginprefs = await SharedPreferences.getInstance();
    var username = loginprefs.getString('username');

    var url = Uri.parse(
      'http://bneeds.in/bneedsoutletapi/AddCompanyApi.aspx?action=delete'
      '&username=$username'
      '&companyId=$companyId',
    );
    http.get(url).then((response) {
      if (response.statusCode == 200) {
        if (response.body == 'Company Deleted Successfully') {
          Fluttertoast.showToast(msg: 'Company Deleted Successfully');
          refreshAlbums();
        } else {
          Fluttertoast.showToast(msg: 'Company Deletion Failed');
        }
      } else {
        Fluttertoast.showToast(msg: 'Error: Company Deletion Failed');
      }
    }).catchError((error) {
      // logger.i('Error: $error');
      Fluttertoast.showToast(msg: 'Error: Company Deletion Failed');
    });
  }

  @override
  void initState() {
    super.initState();
    refreshAlbums();
  }

  Future<void> refreshAlbums() async {
    setState(() {
      futureTotalCompany = fetchAlbums(context);
    });
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "Add Company",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: const [
          Logout(),
        ],
        backgroundColor: AppColors.CommonColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: AppColors.BodyColor,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: _comapnyIdController,
                maxLength: 5,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.wb_shade),
                  labelText: "Company Id",
                  border: const OutlineInputBorder(),
                  errorStyle: const TextStyle(color: Colors.red),
                  errorText: _validatecompanyId
                      ? 'Company Id Value Can\'t Be Empty'
                      : null,
                ),
              ),
              const SizedBox (height: 16),
              TextField(
                controller: _comapnyNameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  labelText: "Company Name",
                  border: const OutlineInputBorder(),
                  errorStyle: const TextStyle(color: Colors.red),
                  errorText: _validatecompanyname
                      ? 'Company Name Value Can\'t Be Empty'
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _onSavePressed,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.CommonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                        child: const Text(
                      "SAVE",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                const  SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () {
                      _comapnyIdController.text = "";
                      _comapnyNameController.text = "";
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.CommonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
             const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       const Text(
                          "Total NO Of Companies:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.CommonColor,
                              fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        FutureBuilder<List<Company>>(
                          future: futureTotalCompany,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              List<Company> data = snapshot.data!;
                              int totalLength = data.length;
                              return Text(
                                "$totalLength",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.CommonColor,
                                    fontSize: 16),
                              );
                            } else {
                              return const Text('No data available.');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: refreshAlbums,
                  child: FutureBuilder<List<Company>>(
                    future: futureTotalCompany,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        final companies = snapshot.data ?? [];
                        return ListView.builder(
                          itemCount: companies.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: AppColors.BodyColor,
                                      title: const Text("Confirm Deletion"),
                                      content: const Text(
                                          "Are you sure you want to delete this company?"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text("Delete"),
                                          onPressed: () {
                                            _deleteCompany(
                                                companies[index].companyid);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },                            
                                child: Card(
                                  color: AppColors.CommonColor,
                                  child: ListTile(
                                    title: Text(companies[index].companyid,
                                        style: const TextStyle(
                                            color: AppColors.BodyColor,
                                            fontWeight: FontWeight.bold)),
                                    trailing: const Icon(
                                      Icons.delete_forever,
                                      color: AppColors.BodyColor,
                                    ),
                                  ),
                                ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
   
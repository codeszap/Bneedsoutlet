import 'package:bneedsoutlet/Database/Database_Helper.dart';
import 'package:bneedsoutlet/Modal/ModalSalesReport.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Modal/AddCompanyModal.dart';
import '../constants/variables.dart';
import '../style/Colors.dart';
import '../widget/CommonDropdown.dart';
import 'Drawer.dart';
import 'Logout.dart';
import 'login.dart';

class sales_report extends StatefulWidget {
  const sales_report({super.key});

  @override
  State<sales_report> createState() => _sales_reportState();
}

class _sales_reportState extends State<sales_report> {
  late Future<List<Company>> _futureCompanies;
  String? _selectedValue;
  String? selectedGroupName;
  List<String> transactionList = [];
  final Logger log = Logger();

  @override
  void initState() {
    super.initState();
    _futureCompanies = fetchAlbums(context);
    _futureCompanies.then((companies) {
      setState(() {
        _selectedValue = determineDefaultCompany(companies);
        loaddropdownData();
      });
    });
  }

  void loaddropdownData() async {
    try {
      final databaseHelper = DatabaseConnection();
      await databaseHelper.setDatabase();
      List<String> data =
          await databaseHelper.getDropDownTran(companyId: _selectedValue);
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

  String determineDefaultCompany(List<Company> companies) {
    if (companies.isNotEmpty) {
      return companies.first.companyid;
    } else {
      return '';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BodyColor,
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "Sales Report",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: const [
          Logout(),
        ],
        backgroundColor: AppColors.CommonColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CommonCompanyDropdown(_futureCompanies, _selectedValue, (String? selectedValue) {
              setState(() {
                _selectedValue = selectedValue;
              });
              log.i('Selected company: $selectedValue');
            }),
          ),
        ],
      ),
    );
  }
}

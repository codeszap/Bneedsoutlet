import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import '../Database/Database_Helper.dart';
import '../Modal/TransactionModal.dart';
import '../style/Colors.dart';
import 'Drawer.dart';
import 'Logout.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart' as logger;
class AddExpense extends StatefulWidget {
  final TransactionModal album;
  final String? Companyid; // Nullable String

  AddExpense({required this.album, this.Companyid, Key? key})
      : super(key: key);

  @override
  State<AddExpense> createState() => _AddExpenseState();
}



class _AddExpenseState extends State<AddExpense> {
final log = logger.Logger();
  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseConnection();
    loadDropdownData();
  }

  Future<void> initializeDatabase() async {
    DatabaseConnection databaseConnection = DatabaseConnection();
   await databaseConnection.setDatabase();
  }

  void loadDropdownData() async {
    try {
      final databaseHelper = DatabaseConnection();
      await databaseHelper.setDatabase();
      List<String> data = await databaseHelper.getDropDownTran(companyId: widget.Companyid);
      setState(() {
        transactionList = data;
        if (data.isNotEmpty && selectedTransaction == null) {
          selectedTransaction = data.first;
        }
      });
      // logger.i('Loaded Data: $transactionList');

      // logger.i('===========================');
      // logger.i('Loaded Data: $selectedTransaction');
    } catch (e) {
      // logger.i('Error loading dropdown data: $e');
      // Handle the error as needed
    }
  }


  void _AddTranApi(Companyid,Billdate,Accode,Narration,Amount, String payBy, String? drCR){
    var url = Uri.parse(
        'http://bneeds.in/bneedsoutletapi/TransactionApi.aspx?action=InsertTransaction'
            '&Companyid=$Companyid'
            '&Billdate=$Billdate'
            '&Accode=$Accode'
            '&Amount=$Amount'
            '&payBy=$payBy'
            '&drCR=$drCR'
            '&Narration=$Narration'
    );
    log.w(url);
    http.get(url).then((response) async {
      if (response.statusCode == 200) {
        if (response.body == 'Successfully updated!') {
          // logger.i("+++++++++++++++++++++++");
          Fluttertoast.showToast(msg: 'Successfully Updated!');
          // logger.i("Successfully Updated! in Api");
          /*refreshAlbums();*/
        } else {
          Fluttertoast.showToast(msg: 'Not Update Properly');
          // logger.i("Not Update Properly");
        }
      }
    }).catchError((error) {
      // logger.i("+++++++++++++++++++++");
      // logger.i('Error: $error');
      Fluttertoast.showToast(msg: 'Error: $error');
      /*refreshAlbums();*/
    });
    // logger.i("+++++++++++++++++++");
    // logger.i("Accmast UpdateApi");
    // logger.i(Companyid);
    // logger.i(Billdate);
    // logger.i(Accode);
    // logger.i(Amount);
    // logger.i(Narration);
    // logger.i(payBy);
    // logger.i(drCR);
  }

  TextEditingController amountController = TextEditingController();
  TextEditingController narrationController = TextEditingController();
  String? selectedTransaction;
  List<String> transactionList = [];
  String? selectedOption = 'Credit';
  late DatabaseConnection databaseHelper;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: AppColors.BodyColor,
      drawer: CustomDrawer(),
      appBar: AppBar(
        title:const Text(
          "Add Expense",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        actions: const [
          Logout(),
        ],
        backgroundColor: AppColors.CommonColor,
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.album.name} (${widget.album.accode})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                style: const TextStyle(
                    color: AppColors.CommonColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.money),
                  labelText: 'Amount',
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
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.note_add),
                  labelText: 'Narration',
                  labelStyle: TextStyle(
                    color: AppColors.CommonColor,
                  ),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              
                 Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                        Icons.payment),
                  ),
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
                    hint: const Text('Select a transaction'),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Flexible(
                    child: Radio<String>(
                      value: 'Credit',
                      groupValue: selectedOption,
                      onChanged: (newValue) {
                        setState(() {
                          selectedOption = newValue;
                        });
                      },
                    ),
                  ),
                 const Flexible(child: Text('Credit')),
                  const SizedBox(width: 20),
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
                const  Flexible(child: Text('Debit')),
                ],
              ),
             const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      String amount = amountController.text;
                      String narration = narrationController.text;
                      String? payBy = selectedTransaction;
                      String? drCR = selectedOption;
                      /*String? companyid = _selectedValue;*/
                      String? accode = widget.album.accode;
                      DateTime now = DateTime.now();
                      String formattedDate =
                      DateFormat('yyyy-MM-dd').format(now);

                      _AddTranApi(
                          widget.Companyid, formattedDate, accode, narration, amount, payBy!, drCR);
                      Navigator.pop(context, true);
                    },                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.CommonColor,
                      foregroundColor: AppColors.BodyColor,
                    ),
                    child: const Text('UPDATE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

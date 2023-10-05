import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../Database/Database_helper.dart';
import '../Modal/AddCompanyModal.dart';
import '../Modal/today_report_modal.dart';
import '../style/Colors.dart';
import 'Drawer.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart' as logger;
import 'Logout.dart';
class AllWiseReport extends StatefulWidget {
  const AllWiseReport({super.key});

  @override
  State<AllWiseReport> createState() => _AllWiseReportState();
}

class _AllWiseReportState extends State<AllWiseReport> {
  final log = logger.Logger();
  late DatabaseConnection databaseHelper;
  late Database _database;
  late DateTime startDate,endDate;
  late Future<List<Company>> _futureCompanies;
  late Future<List<ReportItemGroup>> futureReportItem = Future.value([]);
  List<ReportItemGroup> reportItemData = [];
  String? _selectedCompanyValue;
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();


  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseConnection();
    startDate = DateTime.now().subtract(const Duration(days:7));
    endDate = DateTime.now();
    // logger.i("+++++++++++++");
    // logger.i(startDate);
    // logger.i(endDate);
    initializeDatabase();
    initializeData();
  }
  Future<void> initializeData() async {
    await fetchAndSetCompanies();
    refreshAlbums();
  }
  Future<void> fetchAndSetCompanies() async {
    try {
      _futureCompanies = fetchAlbums(context);
      final companies = await _futureCompanies;

      if (companies.isNotEmpty) {
        setState(() {
          _selectedCompanyValue = companies[0].companyid;
        });
      }
    } catch (error) {
      // logger.i('Error fetching companies: $error');
    }
  }

  Future<void> refreshAlbums() async {
    // logger.i("Im from RefreshAlbum");
    setState(() {
      futureReportItem = fetchData(context,startDate,endDate);
    });
    // await logger.iReportItems();
    // logger.i("Im from RefreshAlbum");
  }

  // Future<void> logger.iReportItems() async {
  //   try {
  //     List<ReportItemGroup> reportItems = await futureReportItem;
  //     for (var item in reportItems) {
  //       logger.i('Company ID: ${item.companyId}');
  //       logger.i('No of Bills: ${item.noOfBills}');
  //     }
  //   } catch (e) {
  //     logger.i('Error fetching report items: $e');
  //   }
  // }


  String formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  Future<List<ReportItemGroup>> fetchData(BuildContext context, DateTime startDate,DateTime endDate) async {
    // logger.i("++++++++++++Fetch Data++++++++++++");
    // logger.i(endDate);
    SharedPreferences loginprefs = await SharedPreferences.getInstance();
    String? username = loginprefs.getString("username");
    final url = Uri.parse(
      'http://bneeds.in/bneedsoutletapi/ReportApi.aspx?action=AllwiseReport&username=$username&Companyid=$_selectedCompanyValue&StartDate=${formatDate(startDate)}&EndDate=${formatDate(endDate)}',
    );
    log.i('Datewise Report: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        /*if(response.body == "Login Failed"){
          Fluttertoast.showToast(msg: "Welcome");
        }*/
        final jsonData = json.decode(response.body) as List<dynamic>;
        List<ReportItemGroup> items = [];
        for (var itemData in jsonData) {
          String companyId = itemData['Companyid'] ?? '';
          String noOfBills = itemData['NoofBills'] ?? '';
          String totalSales = itemData['TotalSales'] ?? '';
          String cashSales = itemData['CashSales'] ?? '';
          String cardSales = itemData['CardSales'] ?? '';
          String creditSales = itemData['CreditSales'] ?? '';
          String discount = itemData['Discount'] ?? '';
          String expense = itemData['Expense'] ?? '';
          String cashBalance = itemData['CashBalance'] ?? '';
          String collection = itemData['Collection'] ?? '';
          String payment = itemData['Payment'] ?? '';
          String advance = itemData['Advance'] ?? '';
          String purchase = itemData['Purchase'] ?? '';
          String cancelBills = itemData['CancelBills'] ?? '';
          String companyname = itemData['Companyname'] ?? '';
          String editBills = itemData['EditBills'] ?? '';
          String billdate = itemData['Billdate'] ?? '';
          String salesReturn = itemData['SalesReturn'] ?? '';
          String profit = itemData['Profit'] ?? '';


          ReportItemGroup item = ReportItemGroup(
            companyId: companyId,
            noOfBills: noOfBills,
            totalSales: totalSales,
            cashSales: cashSales,
            cardSales: cardSales,
            creditSales: creditSales,
            discount: discount,
            expense: expense,
            cashBalance: cashBalance,
            collection: collection,
            payment: payment,
            advance: advance,
            purchase: purchase,
            cancelBills: cancelBills,
            companyname: companyname,
            editBills: editBills,
            billdate: billdate,
            salesReturn: salesReturn,
            profit: profit,
          );
          items.add(item);
        }
        // logger.i(items.length);
        return items;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // logger.i('Error: $e');
      return [];
    }
  }

  Future<void> initializeDatabase() async {
    DatabaseConnection databaseConnection = DatabaseConnection();
    await databaseConnection.setDatabase();
  }


  void _showFilteredDialog(){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:const Text('FILTER DATE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    readOnly: true,
                    controller: fromDateController,
                    onTap: () async {
                      DateTime? fromDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (fromDate != null) {
                        String formattedFromDate = formatDate(fromDate);
                        fromDateController.text = formattedFromDate;
                      }
                    },
                    decoration:const InputDecoration(
                      labelText: 'From',
                      hintText: 'Select From Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    controller: toDateController,
                    onTap: () async {
                      DateTime? toDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (toDate != null) {
                        String formattedToDate = formatDate(toDate);
                        toDateController.text = formattedToDate;
                      }
                    },
                    decoration:const InputDecoration(
                      labelText: 'To',
                      hintText: 'Select To Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                child: const Text('Yes', style: TextStyle(fontSize: 20, color: Colors.teal)),
                onPressed: () async {
                  final DateFormat dateFormatter = DateFormat("yyyy-MM-dd");
                  startDate = dateFormatter.parse(fromDateController.text);
                  endDate = dateFormatter.parse(toDateController.text);
                  // logger.i("++++++++++++++++++++++++++++++");
                  // logger.i(startDate);
                  // logger.i(endDate);
                  if (startDate != null && endDate != null) {
                   refreshAlbums();
                  }
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('No', style: TextStyle(fontSize: 18, color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
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
        title: const Text(
          "Datewise Report",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        actions: [
          IconButton(
              onPressed: _showFilteredDialog,
              icon:const  Icon(Icons.filter_list)
          ),
          const Logout(),
        ],
        backgroundColor: AppColors.CommonColor,
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
      ),
      body: Column(
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
                if (_selectedCompanyValue == null && companies.isNotEmpty) {
                  _selectedCompanyValue = companies.first.companyid;
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedCompanyValue,
                      hint: Text(_selectedCompanyValue ?? 'Select a company'),
                      items: companies.map((company) {
                        return DropdownMenuItem<String>(
                          value: company.companyid,
                          child: Text(company.companyid),
                        );
                      }).toList(),
                      onChanged: (String? selectedValue) {
                        setState(() {
                          _selectedCompanyValue = selectedValue;
                        });
                        refreshAlbums();
                        // logger.i('Selected company: $selectedValue');
                      },
                    ),
                  ),
                );
              } else {
                return const Text('No companies available.');
              }
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: refreshAlbums,
              child: FutureBuilder<List<ReportItemGroup>>(
                future: futureReportItem,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    reportItemData = snapshot.data!;
                    if (reportItemData.isEmpty) {
                      if (reportItemData.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No data available.',
                                style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                    double totalNoOfBills = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalNoOfBills += double.tryParse(album.noOfBills) ?? 0;
                    }

                    double totalSales = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalSales += double.tryParse(album.totalSales) ?? 0;
                    }

                    double totalCashSales = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalCashSales += double.tryParse(album.cashSales) ?? 0;
                    }

                    double totalCardSales = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalCardSales += double.tryParse(album.cardSales) ?? 0;
                    }

                    double totalCreditSales = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalCreditSales += double.tryParse(album.creditSales) ?? 0;
                    }

                    double totalDiscount = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalDiscount += double.tryParse(album.discount) ?? 0;
                    }

                    double totalExpense = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalExpense += double.tryParse(album.expense) ?? 0;
                    }

                    double totalCashBalance = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalCashBalance += double.tryParse(album.cashBalance) ?? 0;
                    }

                    double totalCollection = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalCollection += double.tryParse(album.collection) ?? 0;
                    }

                    double totalPayment = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalPayment += double.tryParse(album.payment) ?? 0;
                    }

                    double totalAdvance = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalAdvance += double.tryParse(album.advance) ?? 0;
                    }

                    double totalPurchase = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalPurchase += double.tryParse(album.purchase) ?? 0;
                    }

                    double totalCancelBills = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalCancelBills += double.tryParse(album.cancelBills) ?? 0;
                    }

                    double totaleditBills = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totaleditBills += double.tryParse(album.editBills) ?? 0;
                    }

                    double totalsalesReturn = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalsalesReturn += double.tryParse(album.salesReturn) ?? 0;
                    }
                    double totalprofit = 0;
                    for (ReportItemGroup album in reportItemData) {
                      totalprofit += double.tryParse(album.profit) ?? 0;
                    }
                    return ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        ReportItemGroup album = reportItemData[index];
                        return GestureDetector(
                          onTap: () {

                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Card(
                              elevation: 3,
                              color: AppColors.CommonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ExpansionTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          album.companyname,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.BodyColor,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                initiallyExpanded: true,
                                children: [
                                  ExpansionTile(
                                    title: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'No.Of.Bills',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalNoOfBills',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                   /* backgroundColor: AppColors.BodyColor,
                                    collapsedBackgroundColor: AppColors.CommonColor,*/
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style: const TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.noOfBills,
                                            style: const TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total Sales',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalSales',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style:const  TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.totalSales,
                                            style: const TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Container(
                                      padding:const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Cash Sales',
                                            style:TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalCashSales',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style:const TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.cashSales,
                                            style: const TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  ExpansionTile(
                                    title: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Card Sales',
                                            style:TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalCardSales',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style: const TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.cardSales,
                                            style: const TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Credit Sales',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalCreditSales',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style:const TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.creditSales,
                                            style: const TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Discount',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalDiscount',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style:const TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.discount,
                                            style:const TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Expense',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalExpense',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style:const TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.expense,
                                            style: const TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Container(
                                      padding: EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Cash Balance',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalCashBalance',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style:const TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.cashBalance,
                                            style: const TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Collection',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalCollection',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style:const TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.collection,
                                            style: const TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Payment',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalPayment',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style:const TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.payment,
                                            style: const TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Advance',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalAdvance',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style:const TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.payment,
                                            style: const TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Purchase',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalPurchase',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style: const TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.purchase,
                                            style: const TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Container(
                                      padding:const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'CancelBills',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalCancelBills',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style:const TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.cancelBills,
                                            style:const TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Edit Bills',
                                            style:TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totaleditBills',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style:const  TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.editBills,
                                            style: const  TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Container(
                                      padding:const  EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Sales Return',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalsalesReturn',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style:const  TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.salesReturn,
                                            style:const  TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Container(
                                      padding: const  EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const  Text(
                                            'profit',
                                            style:TextStyle(
                                                fontSize: 16,
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Noto'
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$totalprofit',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      for (ReportItemGroup item in reportItemData)
                                        ListTile(
                                          title: Text((item.billdate),
                                            style:const  TextStyle(
                                              color: AppColors.BodyColor,
                                            ),
                                          ),
                                          trailing: Text(
                                            item.profit,
                                            style:const  TextStyle(
                                              color: AppColors.BodyColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
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
    );
  }
}



import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Database/Database_Helper.dart';
import 'Drawer.dart';
import '../Modal/today_report_modal.dart';
import '../style/Colors.dart';
import 'Logout.dart';
import 'package:logger/logger.dart' as logger;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TodayReport extends StatefulWidget {
  const TodayReport({super.key});
  @override
  State<TodayReport> createState() => _TodayReportState();
}

class _TodayReportState extends State<TodayReport> {
  final DatabaseConnection databaseConnection = DatabaseConnection();
  final log = logger.Logger();
  late Future<List<ReportItem>> futureReportItem = Future.value([]);
  List<ReportItem> reportItemData = [];
  DateTime? _selectedDate;
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    refreshAlbums();
    // databaseConnection.createNewTable();
    // printDatabasePath();
  }


// Future<String> getDatabasePath() async {
//   final databasesPath = await getDatabasesPath();
//   final databasePath = join(databasesPath, 'NMSADMINDB.db');
//   return databasePath;
// }

// Future<void> printDatabasePath() async {
//   final path = await getDatabasePath();
//   log.i('Database Path: $path');
// }
  Future<void> refreshAlbums() async {
    setState(() {
      futureReportItem = fetchData(_selectedDate!);
    });
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  Future<List<ReportItem>> fetchData(DateTime selectedDate) async {
    SharedPreferences loginprefs = await SharedPreferences.getInstance();
    String? username = loginprefs.getString("username");
    final url = Uri.parse(
      'http://bneeds.in/bneedsoutletapi/ReportApi.aspx?action=TodayReport&username=$username&DateView=${formatDate(selectedDate)}',
    );
    log.i('LatestReport: $url');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        List<ReportItem> items = [];

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
          // logger.i("+++++++++++++++++++++++");
          // logger.i(companyname);

          ReportItem item = ReportItem(
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
        /*    setState(() {
          _dateController.text = "";
        });*/
        return items;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // logger.i('Error: $e');
      return []; // Return null in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "Latest Report",
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
      body: Container(
        color: AppColors.BodyColor,
        child: Column(
          children: [
          /*  Container(
              height: 50,
              *//*color: Colors.yellow,*//*
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total NO Of Companies",
                      style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.CommonColor, fontSize: 16),
                    ),
                    FutureBuilder<List<ReportItem>>(
                      future: futureReportItem,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          List<ReportItem> data = snapshot.data!;
                          int TotalLength = data.length;
                          return Text("$TotalLength",
                            style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.CommonColor, fontSize: 16),
                          );
                        } else {
                          return const Text('No data available.');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),*/

            Flexible(
              child: RefreshIndicator(
                onRefresh: refreshAlbums,
                child: FutureBuilder<List<ReportItem>>(
                  future: futureReportItem,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      reportItemData = snapshot.data!;
                      return ListView.builder(
                        itemCount: reportItemData.length,
                        itemBuilder: (context, index) {
                          ReportItem album = reportItemData[index];
                          return GestureDetector(
                            onTap: () {

                            },
                            child: Container(
                              /*height: 475,*/
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child:Card(
                                  elevation: 3,
                                  color: AppColors.CommonColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child:ExpansionTile(
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
                                            Text(
                                              album.billdate,
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
                                    children: [
                                      /*Container(
                                        color: Colors.white70,
                                        padding: EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${album.companyname}',
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: AppColors.CommonColor),
                                            ),
                                          ],
                                        ),
                                      ),*/
                                      Container(
                                        color: AppColors.BodyColor,
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'No.Of.Bills',
                                              style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto'),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              album.noOfBills,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Total Sales',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto',color: AppColors.BodyColor),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              album.totalSales,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: AppColors.BodyColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          color: AppColors.BodyColor,
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Cash Sales',
                                              style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto'),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              album.cashSales,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Card Sales',
                                              style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto',color: AppColors.BodyColor),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              album.cardSales,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: AppColors.BodyColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                          color: AppColors.BodyColor,
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Credit Sales',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto'),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              album.creditSales,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding:const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Discount',
                                              style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto',color: AppColors.BodyColor),
                                            ),
                                            Text(
                                              album.discount,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: AppColors.BodyColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                          color: AppColors.BodyColor,
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Expense',
                                              style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto'),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              album.expense,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Cash Balance',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto',color: AppColors.BodyColor),
                                            ),
                                            Text(
                                              album.cashBalance,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: AppColors.BodyColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                          color: AppColors.BodyColor,
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Collection',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto'),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              album.collection,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Payment',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto',color: AppColors.BodyColor),
                                            ),
                                            Text(
                                              album.payment,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: AppColors.BodyColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                          color: AppColors.BodyColor,
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Advance',
                                              style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto'),
                                            ),
                                            Text(
                                              album.advance,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Purchase',
                                              style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto',color: AppColors.BodyColor),
                                            ),
                                            Text(
                                              album.purchase,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: AppColors.BodyColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                          color: AppColors.BodyColor,
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Row(
                                              children: [
                                                Text(
                                                  'Cancel Bills',
                                                  style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto'),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              album.cancelBills,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        color: AppColors.CommonColor,
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Row(
                                              children: [
                                                Text(
                                                  'Edit Bills',
                                                  style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto',color: AppColors.BodyColor),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              album.editBills,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: AppColors.BodyColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        color: AppColors.BodyColor,
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Row(
                                              children: [
                                                Text(
                                                  'Sales Return',
                                                  style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto',color: AppColors.CommonColor),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              album.salesReturn,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: AppColors.CommonColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        color: AppColors.CommonColor,
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Row(
                                              children: [
                                                Text(
                                                  'profit',
                                                  style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto',color: AppColors.BodyColor),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              album.profit,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: AppColors.BodyColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  )

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

/*----------------------Dont Delete---------------------*/
/*body: Container(
        color: AppColors.BodyColor,
        child: GridView.count(
          crossAxisCount: 3,
          padding: const EdgeInsets.all(8.0),
          children: [
            buildCard('Company ID', dashboardItems.map((item) => item.companyId).join(', '), Colors.amber),
            buildCard('No.of Bills', dashboardItems.map((item) => item.noOfBills).join(', '), Colors.red),
            buildCard('Sales', dashboardItems.map((item) => item.totalSales).join(', '), Colors.cyan),
            buildCard('Cash Sales', dashboardItems.map((item) => item.cashSales).join(', '), Colors.green),
            buildCard('Card Sales', dashboardItems.map((item) => item.cardSales).join(', '), Colors.teal),
            buildCard('Credit Sales', dashboardItems.map((item) => item.creditSales).join(', '), Colors.deepPurpleAccent),
            buildCard('Discount', dashboardItems.map((item) => item.discount).join(', '), Colors.lime),
            buildCard('Expense', dashboardItems.map((item) => item.expense).join(', '), Colors.indigo),
            buildCard('Cash Bal', dashboardItems.map((item) => item.cashBalance).join(', '), Colors.grey),
            buildCard('Collection', dashboardItems.map((item) => item.collection).join(', '), Colors.red),
            buildCard('Payment', dashboardItems.map((item) => item.payment).join(', '), Colors.cyan),
            buildCard('Advance', dashboardItems.map((item) => item.advance).join(', '), Colors.green),
            buildCard('Purchase', dashboardItems.map((item) => item.purchase).join(', '), Colors.amber),
            buildCard('CancelBills', dashboardItems.map((item) => item.cancelBills).join(', '), Colors.red),
          ],
        ),
      ),*/
/*Widget buildCard(String title, String value, Color color) {
  return Card(
    elevation: 4.0,
    color: color,
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.white,fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}*/







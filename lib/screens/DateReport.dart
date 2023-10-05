import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Modal/today_report_modal.dart';
import '../style/Colors.dart';
import 'Drawer.dart';
import 'Logout.dart';
import 'package:logger/logger.dart' as logger;

class DateReport extends StatefulWidget {
  const DateReport({super.key});

  @override
  State<DateReport> createState() => _DateReportState();
}

class _DateReportState extends State<DateReport> {
  final log = logger.Logger();
  late Future<List<ReportItem>> futureDateReportItem = Future.value([]);
  List<ReportItem> dateReportItemData = [];
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    refreshAlbums();
    log.i("Im from DateReport");
  }

  Future<void> refreshAlbums() async {
    setState(() {
      futureDateReportItem = fetchData(context, _selectedDate!);
    });
  }

  Future<List<ReportItem>> fetchData(BuildContext context, DateTime selectedDate) async {

    SharedPreferences loginprefs = await SharedPreferences.getInstance();
    String? username = loginprefs.getString("Username");
    final url = Uri.parse(
      'http://bneeds.in/bneedsoutletapi/ReportApi.aspx?action=DateReport&username=$username&DateView=${formatDate(selectedDate)}',
    );


    log.i(url);

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

  String formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  String formatOrderDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  final _dateController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = formatOrderDate(picked);
        fetchReportData(picked);
      });
    }
  }

  Future<void> fetchReportData(DateTime selectedDate) async {
    setState(() {
      futureDateReportItem = fetchData(context, selectedDate);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "Date Report",
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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _dateController,
                        readOnly: true, // Prevent manual text input
                        decoration: const InputDecoration(
                          hintText: 'Select Date',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  /*ElevatedButton(
                    onPressed: () {
                      fetchReportData(_selectedDate!);
                    },
                    child: Text("View"),
                    style: ElevatedButton.styleFrom(
                      primary: AppColors.CommonColor,
                      foregroundColor: AppColors.BodyColor,
                    ),
                  ),*/
                ],
              ),
            ),
            /*Container(
              height: 20,
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
                      future: futureDateReportItem,
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
            /*Container(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Filtered Date: $_selectedDate",
                      style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.CommonColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),*/
            Flexible(
              child: RefreshIndicator(
                onRefresh: refreshAlbums,
                child: FutureBuilder<List<ReportItem>>(
                  future: futureDateReportItem,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      dateReportItemData = snapshot.data!;
                      return ListView.builder(
                        itemCount: dateReportItemData.length,
                        itemBuilder: (context, index) {
                          ReportItem album = dateReportItemData[index];
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
                                    iconColor: Colors.white,
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                    children: [
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
                                              style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto',color: AppColors.BodyColor),
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
                                              style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto'),
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
                                        padding: const EdgeInsets.all(6),
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
                                        padding:const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Collection',
                                              style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto'),
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
                                              style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto',color: AppColors.BodyColor),
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
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto',color: AppColors.BodyColor),
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
                                        padding:const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Row(
                                              children: [
                                                Text(
                                                  'Cancel Bills',
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto'),
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
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto',color: AppColors.BodyColor),
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
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Noto',color: AppColors.CommonColor),
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
                                        padding:const EdgeInsets.all(6),
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

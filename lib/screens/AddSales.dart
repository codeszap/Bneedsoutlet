import 'dart:convert';
import 'package:bneedsoutlet/Database/Database_Helper.dart';
import 'package:bneedsoutlet/Modal/AddToCartItems.dart';
import 'package:bneedsoutlet/Modal/accmast_balance_modal.dart';
import 'package:bneedsoutlet/Modal/item_data_modal.dart';
import 'package:bneedsoutlet/Modal/sales_data_modal.dart';
import 'package:bneedsoutlet/screens/Drawer.dart';
import 'package:bneedsoutlet/screens/login.dart';
import 'package:bneedsoutlet/screens/print_page.dart';
import 'package:bneedsoutlet/style/Colors.dart';
import 'package:bneedsoutlet/style/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart' as logger;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../demo.dart';

class AddSales extends StatefulWidget {
  final AccmastBalanceModal album;
  final String selectedCompany;

  AddSales({required this.album, required this.selectedCompany});

  @override
  _AddSalesState createState() => _AddSalesState();
}

class _AddSalesState extends State<AddSales> {
  final log = logger.Logger();
  late DatabaseConnection databaseHelper;
  final TextEditingController _searchcontroller = TextEditingController();
  final TextEditingController _quanitycontroller = TextEditingController();
  final TextEditingController _selratecontroller = TextEditingController();
  final TextEditingController _gstcontroller = TextEditingController();
  final TextEditingController _discountcontroller =
      TextEditingController(text: "0.00");
  dynamic selectedItem;
  List<ItemData> items = [];
  final FocusNode _quantityFocusNode = FocusNode();
  List<AddCartItemData> cartItems = [];
  int totalItems = 0;
  double totalAmount = 0.0;
  String? billPre;
  String? selectedPrintOption;
  // String? billNo;

  void calculateTotal() {
    totalItems = 0;
    totalAmount = 0.0;
    for (var cartItem in cartItems) {
      double quantity = double.parse(cartItem.qty);
      totalItems += quantity.round();
      double selRate = double.parse(cartItem.Net);
      totalAmount += selRate;
    }
    setState(() {});
  }

  Future<String> fetchBillNo() async {
    var databaseConnection = DatabaseConnection();
    var database = await databaseConnection.setDatabase();
    var getAcctId = await database.rawQuery(
      'SELECT BillPre,CAST(BillNo AS INTEGER) + 1 AS NewBillNo FROM companyProfile WHERE Companyid = ?',
      [widget.selectedCompany],
    );
    billPre = (getAcctId.first['BillPre'] ?? '').toString();
    billNo = (getAcctId.first['NewBillNo'] ?? '').toString();
    return '$billPre$billNo';
  }

  void _showDialogForPrint(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.BodyColor,
          title: const Center(
              child: Text(
            "Do you Want Print?",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppColors.CommonColor),
          )),
          content: SingleChildScrollView(
            child: Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navigator.pushNamedAndRemoveUntil(
                          //     context, '/ShowPrinter', (route) => false);
                          // Navigator.of(context).pop();
                          // PrintPage printPage = PrintPage(cartItems: cartItems);
                          PrintPage().twoinch();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.CommonColor,
                          foregroundColor: AppColors.BodyColor,
                        ),
                        child: const Text(
                          "No",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog.
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.CommonColor,
                          foregroundColor: AppColors.BodyColor,
                        ),
                        child: const Text(
                          "2 INCH",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog.
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.CommonColor,
                          foregroundColor: AppColors.BodyColor,
                        ),
                        child: const Text(
                          "3 INCH",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
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
  }

  Future<void> fetchDataAndInsertIntoSQLite(
      DatabaseConnection databaseHelper) async {
    try {
      await databaseHelper.setDatabase();
      final items = await fetchData();
      // logger.i("+++++Item+++++++++++++++");
      log.i('Fetch Data Item Count: ${items.length}');

      if (items.length != 0) {
        await databaseHelper.insertSalesData(items);
        // refreshAlbums();
      } else {
        /*Fluttertoast.showToast(msg: "No New Data Found!");*/
      }
      /*// logger.i('Successfully Fetched');*/
    } catch (e) {
      // logger.i('Error fetchDataAndInsertIntoSQLite : $e');
    }
  }

  Future<List<SalesData>> fetchData() async {
    SharedPreferences loginprefs = await SharedPreferences.getInstance();
    String? username = loginprefs.getString("username");
    String? access = "0";
    final url = Uri.parse(
      'http://bneeds.in/bneedsoutletapi/SalesEntryApi.aspx?action=LoadSalesData&username=$username&access=$access',
    );
    log.i('Sales Data: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        List<SalesData> items = [];
        log.w("Sales Data succes Response");

        for (var itemData in jsonData) {
          String entrefno = itemData['entrefno'] ?? '';
          String billNo = itemData['billNo'] ?? '';
          String billDate = itemData['billDate'] ?? '';
          String accode = itemData['accode'] ?? '';
          String qty = itemData['qty'] ?? '';
          String selrate = itemData['Selrate'] ?? '';
          String amount = itemData['amount'] ?? '';
          String companyId = itemData['companyId'] ?? '';
          String userId = itemData['userId'] ?? '';
          String discPer = itemData['discPer'] ?? '';
          String discount = itemData['discount'] ?? '';
          String gst = itemData['gst'] ?? '';
          String gstVal = itemData['gstVal'] ?? '';
          String billPrefix = itemData['billPrefix'] ?? '';
          String selRateNoTax = itemData['selRateNoTax'] ?? '';
          String taxType = itemData['taxType'] ?? '';

          // log.w('Return Item: $itemID');

          SalesData item = SalesData(
            entrefno: entrefno,
            billNo: billNo,
            billDate: billDate,
            accode: accode,
            qty: qty,
            selRate: selrate,
            amount: amount,
            companyId: companyId,
            userId: userId,
            discPer: discPer,
            discount: discount,
            gst: gst,
            gstVal: gstVal,
            billPrefix: billPrefix,
            selRateNoTax: selRateNoTax,
            taxType: taxType,
          );
          items.add(item);
        }

        /*    setState(() {
          dashboardItems = items;
        });*/
        /*deleteData();*/
        // log.w('Return Item: ${items.length}');
        return items;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      log.i('Error Fetch Data: $e');
      return [];
    }
  }

  void _showConfirmationBottomSheet() {
    String newBillNo = '';
    fetchBillNo().then((value) {
      newBillNo = value;
      showModalBottomSheet(
        backgroundColor: AppColors.BodyColor,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(
                    child: Text(
                      'Do You Want to Save?',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppColors.CommonColor,
                      ),
                    ),
                  ),
                  Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'BillNo: $newBillNo',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.CommonColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Amount: $totalAmount',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.CommonColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Print:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: AppColors.CommonColor),
                          ),
                        ],
                      ),
                      // const SizedBox(width: 10),
                      Flexible(
                        child: Radio<String>(
                          value: '1',
                          groupValue: selectedPrintOption,
                          onChanged: (newValue) {
                            setState(() {
                              selectedPrintOption = newValue;
                            });
                          },
                        ),
                      ),
                      const Flexible(
                          child: Text(
                        'No',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.CommonColor),
                      )),
                      // const SizedBox(width: 10),
                      Flexible(
                        child: Radio<String>(
                          value: '2',
                          groupValue: selectedPrintOption,
                          onChanged: (value) {
                            setState(() {
                              selectedPrintOption = value;
                            });
                          },
                        ),
                      ),
                      const Flexible(
                          child: Text(
                        '2inch',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.CommonColor),
                      )),

                      Flexible(
                        child: Radio<String>(
                          value: '3',
                          groupValue: selectedPrintOption,
                          onChanged: (value) {
                            setState(() {
                              selectedPrintOption = value;
                            });
                          },
                        ),
                      ),
                      const Flexible(
                          child: Text(
                        '3inch',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.CommonColor),
                      )),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.CommonColor,
                          foregroundColor: AppColors.BodyColor,
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () async {
                          List<Map<String, dynamic>> cartItemJsonList = [];
                          for (var cartItem in cartItems) {
                            Map<String, dynamic> cartItemJson = {
                              'itemName': cartItem.itemName,
                              'itemId': cartItem.itemId,
                              'selRate': cartItem.selRate,
                              'cgst': cartItem.cgst,
                              'qty': cartItem.qty,
                              'amount': cartItem.amount,
                              'gst': cartItem.gst,
                              'gstval': cartItem.Gstval,
                              'disval': cartItem.disval,
                              'taxable': cartItem.Taxable,
                              'net': cartItem.Net,
                              'SelRateTax': cartItem.SelRateTax,
                              'TaxType': cartItem.TaxType,
                            };
                            cartItemJsonList.add(cartItemJson);
                          }
                          final Map<String, dynamic> requestBody = {
                            'billno': billNo,
                            'billPre': billPre,
                            'accode': widget.album.accode,
                            'companyid': widget.selectedCompany,
                            'cartItems': cartItemJsonList,
                          };
                          print("Cart Item: $cartItemJsonList");
                          SharedPreferences CompanyId =
                              await SharedPreferences.getInstance();
                          CompanyId.setString(
                              'CompanyId', widget.selectedCompany);

                          PrintAddToCart(requestBody);
                          DatabaseConnection databaseConnection =
                          DatabaseConnection();
                          await databaseConnection.insertSalesEntryData([requestBody]);
                          /*  RequestHandler requestHandler = RequestHandler(requestBody);
                            requestHandler.handleRequest();*/

                          final apiUrl = Uri.parse(
                              'http://bneeds.in/bneedsoutletapi/SalesEntryApi.aspx?action=InsertSalesData');
                          try {
                            http.Response response = await http.post(
                              apiUrl,
                              body: jsonEncode(requestBody),
                              headers: <String, String>{
                                'Content-Type':
                                    'application/json; charset=UTF-8',
                              },
                            );

                            if (response.statusCode == 200) {
                              print( response.body);
                              if (response.body == "Insert Successfuly!") {
                                Fluttertoast.showToast(
                                    msg: "Insert Successfully");
                                DatabaseConnection databaseConnection =
                                    DatabaseConnection();
                               /* await databaseConnection
                                    .insertSalesEntryData(requestBody);*/
                                SharedPreferences PrintModePrefs =
                                    await SharedPreferences.getInstance();
                                PrintModePrefs.setString(
                                    "printMode", selectedPrintOption!);
                                /*_showDialogForPrint(context);*/
                                var database =
                                    await databaseConnection.setDatabase();
                                await database.rawUpdate(
                                    'UPDATE companyProfile SET BillNo = ? WHERE Companyid = ?',
                                    [billNo, widget.selectedCompany]);
                              /*  cartItems.clear();
                                setState(() {});
                                *//*Fluttertoast.showToast(msg:'${cartItems.length}');*//*
                                Navigator.of(context).pop();*/
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Something went wrong");
                              }
                            } else {
                              log.i('Error: ${response.statusCode}');
                            }
                          } catch (error) {
                            log.i('Error: $error');
                          }

                          if (selectedPrintOption != "1") {
                            //save print Mode in Shared Prefrences
                            await Navigator.pushNamedAndRemoveUntil(
                                context, '/showprinter', (route) => false);
                          }else{
                            await Navigator.pushNamedAndRemoveUntil(
                                context, '/SalesEntry', (route) => false);
                          }

                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.CommonColor,
                          foregroundColor: AppColors.BodyColor,
                        ),
                        child: const Text(
                          'No',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        },
      );
    });
  }

  Future<void> _GetPrintModePrefs() async {
    SharedPreferences PrintModePrefs = await SharedPreferences.getInstance();
    setState(() {
      selectedPrintOption = PrintModePrefs.getString("printMode");
    });
    String? Prefs = PrintModePrefs.getString("printMode");
    /*Fluttertoast.showToast(msg: "$Prefs");*/
  }

  void removeFromCart(int index) {
    setState(() {
      cartItems.removeAt(index);
      calculateTotal();
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDatabase();
    databaseHelper = DatabaseConnection();
    refreshAlbums();
    _GetPrintModePrefs();
  }

  Future<void> initializeDatabase() async {
    DatabaseConnection databaseConnection = DatabaseConnection();
    await databaseConnection.setDatabase();
  }

  Future<void> refreshAlbums() async {
    try {
      final databaseHelper = DatabaseConnection();
      await databaseHelper.setDatabase();
      List<ItemData> newItems =
          await databaseHelper.getItems(companyId: widget.selectedCompany);

      setState(() {
        items = newItems;
      });
      log.i('Total Length Of Items: ${items.length}');
    } catch (e) {
      log.i('Error fetching and updating data: $e');
    }
  }

  List<ItemData> _filterItems(String query) {
    return items
        .where(
            (item) => item.itemName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void handleCardTap(AddCartItemData cartItem) {
    /* _selratecontroller.text = '';
    _discountcontroller.text = '';
    _gstcontroller.text = '';
    _quanitycontroller.text = '';*/
    setState(() {
      selectedItem = cartItem;
      _quanitycontroller.text = cartItem.qty;
      _selratecontroller.text = cartItem.selRate;
      _gstcontroller.text = cartItem.gst;
      _discountcontroller.text = cartItem.disval;
    });
    FocusScope.of(context).requestFocus(_quantityFocusNode);
    /*Fluttertoast.showToast(msg: cartItem.qty);*/
  }

  Future<void> addToCart() async {
    if (selectedItem != null) {
      double selRate = double.tryParse(_selratecontroller.text) ?? 0.0;
      double cgst = double.tryParse(_gstcontroller.text) ?? 0.0;
      int qty = int.tryParse(_quanitycontroller.text) ?? 0;
      int gst = int.tryParse(_gstcontroller.text) ?? 0;
      double disval = double.tryParse(_discountcontroller.text) ?? 0.0;

      double selRateTax = 0.00;
      double amount = 0.00;
      double NetTotal = 0.00;
      double gstVal = 0.00;
      double taxable = 0.00;

      final companyProfile =
          await databaseHelper.getCompanyProfile(widget.selectedCompany);
      String TaxType;
      TaxType = companyProfile['TaxType'] ?? '';
      print("TaxType: $TaxType");
      if (TaxType == "2") {
        selRateTax = selRate;
        amount = selRateTax * qty;
        taxable = selRateTax * qty - disval;
        gstVal = taxable * gst / 100;
        NetTotal = taxable + gstVal;
      } else if (TaxType == "1") {
        selRateTax = selRate - selRate * gst / (100 + gst);
        amount = selRateTax * qty;
        taxable = selRateTax * qty - disval;
        gstVal = taxable * gst / 100;
        NetTotal = taxable + gstVal;
      } else {
        gst = 0;
        cgst = 0;
        selRateTax = selRate;
        amount = selRateTax * qty;
        taxable = selRateTax * qty - disval;
        gstVal = taxable * gst / 100;
        NetTotal = taxable + gstVal;
      }

      print(selRateTax);
      final cartItem = AddCartItemData(
        itemName: selectedItem!.itemName,
        itemId: selectedItem!.itemId,
        selRate: selRate.toStringAsFixed(2),
        cgst: cgst.toString(),
        qty: qty.toString(),
        amount: amount.toStringAsFixed(2),
        gst: gst.toStringAsFixed(2),
        disval: disval.toStringAsFixed(2),
        Gstval: gstVal.toStringAsFixed(2),
        Taxable: taxable.toString(),
        Net: NetTotal.toStringAsFixed(2),
        SelRateTax: selRateTax.toStringAsFixed(2),
        TaxType: TaxType.toString()
      );
      /*Fluttertoast.showToast(msg: "$gstVal");*/
      setState(() {
        _selratecontroller.text = selRate.toString();
        _gstcontroller.text = cgst.toString();
        _quanitycontroller.text = qty.toString();
        _discountcontroller.text = disval.toString();
      });

      double newQuantity = double.tryParse(cartItem.qty) ?? 0.0;
      double newNet = double.tryParse(cartItem.Net) ?? 0.0;
      double newGst = double.tryParse(cartItem.gst) ?? 0.0;
      double newGstVal = double.tryParse(cartItem.Gstval) ?? 0.0;
      double newDis = double.tryParse(cartItem.disval) ?? 0.0;

      if (newQuantity <= 0) {
        setState(() {
          cartItems.removeWhere((item) => item.itemName == cartItem.itemName);
        });
      } else {
        bool itemExists = false;
        for (int i = 0; i < cartItems.length; i++) {
          if (cartItems[i].itemName == cartItem.itemName) {
            cartItems[i].qty = newQuantity.toString();
            cartItems[i].Net = newNet.toString();
            cartItems[i].gst = newGst.toString();
            cartItems[i].Gstval = newGstVal.toString();
            cartItems[i].disval = newDis.toString();
            itemExists = true;
            break;
          }
        }

        if (!itemExists && newQuantity > 0) {
          setState(() {
            cartItems.add(cartItem);
          });
        } else {
          setState(() {});
        }
      }

      _searchcontroller.text = '';
      _selratecontroller.text = '';
      _discountcontroller.text = '';
      _gstcontroller.text = '';
      _quanitycontroller.text = '';
      _quantityFocusNode.unfocus();
      selectedItem = null;
      calculateTotal(); // Recalculate the total
    }
    // Fluttertoast.showToast(msg:'${cartItems.length}');
  }

  void PrintAddToCart(Map<String, dynamic> cartItem) {
    CartData.mapList.add(cartItem);
    print("Cart items count after adding: ${CartData.mapList}");
  }

  @override
  Widget build(BuildContext context) {
    bool hasSelectedItems = cartItems.isNotEmpty;
    return Scaffold(
      backgroundColor: AppColors.BodyColor,
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'ADD SALES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.CommonColor,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'Confirm Exit',
                      style: TextStyle(fontSize: 18),
                    ),
                    content: const SingleChildScrollView(
                        child: Center(
                            child: Text(
                      'Are you sure you want to exit?',
                      style: TextStyle(fontSize: 16),
                    ))),
                    actions: [
                      TextButton(
                        child: const Text(
                          'Yes',
                          style: TextStyle(fontSize: 20, color: Colors.teal),
                        ),
                        onPressed: () async {
                          /* SharedPreferences Userprefs = await SharedPreferences.getInstance();
                            await Userprefs.clear();*/
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                        },
                      ),
                      TextButton(
                        child: const Text(
                          'No',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(widget.album.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  TypeAheadField<ItemData>(
                    suggestionsCallback: (String query) {
                      final filteredItems = _filterItems(query);
                      return filteredItems;
                    },
                    itemBuilder: (BuildContext context, ItemData suggestion) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              suggestion.itemName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'MRP: ${suggestion.mrp}, SelRate: ${suggestion.selRate}',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const Divider(
                            thickness:
                                3.0, // Adjust the thickness of the underline
                            color: Colors
                                .grey, // Adjust the color of the underline
                          ),
                        ],
                      );
                    },
                    onSuggestionSelected: (ItemData suggestion) {
                      setState(() {
                        selectedItem = suggestion;
                      });
                      _searchcontroller.text = '';
                      _selratecontroller.text = selectedItem!.selRate;
                      _gstcontroller.text = selectedItem!.cgst;
                      _quantityFocusNode.requestFocus();
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration: const InputDecoration(
                        labelText: 'Search Items',
                        hintText: 'Enter item name',
                      ),
                      controller: _searchcontroller,
                    ),
                  ),
                  if (selectedItem != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20.0),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '${selectedItem!.itemName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      subtitle: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 12.0,
                                            ),
                                            border: OutlineInputBorder(),
                                            labelText: 'Quantity',
                                          ),
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          focusNode: _quantityFocusNode,
                                          controller: _quanitycontroller,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      subtitle: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 12.0,
                                            ),
                                            border: OutlineInputBorder(),
                                            labelText: 'Selrate',
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: _selratecontroller,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      subtitle: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 12.0,
                                            ),
                                            border: OutlineInputBorder(),
                                            labelText: 'Gst',
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: _gstcontroller,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      subtitle: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 12.0,
                                            ),
                                            border: OutlineInputBorder(),
                                            labelText: 'Discount',
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: _discountcontroller,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.CommonColor,
                                      foregroundColor: AppColors.BodyColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    child: const Text("CANCEL"),
                                  ),
                                  const SizedBox(width: 18),
                                  ElevatedButton(
                                    onPressed: addToCart,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.CommonColor,
                                      foregroundColor: AppColors.BodyColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    child: const Text("ADD"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (cartItems.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final cartItem = cartItems[index];
                              double quantity = double.parse(cartItem.qty);
                              return GestureDetector(
                                onTap: () {
                                  handleCardTap(cartItem);
                                  // Fluttertoast.showToast(msg: "welcome");
                                },
                                child: Card(
                                  color: AppColors.CommonColor,
                                  elevation: 1.0,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Flexible(
                                            // Wrap text with Flexible
                                            child: Text(
                                              cartItem.itemName,
                                              style: const TextStyle(
                                                color: AppColors.BodyColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(height: 25),
                                              Text(
                                                '${cartItem.selRate}',
                                                style: const TextStyle(
                                                  color: AppColors.BodyColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'X',
                                                style: const TextStyle(
                                                  color: AppColors.BodyColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              /*const SizedBox(width: 10),*/
                                              /*IconButton(
                                                icon: const Icon(
                                                    Icons.remove_circle_outline,
                                                    size: 30,
                                                    color: AppColors.BodyColor),
                                                onPressed: () {
                                                  if (quantity > 0) {
                                                    setState(() {
                                                      quantity--;
                                                      cartItem.qty =
                                                          quantity.toString();
                                                      calculateTotal();
                                                    });
                                                  }
                                                  if (quantity == 0) {
                                                    removeFromCart(index);
                                                  }
                                                },
                                              ),*/
                                              Text(
                                                '${cartItem.qty}',
                                                style: const TextStyle(
                                                  color: AppColors.BodyColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              /*              IconButton(
                                                icon: const Icon(
                                                    Icons.add_circle_outline,
                                                    size: 30,
                                                    color: AppColors.BodyColor),
                                                onPressed: () {
                                                  setState(() {
                                                    quantity++;
                                                    cartItem.qty =
                                                        quantity.toString();
                                                    calculateTotal();
                                                  });
                                                },
                                              ),
                                              const SizedBox(width: 10),*/
                                              const Text(
                                                '=',
                                                style: TextStyle(
                                                  color: AppColors.BodyColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                '${cartItem.Net}',
                                                style: const TextStyle(
                                                  color: AppColors.BodyColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              const SizedBox(height: 0),
                                              Text(
                                                'Gst: ${cartItem.cgst}',
                                                style: const TextStyle(
                                                  color: AppColors.BodyColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Val: ${cartItem.Gstval}',
                                                style: const TextStyle(
                                                  color: AppColors.BodyColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Dis: ${cartItem.disval}',
                                                style: const TextStyle(
                                                  color: AppColors.BodyColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          /*  SizedBox(height: 12),
                                           Row(
                                             mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(height: 0),
                                               Text(
                                                'Net Total: ${cartItem.Net}',
                                                style: const TextStyle(
                                                  color: AppColors.BodyColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 25,
                                                ),
                                              ),
                                            ],
                                          ),*/
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        color: AppColors.CommonColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Item Count: ${cartItems.length}',
              style: const TextStyle(
                color: AppColors.BodyColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
                onPressed: hasSelectedItems
                    ? () {
                        _showConfirmationBottomSheet();
                      }
                    : null,
                child: const Text(
                  "Save",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.BodyColor),
                )),
            Text(
              'Total: ${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.BodyColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      /*floatingActionButton: hasSelectedItems
          ? FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () {
                _showConfirmationBottomSheet();
              },
              child: const Icon(
                Icons.check,
                color: AppColors.BodyColor,
                size: 30,
                fill: BorderSide.strokeAlignCenter,
              ),
            )
          : null,*/
    );
  }
}

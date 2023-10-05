import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:bneedsoutlet/Database/Database_Helper.dart';
import 'package:bneedsoutlet/Modal/AddToCartItems.dart';
import 'package:bneedsoutlet/Modal/printerenum.dart';
import 'package:bneedsoutlet/style/variables.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../demo.dart';

class PrintPage {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final DatabaseConnection databaseHelper = DatabaseConnection();

  void twoinch() async {
    SharedPreferences CompanyId = await SharedPreferences.getInstance();
    String? companyid = CompanyId.getString('CompanyId');

    final Map<String, dynamic> companyProfile =
    await databaseHelper.getCompanyProfile(companyid!);

    String companyName = companyProfile['CompanyName'] ?? '';
    String Add1 = companyProfile['Add1'] ?? '';
    String Add2 = companyProfile['Add2'] ?? '';
    String Add3 = companyProfile['Add3'] ?? '';
    String Add4 = companyProfile['Add4'] ?? '';
    String Pincode = companyProfile['Pincode'] ?? '';
    String MobileNo = companyProfile['MobileNo'] ?? '';
    String Gstin = companyProfile['Gstin'] ?? '';
    double totalAmount = 0;
    bluetooth.isConnected.then((isConnected) async {
      /*bluetooth.printCustom("--------------------------------", 1, 1);*/
      if (isConnected!) {
        bluetooth.printCustom(
            '$companyName', Size.boldLarge.val, Align.center.val);

        if (Add1 != "") {
          bluetooth.printCustom('$Add1', Size.bold.val, Align.center.val);
        }

        if (Add2 != "") {
          bluetooth.printCustom('$Add2', Size.bold.val, Align.center.val);
        }

        if (Add3 != "") {
          bluetooth.printCustom('$Add3', Size.bold.val, Align.center.val);
        }

        if (Add4 != "") {
          bluetooth.printCustom('$Add4', Size.bold.val, Align.center.val);
        }

        if (Pincode != "") {
          bluetooth.printCustom('$Pincode', Size.bold.val, Align.center.val);
        }
        if (MobileNo != "") {
          bluetooth.printCustom('$MobileNo', Size.bold.val, Align.center.val);
        }
        if (Gstin != "") {
          bluetooth.printCustom('$Gstin', Size.bold.val, Align.center.val);
        }

        bluetooth.printCustom("--------------------------------", 1, 1);

        for (var cartItemData in CartData.mapList) {
          List<Map<String, dynamic>> cartItems = cartItemData['cartItems'];
          String billno = cartItemData['billno'];
          String Date = getCurrentDate();

          String paddedBill = "BillNO: $billno".padRight(8);
          String paddedSpace = "".padRight(0);
          String paddedDate = "Date: $Date".padRight(3);
          String formattedHeadBillDet = '$paddedBill $paddedSpace $paddedDate';
          bluetooth.printCustom(formattedHeadBillDet, 1, 0);

          bluetooth.printCustom("--------------------------------", 1, 1);

          String paddedHeaditemName = "Item Name".padRight(0);
          String paddedHeadRate = "Rate".padRight(0);
          /*String paddedHeadGst = "Gst".padRight(0);*/
          String paddedHeadqty = "Qty".padLeft(0);
          String paddedHeadamount = "Amount".padLeft(0);
          String formattedHeadItemDetails =
              '$paddedHeaditemName  $paddedHeadRate  $paddedHeadqty  $paddedHeadamount';
          bluetooth.printCustom(formattedHeadItemDetails, 1, 1);
          bluetooth.printCustom("--------------------------------", 1, 1);
          /*bluetooth.printNewLine();*/

          for (var cartItem in cartItems) {
            String itemName = cartItem['itemName'];
            String rate = cartItem['selRate'];
            /*String gst = cartItem['gst'];*/
            String qty = cartItem['qty'];
            String amount = cartItem['amount'];
            String net = cartItem['net'];

            double itemTotal = double.parse(net);
            totalAmount += itemTotal;

            int maxLineWidth = 20;
            String wrapText(String text) {
              List<String> words = text.split(" ");
              List<String> lines = [];
              String currentLine = "";

              for (String word in words) {
                if ((currentLine.length + word.length + 1) <= maxLineWidth) {
                  currentLine += (currentLine.isEmpty ? "" : " ") + word;
                } else {
                  lines.add(currentLine);
                  currentLine = word;
                }
              }

              if (currentLine.isNotEmpty) {
                lines.add(currentLine);
              }

              return lines.join("\n");
            }

            /*    String wrappedItemName = wrapText(itemName);
            *//*String EmptySpace = "          ".padRight(0);*//*
            String formattedRate = rate.padLeft(20);
            String formattedQty = qty.padLeft(5);
            String formattedAmount = amount.padLeft(5);

            String formattedHeadItemDetails1 = "$wrappedItemName $formattedRate   $formattedQty $formattedAmount";
            bluetooth.printCustom(formattedHeadItemDetails1, 1, 0);
            bluetooth.printCustom("--------------------------------", 1, 1);*/

            String wrappedItemName = wrapText(itemName);
            String EmptySpace = "".padRight(3);
            String formattedRate = rate.padRight(10);
            /*String formattedGstPer = "$gst%".padRight(8);*/
            String formattedQty = qty.padRight(6);
            String formattedAmount = net.padRight(0);

            String formattedHeadItemDetails1 = "$itemName";
            String formattedHeadItemDetails2 =
                "$formattedRate  $formattedQty $formattedAmount";
            bluetooth.printCustom(formattedHeadItemDetails1, 1, 0);
            /*bluetooth.print3Column(rate, qty, amount, 1);*/
            bluetooth.printCustom(formattedHeadItemDetails2, 1, 0);
            bluetooth.printCustom("--------------------------------", 1, 1);
          }
        }

        String formattedTotalAmount =
            "Total Amount: ${totalAmount.toStringAsFixed(2)}";
        bluetooth.printCustom(formattedTotalAmount, 1, 1);
        bluetooth.paperCut();
        CartData.mapList.clear();
      }
    });
  }

  void threeinch() async {
    SharedPreferences CompanyId = await SharedPreferences.getInstance();
    String? companyid = CompanyId.getString('CompanyId');

    final Map<String, dynamic> companyProfile =
    await databaseHelper.getCompanyProfile(companyid!);

    String companyName = companyProfile['CompanyName'] ?? '';
    String Add1 = companyProfile['Add1'] ?? '';
    String Add2 = companyProfile['Add2'] ?? '';
    String Add3 = companyProfile['Add3'] ?? '';
    String Add4 = companyProfile['Add4'] ?? '';
    String Pincode = companyProfile['Pincode'] ?? '';
    String MobileNo = companyProfile['MobileNo'] ?? '';
    String Gstin = companyProfile['Gstin'] ?? '';
    double totalAmount = 0;
    bluetooth.isConnected.then((isConnected) async {
      /*bluetooth.printCustom("--------------------------------", 1, 1);*/
      if (isConnected!) {
        bluetooth.printCustom(
            '$companyName', Size.boldLarge.val, Align.center.val);

        if (Add1 != "") {
          bluetooth.printCustom('$Add1', Size.bold.val, Align.center.val);
        }

        if (Add2 != "") {
          bluetooth.printCustom('$Add2', Size.bold.val, Align.center.val);
        }

        if (Add3 != "") {
          bluetooth.printCustom('$Add3', Size.bold.val, Align.center.val);
        }

        if (Add4 != "") {
          bluetooth.printCustom('$Add4', Size.bold.val, Align.center.val);
        }

        if (Pincode != "") {
          bluetooth.printCustom('$Pincode', Size.bold.val, Align.center.val);
        }
        if (MobileNo != "") {
          bluetooth.printCustom('$MobileNo', Size.bold.val, Align.center.val);
        }
        if (Gstin != "") {
          bluetooth.printCustom('$Gstin', Size.bold.val, Align.center.val);
        }

        bluetooth.printCustom('-----------------------------------------------', 1, 1);

        for (var cartItemData in CartData.mapList) {
          List<Map<String, dynamic>> cartItems = cartItemData['cartItems'];
          String billno = cartItemData['billno'];
          String Date = getCurrentDate();

          String paddedBill = "BillNO: $billno".padRight(8);
          String paddedSpace = "".padRight(15);
          String paddedDate = "Date: $Date".padRight(3);
          String formattedHeadBillDet = '$paddedBill $paddedSpace $paddedDate';
          bluetooth.printCustom(formattedHeadBillDet, 1, 0);

          bluetooth.printCustom('-----------------------------------------------', 1, 1);

          String paddedHeaditemName = "Item Name".padRight(15);
          String paddedHeadRate = "Rate".padRight(5);
          String paddedHeadGst = "Gst".padRight(5);
          String paddedHeadqty = "Qty".padRight(5);
          String paddedHeadamount = "Amount".padRight(0);
          String formattedHeadItemDetails =
              '$paddedHeaditemName  $paddedHeadRate $paddedHeadGst   $paddedHeadqty  $paddedHeadamount';
          bluetooth.printCustom(formattedHeadItemDetails, 1, 1);
          bluetooth.printCustom('-----------------------------------------------', 1, 1);
          /*bluetooth.printNewLine();*/

          for (var cartItem in cartItems) {
            String itemName = cartItem['itemName'];
            String rate = cartItem['selRate'];
            String gst = cartItem['gst'];
            String qty = cartItem['qty'];
            String amount = cartItem['amount'];
            String net = cartItem['net'];

            double itemTotal = double.parse(net);
            totalAmount += itemTotal;

            int maxLineWidth = 20;
            String wrapText(String text) {
              List<String> words = text.split(" ");
              List<String> lines = [];
              String currentLine = "";

              for (String word in words) {
                if ((currentLine.length + word.length + 1) <= maxLineWidth) {
                  currentLine += (currentLine.isEmpty ? "" : " ") + word;
                } else {
                  lines.add(currentLine);
                  currentLine = word;
                }
              }

              if (currentLine.isNotEmpty) {
                lines.add(currentLine);
              }

              return lines.join("\n");
            }

           /*    String wrappedItemName = wrapText(itemName);
            *//*String EmptySpace = "          ".padRight(0);*//*
            String formattedRate = rate.padLeft(20);
            String formattedQty = qty.padLeft(5);
            String formattedAmount = amount.padLeft(5);

            String formattedHeadItemDetails1 = "$wrappedItemName $formattedRate   $formattedQty $formattedAmount";
            bluetooth.printCustom(formattedHeadItemDetails1, 1, 0);
            bluetooth.printCustom("--------------------------------", 1, 1);*/

            String wrappedItemName = wrapText(itemName);
            String EmptySpace = "".padRight(3);
            String formattedRate = rate.padRight(15);
            String formattedGstPer = "$gst%".padRight(8);
            String formattedQty = qty.padRight(10);
            String formattedAmount = net.padRight(0);

            String formattedHeadItemDetails1 = "$itemName";
            String formattedHeadItemDetails2 =
                "$formattedRate $formattedGstPer  $formattedQty $formattedAmount";
            bluetooth.printCustom(formattedHeadItemDetails1, 1, 0);
            /*bluetooth.print3Column(rate, qty, amount, 1);*/
            bluetooth.printCustom(formattedHeadItemDetails2, 1, 1);
            bluetooth.printCustom('-----------------------------------------------', 1, 1);
          }
        }

        String formattedTotalAmount =
            "Total Amount: ${totalAmount.toStringAsFixed(2)}";
        bluetooth.printCustom(formattedTotalAmount, 1, 1);
        bluetooth.paperCut();
        CartData.mapList.clear();
      }
    });
  }

/*  int getTotalQuantity() {
    int totalQuantity = 0;
    for (var item in cartItems) {
       totalQuantity += item[''] as int;
    }
    return totalQuantity;
  }*/

/*  String getTotalGst() {
    double totalGst = 0;
    String formattedgstval = "";
    double totalQuantity = 0.0;
    for (var item in cartItems) {
      // totalQuantity += item['quantity'] as int;
      // double itemGst = item['itemGst'].toDouble();
      // double itemPrice = item['itemRate'].toDouble() ;
      // totalGst += (itemPrice * totalQuantity * itemGst / (itemGst + 100)) / 2;
      formattedgstval += totalGst.toStringAsFixed(2);
    }
    return formattedgstval;
  }

  String getTotalAmount() {
    double totalAmount = 0;
    double totalQuantity = 0.0;
    String formattedtotalAmount = "";
    for (var item in cartItems) {
      // double Qty = item['quantity'].toDouble();
      // double itemPrice = item['itemRate'].toDouble() ;
      // totalAmount += itemPrice *  Qty;
      formattedtotalAmount += totalAmount.toStringAsFixed(2);
    }
    return formattedtotalAmount;

  }*/

  String getCurrentDate() {
    // Get the current date in the desired format
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    return formattedDate;
  }
}

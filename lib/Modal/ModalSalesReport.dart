import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModalSalesReport {
//Shopping List Name Ithu. Enna Enna Things Vaaganum write panniruku

  final String Entrefno;
  final String BillNo;
  final String Billdate;
  final String Accode;
  final String itemid;
  final String Qty;
  final String Selrate;
  final String Amount;
  final String Companyid;
  final String userid;
  final String DiscPer;
  final String Discount;
  final String gst;
  final String gstval;
  final String BILLPREFIX;
  final String selratenotax;
  final String taxtype;

  //ithu constructor ithoda work correctta antha antha variableku correctta thara valueva set panrathu

  ModalSalesReport({
    required this.Entrefno,
    required this.BillNo,
    required this.Billdate,
    required this.Accode,
    required this.itemid,
    required this.Qty,
    required this.Selrate,
    required this.Amount,
    required this.Companyid,
    required this.userid,
    required this.DiscPer,
    required this.Discount,
    required this.gst,
    required this.gstval,
    required this.BILLPREFIX,
    required this.selratenotax,
    required this.taxtype,
  });

  Map<String, dynamic> toMap() {
    return {
      'Entrefno': Entrefno,
      'BillNo': BillNo,
      'Billdate': Billdate,
      'Accode': Accode,
      'itemid': itemid,
      'Qty': Qty,
      'Selrate': Selrate,
      'Amount': Amount,
      'Companyid': Companyid,
      'userid': userid,
      'DiscPer': DiscPer,
      'Discount': Discount,
      'gst': gst,
      'gstval': gstval,
      'BILLPREFIX': BILLPREFIX,
      'selratenotax': selratenotax,
      'taxtype': taxtype,
    };
  }
}





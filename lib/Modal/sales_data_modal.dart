class SalesData {
  final String entrefno;
  final String billNo;
  final String billDate;
  final String accode;
  final String qty;
  final String selRate;
  final String amount;
  final String companyId;
  final String userId;
  final String discPer;
  final String discount;
  final String gst;
  final String gstVal;
  final String billPrefix;
  final String selRateNoTax;
  final String taxType;

  SalesData({
    required this.entrefno,
    required this.billNo,
    required this.billDate,
    required this.accode,
    required this.qty,
    required this.selRate,
    required this.amount,
    required this.companyId,
    required this.userId,
    required this.discPer,
    required this.discount,
    required this.gst,
    required this.gstVal,
    required this.billPrefix,
    required this.selRateNoTax,
    required this.taxType,
  });

  Map<String, dynamic> toMap() {
  return {
    'entrefno': entrefno,
    'billNo': billNo,
    'billDate': billDate,
    'accode': accode,
    'qty': qty,
    'selRate': selRate,
    'amount': amount,
    'companyId': companyId,
    'userId': userId,
    'discPer': discPer,
    'discount': discount,
    'gst': gst,
    'gstVal': gstVal,
    'billPrefix': billPrefix,
    'selRateNoTax': selRateNoTax,
    'taxType': taxType,
  };
}

}

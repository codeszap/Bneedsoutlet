class CartManager {
  List<Map<String, dynamic>> cartItemJsonList = [];
  String billNo;
  String billPre;
  String accode;
  String companyid;

  CartManager({
    required this.billNo,
    required this.billPre,
    required this.accode,
    required this.companyid,
  });

  void addCartItem({
    required String itemName,
    required String itemId,
    required double selRate,
    required double cgst,
    required int qty,
    required double amount,
    required double gst,
    required double disval,
  }) {
    Map<String, dynamic> cartItemJson = {
      'itemName': itemName,
      'itemId': itemId,
      'selRate': selRate,
      'cgst': cgst,
      'qty': qty,
      'amount': amount,
      'gst': gst,
      'disval': disval,
    };
    cartItemJsonList.add(cartItemJson);
  }

  Map<String, dynamic> generateRequestBody() {
    final Map<String, dynamic> requestBody = {
      'billno': '$billPre$billNo',
      'billPre': billPre,
      'accode': accode,
      'companyid': companyid,
      'cartItems': cartItemJsonList,
    };

    return requestBody;
  }
}

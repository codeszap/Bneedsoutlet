class ItemData {
  final String itemId;
  final String itemName;
  final String selRate;
  final String mrp;
  final String cgst;
  final String wsSelRate;
  final String purRate;
  final String commCode;
  final String lok;
  final String companyid;


  ItemData({
    required this.itemId,
    required this.itemName,
    required this.selRate,
    required this.mrp,
    required this.cgst,
    required this.wsSelRate,
    required this.purRate,
    required this.commCode,
    required this.lok,
    required this.companyid,
  });

  Map<String, dynamic> toMap() {
    return {
      'Itemid': itemId,
      'itemName': itemName,
      'Selrate': selRate,
      'MRP': mrp,
      'cgst': cgst,
      'WSSELRATE': wsSelRate,
      'PurRate': purRate,
      'commCode': commCode,
      'Lok': lok,
      'Companyid': companyid,
    };
  }
}
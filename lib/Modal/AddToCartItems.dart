class AddCartItemData {
   String itemName;
   String itemId;
   String selRate;
   String cgst;
   String qty;
   String amount;
   String gst;
   String disval;
   String Gstval;
   String Taxable;
   String Net;
   String SelRateTax;
   String TaxType;

  AddCartItemData({
    required this.itemName,
    required this.itemId,
    required this.selRate,
    required this.cgst,
    required this.qty,
    required this.amount,
    required this.gst,
    required this.disval,
    required this.Gstval,
    required this.Taxable,
    required this.Net,
    required this.SelRateTax,
    required this.TaxType,
  });
}

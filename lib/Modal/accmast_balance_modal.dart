class AccmastBalanceModal {
  final String accode;
  final String name;
  final String groupname;
  final String companyid;
  final String lok;
  final String mobile;
  final String address1;
  final String address2;
  final String address3;
  final String address4;
  final String gstin;
  final String pincode;

  AccmastBalanceModal({
    required this.accode,
    required this.name,
    required this.groupname,
    required this.companyid,
    required this.lok,
    required this.mobile,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.address4,
    required this.gstin,
    required this.pincode,
  });

  Map<String, dynamic> toMap() {
    return {
      'accode': accode,
      'name': name,
      'groupname': groupname,
      'companyid': companyid,
      'lok': lok,
      'mobile': mobile,
      'address1': address1,
      'address2': address2,
      'address3': address3,
      'address4': address4,
      'gstin': gstin,
      'pincode': pincode,
    };
  }
}

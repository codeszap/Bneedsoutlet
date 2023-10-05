class TransactionModal {
  final String accode;
  final String name;
  final String groupName;
  final String companyid;
  final String lok;
  final String mobile;

  TransactionModal({
    required this.accode,
    required this.name,
    required this.groupName,
    required this.companyid,
    required this.lok,
    required this.mobile,
  });

  Map<String, dynamic> toMap() {
    return {
      'Accode': accode,
      'Name': name,
      'GroupName': groupName,
      'Companyid': companyid,
      'Lok': lok,
      'Mobile': mobile,
    };
  }

}
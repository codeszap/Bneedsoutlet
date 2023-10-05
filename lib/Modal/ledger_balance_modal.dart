class LedgerBalanceModal {
  final String companyId;
  final String accode;
  final String name;
  final String groupName;
  final String mobileNo;
  final String balance;

  LedgerBalanceModal({
    required this.companyId,
    required this.accode,
    required this.name,
    required this.groupName,
    required this.mobileNo,
    required this.balance,
  });

  Map<String, dynamic> toMap() {
    return {
      'Companyid': companyId,
      'Accode': accode,
      'name': name,
      'GroupName': groupName,
      'MobileNo': mobileNo,
      'Balance': balance,
    };
  }
}
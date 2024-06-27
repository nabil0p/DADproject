class UserReport {
  final int cPendingCount;
  final int cDeliveredCount;
  final int rArrivedCount;
  final int rPickedCount;
  final String cAvailable;

  UserReport({
    required this.cPendingCount,
    required this.cDeliveredCount,
    required this.rArrivedCount,
    required this.rPickedCount,
    required this.cAvailable,
  });

  factory UserReport.fromJson(Map<String, dynamic> json) {
    return UserReport(
      cPendingCount: json['cPending'] != null ? json['cPending']['cPendingCount'] : 0,
      cDeliveredCount: json['cDelivered'] != null ? json['cDelivered']['cDeliveredCount'] : 0,
      rArrivedCount: json['rArrivedCount'] != null ? json['rArrivedCount']['rArrivedCount'] : 0,
      rPickedCount: json['rPickedCount'] != null ? json['rPickedCount']['rPickedCount'] : 0,
      cAvailable: json['cAvailable'] != null ? json['cAvailable']['cAvailable'] : "0",
    );
  }

  @override
  String toString() {
    return 'UserReport(cPendingCount: $cPendingCount, cDeliveredCount: $cDeliveredCount, rArrivedCount: $rArrivedCount, rPickedCount: $rPickedCount), cAvailable: $cAvailable)';
  }
}
class HistoryItem {
  final String itemFrom;
  final String locationName;
  final String itemMngtId;
  final DateTime arrivedDate;
  final DateTime pickupDate;


  HistoryItem({
    required this.itemFrom,
    required this.locationName,
    required this.itemMngtId,
    required this.arrivedDate,
    required this.pickupDate,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      itemFrom: json['item_from'] ?? '',
      locationName: json['location_name'] ?? '',
      itemMngtId: json['item_mngt_id'] ?? '',
      arrivedDate: DateTime.parse(json['arrived_date'] ?? DateTime.now().toIso8601String()),
      pickupDate: DateTime.parse(json['pickup_date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
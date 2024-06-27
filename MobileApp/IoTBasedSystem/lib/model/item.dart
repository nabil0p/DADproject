class Item {
  final String itemFrom;
  final String locationName;
  final String itemMngtId;
  final DateTime registerDate;
  final DateTime arrivedDate;

  Item({
    required this.itemFrom,
    required this.locationName,
    required this.itemMngtId,
    required this.registerDate,
    required this.arrivedDate,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemFrom: json['item_from'] ?? '',
      locationName: json['location_name'] ?? '',
      itemMngtId: json['item_mngt_id'] ?? '',
      registerDate: DateTime.parse(json['register_date'] ?? DateTime.now().toIso8601String()),
      arrivedDate: DateTime.parse(json['arrived_date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
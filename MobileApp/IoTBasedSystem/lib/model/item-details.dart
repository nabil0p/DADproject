class ItemDetails {
  final String itemMngtId;
  final String picId;
  final String itemId;
  final String itemMngtStatusId;
  final String statusName;
  final String registerDate;
  final String arrivedDate;
  final String pickupDate;
  final String qrcodeRecipientId;
  final String qrcodeDeliveryId;
  final String availability;
  final String itemFrom;
  final String lockerLocationId;
  final String lockerId;
  final String itemSizeId;
  final String locationName;
  final String locationAddress;
  final String recipientId;

  ItemDetails({
    required this.itemMngtId,
    required this.picId,
    required this.itemId,
    required this.itemMngtStatusId,
    required this.statusName,
    required this.registerDate,
    required this.arrivedDate,
    required this.pickupDate,
    required this.qrcodeRecipientId,
    required this.qrcodeDeliveryId,
    required this.availability,
    required this.itemFrom,
    required this.lockerLocationId,
    required this.lockerId,
    required this.itemSizeId,
    required this.locationName,
    required this.locationAddress,
    required this.recipientId,
  });

  factory ItemDetails.fromJson(Map<String, dynamic> json) {
    return ItemDetails(
      itemMngtId: json['item_mngt_id'],
      picId: json['pic_id'],
      itemId: json['item_id'],
      itemMngtStatusId: json['item_mngt_status_id'],
      statusName: json['status_name'],
      registerDate: json['register_date'],
      arrivedDate: json['arrived_date'],
      pickupDate: json['pickup_date'],
      qrcodeRecipientId: json['qrcode_recipient_id'],
      qrcodeDeliveryId: json['qrcode_delivery_id'],
      availability: json['availability'],
      itemFrom: json['item_from'],
      lockerLocationId: json['locker_location_id'],
      lockerId: json['locker_id'],
      itemSizeId: json['item_size_id'],
      locationName: json['location_name'],
      locationAddress: json['location_address'],
      recipientId: json['recipient_id'],
    );
  }
}
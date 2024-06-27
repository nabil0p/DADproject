class LocationList {
  String _locationName;
  String _locationAddress;
  String _locationId;
  String _locationImage;

  LocationList({
    required String locationName,
    required String locationAddress,
    required String locationId,
    required String locationImage,
  })  : _locationName = locationName,
        _locationAddress = locationAddress,
        _locationId = locationId,
        _locationImage = locationImage;

  // Getters
  String get locationName => _locationName;
  String get locationAddress => _locationAddress;
  String get locationId => _locationId;
  String get locationImage => _locationImage;

  // Setters
  set locationName(String value) {
    _locationName = value;
  }

  set locationAddress(String value) {
    _locationAddress = value;
  }

  set locationId(String value) {
    _locationId = value;
  }

  set locationImage(String value) {
    _locationImage = value;
  }

  factory LocationList.fromJson(Map<String, dynamic> json) {
    return LocationList(
      locationId: json['locker_location_id'],
      locationName: json['location_name'],
      locationAddress: json['location_address'],
      locationImage: json['location_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locker_location_id': _locationId,
      'location_name': _locationName,
      'location_address': _locationAddress,
      'location_image': _locationImage,
    };
  }
}

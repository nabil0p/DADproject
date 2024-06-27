class User {
  String username;
  String? qldId;
  String? imagePath;
  String icNumber;
  String fullName;
  String phoneNumber;
  String emailAddress;
  String roleId;

  User({
    required this.username,
    this.qldId,
    this.imagePath,
    required this.icNumber,
    required this.fullName,
    required this.phoneNumber,
    required this.emailAddress,
    required this.roleId,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      username: data['username'],
      qldId: data['qld_id'],
      imagePath: data['imagePath'],
      icNumber: data['icNumber'],
      fullName: data['fullName'],
      phoneNumber: data['phoneNumber'],
      emailAddress: data['emailAddress'],
      roleId: data['role_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'qld_id': qldId,
      'imagePath': imagePath,
      'icNumber': icNumber,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
      'role_id': roleId,
    };
  }
}

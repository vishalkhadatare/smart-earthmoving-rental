/// User domain entity – represents a platform user.
class UserEntity {
  final int id;
  final String firebaseUid;
  final String role;
  final String name;
  final String email;
  final String companyName;
  final String gstNumber;
  final String phone;
  final String profileImage;
  final String district;
  final String state;
  final bool isVerified;

  const UserEntity({
    required this.id,
    required this.firebaseUid,
    required this.role,
    required this.name,
    required this.email,
    this.companyName = '',
    this.gstNumber = '',
    this.phone = '',
    this.profileImage = '',
    this.district = '',
    this.state = '',
    this.isVerified = false,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] ?? 0,
      firebaseUid: json['firebase_uid'] ?? '',
      role: json['role'] ?? 'contractor',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      companyName: json['company_name'] ?? '',
      gstNumber: json['gst_number'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profile_image'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'role': role,
    'name': name,
    'email': email,
    'company_name': companyName,
    'gst_number': gstNumber,
    'phone': phone,
    'district': district,
    'state': state,
  };

  bool get isOwner => role == 'equipment_owner' || role == 'owner';
  bool get isContractor => role == 'contractor';
  bool get isAdmin => role == 'admin';

  UserEntity copyWith({
    String? role,
    String? name,
    String? companyName,
    String? district,
    String? state,
  }) {
    return UserEntity(
      id: id,
      firebaseUid: firebaseUid,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email,
      companyName: companyName ?? this.companyName,
      gstNumber: gstNumber,
      phone: phone,
      profileImage: profileImage,
      district: district ?? this.district,
      state: state ?? this.state,
      isVerified: isVerified,
    );
  }
}

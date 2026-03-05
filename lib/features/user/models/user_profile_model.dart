class UserProfileModel {
  final String uid;
  String contractorType;
  String contractorClass;
  int yearsExperience;
  String licenseNumber;
  String gstNumber;
  String fullName;
  String companyName;
  String email;
  String mobileNumber;
  String? photoUrl;

  UserProfileModel({
    required this.uid,
    required this.contractorType,
    required this.contractorClass,
    required this.yearsExperience,
    this.licenseNumber = '',
    this.gstNumber = '',
    required this.fullName,
    required this.companyName,
    required this.email,
    required this.mobileNumber,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'contractorType': contractorType,
      'contractorClass': contractorClass,
      'yearsExperience': yearsExperience,
      'licenseNumber': licenseNumber,
      'gstNumber': gstNumber,
      'fullName': fullName,
      'companyName': companyName,
      'email': email,
      'mobileNumber': mobileNumber,
      'photoUrl': photoUrl,
    };
  }

  factory UserProfileModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfileModel(
      uid: uid,
      contractorType: map['contractorType'] ?? '',
      contractorClass: map['contractorClass'] ?? '',
      yearsExperience: map['yearsExperience'] ?? 0,
      licenseNumber: map['licenseNumber'] ?? '',
      gstNumber: map['gstNumber'] ?? '',
      fullName: map['fullName'] ?? '',
      companyName: map['companyName'] ?? '',
      email: map['email'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }
}

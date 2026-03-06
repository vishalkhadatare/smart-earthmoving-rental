class UserProfileModel {
  final String uid;
  final String contractorType;
  final String contractorClass;
  final int yearsExperience;
  final String licenseNumber;
  final String gstNumber;
  final String fullName;
  final String companyName;
  final String email;
  final String mobileNumber;
  final String? photoUrl;

  const UserProfileModel({
    required this.uid,
    this.contractorType = '',
    this.contractorClass = '',
    this.yearsExperience = 0,
    this.licenseNumber = '',
    this.gstNumber = '',
    this.fullName = '',
    this.companyName = '',
    this.email = '',
    this.mobileNumber = '',
    this.photoUrl,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'contractorType': contractorType,
    'contractorClass': contractorClass,
    'yearsExperience': yearsExperience,
    'licenseNumber': licenseNumber,
    'gstNumber': gstNumber,
    'fullName': fullName,
    'companyName': companyName,
    'email': email,
    'mobileNumber': mobileNumber,
    if (photoUrl != null) 'photoUrl': photoUrl,
  };

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] ?? '',
      contractorType: map['contractorType'] ?? '',
      contractorClass: map['contractorClass'] ?? '',
      yearsExperience: map['yearsExperience'] ?? 0,
      licenseNumber: map['licenseNumber'] ?? '',
      gstNumber: map['gstNumber'] ?? '',
      fullName: map['fullName'] ?? map['name'] ?? '',
      companyName: map['companyName'] ?? '',
      email: map['email'] ?? '',
      mobileNumber: map['mobileNumber'] ?? map['phone'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }
}

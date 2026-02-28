enum AccountType { owner, hirer, manufacturer }

extension AccountTypeX on AccountType {
  String get value {
    switch (this) {
      case AccountType.owner:
        return 'owner';
      case AccountType.hirer:
        return 'hirer';
      case AccountType.manufacturer:
        return 'manufacturer';
    }
  }
}

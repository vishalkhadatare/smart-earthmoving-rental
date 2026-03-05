enum AccountType { owner, user }

extension AccountTypeX on AccountType {
  String get value {
    switch (this) {
      case AccountType.owner:
        return 'owner';
      case AccountType.user:
        return 'user';
    }
  }

  String get label {
    switch (this) {
      case AccountType.owner:
        return 'Owner';
      case AccountType.user:
        return 'User';
    }
  }
}

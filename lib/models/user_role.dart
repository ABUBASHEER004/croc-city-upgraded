enum UserRole {
  player,
  parent,
 coach,
  admin,
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.player:
        return "Player";
      case UserRole.parent:
        return "Parent";
      case UserRole.coach:
        return "Coach";
      case UserRole.admin:
        return "Administrator";
    }
  }
}
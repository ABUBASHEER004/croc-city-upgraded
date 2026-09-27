enum UserRole {
  player,
  playerParent,
  parent, // Legacy value retained so older screens remain source-compatible.
  coach,
  teacher,
  staff,
  student,
  studentParent,
  admin,
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.player:
        return 'Player';
      case UserRole.playerParent:
        return 'Player Parent';
      case UserRole.parent:
        return 'Parent';
      case UserRole.coach:
        return 'Coach';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.staff:
        return 'Staff';
      case UserRole.student:
        return 'Student';
      case UserRole.studentParent:
        return 'Student Parent';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  String get firestoreValue => label;
}

import 'package:fintracker_app/models/user.dart';

class RolePolicy {
  const RolePolicy._();

  static bool canEdit(AppUser? user) =>
      user?.role == UserRole.admin || user?.role == UserRole.editor;

  static bool canDelete(AppUser? user) => user?.role == UserRole.admin;

  static bool canManageUsers(AppUser? user) => user?.role == UserRole.admin;
}

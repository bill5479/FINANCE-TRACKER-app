import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:fintracker_app/models/user.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _currentUser;
  List<AppUser> _users = [];
  final _uuid = Uuid();

  AppUser? get currentUser => _currentUser;
  List<AppUser> get users => List.unmodifiable(_users);
  bool get isLoggedIn => _currentUser != null;
  bool get canEdit => _currentUser?.canEdit ?? false;
  bool get canDelete => _currentUser?.canDelete ?? false;
  bool get canManageUsers => _currentUser?.canManageUsers ?? false;

  AuthProvider() {
    _initDefaultUser();
  }

  void _initDefaultUser() {
    final defaultUser = AppUser(
      id: _uuid.v4(),
      name: 'Alex Morgan',
      email: 'alex@fintracker.app',
      role: UserRole.admin,
    );
    _users = [
      defaultUser,
      AppUser(id: _uuid.v4(), name: 'Sarah Chen', email: 'sarah@fintracker.app', role: UserRole.editor),
      AppUser(id: _uuid.v4(), name: 'James Wilson', email: 'james@fintracker.app', role: UserRole.viewer),
    ];
    _currentUser = defaultUser;
    notifyListeners();
  }

  void switchUser(String userId) {
    try {
      _currentUser = _users.firstWhere((u) => u.id == userId);
      notifyListeners();
    } catch (_) {}
  }

  void addUser(AppUser user) {
    _users.add(user);
    notifyListeners();
  }

  void removeUser(String userId) {
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

  void logout() {
    _currentUser = _users.isEmpty ? null : _users.first;
    notifyListeners();
  }
}





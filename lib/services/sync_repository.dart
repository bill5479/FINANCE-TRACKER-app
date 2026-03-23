abstract class SyncRepository {
  Future<void> syncNow();
  bool get isActive;
  String get statusLabel;
}

class LocalOnlySyncRepository implements SyncRepository {
  @override
  bool get isActive => false;

  @override
  String get statusLabel => 'Local only';

  @override
  Future<void> syncNow() async {
    return;
  }
}

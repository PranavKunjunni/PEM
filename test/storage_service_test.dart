import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pem/controllers/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('clearAllUserData removes auth, profile, and budget data', () async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'token-123',
      'nickname': 'Alice',
      'expense_limit': 2500,
    });

    final storageService = StorageService();

    await storageService.saveToken('token-123');
    await storageService.saveNickname('Alice');
    await storageService.saveBudgetLimit(2500);

    await storageService.clearAllUserData();

    expect(await storageService.getToken(), isNull);
    expect(await storageService.getNickname(), isNull);
    expect(await storageService.getBudgetLimit(), 1000);
  });
}

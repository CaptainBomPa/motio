import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motio_client/models/user.dart';
import 'package:motio_client/services/user_service.dart';

final userServiceProvider = Provider((ref) => UserService());

class UserNotifier extends StateNotifier<User?> {
  final UserService _userService;

  UserNotifier(this._userService) : super(null);

  Future<void> fetchUser() async {
    try {
      final user = await _userService.getUserInfo();
      if (user != null) {
      } else {
      }
      state = user;
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  void clearUser() {
    state = null;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  final userService = ref.read(userServiceProvider);
  return UserNotifier(userService);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motio_client/models/user.dart';
import 'package:motio_client/services/user_service.dart';

final userServiceProvider = Provider((ref) => UserService());

class UserNotifier extends StateNotifier<User?> {
  final UserService _userService;

  UserNotifier(this._userService) : super(null);

  Future<void> fetchUser() async {
    try {
      print('Fetching user info...');
      final user = await _userService.getUserInfo();
      if (user != null) {
        print('User info fetched successfully: ${user.firstName} ${user.lastName}');
      } else {
        print('Failed to fetch user info.');
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

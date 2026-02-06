// defines the abstract contract we must return

import 'package:flutter_application_4/features/users/domain/model/user_model.dart';

abstract class UsersRepository {
  Future<List<UserModel>> getUsers();
}

abstract class NetworkInfoRepository {
  Stream<bool> isConnected();
}

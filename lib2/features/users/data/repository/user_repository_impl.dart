import 'package:flutter_application_4/features/users/data/datasource/user_remote_datasource.dart';
import 'package:flutter_application_4/features/users/domain/model/user_model.dart';
import 'package:flutter_application_4/features/users/domain/repository/user_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDatasource usersRemoteDatasource;

  UsersRepositoryImpl({required this.usersRemoteDatasource});

  @override
  Future<List<UserModel>> getUsers() async {
    return await usersRemoteDatasource.getUsers();
  }
}

class NetworkInfoImpl implements NetworkInfoRepository {
  final IsConnectedRemoteDatasource isConnectedRemoteDatasource;

  NetworkInfoImpl({required this.isConnectedRemoteDatasource});

  @override
  Stream<bool> isConnected() {
    return isConnectedRemoteDatasource.isConnected();
  }
}

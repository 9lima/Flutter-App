// performes network requests
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_4/features/users/domain/model/user_model.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class UsersRemoteDatasource {
  final Dio dio;

  UsersRemoteDatasource({required this.dio});

  Future<List<UserModel>> getUsers() async {
    var result = await dio.get('users');
    return (result.data['users'] as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
  }
}

class IsConnectedRemoteDatasource {
  final Connectivity connectivity;
  final InternetConnectionChecker internetConnectionChecker;

  IsConnectedRemoteDatasource({
    required this.connectivity,
    required this.internetConnectionChecker,
  });

  Stream<bool> isConnected() {
    return internetConnectionChecker.onStatusChange
        .map((result) => result != ConnectivityResult.none)
        .distinct();
  }
}

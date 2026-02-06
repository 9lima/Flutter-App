import 'package:flutter_application_4/core/api/api_client.dart';
import 'package:flutter_application_4/features/users/data/datasource/user_remote_datasource.dart';
import 'package:flutter_application_4/features/users/data/repository/user_repository_impl.dart';
import 'package:flutter_application_4/features/users/domain/repository/user_repository.dart';
import 'package:flutter_application_4/features/users/presentation/bloc/network_info_bloc.dart';
import 'package:flutter_application_4/features/users/presentation/bloc/users_bloc.dart';
import 'package:get_it/get_it.dart';

var getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton(ApiClient());
  getIt.registerSingleton(getIt<ApiClient>().getDio());
  getIt.registerLazySingleton(() => UsersRemoteDatasource(dio: getIt()));
  getIt.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(usersRemoteDatasource: getIt()),
  );
  getIt.registerFactory(() => UsersBloc(usersRepository: getIt()));
  //
  getIt.registerSingleton(ApiClient2());
  getIt.registerSingleton(getIt<ApiClient2>().getChecker());
  getIt.registerSingleton(getIt<ApiClient2>().getConnectivity());
  getIt.registerLazySingleton(
    () => IsConnectedRemoteDatasource(
      connectivity: getIt(),
      internetConnectionChecker: getIt(),
    ),
  );
  getIt.registerLazySingleton<NetworkInfoRepository>(
    () => NetworkInfoImpl(isConnectedRemoteDatasource: getIt()),
  );
  getIt.registerFactory(() => NetworkInfoBloc(networkInfoRepository: getIt()));
}

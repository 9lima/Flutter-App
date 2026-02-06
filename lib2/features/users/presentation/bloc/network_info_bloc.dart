import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_application_4/features/users/domain/repository/user_repository.dart';
import 'package:flutter_application_4/features/users/presentation/bloc/network_info_event.dart';
import 'package:flutter_application_4/features/users/presentation/bloc/network_info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class NetworkInfoBloc extends Bloc<NetworkInfoEvent, NetworkInfoState> {
  final NetworkInfoRepository networkInfoRepository;
  late final StreamSubscription connectivitySubscription;

  NetworkInfoBloc({required this.networkInfoRepository})
    : super(NetworkInfoState.initial()) {
    on<NetworkInfoEvent>(onCheckNetwork);
  }

  Future onCheckNetwork(
    NetworkInfoEvent event,
    Emitter<NetworkInfoState> emit,
  ) async {
    emit(state.copyWith(status: NetworkInfoStatus.wait));
    try {
      connectivitySubscription = networkInfoRepository.isConnected().listen((
        isConnected,
      ) {
        print('Is connected: $isConnected');
        if (isConnected) {
          emit(state.copyWith(status: NetworkInfoStatus.yes));
        }
      });
    } catch (e) {
      emit(
        state.copyWith(
          status: NetworkInfoStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    // It's crucial to cancel the stream subscription to prevent memory leaks
    connectivitySubscription.cancel();
    return super.close();
  }
}

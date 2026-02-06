import 'package:flutter/material.dart';
import 'package:flutter_application_4/core/api/dependency_injection.dart';
import 'package:flutter_application_4/features/users/presentation/bloc/network_info_bloc.dart';
import 'package:flutter_application_4/features/users/presentation/bloc/network_info_state.dart';
import 'package:flutter_application_4/features/users/presentation/bloc/users_bloc.dart';
import 'package:flutter_application_4/features/users/presentation/bloc/users_event.dart';
import 'package:flutter_application_4/features/users/presentation/bloc/users_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // return BlocProvider(
    //   create: (context) => getIt<UsersBloc>()..add(GetUsersEvent()),
    //   child: Scaffold(
    //     appBar: AppBar(title: Text("Users")),
    //     body: BlocBuilder<UsersBloc, UsersState>(
    //       builder: (context, state) {
    //         if (state.status == UsersStatus.loading) {
    //           return Center(child: CircularProgressIndicator());
    //         }
    //         if (state.status == UsersStatus.error) {
    //           return Center(child: Text(state.errorMessage ?? ''));
    //         }
    //         if (state.status == UsersStatus.success) {
    //           return ListView.builder(
    //             itemBuilder: (contex, index) {
    //               return ListTile(
    //                 title: Text(state.users![index].firstName),
    //                 subtitle: Text(state.users![index].email),
    //               );
    //             },
    //             itemCount: state.users?.length ?? 0,
    //           );
    //         }
    //         return Container();
    //       },
    //     ),
    //   ),
    // );
    return BlocProvider(
      create: (context) => getIt<NetworkInfoBloc>(),
      child: MaterialApp(
        title: 'Network Checker Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const NetworkCheckerPage(),
      ),
    );
  }
}

class NetworkCheckerPage extends StatefulWidget {
  const NetworkCheckerPage({super.key});

  @override
  State<NetworkCheckerPage> createState() => _NetworkCheckerPageState();
}

class _NetworkCheckerPageState extends State<NetworkCheckerPage> {
  final NetworkInfoBloc networkInfoBloc = getIt<NetworkInfoBloc>();

  // @override
  // void initState() {
  //   super.initState();
  //   // Listen to the BLoC's state stream
  //   networkInfoBloc.stream.listen((state) {
  //     if (state.status == NetworkInfoStatus.yes) {
  //       toastInfo(msg: "Data connection is available.", status: Status.success);
  //     } else {
  //       toastInfo(
  //         msg: "You are disconnected from the internet.",
  //         status: Status.error,
  //       );
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Connectivity')),
      body: Center(
        child: BlocBuilder<NetworkInfoBloc, NetworkInfoState>(
          builder: (context, state) {
            if (state.status == NetworkInfoStatus.yes) {
              return Center(child: Text("coneccted"));
            } else {
              return Center(child: Text("not coneccted"));
            }
          },
        ),
      ),
    );
  }
}

enum Status { success, error }

void toastInfo({required String msg, required Status status}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: status == Status.success ? Colors.green : Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

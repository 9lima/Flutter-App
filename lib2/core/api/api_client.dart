import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// create an class with method to get instance of dio
class ApiClient {
  Dio getDio() {
    Dio dio = Dio();
    dio.options.baseUrl = 'https://dummyjson.com/';
    return dio;
  }
}

class ApiClient2 {
  Connectivity getConnectivity() {
    Connectivity connectivity = Connectivity();
    return connectivity;
  }

  InternetConnectionChecker getChecker() {
    InternetConnectionChecker internetConnectionChecker =
        InternetConnectionChecker.createInstance(
          addresses: [
            AddressCheckOption(uri: Uri.parse('https://google.com')),
            AddressCheckOption(uri: Uri.parse('https://yahoo.com')),
          ],
        );
    return internetConnectionChecker;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_4/core/api/dependency_injection.dart';
import 'package:flutter_application_4/page/user_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setup();
  runApp(MaterialApp(home: UsersPage()));
}

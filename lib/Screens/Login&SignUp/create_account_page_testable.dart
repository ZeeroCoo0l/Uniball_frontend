import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/Screens/Login&SignUp/create_account_page.dart';

class CreateAccountPageTestable extends CreateAccountPage {
  const CreateAccountPageTestable({super.key});

  @override
  CreateAccountPageState createState() => CreateAccountPageTestableState();
}

class CreateAccountPageTestableState extends CreateAccountPageState {
  TextEditingController get emailController => super.emailController;
  TextEditingController get passwordController => super.passwordController;
  TextEditingController get confirmPasswordController => super.confirmPasswordController;
  TextEditingController get usernameController => super.usernameController;

  @override
  String? validateEmail(String? value) => super.validateEmail(value);
  String? validatePassword(String? value) => super.validatePassword(value);
  String? validateConfirmPassword(String? value) => super.validateConfirmPassword(value);
  String? validateUsername(String? value) => super.validateUsername(value);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
} 
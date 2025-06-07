import 'dart:io';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';

///
/// Denna klassen sköter inloggning med email + lösenord. När Supabase har
/// godkänt nya användare, läggs de sedan till i backend-databasen.
///
class EmailLoginService {
  BackendUserCommunication backend = BackendUserCommunication();

  Future<bool> signUpNewUser(String email, String password, String username) async {
    final result = await hasInternetConnection();
    if(!result){
      return false;
    }

    AuthResponse response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    User? respUser = response.user;
    if (respUser != null) {
      UserClient user = UserClient(
        respUser.id,
        username,
        respUser.email ?? "",
        respUser.phone,
        Position.NOPOSITION,
        null,
        null,
        null,
        null
      );
      backend.createUser(user, respUser.id);
    } else {
      return false;
    }
    return true;
  }

  Future<bool> logIn(String email, String password) async {
    final result = await hasInternetConnection();
    if(!result){
      return false;
    }

    try {
      AuthResponse response = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      
      debugPrint('Login response: ${response.toString()}');
      debugPrint('Email confirmed at: ${response.user?.emailConfirmedAt}');
      
      if (response.user?.emailConfirmedAt == null) {
        debugPrint('Email not verified, throwing error');
        throw Exception('email_not_verified');
      }

      return true;
    } on AuthException catch (e) {
      debugPrint('AuthException during login: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Error during login: ${e.toString()}');
      rethrow;
    }
  }

  Future<bool> hasInternetConnection()async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty) {
        debugPrint(
          'No internet connection was found. You may need to allow internet permission on your device.',
        );
        return false;
      }
      return true;
    } on Exception catch (e) {
      debugPrint(
        'No internet connection was found. You may need to allow internet permission on your device.',
      );
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> signOut() async {
    await Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
    return true;
  }

  Future<void> resetPassword(String email) async {
    await Supabase.instance.client.auth.signInWithOtp(
      email:email,
    );
  }

  Future<bool> logInOTP(String email, String otp) async {
    final result = await hasInternetConnection();
    if(!result){
      return false;
    }

    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );
      
      debugPrint(response.toString());
      return true;
    } catch (e) {
      debugPrint('OTP verification failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> setNewPassword(String password) async{
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: password),
    );

    return true;
  }

  Future<bool> resendVerificationEmail(String? email) async {
    if (email == null || email.isEmpty) {
      return false;
    }

    try {
      await Supabase.instance.client.auth.resend(
        email: email,
        type: OtpType.signup,
      );
      return true;
    } on AuthException {
      return false;
    } catch (e) {
      return false;
    }
  }
}

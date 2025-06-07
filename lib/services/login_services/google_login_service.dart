import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';

/// Denna tjänst sköter inloggning med Google Provider. När inloggningen är godkänd, kommer 
/// användaren läggas till i backend-databasen. 

class GoogleLoginService {
  BackendUserCommunication backend = BackendUserCommunication();

  Future<bool> nativeGoogleSignIn() async {

    final result = await hasInternetConnection();
    if(!result){
      return false;
    }

    const webClientId =
        'ID_TO_WEB_CLIENT_IN_GOOGLE_CONSOLE';

    const iosClientId =
        'ID_TO_IOS_CLIENT_IN_GOOGLE_CONSOLE';


    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: Platform.isIOS ? iosClientId : null,//androidClientID,
      serverClientId: webClientId,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null){
      return false;
    }
    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access token found';
    }
    if (idToken == null) {
      throw 'No Id token found';
    }

    final response = await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    User? respUser = response.user;
    if (respUser != null) {
      UserClient? existingUser = await backend.getUser(respUser.id);

      if (existingUser == null) {
        UserClient newUser = UserClient(
          respUser.id,
          "default", 
          respUser.email ?? "",
          respUser.phone ?? "",
          Position.NOPOSITION,
          "",
          "",
          "",
          null,
        );

        final String? authToken = Supabase.instance.client.auth.currentSession?.accessToken;
        if (authToken != null) {
          await backend.createUser(newUser, authToken);
        } else {
        
          debugPrint('Error: Auth token was null after Google Sign-In with Supabase.');
          return false; 
        }
      } else {
       
        debugPrint('User ${respUser.id} already exists in backend. Treating as login.');
      }
    } else {
      return false;
    }

    return true;
  }

  Future<bool> hasInternetConnection()async{
    //Check Internet-access
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
    await Supabase.instance.client.auth.signOut();
    return true;
  }
}

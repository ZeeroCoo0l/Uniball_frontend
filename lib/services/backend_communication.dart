import 'dart:async';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BackendCommunication {
  final _baseURL = 'URL_TO_BACKEND_SERVICE';

  Future<String?> getCurrentUserID() async {
    final currentUserID = Supabase.instance.client.auth.currentUser;
    return currentUserID?.id;
  }

  Future<String?> getCurrentUserToken() async {
    var currentSession = await Supabase.instance.client.auth.currentSession;
    if(currentSession == null){
      print("Current session was not found.");
      return null;
    }
    
    if(currentSession.isExpired){
      await Supabase.instance.client.auth.refreshSession();
    }
    final currentUserToken = await Supabase.instance.client.auth.currentSession?.accessToken; 

    
    return currentUserToken;
  }

  // PRIVATE
  Future<http.Response> makeGetRequest(
    String command,
    String userFolder,
    String authToken,
  ) async {
    try {
      authToken = await getCurrentUserToken() ??"";
      debugPrint('TEST: ' + authToken);
      final String path = userFolder + (command.startsWith('/') ? command : '/$command');
      final url = _baseURL + path;
      print('Making GET request to: $url');
      http.Response response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': 'Bearer $authToken',
            },
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw 'SERVER ERROR: ${response.statusCode} - ${response.body}';
      } else {
        return response;
      }
    } on TimeoutException {
      throw 'NETWORK ERROR: Request timed out. Please try again later.';
    } on Exception catch (e) {
      throw 'NETWORK ERROR: $e';
    }
  }

  Future<http.Response> makePostRequest(
    String json,
    String authToken,
    String command,
    String userFolder,
  ) async {
    authToken = await getCurrentUserToken() ??"";
    try {
      final String path = userFolder + (command.startsWith('/') ? command : '/$command');
      final url = _baseURL + path;
      http.Response response = await http.post(
        Uri.parse(url),
        body: json,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode != 200) {
        throw 'SERVER ERROR: ${response.statusCode} - ${response.body}';
      } else {
        return response;
      }
    } on TimeoutException {
      throw 'NETWORK ERROR: Request timed out. Please try again later.';
    } on FormatException {
      throw 'FORMAT ERROR: Url was not formatted correct during Post-request.';
    } on Exception catch (e) {
      throw 'NETWORK ERROR: $e';
    }
  }

  Future<http.Response> makePostRequestWithPathVariable(
    String json,
    String authToken,
    String command,
    String userFolder,
    String pathVariable
  ) async {
    try {
      final String path = userFolder + (command.startsWith('/') ? command : '/$command') + (pathVariable.startsWith("/") ? pathVariable : '/$pathVariable');
      final url = _baseURL + path;
      http.Response response = await http.post(
        Uri.parse(url),
        body: json,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode != 200) {
        throw 'SERVER ERROR: ${response.statusCode} - ${response.body}';
      } else {
        return response;
      }
    } on TimeoutException {
      throw 'NETWORK ERROR: Request timed out. Please try again later.';
    } on FormatException {
      throw 'FORMAT ERROR: Url was not formatted correct during Post-request.';
    } on Exception catch (e) {
      throw 'NETWORK ERROR: $e';
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_communication.dart';

/// Denna tjänsten sköter kommunikationen mellan Flutter och Springboot.
/// Den används i båda login_services för att automatiskt lägga till användaren i backend.
/// OBS! Denna klass ska specifikt användas för användaren (UserClient).
class BackendUserCommunication extends BackendCommunication {
  final _userFolder = '/user';
  final _profileFolder = "profilepictures";

  Future<String> uploadProfilePic(File? file) async {
    if (file == null) {
      return "";
    }

    String currentUserId = await getCurrentUserID() ?? "";
    if (currentUserId.isEmpty) return "";

    StorageFileApi fileApi = Supabase.instance.client.storage.from(
      _profileFolder,
    );

    String path = "$currentUserId/current.${file.path.split(".").last}";

    String result = await fileApi.upload(
      path,
      file,
      fileOptions: FileOptions(upsert: true, cacheControl: 'public, max-age=1'),
    );
    //Returnera URL med cache-buster (timestamp)
    final publicUrl = fileApi.getPublicUrl(path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    if (result.isNotEmpty) {
      var path1 = "$currentUserId/current.png";
      if (await fileApi.exists(path1) && path != path1) {
        fileApi.remove(["$currentUserId/current.png"]);
      }
      var path2 = "$currentUserId/current.jpeg";
      if (await fileApi.exists(path2) && path != path2) {
        fileApi.remove(["$currentUserId/current.jpeg"]);
      }
      var path3 = "$currentUserId/current.jpg";
      if (await fileApi.exists(path3) && path != path3) {
        fileApi.remove(["$currentUserId/current.jpg"]);
      }
    }

    return "$publicUrl?t=$timestamp";
  }

  Future<String> getProfilePic(String path) async {
    StorageFileApi fileApi = Supabase.instance.client.storage.from(
      _profileFolder,
    );
    String urlString = fileApi.getPublicUrl(path);
    print("STRING: " + urlString);

    return urlString;
  }

  Future<UserClient?> getCurrentUser() async {
    String? id = await getCurrentUserID(); // get the auth ID
    if (id == null) return null; // No logged-in user
    return await getUser(id); // Fetch the full UserClient from backend
  }

  Future<String> getAllUsers() async {
    final command = "all";
    http.Response response = await makeGetRequest(
      command,
      _userFolder,
      await getCurrentUserToken() ?? "",
    );
    return response.body;
  }

  // CREATE
  Future<void> createUser(UserClient user, String? authToken) async {
    String json = jsonEncode(user.toJson());
    if (authToken == null) {
      throw 'ID ERROR: No current user found when creating new user.';
    }
    String command = "addUser";

    http.Response response = await makePostRequest(
      json,
      authToken,
      command,
      _userFolder,
    );

    debugPrint("Successfully added player to backend-database");
  }

  // READ
  Future<UserClient?> getUser(String? userID) async {
    if (userID == null || userID.isEmpty) {
      return null;
    }

    try {
      String command = "/all/$userID";
      final response = await makeGetRequest(
        command,
        _userFolder,
        await getCurrentUserToken() ?? "",
      );

      final decoded = utf8.decode(response.bodyBytes);
      final jsonDecoded = jsonDecode(decoded);

      if (jsonDecoded != null) {
        UserClient? user = UserClient.fromJson(jsonDecoded);
        return user;
      }
      return null;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // UPDATE
  Future<bool> updateUser(String? userID, UserClient? newUser) async {
    if (userID == null || userID.isEmpty) {
      debugPrint("userID is null or empty when trying to update the user.");
      return false;
    }
    if (newUser == null) {
      debugPrint("User is null when trying to update it.");
      return false;
    }

    String json = jsonEncode(newUser.toJson());
    try {
      final command = "updateUser";
      final response = await makePostRequest(
        json,
        userID,
        command,
        _userFolder,
      );
      debugPrint("Successfully updated the user");
      debugPrint(json);
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }

    return true;
  }

  // DELETE
  Future<bool> removeUser(UserClient? user) async {
    if (user == null) {
      debugPrint("user to be deleted was null");
      return false;
    }

    final command = "deleteUser";
    String json = jsonEncode(user.toJson());
    try {
      final response = await makePostRequest(
        json,
        user.id,
        command,
        _userFolder,
      );
      debugPrint("Successfully removed the user");

      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}


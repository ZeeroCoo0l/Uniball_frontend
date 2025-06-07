import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:uniball_frontend_2/entities/team.dart';
import 'package:uniball_frontend_2/services/backend_communication.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';

class BackendTeamCommunication extends BackendCommunication {
  final _userFolder = "/team";

  Future<bool> isCurrentUserPartOfTeam() async {
    final command = "isPartOfTeam";
    String authToken = await getCurrentUserToken() ?? "";
    http.Response response = await makeGetRequest(
      command,
      _userFolder,
      authToken,
    );

    return bool.parse(response.body);
  }

  Future<String> getAll() async {
    final command = "all";
    String authToken = await getCurrentUserToken() ?? "";
    http.Response response = await makeGetRequest(
      command,
      _userFolder,
      authToken,
    );
    return utf8.decode(response.bodyBytes);
  }

  Future<Team?> getTeamByName(String name) async {
    String json = await getAll();
    List<dynamic> jsonList = jsonDecode(json);

    for (var item in jsonList) {
      Team team = Team.fromJson(item);
      if (team.name == name) {
        return team;
      }
    }
    return null;
  }

  //CREATE
  Future<bool> createTeam(Team team, String? authToken) async {
    String json = jsonEncode(team.toJson());
    if (authToken == null) {
      debugPrint(
        "ID ERROR: No user ID found when creating new team. It's needed for checking authorization.",
      );
      return false;
    }

    String command = "add";
    http.Response response = await makePostRequest(
      json,
      authToken,
      command,
      _userFolder,
    );

    debugPrint("Successfully added team to backend-database");
    return true;
  }

  //READ
  Future<Team?> getTeam(String? teamId) async {
    if (teamId == null || teamId.isEmpty) {
      return null;
    }
    try {
      String command = "all/$teamId";
      String authToken = await getCurrentUserToken() ?? "";
      final response = await makeGetRequest(command, _userFolder, authToken);
      final decoded = utf8.decode(response.bodyBytes);
      final jsonDecoded = jsonDecode(decoded);
      if (jsonDecoded != null) {
        Team? team = Team.fromJson(jsonDecoded);
        return team;
      }
      return null;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // UPDATE
  Future<bool> updateTeam(String? teamId, Team updatedTeam) async {
    if (teamId == null || teamId.isEmpty) {
      debugPrint("teamID is null or empty when trying to update the team.");
      return false;
    }

    String json = jsonEncode(updatedTeam.toJson());
    try {
      final command = "updateTeam";
      final response = await makePostRequest(
        json,
        await getCurrentUserToken() ?? "",
        command,
        _userFolder,
      );
      debugPrint("Successfully updated the team");
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
    return true;
  }

  // Add admin to team
  Future<bool> addAdminToTeam(Team? team, UserClient? player) async {
    if (team == null) {
      print("Could not add admin to team, team was not found");
      return false;
    }
    if (player == null) {
      print("Could not add admin to team, player was not found");
      return false;
    }

    final command = "addAdmin";
    String jsonPlayer = jsonEncode(player.toJson());

    try {
      String authToken = await getCurrentUserToken() ?? "";
      final response = await makePostRequestWithPathVariable(
        jsonPlayer,
        authToken,
        command,
        _userFolder,
        team.id,
      );
      print(response.statusCode.toString() + " - " + response.body.toString());
      print("Successfully added admin (${player.id}) to team (${team.id})");
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
    return true;
  }

  // Add admin to team
  Future<bool> removeAdminFromTeam(Team? team, UserClient? player) async {
    if (team == null) {
      print("Could not remove admin from team, team was not found");
      return false;
    }
    if (player == null) {
      print("Could not remove admin from team, player was not found");
      return false;
    }

    final command = "removeAdmin";
    String jsonPlayer = jsonEncode(player.toJson());

    try {
      String authToken = await getCurrentUserToken() ?? "";
      final response = await makePostRequestWithPathVariable(
        jsonPlayer,
        authToken,
        command,
        _userFolder,
        team.id,
      );
      debugPrint(
        'TEST backend team communication: ' + response.body.toString(),
      );
      if (response.body.toString().startsWith(
        'Could not remove admin from team',
      )) {
        return false;
      }
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
    return true;
  }

  // REMOVE
  Future<bool> removeTeam(Team? team) async {
    if (team == null) {
      debugPrint("user to be deleted was null");
      return false;
    }

    final command = "remove";
    String json = jsonEncode(team.toJson());
    try {
      String authToken = await getCurrentUserToken() ?? "";
      final response = await makePostRequest(
        json, 
        authToken, //team.id,
        command,
        _userFolder,
      );
      debugPrint("Successfully removed the team");

      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Add player to team
  Future<bool> addPlayerToTeam(Team? team, UserClient? player) async {
    if (team == null) {
      print("Could not add player to team, team was not found");
      return false;
    }
    if (player == null) {
      print("Could not add player to team, player was not found");
      return false;
    }

    final command = "addPlayer";
    String jsonPlayer = jsonEncode(player.toJson());

    try {
      String authToken = await getCurrentUserToken() ?? "";
      final response = await makePostRequestWithPathVariable(
        jsonPlayer,
        authToken,
        command,
        _userFolder,
        team.id,
      );
      print(response.statusCode.toString() + " - " + response.body.toString());
      print("Successfully added player (${player.id}) to team (${team.id})");
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
    return true;
  }

  // Remove player from team
  Future<bool> removePlayerFromTeam(Team? team, UserClient? player) async {
    if (team == null) {
      print("Could not remove player from team, team was not found");
      return false;
    }
    if (player == null) {
      print("Could not remove player from team, player was not found");
      return false;
    }

    final command = "removePlayer";
    String jsonPlayer = jsonEncode(player.toJson());
    try {
      String authToken = await getCurrentUserToken() ?? "";
      final response = await makePostRequestWithPathVariable(
        jsonPlayer,
        authToken,
        command,
        _userFolder,
        team.id,
      );
      if (response.body.toString().startsWith(
        'Could not remove admin from team',
      )) {
        return false;
      }
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
    return true;
  }

  Future<bool> isAdminForTeam(UserClient? user, String teamId) async {
    if (user == null) {
      print("Could not check is player was admin because user was null.");
      return false;
    }
    if (teamId.isEmpty || int.tryParse(teamId) == null) {
      print("Could not check if player was admin because team_id was invalid.");
      return false;
    }

    final command = "isAdminOfTeam";
    String jsonPlayer = jsonEncode(user.toJson());
    try {
      String authToken = await getCurrentUserToken() ?? "";
      final response = await makePostRequestWithPathVariable(
        jsonPlayer,
        authToken,
        command,
        _userFolder,
        teamId,
      );
      print("Response ${response.statusCode}: ${response.body}.");
      if (response.body.toLowerCase() == "false") {
        return false;
      } else {
        return true;
      }
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }
}

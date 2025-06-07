import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:uniball_frontend_2/entities/award.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_communication.dart';

class BackendPracticeCommunication extends BackendCommunication {
  final _userFolder = "/practice";
  final _awardFolder = "/awards";

  Future<String> getAllpractices() async {
    final command = "all";
    String? authToken = await getCurrentUserToken();
    http.Response response = await makeGetRequest(
      command,
      _userFolder,
      authToken ?? "",
    );
    return response.body;
  }

  // Create
  Future<void> createPractice(Practice practice) async {
    String? authToken = await getCurrentUserToken();
    String json = jsonEncode(practice.toJson());
    if (authToken == null) {
      throw "ID ERROR: No user ID found when creating new practice. It's needed for checking authorization.";
    }
    String command = "add";
    debugPrint(json);

    http.Response response = await makePostRequest(
      json,
      authToken,
      command,
      _userFolder,
    );
    debugPrint("Successfully added practice to backend-database");
  }

  // Read
  Future<Practice?> getPractice(String? practiceID) async {
    if (practiceID == null || practiceID.isEmpty) {
      return null;
    }
    String? authToken = await getCurrentUserToken();
    try {
      String command = "all/$practiceID";
      final response = await makeGetRequest(
        command,
        _userFolder,
        authToken ?? "",
      );
      final decoded = utf8.decode(response.bodyBytes);
      final jsonDecoded = jsonDecode(decoded);
      if (jsonDecoded != null) {
        Practice? practice = Practice.fromJson(jsonDecoded);
        return practice;
      }
      return null;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<List<Practice>?> getPracticeForTeam(String? teamId) async {
    if (teamId == null) {
      return null;
    }
    String? authToken = await getCurrentUserToken();
    List<Practice> practices = [];
    String command = "/team/$teamId";
    final response = await makeGetRequest(
      command,
      _userFolder,
      authToken ?? "",
    );
    final decoded = utf8.decode(response.bodyBytes);
    final jsonDecoded = jsonDecode(decoded);
    if (jsonDecoded != null) {
      for (dynamic jsonP in jsonDecoded) {
        Practice practice = Practice.fromJson(jsonP);
        practices.add(practice);
      }
    }
    return practices;
  }

  // Update
  Future<bool> updatePractice(Practice? newPractice) async {
    String? authToken = await getCurrentUserToken();
    if (authToken == null || authToken.isEmpty) {
      debugPrint(
        "practiceID is null or empty when trying to update the practice-event.",
      );
      return false;
    }
    if (newPractice == null) {
      debugPrint("Practice is null when trying to update it.");
      return false;
    }

    String json = jsonEncode(newPractice.toJson());
    try {
      final command = "updateEvent";
      final response = await makePostRequest(
        json,
        authToken,
        command,
        _userFolder,
      );
      debugPrint("Successfully updated the practice-event");
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
    return true;
  }

  Future<bool> toggleCancelledPractice(Practice practice)async{
    String? authToken = await getCurrentUserToken();
    if (authToken == null || authToken.isEmpty) {
      debugPrint(
        "practiceID is null or empty when trying to cancel the practice-event.",
      );
      return false;
    }
    if (practice == null) {
      debugPrint("Practice is null when trying to cancel it.");
      return false;
    }
    String json = jsonEncode(practice.toJson());
    try{
      final command = "toggleCancel";
      final response = await makePostRequest(json, authToken, command, _userFolder);
      debugPrint("Successfully cancelled the practice with id:${practice.id}");
    }
    on Exception catch (e){
      debugPrint(e.toString());
      return false;
    }
    return true;
  }

  // Update information
  Future<bool> updateInformation(Practice? updatedPractice) async {
    String? authToken = await getCurrentUserToken();
    if (authToken == null || authToken.isEmpty) {
      debugPrint(
        "practiceID is null or empty when trying to update the information for practice-event.",
      );
      return false;
    }
    if (updatedPractice == null) {
      debugPrint("Practice is null when trying to update its information.");
      return false;
    }

    dynamic temp = {
      'practiceId': updatedPractice.id.toString(),
      'information': updatedPractice.information ?? '',
    };
    String json = jsonEncode(temp);
    try {
      final command = "updateInformation";
      final response = await makePostRequest(
        json,
        authToken,
        command,
        _userFolder,
      );
      debugPrint("Successfully updated the information t practice-event");
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
    return true;
  }

  // Delete
  Future<bool> removePractice(Practice? practice) async {
    if (practice == null) {
      debugPrint("Practice to be deleted was null");
      return false;
    }
    String? authToken = await getCurrentUserToken();

    final command = "remove";
    String json = jsonEncode(practice.toJson());
    try {
      final response = await makePostRequest(
        json, 
        authToken ?? "", 
        command,
        _userFolder,
      );
      debugPrint("Successfully removed the practice-event");

      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // ADD ATTENDEE
  Future<bool> addAttendee(String practiceId, UserClient user) async {
    String? authId = await getCurrentUserToken();
    if (authId == null) {
      debugPrint("No auth token found.");
      return false;
    }

    String command = "addAttendee/$practiceId";
    String json = jsonEncode(user.toJson());

    try {
      final response = await makePostRequest(
        json,
        authId,
        command,
        _userFolder,
      );
      if (response.statusCode == 200) {
        debugPrint("Successfully added attendee to practice $practiceId");
        return true;
      } else {
        debugPrint(
          "Failed to add attendee. Status: ${response.statusCode}, Body: ${response.body}",
        );
        return false;
      }
    } catch (e) {
      debugPrint("Error adding attendee: $e");
      return false;
    }
  }

  // REMOVE ATTENDEE
  Future<bool> removeAttendee(String practiceId, UserClient user) async {
    String? authId = await getCurrentUserToken();
    if (authId == null) {
      debugPrint("No auth token found.");
      return false;
    }

    String command = "removeAttendee/$practiceId";
    String json = jsonEncode(user.toJson());

    try {
      final response = await makePostRequest(
        json,
        authId,
        command,
        _userFolder,
      );

      if (response.statusCode == 200) {
        debugPrint("Successfully removed attendee from practice $practiceId");
        return true;
      } else {
        debugPrint(
          "Failed to remove attendee. Status: ${response.statusCode}, Body: ${response.body}",
        );
        return false;
      }
    } catch (e) {
      debugPrint("Error removing attendee: $e");
      return false;
    }
  }

  // CREATE AWARD
  Future<void> createAward(Award award) async {
    String? authToken = await getCurrentUserToken();
    String json = jsonEncode(award.toJson());
    if (authToken == null) {
      throw "ID ERROR: No user ID found when creating new practice. It's needed for checking authorization.";
    }
    String command = "add";

    http.Response response = await makePostRequest(
      json,
      authToken,
      command,
      _awardFolder,
    );
    debugPrint("Successfully added player to backend-database");
  }

  // READ AWARD
  Future<Practice?> getAward(String? awardID) async {
    if (awardID == null || awardID.isEmpty) {
      return null;
    }
    String? authToken = await getCurrentUserToken();
    try {
      String command = "/all/$awardID";
      final response = await makeGetRequest(
        command,
        _awardFolder,
        authToken ?? "",
      );

      final decoded = utf8.decode(response.bodyBytes);
      final jsonDecoded = jsonDecode(decoded);
      if (jsonDecoded != null) {
        Practice? practice = Practice.fromJson(jsonDecoded);
        return practice;
      }
      return null;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // GET AWARDS FROM PRACTICE
  Future<List<Award>?> getAwardsFromPractice(String? practiceId) async {
    if (practiceId == null || practiceId.isEmpty) {
      return null;
    }
    String? authToken = await getCurrentUserToken();
    List<Award> awards = [];

    String command = "/award/$practiceId";

    final response = await makeGetRequest(
      command,
      _userFolder,
      authToken ?? "",
    );

    if (response.statusCode == 200) {

      final decoded = utf8.decode(response.bodyBytes);
      print(
        "DEBUG: JSON response for awards from /practice/award/$practiceId: $decoded",
      );

      final List<dynamic> jsonDecodedList = jsonDecode(decoded);
    
      for (dynamic jsonAward in jsonDecodedList) {
        if (jsonAward is Map<String, dynamic>) {
          Award award = Award.fromJson(jsonAward);
          awards.add(award);
        }
      }
    } else {
      debugPrint(
        "Failed to load awards for the practice $practiceId. status: ${response.statusCode}, Body: ${response.body}",
      );
      return null;
    }

   
    return awards;
  }

  // GET CURRENT WINNERS
  Future<List<UserClient>?> GetCurrentWinners(String? awardId) async {
    if (awardId == null || awardId.isEmpty) {
      return null;
    }
    String? authToken = await getCurrentUserToken();
    if (authToken == null || authToken.isEmpty) {
      debugPrint(
        "Auth token is null or empty when trying to get current winners.",
      );
      return null;
    }

    List<UserClient> winners = [];

    String command = "/award/getCurrentWinners/$awardId";

    final response = await makeGetRequest(
      command,
      _awardFolder,
      authToken ?? "",
    );

    if (response.statusCode == 200) {
      String body = response.body;
      final List<dynamic> jsonDecodedList = jsonDecode(body);

      for (dynamic userC in jsonDecodedList) {
        UserClient uC = UserClient.fromJson(userC);
        winners.add(uC);
      }
      return winners;
    } else {
      debugPrint(
        "Failed to load winners of award for the award with id $awardId.Status ${response.statusCode}, body ${response.body}",
      );
      return null;
    }
  }

  // UPDATE AWARD
  Future<bool> updateAward(Award? newAward) async {
    String? authToken = await getCurrentUserToken();
    if (authToken == null || authToken.isEmpty) {
      debugPrint(
        "practiceID is null or empty when trying to update the practice-event.",
      );
      return false;
    }
    if (newAward == null) {
      debugPrint("Practice is null when trying to update it.");
      return false;
    }

    String json = jsonEncode(newAward.toJson());
    try {
      final command = "update";
      final response = await makePostRequest(
        json,
        authToken,
        command,
        _awardFolder,
      );
      debugPrint("Successfully updated the practice-event");
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
    return true;
  }

  // DELETE AWARD
  Future<bool> removeAward(Award? award) async {
    if (award == null) {
      debugPrint("Practice to be deleted was null");
      return false;
    }
    String? authToken = await getCurrentUserToken();

    final command = "remove";
    String json = jsonEncode(award.toJson());
    try {
      final response = await makePostRequest(
        json, 
        authToken ?? "", 
        command,
        _awardFolder,
      );
      debugPrint("Successfully removed the practice-event");

      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // HAS VOTED
  Future<bool> hasVoted(int awardId, String userId) async {
    String? authToken = await getCurrentUserToken();

    if (authToken == null) {
      debugPrint("User token is null, cannot check voting status.");
      return false;
    }

    final command = '/hasVoted/$awardId/$userId';

    try {
      final response = await makeGetRequest(command, _awardFolder, authToken);

      final responseBody = response.body.trim().toLowerCase();
      return responseBody == 'true';
    } catch (e) {
      debugPrint('Error checking if user has voted: $e');
      return false;
    }
  }

  // GET CURRENT RANK
  Future<List<UserClient>> getCurrentRank(int awardId) async {
    String? authToken = await getCurrentUserToken();

    if (authToken == null) {
      debugPrint("Token is null, cannot fetch current rank.");
      return [];
    }

    final command = '/getCurrentRank/$awardId';

    try {
      final response = await makeGetRequest(command, _awardFolder, authToken);
      final decoded = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decoded);
      final rankedUsers =
          jsonList.map((json) => UserClient.fromJson(json)).toList();

      return rankedUsers.cast<UserClient>();
    } catch (e) {
      debugPrint('Error fetching current rank: $e');
      return [];
    }
  }

  // ADD TO ALREADY VOTED
  Future<bool> addToAlreadyVoted(int awardId, UserClient user) async {
    String? authToken = await getCurrentUserToken();

    if (authToken == null) {
      debugPrint("User token is null, cannot add to already voted.");
      return false;
    }

    final command = '/addToAlreadyVoted/$awardId';

    try {
      String json = jsonEncode(user.toJson());

      final response = await makePostRequest(
        json,
        authToken,
        command,
        _awardFolder,
      );

      if (response.statusCode == 200) {
        debugPrint(
          'Successfully added user to already voted: ${response.body}',
        );
        return true;
      } else {
        debugPrint('Failed to add user to already voted: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error during addToAlreadyVoted: $e');
      return false;
    }
  }

  // REMOVE FROM ALREADY VOTED

  // UPDATE VOTE
  Future<String> updateVote({
    required UserClient playerToVoteOn,
    required int awardId,
    required bool votedFor,
  }) async {
    String? authToken = await getCurrentUserToken();

    if (authToken == null) {
      debugPrint("Auth token is null. Cannot update vote.");
      return "Failed: no auth token";
    }

    final command = '/updateVote/$awardId/$votedFor';
    final jsonBody = jsonEncode(playerToVoteOn.toJson());

    try {
      final response = await makePostRequest(
        jsonBody,
        authToken,
        command,
        _awardFolder,
      );

      return response.body; 
    } catch (e) {
      debugPrint("Error updating vote: $e");
      return "Failed to update vote";
    }
  }

  //GET TOP 3 IN TEAM
  Future<List<UserClient>?> GetTop3InTeam(int teamId, String awardType) async {
    String? authToken = await getCurrentUserToken();

    if (authToken == null) {
      debugPrint("User token is null, cannot get top 3.");
      return null;
    }

    final command = '/getTop3/$awardType/$teamId';

    final response = await makeGetRequest(command, _awardFolder, authToken);

    if (response.statusCode == 200) {
      String body = response.body;
      final decoded = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonDecodedList = jsonDecode(decoded);
      List<UserClient> topUsers = [];
      for (dynamic jsonUser in jsonDecodedList) {
        if (jsonUser is Map<String, dynamic>) {
          topUsers.add(UserClient.fromJson(jsonUser));
        }
      }
      return topUsers;
    } else {
      debugPrint(
        "Failed to load top 3 for team $teamId and award type $awardType. Status: ${response.statusCode}, Body: ${response.body}",
      );
      return null;
    }
  }

  //CloseVote
  Future<bool> closeVote(int awardId) async {
    String? authToken = await getCurrentUserToken();
    if (awardId == null) {
      debugPrint("Award to close was null");
      return false;
    }

    if (authToken == null) {
      debugPrint("User token is null, Cannot close Vote");
      return false;
    }

    final command = '/closeVote/$awardId';
    try {
      final response = await makeGetRequest(command, _awardFolder, authToken);

      if (response.body == 200) {
        debugPrint('Successfully closed vote: ${response.body}');
        return true;
      } else {
        debugPrint('Failed to close vote: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error during closeVote: $e');
      return false;
    }
  }

  
}

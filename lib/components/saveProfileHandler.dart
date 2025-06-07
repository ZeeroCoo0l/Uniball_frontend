import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';
import 'package:uniball_frontend_2/services/backend_team_communication.dart';
import 'package:uniball_frontend_2/entities/team.dart';

class SaveProfileHandler {
  final BuildContext context;
  final TextEditingController usernameController;
  final TextEditingController bioController;
  final backendUser = BackendUserCommunication();
  final backendTeam = BackendTeamCommunication();
  final Position selectedPosition;
  final dynamic profileImage;

  SaveProfileHandler({
    required this.context,
    required this.usernameController,
    required this.bioController,
    required backendUser,
    required backendTeam,
    required this.selectedPosition,
    required this.profileImage,
  });

  Future<void> saveProfile() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    UserClient? currentUser = await backendUser.getCurrentUser();
    if (currentUser == null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Inloggad användare kunde inte identifieras.")),
      );
      return;
    }

    String userId = currentUser.id;

    String filePathToProfilePicture = await backendUser.uploadProfilePic(
      profileImage,
    );

    final updatedUser = UserClient(
      userId,
      usernameController.text.isEmpty
          ? currentUser.name
          : usernameController.text,
      currentUser.email,
      currentUser.phone,
      selectedPosition,
      bioController.text.isEmpty ? currentUser.description : bioController.text,
      filePathToProfilePicture.isEmpty
          ? currentUser.profilePic
          : filePathToProfilePicture,
      currentUser.teamId,
      currentUser.awards,
    );

    final success = await backendUser.updateUser(userId, updatedUser);
    Team? currentTeam = await backendTeam.getTeam(updatedUser.teamId);

    if (currentTeam == null) return;

    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Sparat"),
          content: Text("Dina profiländringar har sparats."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'username': updatedUser.name,
                  'email': updatedUser.email,
                  'bio': updatedUser.description,
                  'favoritePosition': updatedUser.favoritePosition,
                  'profilePic': updatedUser.profilePic,
                  'teamName': currentTeam.name,
                  'teamId': updatedUser.teamId,
                });
                Navigator.pushNamed(context, '/profilepageshort');
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Kunde inte spara ändringar. Försök igen.")),
      );
    }
  }
}

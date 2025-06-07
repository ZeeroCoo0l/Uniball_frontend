import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class DeleteAccountHandler {
  final BuildContext context;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController usernameConfirmController;
  final TextEditingController emailConfirmController;
  final VoidCallback onDeleteSuccess;
  final void Function(bool) onToggleDeleting; // hanterar _isDeleting
  final backendUser = BackendUserCommunication();

  DeleteAccountHandler({
    required this.context,
    required this.usernameController,
    required this.emailController,
    required this.usernameConfirmController,
    required this.emailConfirmController,
    required this.onDeleteSuccess,
    required this.onToggleDeleting,
  });

  void startAccountDeletionFlow() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Bekräfta din identitet"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Skriv in ditt användarnamn och e-postadress för att bekräfta."),
            SizedBox(height: 10),
            TextField(
              controller: usernameConfirmController,
              decoration: InputDecoration(labelText: "Användarnamn"),
            ),
            TextField(
              controller: emailConfirmController,
              decoration: InputDecoration(labelText: "E-postadress"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Avbryt"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Fortsätt"),
            onPressed: () {
              final inputUsername = usernameConfirmController.text.trim();
              final inputEmail = emailConfirmController.text.trim();

              if (inputUsername == usernameController.text.trim() &&
                  inputEmail == emailController.text.trim()) {
                Navigator.of(context).pop();
                _confirmFinalDelete();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Uppgifterna stämmer inte.")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmFinalDelete() async {
    UserClient? currentUser = await backendUser.getCurrentUser();

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ingen användare inloggad.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Säker?"),
        content: Text("Detta raderar ditt konto permanent. Fortsätta?"),
        actions: [
          TextButton(
            child: Text("Avbryt"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Ja, ta bort", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(context).pop();
              onToggleDeleting(true);

              final success = await BackendUserCommunication().removeUser(currentUser);

              onToggleDeleting(false);

              if (success) {
                await Supabase.instance.client.auth.signOut();

                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Ditt konto har tagits bort.")),
                    );
                  });
                  onDeleteSuccess();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Det gick inte att ta bort kontot.")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
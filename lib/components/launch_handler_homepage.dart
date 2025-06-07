import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/Screens/homepage.dart';
import 'package:uniball_frontend_2/Screens/homepage_admin.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_team_communication.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';

class LaunchHandlerHomepage extends StatefulWidget {
  const LaunchHandlerHomepage({super.key});

  @override
  State<LaunchHandlerHomepage> createState() => _LaunchHandlerHomepageState();
}

class _LaunchHandlerHomepageState extends State<LaunchHandlerHomepage> {
  Widget? _widgetToLoad;

  @override
  void initState() {
    super.initState();
    _launchPage();
  }

  Future<void> _launchPage() async {
    bool isAdmin = await _checkIfUserIsAdmin();
    MainScaffold.isAdmin = isAdmin;
    setState(() {
      _widgetToLoad = isAdmin ? HomePageAdmin() : HomePage();
    });
  }

  Future<bool> _checkIfUserIsAdmin() async {
    UserClient? currentUser = await BackendUserCommunication().getCurrentUser();
    String teamId = currentUser?.teamId ?? "";
    return await BackendTeamCommunication().isAdminForTeam(currentUser, teamId);
  }

  @override
  Widget build(BuildContext context) {
    if (_widgetToLoad == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _widgetToLoad!;
  }
}
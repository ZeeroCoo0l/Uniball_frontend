import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/components/launch_handler_homepage.dart';
import 'package:uniball_frontend_2/entities/team.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_team_communication.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';

class JoinTeam extends StatefulWidget {
  const JoinTeam({super.key});

  @override
  State<JoinTeam> createState() => JoinTeamState();
}

class JoinTeamState extends State<JoinTeam> {
  final BackendTeamCommunication _backend = BackendTeamCommunication();
  final BackendUserCommunication _backendUserCommunication =
      BackendUserCommunication();
  List<Team> _teams = [];
  Team? _selectedTeam;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      String jsonString = await _backend.getAll();
      List<dynamic> decoded = json.decode(jsonString);
      setState(() {
        _teams = decoded.map((e) => Team.fromJson(e)).toList();
      });
    } catch (e) {
      debugPrint("Failed to load teams: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6CBC8C), // Ljusare grön högst upp
                  Color(0xFF1A990E), // Mörkare grön längst ner
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/uniballLogo.png', width: 220, height: 220),
                const SizedBox(height: 50),
                _teams.isEmpty
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      constraints: const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<Team>(
                        value: _selectedTeam,
                        hint: const Text("Välj lag"),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        underline: Container(),
                        onChanged: (Team? newTeam) {
                          setState(() {
                            _selectedTeam = newTeam;
                          });
                        },
                        items:
                            _teams.map((Team team) {
                              return DropdownMenuItem<Team>(
                                value: team,
                                child: Text(team.name),
                              );
                            }).toList(),
                      ),
                    ),
                const SizedBox(height: 30),
                if (_selectedTeam != null)
                  ElevatedButton(
                    onPressed: () async {
                      if (_selectedTeam == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Välj ett lag först!")),
                        );
                        return;
                      }

                      UserClient? currentPlayer = await _backendUserCommunication.getCurrentUser();
                      currentPlayer?.setTeamId = _selectedTeam!.id;

                      bool result = await _backend.addPlayerToTeam(
                        _selectedTeam,
                        currentPlayer,
                      );

                      if (!result) {
                        print("Failed to add player to team");
                        Navigator.pop(context);
                        return;
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LaunchHandlerHomepage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF094A1C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Fortsätt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniball_frontend_2/components/launch_handler_homepage.dart';
import 'package:uniball_frontend_2/entities/team.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_team_communication.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart'; 

class CreateTeam extends StatefulWidget {
  const CreateTeam({super.key});

  @override
  State<CreateTeam> createState() => CreateTeamState();
}

class CreateTeamState extends State<CreateTeam> {
  final TextEditingController _teamNameController = TextEditingController();
  bool _hasEnteredName = false;
  final BackendTeamCommunication _teamComm = BackendTeamCommunication();
  final BackendUserCommunication _userComm = BackendUserCommunication();

  void _onTeamNameChanged() {
    setState(() {
      _hasEnteredName = _teamNameController.text.trim().isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _teamNameController.addListener(_onTeamNameChanged);
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    final teamName = _teamNameController.text.trim();
    final team = Team(
      id: "",
      name: teamName,
      createdAt: DateTime.now(),
    );
    final authToken = Supabase.instance.client.auth.currentSession;

    try {
      await _teamComm.createTeam(team, authToken.toString());
      UserClient? currentUser = await _userComm.getCurrentUser();
      Team? teamFromDatabase = await _teamComm.getTeamByName(teamName);
      if(teamFromDatabase == null){
        debugPrint("Didnt find the team after creation");
        return;
      }
      if(currentUser == null){
        debugPrint("Could not find current User after created team.");
        return;
      }
      await _teamComm.addPlayerToTeam(teamFromDatabase, currentUser);
      await _teamComm.addAdminToTeam(teamFromDatabase, currentUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lag skapat!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LaunchHandlerHomepage()),
        );
      }
    } catch (e) {
      debugPrint("Fel vid lag-skapande: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Något gick fel, försök igen.")),
        );
      }
    }
  }

  void _confirmCreateTeam() {
    final teamName = _teamNameController.text.trim();
    if (teamName.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bekräfta lagnamn'),
        content: Text('Vill du skapa laget "$teamName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Avbryt'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createTeam();
            },
            child: const Text('Skapa lag'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6CBC8C),
                  Color(0xFF1A990E),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/uniballLogo.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _teamNameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Ange lagnamn',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_hasEnteredName)
                    ElevatedButton(
                      onPressed: _confirmCreateTeam,
                      child: const Text('Skapa lag'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

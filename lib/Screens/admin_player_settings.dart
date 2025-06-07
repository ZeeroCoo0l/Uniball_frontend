import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_team_communication.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';
import 'package:uniball_frontend_2/entities/team.dart';

class PlayerSettings extends StatefulWidget {
  const PlayerSettings({super.key});

  @override
  State<PlayerSettings> createState() => _PlayerSettingsState();
}

class _PlayerSettingsState extends State<PlayerSettings> {
  final backendTeam = BackendTeamCommunication();
  final backendUser = BackendUserCommunication();
  late UserClient currentUser;
  late Team team;

  List<UserClient> players = [];

  Set<UserClient> admins = {};

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      final fetchedUser = await backendUser.getCurrentUser();
      final fetchedTeam = await backendTeam.getTeam(fetchedUser!.teamId);

      if (fetchedUser != null && fetchedTeam != null) {
        setState(() {
          currentUser = fetchedUser;
          team = fetchedTeam;
          players = team.players.toList(); 
          admins = team.admins;
        });
      } else {
        debugPrint("Fel vid laddning av användare eller lag.");
      }
    } catch (e) {
      debugPrint("Fel i _loadPlayers: $e");
    }
    debugPrint('TEST vilka är admins: ' + admins.toString());
  }

  void toggleAdmin(UserClient user) {
    setState(() {
      if (admins.contains(user)) {
        if (admins.length == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Du kan inte ta bort den sista administratören.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.red[600],
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        admins.remove(user);
        backendTeam.removeAdminFromTeam(team, user);
        MainScaffold.isAdmin = false;
      } else {
        admins.add(user);
        backendTeam.addAdminToTeam(team, user);
        MainScaffold.isAdmin = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      selectedIndex: -1,
      onTabChange: (index) => handleTabChange(context, index),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Admininställningar',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Spelare:',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const Divider(thickness: 1.2),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPlayers,
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 8,
                radius: Radius.circular(10),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: players.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final isAdmin = admins.contains(player);
                    return ListTile(
                      leading: Text(
                        '${index + 1}.',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              player.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          if (isAdmin) ...[
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 27,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'toggle_admin') {
                            toggleAdmin(player);
                          }
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: 'toggle_admin',
                                child: Text(
                                  isAdmin ? 'Ta bort admin' : 'Gör till admin',
                                ),
                              ),
                            ],
                        icon: const Icon(Icons.more_vert),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/Screens/Login&SignUp/launch_page.dart';
import 'package:uniball_frontend_2/Screens/homepage.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/screens/editprofilepage.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';
import 'package:uniball_frontend_2/services/login_services/email_login_service.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/components/buildinfocard.dart';
import 'package:uniball_frontend_2/services/backend_team_communication.dart';
import 'package:uniball_frontend_2/entities/team.dart';
import 'package:uniball_frontend_2/components/deleteAccountHandler.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class ProfilePageShortcut extends StatelessWidget {
  const ProfilePageShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage(initialIndex: 1);
  }
}

class _ProfilePageState extends State<ProfilePage> {
  final backendUser = BackendUserCommunication();
  final backendTeam = BackendTeamCommunication();
  String username = 'ditt_användarnamn';
  String email = "exempel@mail.se";
  String bio = "Det här är en kort biografi om användaren.";
  Position favoritePosition = Position.NOPOSITION;
  String? profilePic;
  File? profilePicFile;
  bool isLoading = true;
  String teamName = 'lagnamn';
  late Team team;
  late String teamId;
  bool _isDeleting = false;


  final Map<Position, String> _positionLabels = {
    Position.NOPOSITION: 'Ingen position',
    Position.GOALKEEPER: 'Målvakt',
    Position.DEFENDER: 'Försvarare',
    Position.MIDFIELDER: 'Mittfältare',
    Position.FORWARD: 'Anfallare',
  };

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      UserClient? currentUser = await backendUser.getCurrentUser();
      if (currentUser == null) return;
      profilePic = await backendUser.getProfilePic(currentUser.profilePic);

      String teamId = currentUser.teamId;
      Team? currentTeam = await backendTeam.getTeam(teamId);
      teamName = currentTeam?.name ?? 'Du är inte med i ett lag';

      setState(() {
        username = currentUser.name;
        email = currentUser.email;
        favoritePosition = currentUser.favoritePosition ?? Position.NOPOSITION;
        bio = currentUser.description;
        profilePic = currentUser.profilePic;
      });
    } catch (e) {
      if (!mounted) return;
      print('Fel vid hämtning av användarinformation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kunde inte ladda användarinformation.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Colors.grey.withOpacity(0.3),
        leadingWidth: 120, 
        leading: TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Loggat ut!")),
            );
            signOut();
          },
          icon: const Icon(Icons.logout, color: Colors.black),
          label: const Text('Logga ut', style: TextStyle(color: Colors.black)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
        ),
        title: const Text("Min profil"),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
              if (result != null) {
                setState(() {
                  username = result['username'];
                  email = result['email'];
                  bio = result['bio'];
                  favoritePosition = result['favoritePosition'];
                  profilePic = result['profilePic'];
                  teamName = result['teamName'];
                  teamId = result['teamId'];
                });
              }
            },
            icon: const Icon(Icons.settings, color: Colors.black),
            label: const Text('Redigera profil', style: TextStyle(color: Colors.black)),
          ),
        ],

      ),


      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserInfo,
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 6,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    _buildProfilePicture(),
                    const SizedBox(height: 30),
                    BuildInfoCard(title: "Användarnamn", value: username),
                    BuildInfoCard(title: "E-postadress", value: email),
                    BuildInfoCard(
                      title: "Favoritposition",
                      value: _positionLabels[favoritePosition] ?? 'Välj favoritposition',
                    ),
                    BuildInfoCard(title: "Mitt Lag", value: teamName),
                    BuildInfoCard(title: "Biografi", value: bio, maxLines: 5),
                      
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: _isDeleting
                                ? null
                                : () {
                                    final handler = DeleteAccountHandler(
                                      context: context,
                                      usernameController: TextEditingController(text: username),
                                      emailController: TextEditingController(text: email),
                                      usernameConfirmController: TextEditingController(),
                                      emailConfirmController: TextEditingController(),
                                      onToggleDeleting: (isDeleting) => setState(() {
                                        _isDeleting = isDeleting;
                                      }),
                                      onDeleteSuccess: () {
                                        signOut();
                                      },
                                    );
                                    handler.startAccountDeletionFlow();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 45, 41, 41),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isDeleting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Ta bort konto", style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              UserClient? currentUser = await backendUser.getCurrentUser();
                              if (currentUser != null) {
                                Team? team = await backendTeam.getTeam(currentUser.teamId);
                                if (team != null && team.admins.contains(currentUser)) {
                                  if (team.players.length == 1) {
                                    bool confirmed = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Bekräfta borttagning'),
                                          content: const Text(
                                              'Du är den enda spelaren i laget. Om du lämnar kommer laget att tas bort. Är du säker på att du vill fortsätta?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Avbryt'),
                                              onPressed: () => Navigator.of(context).pop(false),
                                            ),
                                            TextButton(
                                              child: const Text('Ja, lämna och ta bort laget'),
                                              onPressed: () => Navigator.of(context).pop(true),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirmed == true) {
                                      bool removeAdmin = await backendTeam.removeAdminFromTeam(team, currentUser);
                                      if (removeAdmin) {
                                        bool removePlayer = await backendTeam.removePlayerFromTeam(team, currentUser);
                                        if (removePlayer) {
                                          bool result = await backendTeam.removeTeam(team);
                                          if (result) {
                                            MainScaffold.isAdmin = false; // Ändrar till default.
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              "/create_or_join_team",
                                              (Route<dynamic> route) => false,
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Misslyckades med att lämna laget.')),
                                            );
                                          }
                                        }
                                      }
                                    }
                                    return;
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Could not remove because you are admin. Change that first!")),
                                  );
                                  return;
                                }

                                bool result = await backendTeam.removePlayerFromTeam(team, currentUser);
                                if (result) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    "/create_or_join_team",
                                    (Route<dynamic> route) => false,
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 120, 118, 118),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Lämna lag", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      const Divider(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return CircleAvatar(
      radius: 75,
      backgroundColor: Colors.grey.withOpacity(0.3),
      backgroundImage: (profilePic != null && profilePic!.isNotEmpty)
          ? NetworkImage(profilePic!)
          : null,
      child: (profilePic == null || profilePic!.isEmpty)
          ? const Center(
              child: Icon(
                Icons.person,
                size: 75,
                color: Colors.black54,
              ),
            )
          : null,
    );
  }

  void signOut() {
    EmailLoginService().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LaunchPage()),
      (Route<dynamic> route) => false,
    );
  }
}

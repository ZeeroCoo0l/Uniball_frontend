import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/Screens/leaderboard.dart';
import 'package:uniball_frontend_2/Screens/profilepage.dart';
import 'package:uniball_frontend_2/components/HomePageComponents/home_button.dart';
import 'package:uniball_frontend_2/components/HomePageComponents/home_container.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/components/previous_practice_card.dart';
import 'package:uniball_frontend_2/entities/award.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/team.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_practice_communication.dart';
import 'package:uniball_frontend_2/services/backend_team_communication.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';

class HomePageAdmin extends StatefulWidget {
  final int initialIndex;
  const HomePageAdmin({super.key, this.initialIndex = 0});

  @override
  State<HomePageAdmin> createState() => _HomePageState();
}


class HomeContentAdmin extends StatelessWidget {
  final List<Practice> practices;
  final UserClient currentUser;
  final Team currentTeam;
  final Future<void> Function() onCloseVotingPressed;
  final Future<void> Function() onRefresh;

  const HomeContentAdmin({
    Key? key,
    required this.practices,
    required this.currentUser,
    required this.currentTeam,
    required this.onCloseVotingPressed,
    required this.onRefresh,
  }) : super(key: key);

  void _confirmCloseVoting(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Bekräfta'),
      content: const Text('Är du säker på att du vill stänga röstningen?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Nej'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Ja'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await onCloseVotingPressed();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Röstningen har stängts.')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final upcomingPractices =
        practices.where((p) => p.date.isAfter(DateTime.now())).toList();
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: Colors.red.shade100,
          child: const Text(
            "Du är inloggad som ADMIN",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeContainer(
                      practices: upcomingPractices,
                      currentUser: currentUser,
                      currentTeam: currentTeam,
                    ),
                    const SizedBox(height: 20),

                    PreviousPracticeCard(
                      practices: practices,
                      currentUser: currentUser,
                    ),
                    // lägg tillbaka om vi vill implementera informationssidan i framtiden
                    // HomeButton(
                    //   label: "Information",
                    //   icon: Icons.info,
                    //   onPressed: () => Navigator.pushNamed(context, '/informationpage'),
                    // ),
                    // const SizedBox(height: 12),
                    HomeButton(
                      icon: Icons.event,
                      label: "Skapa träningsstillfälle",
                      onPressed:
                          () => Navigator.pushNamed(context, '/create_event'),
                    ),
                    const SizedBox(height: 12),
                    HomeButton(
                      icon: Icons.fitness_center,
                      label: "Träningsövningar",
                      onPressed:
                          () => Navigator.pushNamed(
                            context,
                            '/trainingexercisepage',
                          ),
                    ),
                    const SizedBox(height: 12),
                    HomeButton(
                      icon: Icons.groups,
                      label: "Dela upp lag",
                      onPressed:
                          () => Navigator.pushNamed(context, '/toDividePage'),
                    ),
                    const SizedBox(height: 12),
                    HomeButton(
                      icon: Icons.settings,
                      label: "Admininställningar",
                      onPressed:
                          () => Navigator.pushNamed(
                            context,
                            '/admin_player_settings',
                          ),
                    ),
                    const SizedBox(height: 12),
                    HomeButton(
                      icon: Icons.how_to_vote,
                      label: "Stäng röstning",
                      onPressed: () => _confirmCloseVoting(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomePageState extends State<HomePageAdmin> {
  late int _selectedIndex;
  UserClient? _currentUser;
  Team? _currentTeam;
  late String teamID;
  List<Practice> _currentTeamPractices = [];

  final BackendUserCommunication _userDatabase = BackendUserCommunication();
  final BackendTeamCommunication _teamDatabase = BackendTeamCommunication();
  final BackendPracticeCommunication _backendService =
      BackendPracticeCommunication();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadCurrentUser();
  }

  Future<bool> _fetchMostRecentPastPracticeInState() async {
    if (_currentUser == null || _currentUser!.teamId.isEmpty) {
      debugPrint(
        "Cannot fetch recent practice: Current user or team ID is missing.",
      );
      return false;
    }
    String teamId = _currentUser!.teamId;
    List<Award>? awards;
    bool voteClosedResult = false;
    try {
      String practicesJsonString = await _backendService.getAllpractices();
      List<dynamic> decodedPracsJson = jsonDecode(practicesJsonString);

      List<Practice> allPractices =
          decodedPracsJson
              .map((jsonPrac) {
                if (jsonPrac is Map<String, dynamic>) {
                  return Practice.fromJson(jsonPrac);
                }
                return null;
              })
              .whereType<Practice>()
              .toList();

      DateTime now = DateTime.now();
      List<Practice> pastPracticesInTeam =
          allPractices
              .where((p) => p.teamId == teamId && !p.date.isAfter(now))
              .toList();

      if (pastPracticesInTeam.isNotEmpty) {
        pastPracticesInTeam.sort((a, b) => b.date.compareTo(a.date));
        Practice recentPractice = pastPracticesInTeam.first;

        if (recentPractice != null) {
          awards = await _backendService.getAwardsFromPractice(
            recentPractice.id.toString(),
          );
        } else {
          debugPrint("Recent practice ID is null, cannot fetch awards.");
          awards = null;
        }
        if (awards != null) {
          for (Award award in awards) {
            if (award.id != null) {
              int? awId = award.id;
              _backendService.closeVote(awId!);
              voteClosedResult = true;
            }
          }
        }
      }
      return voteClosedResult;
    } catch (e, s) {
      debugPrint(
        "Error in _fetchMostRecentPastPracticeInState: $e\nStack trace: $s",
      );
      return false;
    }
  }

  Future<void> _refreshAllData() async {
    await _loadCurrentUser();
    debugPrint("Uppdatering genomförd via pull to refresh.");
  }

  Future<void> _handleCloseVotingPressed() async {
    debugPrint("'Stäng röstning' button pressed. Processing...");
    bool success = await _fetchMostRecentPastPracticeInState();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successful"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    UserClient? user = await _userDatabase.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });

      // Load team if user has a teamId
      if (user?.teamId != null && user!.teamId.isNotEmpty) {
        Team? team = await _teamDatabase.getTeam(user.teamId);
        if (team == null) return;
        if (mounted) {
          setState(() {
            _currentTeam = team;
            _currentTeamPractices = _currentTeam!.practices;
          });
        }
      }
    }
  }

  List<Widget> get _pages {
    if (_currentUser != null && _currentTeam != null) {
      return [
        HomeContentAdmin(
          practices: _currentTeamPractices,
          currentUser: _currentUser!,
          currentTeam: _currentTeam!,
          onCloseVotingPressed: _handleCloseVotingPressed,
          onRefresh: _refreshAllData,
        ),
        ProfilePage(),
        LeaderBoardContent(),
      ];
    } else {
      return const [
        Center(child: CircularProgressIndicator()),
        Center(child: CircularProgressIndicator()),
        Center(child: CircularProgressIndicator()),
      ];
    }
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      selectedIndex: _selectedIndex,
      onTabChange: _onTabChange,
      child: _pages[_selectedIndex],
    );
  }
}

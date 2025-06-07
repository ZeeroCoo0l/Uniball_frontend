import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/Screens/leaderboard.dart';
import 'package:uniball_frontend_2/Screens/profilepage.dart';
import 'package:uniball_frontend_2/components/HomePageComponents/home_button.dart';
import 'package:uniball_frontend_2/components/HomePageComponents/home_container.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/components/previous_practice_card.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/team.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_team_communication.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';

//om vi vill lägga till metoden maybeshowpopup behövs dessa
//import 'package:uniball_frontend_2/components/votingpopup.dart';
//import 'package:uniball_frontend_2/entities/award.dart';
//import 'package:uniball_frontend_2/services/backend_practice_communication.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class HomeContent extends StatelessWidget {
  final List<Practice> practices;
  final UserClient currentUser;
  final Team currentTeam;
  final Future<void> Function() onRefresh;
  final upcomingPractices;

  const HomeContent({
    Key? key,
    required this.practices,
    required this.currentUser,
    required this.currentTeam,
    required this.onRefresh,
    required this.upcomingPractices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeContainer(
                  currentTeam: currentTeam,
                  practices: upcomingPractices,
                  currentUser: currentUser,
                ),
                const SizedBox(height: 20),
                //kan läggas till i framtiden
                // HomeButton(
                //   label: "Information",
                //   icon: Icons.mark_email_unread,
                //   onPressed: () => Navigator.pushNamed(context, '/informationpage'),
                // ),
                // const SizedBox(height: 12),

                //AwardButton(),  //Awardknappen kan läggas till i framtiden
                
                // Knapp för navigering när man utvecklar
                /*HomeButton(
                  label: "Knappsida",
                  icon: Icons.abc,
                  onPressed: () => Navigator.pushNamed(context, '/knappsida'),
                ),*/
                const SizedBox(height: 12),
                PreviousPracticeCard(
                  practices: practices,
                  currentUser: currentUser,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  UserClient? _currentUser;
  Team? _currentTeam;
  late String teamID;
  List<Practice> _currentTeamPractices = [];
  //bool _popupShown = false;
  List<Practice> practicesToSend = [];

  final BackendUserCommunication _userDatabase = BackendUserCommunication();
  final BackendTeamCommunication _teamDatabase = BackendTeamCommunication();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _refreshAllData();
  }

  //finns att implementera om vi vill i framtiden,
  /*void _maybeShowVotePopup() async {
    if (_popupShown || _currentUser == null || _currentTeamPractices.isEmpty) {
      return;
    }

    final pastPractices =
        _currentTeamPractices
            .where((p) => p.date.isBefore(DateTime.now()))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)); // Nyaste först

    if (pastPractices.isEmpty) {
      debugPrint("Inga tidigare träningar.");
      return;
    }

    final lastPractice = pastPractices.first;

    // Kontrollera om användaren deltog
    bool wasAttending = lastPractice.attendees.any(
      (attendee) => attendee.id == _currentUser!.id,
    );

    if (!wasAttending) {
      // Om användaren inte deltog, ingen popup
      return;
    }

    // Här gör vi asynkrona anropet för att kolla om användaren redan röstat
    final bpc = BackendPracticeCommunication();
    final fetchedAwards =
        await bpc.getAwardsFromPractice(lastPractice.id.toString()) ?? [];

    bool userHasVoted = false;
    for (Award award in fetchedAwards) {
      if (award.id == null) continue;
      bool voted = await bpc.hasVoted(award.id!, _currentUser!.id);
      if (voted) {
        userHasVoted = true;
        break;
      }
    }

    if (_popupShown || userHasVoted) {
      // Om popup redan visats eller användaren har röstat, visa inget
      return;
    }

    _popupShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => VotePopup(
              practice: lastPractice,
              onContinue: () {
                Navigator.pushNamed(
                  context,
                  '/votingpopup',
                  arguments: lastPractice,
                );
              },
              onClose: () {
                debugPrint("Popup stängdes.");
              },
            ),
      );
    });
  }
  */

  List<Widget> get _pages => [
    if (_currentUser != null && _currentTeam != null)
      HomeContent(
        practices: _currentTeamPractices,
        currentUser: _currentUser!,
        currentTeam: _currentTeam!,
        onRefresh: _refreshAllData,
        upcomingPractices: practicesToSend,
      )
    else
      const Center(child: CircularProgressIndicator()),
    ProfilePage(),
    LeaderBoardContent(),
  ];

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _refreshAllData() async {
    final user = await _userDatabase.getCurrentUser();
    if (user == null) return;

    Team? team;
    List<Practice> practices = [];

    if (user.teamId.isNotEmpty) {
      team = await _teamDatabase.getTeam(user.teamId);
      if (team != null) {
        practices = team.practices;
      }
    }

    if (!mounted) return;

    setState(() {
      _currentUser = user;
      _currentTeam = team;
      _currentTeamPractices = practices;
      practicesToSend =
          practices.where((p) => p.date.isAfter(DateTime.now())).toList();
    });

    //_maybeShowVotePopup();
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uniball_frontend_2/Screens/homepage.dart';
import 'package:uniball_frontend_2/entities/award.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_practice_communication.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';

class LeaderBoard extends StatelessWidget {
  const LeaderBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage(initialIndex: 2);
  }
}

class PracticeLeaderboardData {
  final Practice practice;
  final List<Award> awards;

  PracticeLeaderboardData({required this.practice, required this.awards});
}

class LeaderBoardContent extends StatefulWidget {
  const LeaderBoardContent({super.key});

  @override
  State<LeaderBoardContent> createState() => _LeaderBoardContentState();
}

class _LeaderBoardContentState extends State<LeaderBoardContent> {
  final ScrollController _scrollController = ScrollController();

  List<PracticeLeaderboardData> _leaderboardItems = [];
  Map<int, UserClient> _usersByAwardId = {};
  bool _isLoading = true;
  String? _errorMessage;
  final BackendPracticeCommunication _backendService =
      BackendPracticeCommunication();
  final BackendUserCommunication _userService = BackendUserCommunication();
  UserClient? _currentUser;

  List<UserClient>? _top3AssistPlayers;
  List<UserClient>? _top3MvpPlayers;
  List<UserClient>? _top3SnyggastMalPlayers;
  bool _isLoadingHighlights = true;
  String? _highlightsErrorMessage;

  final List<String> boxTitles = [
    'Snyggast Assist',
    'MVP',
    'Snyggast Mål',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollPercent);
    _loadCurrentUserAndAllLeaderboardData();
  }

  void _updateScrollPercent() {
    if (!_scrollController.hasClients) return;

    setState(() {});
   
  }

  Future<void> _loadCurrentUserAndAllLeaderboardData() async {
    setState(() {
      _isLoading = true;
      _isLoadingHighlights = true;
      _errorMessage = null;
      _highlightsErrorMessage = null;
    });
    try {
      _currentUser = await _userService.getCurrentUser();
      if (!mounted) return;

      if (_currentUser == null || _currentUser!.teamId.isEmpty) {
        final errorMsg = "Please join a team to view leaderboard data.";
        if (mounted) {
          setState(() {
            _errorMessage = errorMsg;
            _highlightsErrorMessage = errorMsg;
            _isLoading = false;
            _isLoadingHighlights = false;
          });
        }
        return;
      }
      await Future.wait([
        _fetchLeaderboardData(),
        _fetchHighlightBoxData(),
      ]);
    } catch (e, s) {
      if (mounted) {
        final errorMsg = "Failed to load initial data: ${e.toString()}";
        setState(() {
          _errorMessage = errorMsg;
          _highlightsErrorMessage = errorMsg;
          _isLoading = false;
          _isLoadingHighlights = false;
        });
        debugPrint("Error loading current user or dispatching fetches: $e\nStack trace: $s");
      }
    }
  }

  Future<void> _fetchHighlightBoxData() async {
    if (_currentUser == null || _currentUser!.teamId.isEmpty) return;

    try {
      final teamId = int.tryParse(_currentUser!.teamId);
      if (teamId == null) {
        throw Exception("Invalid Team ID format for highlights");
      }

      final results = await Future.wait([
        _backendService.GetTop3InTeam(teamId, "PLAYER_OF_THE_EVENING"),
        _backendService.GetTop3InTeam(teamId, "MVP"),
        _backendService.GetTop3InTeam(teamId, "GOAL"),
      ]);

      if (mounted) {
        setState(() {
          _top3AssistPlayers = results[0];
          _top3MvpPlayers = results[1];
          _top3SnyggastMalPlayers = results[2];
          _isLoadingHighlights = false;
        });
      }
    } catch (e, s) {
      if (mounted) {
        setState(() {
          _highlightsErrorMessage = "Failed to load highlights: ${e.toString()}";
          _isLoadingHighlights = false;
        });
        debugPrint("Error fetching highlight data: $e\nStack trace: $s");
      }
    }
  }

  Future<void> _fetchLeaderboardData() async {
    Map<int, UserClient> fetchedUsersByAwardId = {};

    try {
      if (_currentUser == null || _currentUser!.teamId.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = _currentUser == null ? "User not loaded." : "User has no team ID.";
            _isLoading = false;
          });
        }
        return;
      }

      if(mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      String userTeamId = _currentUser!.teamId;
      String practicesJsonString = await _backendService.getAllpractices();

      List<dynamic> decodedPracsJson = jsonDecode(practicesJsonString);
      List<Practice> allPractices = decodedPracsJson
          .map((jsonPrac) {
            if (jsonPrac is Map<String, dynamic>) {
              return Practice.fromJson(jsonPrac);
            } else {
              debugPrint("Skipping non-map item in practices list: $jsonPrac");
              return null;
            }
          })
          .whereType<Practice>()
          .toList();

      DateTime now = DateTime.now();

      List<Practice> filteredPractices = allPractices
          .where((p) => p.teamId == userTeamId && !p.date.isAfter(now))
          .toList();

      filteredPractices.sort((a, b) => b.date.compareTo(a.date));

      List<Practice> recentPractices = filteredPractices.take(3).toList();

      List<PracticeLeaderboardData> items = [];
      for (var practice in recentPractices) {
        if (practice.id != null) {
          List<Award>? awards = await _backendService.getAwardsFromPractice(practice.id.toString());
          items.add(PracticeLeaderboardData(practice: practice, awards: awards ?? []));
          if(awards != null){
            for( Award award in awards){
            var awardId = award.id;
            UserClient? user = await _userService.getUser(award.playerId);
            if(awardId != null && user != null){
              fetchedUsersByAwardId[awardId] = user;
            }
          }
          }
        }
      }


      if (mounted) {
        setState(() {
          _leaderboardItems = items;
          _usersByAwardId = fetchedUsersByAwardId;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e, s) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load practice awards: ${e.toString()}";
          _isLoading = false;
          _usersByAwardId = {};
        });
        debugPrint("Error fetching practice awards data: $e\nStack trace: $s");
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollPercent);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<List<UserClient>?> topPlayersForHighlightBoxes = [
      _top3AssistPlayers,
      _top3MvpPlayers,
      _top3SnyggastMalPlayers,
    ];

    return Scrollbar(
      thumbVisibility: true,
      thickness: 6,
      radius: Radius.circular(8),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
          const Center(
            child: Text(
              "Topplistan",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          if (_isLoadingHighlights)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
          else if (_highlightsErrorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_highlightsErrorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 170,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListView.separated(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: boxTitles.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        return HighlightBox(
                          height: 150,
                          width: 250,
                          label: boxTitles[index],
                          topPlayers: topPlayersForHighlightBoxes[index],
                          isLoadingHighlights: _isLoadingHighlights, 
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const double pillWidth = 50;
                    final double trackWidth = constraints.maxWidth - 40;
                    final maxScrollExtent =
                        _scrollController.hasClients &&
                                _scrollController.position.hasContentDimensions
                            ? _scrollController.position.maxScrollExtent
                            : 1.0;
                    final scrollOffset =
                        _scrollController.hasClients &&
                                _scrollController.position.hasContentDimensions
                            ? _scrollController.offset.clamp(0.0, maxScrollExtent)
                            : 0.0;
                    final double scrollRatio =
                        maxScrollExtent == 0
                            ? 0.0
                            : scrollOffset / maxScrollExtent;
                    final double leftOffset =
                        scrollRatio * (trackWidth - pillWidth);

                    return Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: leftOffset,
                            child: Container(
                              width: pillWidth,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.green.shade700,
                                borderRadius: BorderRadius.circular(3),
                                
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          const SizedBox(height: 30),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          else if (_leaderboardItems.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No recent practice data with awards available.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _leaderboardItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return TrophyBox(
                  practiceData: _leaderboardItems[index],
                  usersByAwardId: _usersByAwardId,
                );
              },
            ),
        ],
      ),
    ),
   ); 
  }
}

class HighlightBox extends StatelessWidget {
  final double height;
  final double width;
  final String? label;
  final List<UserClient>? topPlayers;
  final bool isLoadingHighlights; 

  const HighlightBox({
    super.key,
    required this.height,
    required this.width,
    this.label,
    required this.topPlayers,
    required this.isLoadingHighlights,
  });

  static const List<Map<String, dynamic>> podiumConfig = [
    {'asset': 'assets/Gold.png', 'bottom': 58.0, 'left': 90.0},
    {'asset': 'assets/Silver.png', 'bottom': 32.0, 'left': 22.0},
    {'asset': 'assets/Bronze.png', 'bottom': 0.0, 'left': 160.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: leaderboardBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (label != null)
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            const Spacer(),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Image.asset('assets/podium3.png'),
                if (topPlayers != null && topPlayers!.isNotEmpty)
                  ...List.generate(
                    topPlayers!.length > 3 ? 3 : topPlayers!.length,
                    (index) {
                      final player = topPlayers![index];
                      final config = podiumConfig[index];
                      return Positioned(
                        bottom: config['bottom'] as double,
                        left: config['left'] as double?,
                        right: config['left'] == null ? 0 : null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(config['asset'] as String, height: 55),
                            Transform.translate(
                              offset: const Offset(0, -7),
                              child: Text(
                                player.name,// ?? "N/A",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                else
                  Positioned(
                    bottom: 60,
                    child: Text(
                      isLoadingHighlights ? "Loading..." : "Inga vinnare än",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TrophyBox extends StatelessWidget {
  final PracticeLeaderboardData practiceData;
  final Map<int, UserClient> usersByAwardId;

  const TrophyBox({
    super.key,
    required this.practiceData,
    required this.usersByAwardId,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(
      'd MMMM yyyy',
      'sv_SE',
    ).format(practiceData.practice.date);

    List<Award> awardsToDisplay =
        practiceData.awards
            .where((award) => award.type != Type.NO_VALUE)
            .take(3)
            .toList();
    if (awardsToDisplay.isEmpty && practiceData.awards.isNotEmpty) {
      awardsToDisplay = practiceData.awards.take(3).toList();
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      width: 350,
      decoration: leaderboardBoxDecoration,
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 12,
            child: Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 30,
              bottom: 10,
              left: 8,
              right: 8,
            ),
            child:
                awardsToDisplay.isEmpty
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          "Inga utmärkelser för denna träning",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          awardsToDisplay.map((award) {
                            String title;
                            if (award.type == Type.PLAYER_OF_THE_EVENING) {
                              title = "Snyggast Assist";
                            } else if (award.type == Type.GOAL) {
                              title = "Snyggast Mål";
                            } else {
                              title = award.type.name.toLowerCase().replaceAll(
                                '_',
                                ' ',
                              );
                              if (title.isNotEmpty) {
                                title =
                                    title[0].toUpperCase() + title.substring(1);
                              }
                            }
                            UserClient? user = usersByAwardId[award.id];
                            String name = user?.name ?? "N/A";

                            return Flexible(
                              child: TrophyColumn(title: title, name: name),
                            );
                          }).toList(),
                    ),
          ),
        ],
      ),
    );
  }
}

class TrophyColumn extends StatelessWidget {
  final String title;
  final String name;

  const TrophyColumn({super.key, required this.title, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Image.asset('assets/goldTrophy.png', height: 33),
        const SizedBox(height: 4),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }
}

const BoxDecoration leaderboardBoxDecoration = BoxDecoration(
  color: Color(0xFFE8F4E8),
  borderRadius: BorderRadius.all(Radius.circular(24)),
  boxShadow: [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.2),
      spreadRadius: 1,
      blurRadius: 5,
      offset: Offset(0, 3),
    ),
  ],
);
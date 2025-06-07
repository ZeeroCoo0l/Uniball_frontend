import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/components/footballfieldpainter.dart';
import 'package:uniball_frontend_2/entities/award.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_practice_communication.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';

class Voting2Mvp extends StatefulWidget {
  final Practice currentPractice;
  const Voting2Mvp({super.key, required this.currentPractice});

  @override
  State<StatefulWidget> createState() => Voting2MvpState();
}

class Voting2MvpState extends State<Voting2Mvp> {
  int currentIndex = -1;
  List<UserClient> teamA = [];
  List<UserClient> teamB = [];
  UserClient? selectedMvp;
  final BackendPracticeCommunication _backendPC =
      BackendPracticeCommunication();
  final BackendUserCommunication _backendUC = BackendUserCommunication();
  late UserClient _currentUser;
  late List<Award> awards = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    List<UserClient> attendeesList = widget.currentPractice.attendees.toList();
    List<Award>? loadedAwards = await _backendPC.getAwardsFromPractice(
      widget.currentPractice.id.toString(),
    );

    _currentUser = (await _backendUC.getCurrentUser())!;

    setState(() {
      awards = loadedAwards ?? [];
      int midpoint = (attendeesList.length / 2).ceil();
      teamA = attendeesList.sublist(0, midpoint);
      teamB = attendeesList.sublist(midpoint);
    });
  }

  void onPlayerTap(UserClient player) {
    setState(() {
      // Avmarkera om spelaren redan är vald, annars markera
      if (selectedMvp == player) {
        selectedMvp = null; // Avmarkera
      } else {
        selectedMvp = player; // Markera ny spelare
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      selectedIndex: currentIndex,
      onTabChange: (index) {
        setState(() {
          handleTabChange(context, index);
        });
      },
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            'Vem var kvällens MVP?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 2)],
            ),
          ),
          const SizedBox(height: 10),

          //Football Field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final fieldHeight = constraints.maxHeight;
                  final fieldWidth = constraints.maxWidth;

                  return Stack(
                    children: [
                      CustomPaint(
                        painter: FootballFieldPainter(),
                        size: Size(fieldWidth, fieldHeight),
                      ),
                      ...TeamFormation(
                        team: teamA,
                        isTeamA: true,
                        fieldWidth: fieldWidth,
                        fieldHeight: fieldHeight,
                        onPlayerTap: onPlayerTap,
                        selectedMvp: selectedMvp,
                      ).buildFormation(),
                      ...TeamFormation(
                        team: teamB,
                        isTeamA: false,
                        fieldWidth: fieldWidth,
                        fieldHeight: fieldHeight,
                        onPlayerTap: onPlayerTap,
                        selectedMvp: selectedMvp,
                      ).buildFormation(),
                    ],
                  );
                },
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '2',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: ' / 3',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Award? MVPAward =
                          awards
                              .where((award) => award.type == Type.MVP)
                              .firstOrNull;

                      if (selectedMvp != null && MVPAward != null) {
                        String result = await _backendPC.updateVote(
                          playerToVoteOn: selectedMvp!,
                          awardId: MVPAward.id!,
                          votedFor: true,
                        );
                        debugPrint("Vote update result: $result");
                        _backendPC.addToAlreadyVoted(
                          MVPAward.id!,
                          _currentUser,
                        );
                      } else {
                        debugPrint("No player selected or no award found.");
                      }

                      Navigator.pushNamed(
                        context,
                        '/voting3Goal',
                        arguments: widget.currentPractice,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      selectedMvp != null ? 'Nästa' : 'Skippa och gå vidare',
                    ),
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

class TeamFormation {
  final List<UserClient> team;
  final bool isTeamA;
  final double fieldWidth;
  final double fieldHeight;
  final UserClient? selectedMvp;
  final Function(UserClient) onPlayerTap;

  TeamFormation({
    required this.team,
    required this.isTeamA,
    required this.fieldWidth,
    required this.fieldHeight,
    required this.onPlayerTap,
    required this.selectedMvp,
  });

  List<Widget> buildFormation() {
    if (team.isEmpty) return [];

    final UserClient goalie = team.first;
    final List<UserClient> outfieldPlayers = team.sublist(1);

    List<Widget> widgets = [];

    // Add goalie
    widgets.add(_buildGoalie(goalie));

    // Get offsets for remaining players
    List<Offset> formation = _getFormationOffsets(outfieldPlayers.length);

    // Add outfield players
    for (int i = 0; i < outfieldPlayers.length; i++) {
      final player = outfieldPlayers[i];
      final pos = formation[i];

      final double x = pos.dx * fieldWidth - 50;
      final double y =
          (isTeamA
              ? pos.dy * fieldHeight
              : fieldHeight - pos.dy * fieldHeight) -
          40;

      widgets.add(
        Positioned(
          left: x,
          top: y,
          child: _buildPlayerWidget(
            player,
            () => onPlayerTap(player),
            selectedMvp == player,
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildGoalie(UserClient goalie) {
    return Positioned(
      top: isTeamA ? 3 : null,
      bottom: isTeamA ? null : 3,
      left: fieldWidth / 2 - 50,
      child: _buildPlayerWidget(
        goalie,
        () => onPlayerTap(goalie),
        selectedMvp == goalie,
      ),
    );
  }

  Widget _buildPlayerWidget(UserClient player, VoidCallback onTap, bool isMvp) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Image.asset(
                  isTeamA
                      ? 'assets/teamShirt.png'
                      : 'assets/argentinaShirt.png',
                  height: 40,
                ),
                if (isMvp)
                  Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Image.asset('assets/goldTrophy.png', height: 30),
                  ),
              ],
            ),
            Text(
              player.name,
              style: const TextStyle(
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1.5, 1.5),
                    blurRadius: 3,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Offset> _getFormationOffsets(int count) {
    switch (count) {
      case 1:
        return [Offset(0.5, 0.3)];
      case 2:
        return [Offset(0.3, 0.3), Offset(0.7, 0.3)];
      case 3:
        return [Offset(0.5, 0.2), Offset(0.3, 0.35), Offset(0.7, 0.35)];
      case 4:
        return [
          Offset(0.3, 0.2),
          Offset(0.7, 0.2),
          Offset(0.3, 0.4),
          Offset(0.7, 0.4),
        ];
      case 5:
        return [
          Offset(0.3, 0.2),
          Offset(0.7, 0.2),
          Offset(0.5, 0.3),
          Offset(0.3, 0.4),
          Offset(0.7, 0.4),
        ];
      case 6:
        return [
          Offset(0.25, 0.25),
          Offset(0.5, 0.2),
          Offset(0.75, 0.25),
          Offset(0.25, 0.4),
          Offset(0.5, 0.35),
          Offset(0.75, 0.4),
        ];
      case 7:
        return [
          Offset(0.35, 0.2),
          Offset(0.65, 0.2),
          Offset(0.5, 0.3),
          Offset(0.2, 0.3),
          Offset(0.8, 0.3),
          Offset(0.35, 0.4),
          Offset(0.65, 0.4),
        ];

      case 8:
        return [
          Offset(0.15, 0.17),
          Offset(0.85, 0.17),
          Offset(0.5, 0.2),
          Offset(0.3, 0.3),
          Offset(0.7, 0.3),
          Offset(0.2, 0.44),
          Offset(0.8, 0.44),
          Offset(0.5, 0.4),
        ];

      case 9:
        return [
          Offset(0.15, 0.1),
          Offset(0.85, 0.1),
          Offset(0.5, 0.18),
          Offset(0.25, 0.25),
          Offset(0.75, 0.25),
          Offset(0.5, 0.3),
          Offset(0.15, 0.4),
          Offset(0.85, 0.4),
          Offset(0.5, 0.44),
        ];

      case 10:
        return [
          Offset(0.15, 0.1),
          Offset(0.85, 0.1),
          Offset(0.65, 0.18),
          Offset(0.35, 0.18),
          Offset(0.85, 0.25),
          Offset(0.15, 0.25),
          Offset(0.5, 0.28),
          Offset(0.85, 0.38),
          Offset(0.15, 0.38),
          Offset(0.5, 0.42),
        ];
      default:
        // Fallback to grid if count is too high
        int perRow = 4;
        List<Offset> result = [];
        for (int i = 0; i < count; i++) {
          int row = i ~/ perRow;
          int col = i % perRow;
          result.add(Offset(0.2 + 0.2 * col, 0.15 + row * 0.13));
        }
        return result;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';

class TeamFormation {
  final List<UserClient> team;
  final bool isTeamA;
  final double fieldWidth;
  final double fieldHeight;

  TeamFormation({
    required this.team,
    required this.isTeamA,
    required this.fieldWidth,
    required this.fieldHeight,
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
        Positioned(left: x, top: y, child: _buildPlayerWidget(player)),
      );
    }

    return widgets;
  }

  Widget _buildGoalie(UserClient goalie) {
    return Positioned(
      top: isTeamA ? 5 : null,
      bottom: isTeamA ? null : 5,
      left: fieldWidth / 2 - 50,
      child: _buildPlayerWidget(goalie),
    );
  }

  Widget _buildPlayerWidget(UserClient player) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Image.asset(
            isTeamA ? 'assets/teamShirt.png' : 'assets/argentinaShirt.png',
            height: 40,
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
    );
  }

  /// Define player positions as fractions of screen width/height
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

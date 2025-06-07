import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/components/footballfieldpainter.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/components/teamformation.dart';

class ShuffledTeams extends StatefulWidget {
  final Practice currentPractice;
  const ShuffledTeams({super.key, required this.currentPractice});

  @override
  State<StatefulWidget> createState() => ShuffledTeamsState();
}

class ShuffledTeamsState extends State<ShuffledTeams> {
  int currentIndex = -1; // alla sidor som inte är med i NAVbar ska ha -1
  late List<UserClient> teamA;
  late List<UserClient> teamB;

  @override
  void initState() {
    super.initState();
    List<UserClient> attendeesList = widget.currentPractice.attendees.toList();

    attendeesList.shuffle(); // Randomize

    int midpoint = (attendeesList.length / 2).ceil();
    teamA = attendeesList.sublist(0, midpoint);
    teamB = attendeesList.sublist(midpoint);
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

      child: LayoutBuilder(
        builder: (context, constraints) {
          //Skapa så stor plan som möjligt
          final double fieldWidth = constraints.maxWidth;
          final double fieldHeight = constraints.maxHeight;

          return Stack(
            children: [
              CustomPaint(
                painter: FootballFieldPainter(),
                child: SizedBox.expand(),
              ),

              // Team players
              ...TeamFormation(
                team: teamA,
                isTeamA: true,
                fieldWidth: fieldWidth,
                fieldHeight: fieldHeight,
              ).buildFormation(),

              ...TeamFormation(
                team: teamB,
                isTeamA: false,
                fieldWidth: fieldWidth,
                fieldHeight: fieldHeight,
              ).buildFormation(),
            ],
          );
        },
      ),
    );
  }
}

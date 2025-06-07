import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/components/HomePageComponents/eventcard.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/entities/team.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';
import 'package:uniball_frontend_2/services/backend_team_communication.dart';

class UpcomingEvents extends StatefulWidget {
  const UpcomingEvents({Key? key}) : super(key: key);

  @override
  State<UpcomingEvents> createState() => _UpcomingEventsState();
}

class _UpcomingEventsState extends State<UpcomingEvents> {
  final BackendUserCommunication _userDatabase = BackendUserCommunication();
  final BackendTeamCommunication _teamDatabase = BackendTeamCommunication();
  UserClient? _currentUser;

  List<Practice> _practices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPractices();
  }

  Future<void> _loadPractices() async {
    try {
      UserClient? user = await _userDatabase.getCurrentUser();

      if (user != null && user.teamId.isNotEmpty) {
        Team? team = await _teamDatabase.getTeam(user.teamId);
        if (team != null) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final upcomingPractices =
              team.practices.where((practice) {
                final practiceDate = DateTime(
                  practice.date.year,
                  practice.date.month,
                  practice.date.day,
                );
                return practiceDate.isAtSameMomentAs(today) ||
                    practiceDate.isAfter(today);
              }).toList().sublist(0,4);

          setState(() {
            _currentUser = user;
            _practices = upcomingPractices;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading practices: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.tightForFinite(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFF6CBC8C), Color(0xFF1A990E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Kommande",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 410,
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      children:
                          _practices.map((p) {
                            return EventCard(
                              event: p,
                              currentUser: _currentUser!,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/shakesquad',
                                  arguments: p,
                                );
                              },
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}

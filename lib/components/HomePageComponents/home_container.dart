import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/Screens/schedulepage.dart';
import 'package:uniball_frontend_2/components/HomePageComponents/eventcard.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/team.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';

class HomeContainer extends StatelessWidget {
  final List<Practice> practices;
  final UserClient currentUser;
  final Team currentTeam;

  const HomeContainer({
    Key? key,
    required this.practices,
    required this.currentUser,
    required this.currentTeam,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 460,
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
          Column(
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 28.0,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Kommande",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  //lägg tillbaka när vi vill implementera kalender api i framtiden
                  // InkWell(
                  //   onTap: () {},
                  //   borderRadius: BorderRadius.circular(4),
                  //   child: Stack(
                  //     children: const [
                  //       Icon(Icons.calendar_today, size: 28.0),
                  //       Positioned(
                  //         bottom: 0,
                  //         right: 0,
                  //         child: Icon(Icons.file_upload, size: 16.0),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 380,
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children:
                      practices
                          .map(
                            (practice) => EventCard(
                              event: practice,
                              currentUser: currentUser,
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
          SizedBox(width: 6),

          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SchedulePage(team: currentTeam),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "Se hela Schemat",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

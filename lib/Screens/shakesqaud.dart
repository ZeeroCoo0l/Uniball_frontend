import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:uniball_frontend_2/Screens/shuffled_teams.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/main.dart'; // Behövs för routeObserver

class ShakeSqaudPage extends StatefulWidget {
  final Practice practice;
  const ShakeSqaudPage({super.key, required this.practice});

  @override
  State<ShakeSqaudPage> createState() => _ShakeSquadPageState();
}

class _ShakeSquadPageState extends State<ShakeSqaudPage> with RouteAware {
  late final ShakeDetector _shakeDetector;
  bool _hasNavigatedToShuffled = false;
  bool groupByPosition = false;
  int teamSize = 2;

  @override
  void initState() {
    super.initState();
    _shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: 2.7,
      onPhoneShake: (_) async {
        final practice = widget.practice;
        if (!_hasNavigatedToShuffled && mounted) {
          _hasNavigatedToShuffled = true;
          _shakeDetector.stopListening();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 6),
              content: Text(
                "Slumpat Lagen! Gå tillbaka för att slumpa om!",
                textAlign: TextAlign.center,
              ),
            ),
          );

          final result = await Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder:
                      (context) => ShuffledTeams(currentPractice: practice),
                ),
              )
              .then((_) {
                _hasNavigatedToShuffled = false;
              });
          if (result != null) {
            setState(() {
              groupByPosition = result['groupByPosition'];
              teamSize = result['teamSize'];
            });
          }
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _shakeDetector.stopListening();
    super.dispose();
  }

  @override
  void didPushNext() {
    _shakeDetector.stopListening();
  }

  @override
  void didPopNext() {
    if (!_hasNavigatedToShuffled) {
      _shakeDetector.startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    final practice = widget.practice;
    List<UserClient> attendees = practice.attendees.toList();
    //int teamSize = (attendees.length / 2).ceil(); //används om vi vill lägga tillbaka knappen för att ändra lagstorlek

    return MainScaffold(
      selectedIndex: -1,
      onTabChange: (index) => handleTabChange(context, index),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 6),
                        content: Text(
                          "Slumpat Lagen! Gå tillbaka för att slumpa om!",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                    Navigator.pushNamed(
                      context,
                      '/shuffledteams',
                      arguments: practice,
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6CBC8C), Color(0xFF1A990E)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Randomize\nSquad',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Image.asset(
                            'assets/shakePhone.png',
                            width: 160,
                            height: 160,
                            color: Color(0xFF4B4B4B),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Skaka',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Närvarande spelare:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // const SizedBox(height: 10),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: attendees.length,
                  itemBuilder: (context, index) {
                    final attendee = attendees[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade700,
                          child: Text(
                            attendee.name.isNotEmpty
                                ? attendee.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          attendee.name,
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          "Favorit position: ${attendee.favoritePosition!.toReadableString}",
                        ),
                      ),
                    );
                  },
                ),
                //kod för framtida utveckling med att dela in efter position, ändra lagstorlek och dela in lag manuellt
                // Switch för gruppindelning
                // ElevatedButton(
                //   onPressed:
                //       () => setState(() => groupByPosition = !groupByPosition),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: const Color(0xFFE8F4E8),
                //     foregroundColor: Colors.black,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     padding: const EdgeInsets.symmetric(horizontal: 16),
                //   ),
                //   child: Row(
                //     children: [
                //       const Text(
                //         "Dela in med position",
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       const Spacer(),
                //       Switch(
                //         value: groupByPosition,
                //         onChanged:
                //             (val) => setState(() => groupByPosition = val),
                //         activeTrackColor: const Color(0xFF4CAF50),
                //         inactiveThumbColor: Colors.white,
                //         inactiveTrackColor: const Color(0xFFE57373),
                //       ),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 12),
                // Lagstorlek
                // ElevatedButton(
                //   onPressed: () {},
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: const Color(0xFFE8F4E8),
                //     foregroundColor: Colors.black,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 16,
                //       vertical: 8,
                //     ),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       const Text(
                //         "Lagstorlek",
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       Row(
                //         children: [
                //           IconButton(
                //             onPressed:
                //                 () => setState(() {
                //                   if (teamSize > 1) teamSize--;
                //                 }),
                //             icon: const Icon(Icons.remove),
                //           ),
                //           Text(teamSize.toString()),
                //           IconButton(
                //             onPressed: () => setState(() => teamSize++),
                //             icon: const Icon(Icons.add),
                //           ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 12),
                // Skapa lag manuellt
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //         builder:
                //             (context) => ManuallyDividePage(
                //               attendees: attendees.map((u) => u.name).toList(),
                //               teamSize: teamSize,
                //             ),
                //       ),
                //     );
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: const Color(0xFFE8F4E8),
                //     foregroundColor: Colors.black,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     minimumSize: const Size(double.infinity, 50),
                //   ),
                //   child: const Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         "Skapa lag manuellt",
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       Icon(Icons.arrow_forward),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

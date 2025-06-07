import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/constants.dart';
import 'package:uniball_frontend_2/entities/team.dart';
import 'package:uniball_frontend_2/Screens/editpractice.dart';
import 'package:uniball_frontend_2/services/backend_team_communication.dart';


class SchedulePage extends StatefulWidget {
  final Team team;

  const SchedulePage({super.key, required this.team});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late Team team;
  final Set<int> _expandedItems = {};
  final BackendTeamCommunication _backendTeam = BackendTeamCommunication();

  @override
  void initState() {
    super.initState();
    team = widget.team;
  }
  Future<void> _refreshPractices() async {
  try {
    final updatedTeam = await _backendTeam.getTeam(team.id);
    if (updatedTeam != null) {
      setState(() {
        team = updatedTeam;
      });
    } else {
      debugPrint("Misslyckades att hämta team från backend.");
    }
  } catch (e) {
    debugPrint("Fel vid uppdatering av träningar: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final upcomingPractices =
        team.practices.where((p) => p.date.isAfter(now)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    return MainScaffold(
      selectedIndex: -1,
      onTabChange: (index) => handleTabChange(context, index),
      child: Column(
        children: [
          const Text(
            "Träningar",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Container(height: 1, color: Colors.grey),
          const SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
    onRefresh: _refreshPractices,
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: upcomingPractices.length,
                itemBuilder: (context, index) {
                  final practice = upcomingPractices[index];


                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: !practice.isCancelled ? AppColors.veryLightGreen : Colors.red,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${DateFormat.EEEE('sv_SE').format(practice.date)[0].toUpperCase()}${DateFormat.EEEE('sv_SE').format(practice.date).substring(1)} ${DateFormat.d('sv_SE').format(practice.date)}:e ${DateFormat.MMMM('sv_SE').format(practice.date)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (MainScaffold.isAdmin)
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 22,
                                  color: Colors.black87,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              EditPractice(practice: practice),
                                    ),
                                  );
                                },
                                tooltip: 'Redigera',
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.sports_soccer),
                            const SizedBox(width: 8),
                            Text(
                              "${practice.name} ${DateFormat.Hm().format(practice.date)}, ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on),
                            const SizedBox(width: 8),
                            Text(
                              practice.location,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.info_outline),
                            const SizedBox(width: 8),
                            Text(
                              "Information",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 32, top: 4),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              practice.information,
                              softWrap: true,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_expandedItems.contains(index)) {
                                _expandedItems.remove(index);
                              } else {
                                _expandedItems.add(index);
                              }
                            });
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.group),
                              const SizedBox(width: 8),
                              Text(
                                "${practice.attendees.length} anmälda",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              //const Spacer(),
                              Icon(
                                _expandedItems.contains(index)
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        if (_expandedItems.contains(index))
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                practice.attendees
                                    .map(
                                      (attendee) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Text(attendee.toString()),
                                      ),
                                    )
                                    .toList(),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      )],
      ),
    );
  }
}

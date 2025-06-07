import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/constants.dart';
import 'package:uniball_frontend_2/entities/event.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_practice_communication.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';
import 'package:uniball_frontend_2/Screens/editpractice.dart';

class EventPopUp extends StatefulWidget {
  final Event event;

  const EventPopUp({super.key, required this.event});

  @override
  _EventPopUpState createState() => _EventPopUpState();
}

class _EventPopUpState extends State<EventPopUp> {
  bool _isExpanded = false;
  final database = BackendUserCommunication();

  UserClient? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    UserClient? user = await database.getCurrentUser();
    if (mounted) {
      setState(() {
        currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final Practice practice = event as Practice;
    final backend = BackendPracticeCommunication();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.veryLightGreen,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat.EEEE('sv_SE').format(event.date) +
                ' ' +
                DateFormat.d().format(event.date) +
                ":e",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (MainScaffold.isAdmin)
            IconButton(
              icon: const Icon(Icons.edit, size: 22, color: Colors.black87),
              onPressed: () {
                Navigator.pop(context); // Stäng popup först
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            EditPractice(practice: widget.event as Practice),
                  ),
                );
              },
              tooltip: 'Redigera',
            ),
        ],
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_soccer),
              const SizedBox(width: 8),
              Text("${event.name} ${DateFormat.Hm().format(event.date)}"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on),
              const SizedBox(width: 8),
              Text(event.location),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text("Information", style: TextStyle()),
                ],
              ),
              const SizedBox(height: 4),
              Text((event.information), softWrap: true),
            ],
          ),

          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                const Icon(Icons.group),
                const SizedBox(width: 8),
                Text("${event.attendees.length} anmälda"),
                const Spacer(),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),

          const Divider(),
          if (_isExpanded)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  event.attendees
                      .map(
                        (attendee) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(attendee.toString()),
                        ),
                      )
                      .toList(),
            ),
          const SizedBox(height: 16),
          const Text(
            "Kommer du?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),

                onPressed: // Kod för JA tryck
                    currentUser == null
                        ? null
                        : () async {
                          Navigator.pop(context);
                          event.attendees.add(currentUser!);
                          await backend.addAttendee(
                            practice.id.toString(),
                            currentUser!,
                          );
                        },
                child: const Text("JA"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: 
                    currentUser == null
                        ? null
                        : () async {
                          Navigator.pop(context);
                          event.attendees.remove(currentUser);
                          await backend.removeAttendee(
                            practice.id.toString(),
                            currentUser!,
                          );
                        },
                child: const Text("NEJ"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uniball_frontend_2/entities/award.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/Screens/voting1Best.dart';
import 'package:uniball_frontend_2/services/backend_practice_communication.dart';

class PreviousPracticeCard extends StatefulWidget {
  final List<Practice> practices;
  final UserClient currentUser;

  const PreviousPracticeCard({
    Key? key,
    required this.practices,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<PreviousPracticeCard> createState() => _PreviousPracticeCardState();
}

class _PreviousPracticeCardState extends State<PreviousPracticeCard> {
  Practice? latestPastPractice;
  List<Award> awards = [];
  late bool hasVoted;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPracticeAndAwards();
  }

  Future<void> _loadPracticeAndAwards() async {
    final now = DateTime.now();
    final pastPractices =
        widget.practices.where((p) => p.date.isBefore(now)).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    if (pastPractices.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final practice = pastPractices.first;
    final BackendPracticeCommunication bpc = BackendPracticeCommunication();
    final fetchedAwards =
        await bpc.getAwardsFromPractice(practice.id.toString()) ?? [];

    bool userHasVoted = false;
    for (Award award in fetchedAwards) {
      if (award.id == null) continue;
      bool voted = await bpc.hasVoted(award.id!, widget.currentUser.id);
      if (voted) {
        userHasVoted = true;
        break; // No need to check further if one vote is found
      }
    }

    setState(() {
      latestPastPractice = practice;
      awards = fetchedAwards;
      isLoading = false;
      hasVoted = userHasVoted;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || latestPastPractice == null) {
      return const SizedBox.shrink();
    }

    final isAttendee = latestPastPractice!.attendees.any(
      (attendee) => attendee.id == widget.currentUser.id,
    );

    final bool clickable = isAttendee && !hasVoted;

    final String label =
        hasVoted
            ? "Redan röstat!"
            : isAttendee
            ? "Rösta på träningen!"
            : "Du deltog inte.";

    return (latestPastPractice != null && !latestPastPractice!.isCancelled) // Check if cancelled
        ? GestureDetector(
          onTap:
              clickable
                  ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => Voting1Best(
                              currentPractice: latestPastPractice!,
                            ),
                      ),
                    );
                  }
                  : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 91, 184, 128),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${DateFormat.EEEE('sv_SE').format(latestPastPractice!.date)[0].toUpperCase()}${DateFormat.EEEE('sv_SE').format(latestPastPractice!.date).substring(1)} ${DateFormat.d('sv_SE').format(latestPastPractice!.date)}:e ${DateFormat.MMMM('sv_SE').format(latestPastPractice!.date)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      "Senaste träningen",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.how_to_vote,
                      color: clickable ? null : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: clickable ? null : Colors.black,
                        fontStyle:
                            clickable ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        : SizedBox.shrink();
  }
}

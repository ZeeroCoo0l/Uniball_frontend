import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/components/HomePageComponents/eventpopup.dart';
import 'package:uniball_frontend_2/entities/event.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';

// Kort för Hemskärmen

class EventCard extends StatefulWidget {
  final Event event;
  final UserClient currentUser;
  final VoidCallback? onTap; // Optional custom tap handler

  const EventCard({
    super.key,
    required this.event,
    required this.currentUser,
    this.onTap,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    //Kollar om current user finns bland attendees
    bool isAttending = widget.event.attendees.any(
      (user) => user.id == widget.currentUser.id,
    );

    Color? backgroundColor = widget.event.isCancelled ? Colors.red : null;

    return InkWell(
      onTap: // Use custom onTap if provided, otherwise show default popup
          widget.onTap ??
          () {
            showDialog(
              context: context,
              builder: (context) => EventPopUp(event: widget.event),
            ).then((_) {
              // After closing the popup, update the state of the card
              setState(() {}); // Rebuild the widget to reflect any changes
            });
          },
      child: Card(
        color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      (getDaysUntilEvent(widget.event.date)),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.event.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!widget.event.isCancelled) ...[
                    Text(
                      widget.event.formattedDate,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Kl: ${widget.event.formattedTime}"),
                    Text(widget.event.location),
                  ],
                ],
              ),
            ),
            if(!widget.event.isCancelled)
            Positioned(
              top: 5,
              right: 5,
              child: Icon(
                isAttending ? Icons.check_circle : Icons.warning_rounded,
                color: isAttending ? Colors.green : Colors.red,
                size: 25,
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Text(
                widget.event.isCancelled
                    ? 'Inställd!'
                    : (isAttending ? 'Svarat!' : 'Svara Kallelse!'),
                style: TextStyle(
                  fontSize: widget.event.isCancelled ? 20 : 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

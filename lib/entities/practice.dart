import 'package:intl/intl.dart';
import 'package:uniball_frontend_2/entities/event.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';

// implementera excercise funktionalitet om det ska vara med

class Practice extends Event {
  String? teamId;

  Practice({
    required this.teamId,
    required super.name,
    required super.location,
    required DateTime dateTime,
    required super.id,
    super.information,
    super.attendees,
    bool isRead = false,
    bool isCancelled = false,
  }) : super(date: dateTime) {
    this.isRead = isRead;
    this.isCancelled = isCancelled;
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    return {
      "type": "Practice",
      "id": id,
      "date": dateFormat.format(date), 
      "name": name,
      "location": location,
      "information": information,
      "isCancelled": isCancelled,
      "cancelled" : isCancelled,
      "isRead": isRead,
      // Backend expects a nested team object with id
      "team_id":teamId,
      "attendees": attendees.map((e) => e.toJson()).toList(),
    };
  }

  factory Practice.fromJson(Map<String, dynamic> json) {
    return Practice(
      teamId: json['team_id']?.toString(),
      name: json['name'],
      location: json['location'],
      dateTime: DateTime.parse(json['date']),
      id: json['id'],
      isRead: json['read'] ?? false,
      isCancelled: json['cancelled'] ?? false,

      information:
          (json['information'] as String?)?.trim().isEmpty ?? true
              ? "Ingen information än"
              : json['information'],

      attendees:
          (json['attendees'] as List<dynamic>)
              .map((userJson) => UserClient.fromJson(userJson))
              .toSet(),
    );
  }
}

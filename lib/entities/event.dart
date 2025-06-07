import 'package:uniball_frontend_2/entities/userClient.dart';

abstract class Event {
  final int? _id;
  final String _location;
  final String _name;
  final String _information;
  final DateTime _date;
  final Set<UserClient> _attendees;
  bool isRead = false; //används inte
  bool isCancelled = false;

  Event({
    required int? id,
    required DateTime date,
    required String location,
    Set<UserClient>? attendees,
    String information = "",
    required String name,
  }) : _id = id,
       _name = name,
       _location = location,
       _date = date,
       _information =
           (information.trim().isEmpty) ? "Ingen information än" : information,
       _attendees = attendees ?? <UserClient>{};

  // getters
  int? get id => _id;
  String get name => _name;
  String get location => _location;
  String get information => _information;
  DateTime get date => _date;
  Set<UserClient> get attendees => _attendees;

  set information(String information) => _information;

  Map<String, dynamic> toJsonBase() {
    return {
      "id": _id,
      "name": _name,
      "location": _location,
      "date": _date.toIso8601String(),
      "information": _information,
      "isRead": isRead,
      "isCancelled": isCancelled,
      "attendees":
          _attendees
              .map((a) => a.toJson())
              .toList(),
    };
  }

  // Optional formatter
  String get formattedDate =>
      "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}";
  String get formattedTime =>
      "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
}

String getDaysUntilEvent(DateTime EventDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final eventDay = DateTime(EventDate.year, EventDate.month, EventDate.day);
  final difference = eventDay.difference(today).inDays;

  if (difference == 0) return "Idag!";
  if (difference == 1) return "Imorgon";
  return "Om $difference dagar";
}

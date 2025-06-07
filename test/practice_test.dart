import 'package:test/test.dart' as test;
import 'package:uniball_frontend_2/entities/practice.dart';

void main(){
  test.test("Create practice", (){
    Practice practice = Practice(teamId: "1" , name: "Tisdagskväll", location: "Stora planen", dateTime: DateTime.now(), id: 3);

    test.expect(practice, test.isNotNull, reason: "Practice could be created through constructor");
  });

  test.test("Convert practice to JSON", () {
    // Create a Practice object
    Practice practice = Practice(
      teamId: "1",
      name: "Tisdagskväll",
      location: "Stora planen",
      dateTime: DateTime.parse("20250513T18:00:00Z"),
      id: 3,
    );

    // Convert to JSON
    Map<String, dynamic> json = practice.toJson();

    // Verify the JSON structure
    test.expect(json, test.isNotNull, reason: "JSON should not be null.");
    test.expect(json['id'], 3);
    test.expect(json['team_id'], "1");
    test.expect(json['name'], "Tisdagskväll");
    test.expect(json['location'], "Stora planen");
    // Ensure the date string matches the format produced by toJson()
    test.expect(json['date'], "2025-05-13T18:00:00");
  });

  test.test("Create practice from JSON", () {
    // JSON input
    DateTime now = DateTime.now();
    String formattedDate = now.toIso8601String();

    Map<String, dynamic> json = {
      "id": 3,
      "team_id": "1",
      "name": "Tisdagskväll",
      "location": "Stora planen",
      "date": formattedDate,
      "read": false,
      "cancelled" : false,
      "attendees": []
    };

    // Create Practice object from JSON
    Practice practice = Practice.fromJson(json);

    // Verify the Practice object
    test.expect(practice, test.isNotNull, reason: "Practice should be created successfully from JSON");
    test.expect(practice.id, 3);
    test.expect(practice.teamId, "1");
    test.expect(practice.name, "Tisdagskväll");
    test.expect(practice.location, "Stora planen");
    
    test.expect(practice.date, DateTime.parse(formattedDate));
  });
}
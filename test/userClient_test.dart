import 'package:test/test.dart' as test;
import 'package:uniball_frontend_2/entities/award.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';

void main() {
  test.test("Create UserClient", () {
    UserClient user = UserClient(
      "1",
      "Zack",
      "zack@example.com",
      "123456789",
      Position.DEFENDER,
      "A great defender",
      "base64ProfilePic",
      "team1",
      [],
    );

    test.expect(
      user,
      test.isNotNull,
      reason: "UserClient should be created successfully.",
    );
    test.expect(user.id, "1");
    test.expect(user.name, "Zack");
    test.expect(user.email, "zack@example.com");
    test.expect(user.phone, "123456789");
    test.expect(user.favoritePosition, Position.DEFENDER);
    test.expect(user.description, "A great defender");
    test.expect(user.profilePic, "base64ProfilePic");
    test.expect(user.teamId, "team1");
    test.expect(user.awards, test.isEmpty);
  });

  test.test("Convert UserClient to JSON", () {
    UserClient user = UserClient(
      "1",
      "Zack",
      "zack@example.com",
      "123456789",
      Position.DEFENDER,
      "A great defender",
      "base64ProfilePic",
      "team1",
      [],
    );

    Map<String, dynamic> json = user.toJson();

    test.expect(json, test.isNotNull, reason: "JSON should not be null.");
    test.expect(json['id'], "1");
    test.expect(json['name'], "Zack");
    test.expect(json['email'], "zack@example.com");
    test.expect(json['phone'], "123456789");
    test.expect(json['favoritePosition'], "DEFENDER");
    test.expect(json['description'], "A great defender");
    test.expect(json['profilePic'], "base64ProfilePic");
    test.expect(json['awards'], test.isEmpty);
  });

  test.test("Create UserClient from JSON", () {
    Map<String, dynamic> json = {
      "id": "1",
      "name": "Zack",
      "email": "zack@example.com",
      "phone": "123456789",
      "favoritePosition": "DEFENDER",
      "description": "A great defender",
      "profilePic": "base64ProfilePic",
      "team_id": "team1",
      "awards": "[]",
    };

    UserClient user = UserClient.fromJson(json);

    test.expect(
      user,
      test.isNotNull,
      reason: "UserClient should be created successfully from JSON.",
    );
    test.expect(user.id, "1");
    test.expect(user.name, "Zack");
    test.expect(user.email, "zack@example.com");
    test.expect(user.phone, "123456789");
    test.expect(user.favoritePosition, Position.DEFENDER);
    test.expect(user.description, "A great defender");
    test.expect(user.profilePic, "base64ProfilePic");
    test.expect(user.teamId, "team1");
    test.expect(user.awards, test.isEmpty);
  });

  test.test("Handle null and default values in UserClient", () {
    UserClient user = UserClient(
      "2",
      "Anna",
      "anna@example.com",
      null,
      null,
      null,
      null,
      null,
      null,
    );

    test.expect(
      user,
      test.isNotNull,
      reason: "UserClient should handle null values.",
    );
    test.expect(user.id, "2");
    test.expect(user.name, "Anna");
    test.expect(user.email, "anna@example.com");
    test.expect(user.phone, test.isNull);
    test.expect(user.favoritePosition, Position.NOPOSITION);
    test.expect(user.description, "");
    test.expect(user.profilePic, "");
    test.expect(user.teamId, "");
    test.expect(user.awards, test.isEmpty);
  });

  test.test("Create UserClient with awards", () {
    List<Award> awards = [
      Award(
        id: 1,
        practiceId: 101,
        description: "Best Player",
        type: Type.MVP,
        value: Value.GOLD,
      ),
      Award(
        id: 2,
        practiceId: 102,
        description: "Top Scorer",
        type: Type.GOAL,
        value: Value.SILVER,
      ),
    ];

    UserClient user = UserClient(
      "1",
      "Zack",
      "zack@example.com",
      "123456789",
      Position.DEFENDER,
      "A great defender",
      "base64ProfilePic",
      "team1",
      awards,
    );

    test.expect(
      user,
      test.isNotNull,
      reason: "UserClient should be created successfully.",
    );
    test.expect(
      user.awards,
      test.isNotEmpty,
      reason: "Awards list should not be empty.",
    );
    test.expect(
      user.awards.length,
      2,
      reason: "Awards list should contain 2 awards.",
    );
    test.expect(user.awards[0].description, "Best Player");
    test.expect(user.awards[1].type, Type.GOAL);
  });

  test.test("Convert UserClient with awards to JSON", () {
    List<Award> awards = [
      Award(
        id: 1,
        practiceId: 101,
        description: "Best Player",
        type: Type.MVP,
        value: Value.GOLD,
      ),
      Award(
        id: 2,
        practiceId: 102,
        description: "Top Scorer",
        type: Type.GOAL,
        value: Value.SILVER,
      ),
    ];

    UserClient user = UserClient(
      "1",
      "Zack",
      "zack@example.com",
      "123456789",
      Position.DEFENDER,
      "A great defender",
      "base64ProfilePic",
      "team1",
      awards,
    );

    Map<String, dynamic> json = user.toJson();

    test.expect(json, test.isNotNull, reason: "JSON should not be null.");
    test.expect(
      json['awards'],
      test.isNotEmpty,
      reason: "Awards list in JSON should not be empty.",
    );
    test.expect(
      json['awards'].length,
      2,
      reason: "Awards list in JSON should contain 2 awards.",
    );
    test.expect((json['awards'][0] as Map<String,dynamic>)['description'], "Best Player");
    test.expect((json['awards'][1] as Map<String,dynamic>)['type'], "GOAL");
  });

  test.test("Create UserClient from JSON with awards", () {
    Map<String, dynamic> json = {
      "id": "1",
      "name": "Zack",
      "email": "zack@example.com",
      "phone": "123456789",
      "favoritePosition": "DEFENDER",
      "description": "A great defender",
      "profilePic": "base64ProfilePic",
      "team_id": "team1",
      "awards": [
        {
          "id": 1,
          "eventId": 101,
          "description": "Best Player",
          "type": "MVP",
          "value": "GOLD",
        },
        {
          "id": 2,
          "eventId": 102,
          "description": "Top Scorer",
          "type": "GOAL",
          "value": "SILVER",
        },
      ],
    };

    UserClient user = UserClient.fromJson(json);

    test.expect(
      user,
      test.isNotNull,
      reason: "UserClient should be created successfully from JSON.",
    );
    test.expect(
      user.awards,
      test.isNotEmpty,
      reason: "Awards list should not be empty.",
    );
    test.expect(
      user.awards.length,
      2,
      reason: "Awards list should contain 2 awards.",
    );
    test.expect(user.awards[0].description, "Best Player");
    test.expect(user.awards[1].type, Type.GOAL);
  });

  test.test("Set UserClient name to default", () {
    UserClient user = UserClient(
      "1",
      "Zack",
      "zack@example.com",
      "123456789",
      Position.DEFENDER,
      "A great defender",
      "base64ProfilePic",
      "team1",
      [],
    );

    user.setName = '';

    test.expect(
      user,
      test.isNotNull,
      reason: "UserClient should handle empty string.",
    );
    test.expect(user.name, "default");
  });

  test.test("Update UserClient email", () {
    UserClient user = UserClient(
      "1",
      "Zack",
      "zack@example.com",
      "123456789",
      Position.DEFENDER,
      "A great defender",
      "base64ProfilePic",
      "team1",
      [],
    );

    user.setEmail = "new_email@example.com";

    test.expect(
      user,
      test.isNotNull,
      reason: "UserClient should handle email update.",
    );
    test.expect(user.email, "new_email@example.com");
  });
}

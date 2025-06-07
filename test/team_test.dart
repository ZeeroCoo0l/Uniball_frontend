import 'package:flutter_test/flutter_test.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/team.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:intl/intl.dart';

void main() {
  group('Team', () {
    late UserClient mockUser1;
    late UserClient mockUser2;
    late Practice mockPractice1;
    late Practice mockPractice2;
    late DateTime testDate;
    final dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");


    setUp(() {
      testDate = DateTime(2023, 1, 1, 10, 0, 0);
      mockUser1 = UserClient(
        'user1',
        'User One',
        'user1@example.com',
        null,
        null,
        null,
        null,
        null,
        null,
      );
      mockUser2 = UserClient(
        'user2',
        'User Two',
        'user2@example.com',
        null,
        null,
        null,
        null,
        null,
        null,
      );
      mockPractice1 = Practice(
        id: 1,
        name: 'Practice One',
        location: 'Location A',
        dateTime: testDate,
        information: 'First practice',
        teamId: "team1"
      );
      mockPractice2 = Practice(
        id: 2,
        name: 'Practice Two',
        location: 'Location B',
        dateTime: testDate.add(const Duration(days: 1)),
        information: 'Second practice',
        teamId: "team1"
      );
    });

    test('constructor creates a team with default values', () {
      final team = Team(
        id: 'team1',
        name: 'Team Alpha',
        createdAt: testDate,
      );
      expect(team.id, 'team1');
      expect(team.name, 'Team Alpha');
      expect(team.createdAt, testDate);
      expect(team.players, isEmpty);
      expect(team.practices, isEmpty);
      expect(team.admins, isEmpty);
    });

    test('constructor creates a team with provided values', () {
      final team = Team(
        id: 'team2',
        name: 'Team Beta',
        createdAt: testDate,
        players: {mockUser1},
        practices: [mockPractice1],
        teamAdmins: {mockUser2},
      );
      expect(team.id, 'team2');
      expect(team.name, 'Team Beta');
      expect(team.createdAt, testDate);
      expect(team.players, {mockUser1});
      expect(team.practices, [mockPractice1]);
      expect(team.admins, {mockUser2});
    });

    test('addPlayers adds a player to the team', () {
      final team = Team(id: 't1', name: 'Test Team', createdAt: testDate);
      expect(team.addPlayers(mockUser1), isTrue);
      expect(team.players, contains(mockUser1));
    });

    test('removePlayers removes a player from the team', () {
      final team = Team(id: 't1', name: 'Test Team', createdAt: testDate, players: {mockUser1});
      expect(team.removePlayers(mockUser1), isTrue);
      expect(team.players, isNot(contains(mockUser1)));
    });

    test('addPractice adds a practice to the team', () {
      final team = Team(id: 't1', name: 'Test Team', createdAt: testDate);
      expect(team.addPractice(mockPractice1), isTrue);
      expect(team.practices, contains(mockPractice1));
    });

    test('removePractice should remove a practice from the team', () {
      final team = Team(id: 't1', name: 'Test Team', createdAt: testDate, practices: [mockPractice1]);
      expect(team.removePractice(mockPractice1), isTrue);
      expect(team.practices, isNot(contains(mockPractice1)));
    });

    test('addAdminToTeam  should add an admin to the team', () {
      final team = Team(id: 't1', name: 'Test Team', createdAt: testDate);
      expect(team.addAdminToTeam(mockUser1), isTrue);
      expect(team.admins, contains(mockUser1));
    });

    test('removeAdminToTeam removes an admin from the team', () {
      final team = Team(id: 't1', name: 'Test Team', createdAt: testDate, teamAdmins: {mockUser1});
      expect(team.removeAdminToTeam(mockUser1), isTrue);
      expect(team.admins, isNot(contains(mockUser1)));
    });

    test('toJson serializez team to JSON', () {
      final team = Team(
        id: 'teamJson1',
        name: 'JSON Team',
        createdAt: testDate,
        players: {mockUser1},
        practices: [mockPractice1],
        teamAdmins: {mockUser2},
      );
      final json = team.toJson();

      expect(json['id'], 'teamJson1');
      expect(json['name'], 'JSON Team');
      expect(json['createdAt'], dateFormat.format(testDate));
      expect(json['players'], [mockUser1.toJson()]);
      expect(json['practices'], [mockPractice1.toJson()]);
      expect(json['teamAdmins'], [mockUser2.toJson()]);
    });

    test('fromJson deserializes JSON to team object', () {
      final json = {
        'id': 'teamJson2',
        'name': 'JSON Team Two',
        'createdAt': dateFormat.format(testDate),
        'players': [mockUser1.toJson()],
        'practices': [mockPractice1.toJson()],
        'teamAdmins': [mockUser2.toJson()],
      };
      final team = Team.fromJson(json);

      expect(team.id, 'teamJson2');
      expect(team.name, 'JSON Team Two');
      expect(team.createdAt, testDate);
      expect(team.players.first.id, mockUser1.id);
      expect(team.practices.first.id, mockPractice1.id);
      expect(team.admins.first.id, mockUser2.id);
    });
     test('toString returns a formatted string representation', () {
      final team = Team(
        id: 'teamString',
        name: 'String Team',
        createdAt: testDate,
        players: {mockUser1},
        practices: [mockPractice1],
        teamAdmins: {mockUser2},
      );
      final expectedString = '''
Team Name: String Team
Team ID: teamString
Created At: ${testDate.toString()}
Players: [User One]
Practices: [Practice One]
Team Admins: [User Two]
''';
      expect(team.toString(), expectedString);
    });
  });
}

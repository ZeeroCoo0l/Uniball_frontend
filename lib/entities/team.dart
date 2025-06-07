import 'package:intl/intl.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';

class Team {
  late final DateTime _createdAt;
  late String _id;
  late String _name;
  late Set<UserClient> _players;
  late List<Practice> _practices;
  late Set<UserClient> _teamAdmins;

  Team({
    required String id,
    required String name,
    required DateTime createdAt,
    List<Practice>? practices,
    Set<UserClient>? players,
    Set<UserClient>? teamAdmins,
  }) : _id = id,
       _createdAt = createdAt, //DateTime.now(),
       _name = name,
       _players = players ?? Set(),
       _practices = practices ?? [],
       _teamAdmins =
           teamAdmins ?? Set(); // Creator is added as the first team admin

  String get id => _id;
  String get name => _name;
  Set<UserClient> get players => _players;
  List<Practice> get practices => _practices;
  Set<UserClient> get admins => _teamAdmins;
  DateTime get createdAt => _createdAt;

  bool addPractice(Practice practice) {
    _practices.add(practice);
    return true;
  }

  bool removePractice(Practice practice) {
    _practices.remove(practice);
    return true;
  }

  bool addPlayers(UserClient userClient) {
    _players.add(userClient);
    return true;
  }

  bool removePlayers(UserClient userClient) {
    _players.remove(userClient);
    return true;
  }

  bool addAdminToTeam(UserClient userClient) {
    _teamAdmins.add(userClient);
    return true;
  }

  bool removeAdminToTeam(UserClient userClient) {
    _teamAdmins.remove(userClient);
    return true;
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    return {
      'id': int.tryParse(id) ?? id,
      'name': name,
      'createdAt': dateFormat.format(
        createdAt,
      ),
      'players': players.map((p) => p.toJson()).toList(),
      'practices': practices.map((p) => p.toJson()).toList(),
      'teamAdmins': _teamAdmins.map((a) => a.toJson()).toList(),
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    final practicesFromJson =
        json['practices'] != null
            ? (json['practices'] as List)
                .map((p) => Practice.fromJson(p))
                .toList()
            : <Practice>[];

    final playersFromJson =
        json['players'] != null
            ? (json['players'] as List)
                .map((p) => UserClient.fromJson(p))
                .toSet()
            : <UserClient>{};

    final teamAdminsFromJson =
        json['teamAdmins'] != null
            ? (json['teamAdmins'] as List)
                .map((a) => UserClient.fromJson(a))
                .toSet()
            : <UserClient>{};

    return Team(
      id: json['id'].toString(),
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      practices: practicesFromJson,
      players: playersFromJson,
      teamAdmins: teamAdminsFromJson,
    );
  }

  @override
  String toString() {
    final playerNames = _players.map((p) => p.name).join(', ');
    final practiceNames = _practices.map((p) => p.name).join(', ');
    final adminNames = _teamAdmins.map((a) => a.name).join(', ');

    return '''
Team Name: $_name
Team ID: $_id
Created At: $_createdAt
Players: [$playerNames]
Practices: [$practiceNames]
Team Admins: [$adminNames]
''';
  }
}

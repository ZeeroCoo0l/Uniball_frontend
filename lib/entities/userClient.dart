import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:uniball_frontend_2/entities/award.dart';

//OBS! Inte ändra dessa till små bokstäver,
//ha de såhär för att förenkla json-konvertering.
enum Position {
  GOALKEEPER,
  DEFENDER,
  MIDFIELDER,
  FORWARD,
  NOPOSITION;

  String get toReadableString {
    switch (this) {
      case Position.GOALKEEPER:
        return "Målvakt";
      case Position.DEFENDER:
        return "Försvarare";
      case Position.MIDFIELDER:
        return "Mittfältare";
      case Position.FORWARD:
        return "Anfallare";
      case Position.NOPOSITION:
        return "Ingen position";
    }
  }
}

class UserClient {
  late String _id;
  late String _name;
  late String _email;
  late String? _phone;
  late Position _favoritePosition;
  late String _description;
  late String _profilePic;
  late String _teamId;
  List<Award> _awards = [];

  UserClient(
    String id,
    String name,
    String email,
    String? phone,
    Position? pos,
    String? desc,
    String? profilePic,
    String? teamId,
    List<Award>? awards,
  ) {
    _id = id;
    _name = UserClient._sanitizeInput(name);

    if (UserClient._isEmailValid(email)) {
      _email = UserClient._sanitizeInput(email);
    } else {
      _email = '';
    }
    _phone = phone;
    _favoritePosition = pos ?? Position.NOPOSITION;
    _description = UserClient._sanitizeInput(desc ?? "");
    _profilePic = profilePic ?? "";
    _teamId = teamId ?? "";
    _awards = awards ?? [];
  }

  factory UserClient.fromJson(Map<String, dynamic> json) {
    Position position = UserClient._getPosition(json['favoritePosition']);
    List<Award> awardsList = UserClient._getAwards(json['awards']);
    return UserClient(
      json['id'].toString(),
      json['name'] ?? '',
      json['email'],
      json['phone'],
      position,
      json['description'],
      json['profilePic'],
      json['team_id']?.toString(),
      awardsList,
    );
  }

  String get name => _name;
  String get email => _email;
  String? get phone => _phone;
  String get id => _id;
  Position? get favoritePosition => _favoritePosition;
  String get description => _description;
  String get profilePic => _profilePic;
  String get teamId => _teamId;
  List<Award> get awards => _awards;

  set setTeamId(String? teamId) {
    _teamId = teamId ?? "";
  }

  set setId(String id) {
    _id = id;
  }

  set setName(String name) {
    if (name.isEmpty) {
      _name = 'default';
      return;
    }
    _name = UserClient._sanitizeInput(name);
  }

  set setphone(String phone) {
    if (phone.isEmpty) {
      return;
    }
    _phone = phone;
  }

  set setEmail(String email) {
    if (email.isEmpty || !UserClient._isEmailValid(email)) {
      return;
    }
    _email = UserClient._sanitizeInput(email);
  }

  set setFavoritePos(Position pos) {
    if (pos == Position.NOPOSITION) {
      return;
    }
    _favoritePosition = pos;
  }

  set setDescription(String desc) {
    _description = UserClient._sanitizeInput(desc);
  }

  set setProfilePic(String picture) {
    _profilePic = picture;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': _name,
      'email': email,
      'phone': phone != null ? phone.toString() : "",
      'favoritePosition':
          favoritePosition != null && favoritePosition != Position.NOPOSITION
              ? favoritePosition!.name.toString()
              : "",
      'description': description,
      'profilePic': profilePic,
      'awards': _awards.map((award) => award.toJson()).toList(),
      'team_id': teamId,
    };
  }

  @override
  String toString() {
    return _name;
  }

  static bool _isEmailValid(String? email) {
    if (email == null || email.isEmpty) {
      return false;
    }
    // Regex allows single quotes for later sanitization
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+'-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    if (!emailRegex.hasMatch(email)) {
      return false;
    }
    return true;
  }

  static String _sanitizeInput(String? input) {
    if (input == null || input.isEmpty) {
      return input ?? '';
    }
    String sanitized = input;
    sanitized = sanitized.replaceAll("'", "''");
    sanitized = sanitized.replaceAll(";", "");
    sanitized = sanitized.replaceAll("--", "");
    return sanitized;
  }

  static Position _getPosition(String? positionString) {
    if (positionString == null) {
      return Position.NOPOSITION;
    }
    switch (positionString.toUpperCase()) {
      case "GOALKEEPER":
        return Position.GOALKEEPER;
      case "DEFENDER":
        return Position.DEFENDER;
      case "MIDFIELDER":
        return Position.MIDFIELDER;
      case "FORWARD":
        return Position.FORWARD;
      default:
        return Position.NOPOSITION;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserClient &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  static List<Award> _getAwards(dynamic awardJsonList) {
    List<Award> awards = [];
    if (awardJsonList == null) return awards;

    if (awardJsonList is List) {
      for (var p in awardJsonList) {
        if (p is Map<String, dynamic>) {
          awards.add(Award.fromJson(p));
        } else if (p is Award) {
          awards.add(p);
        }
      }
    } else if (awardJsonList is String) {
      try {
        final List<dynamic> parsed = jsonDecode(awardJsonList);
        for (var p in parsed) {
          if (p is Map<String, dynamic>) {
            awards.add(Award.fromJson(p));
          }
        }
      } catch (e) {
        debugPrint("Error parsing awards string: $e");
      }
    }
    return awards;
  }
}

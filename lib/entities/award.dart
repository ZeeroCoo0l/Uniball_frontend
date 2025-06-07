enum Type { GOAL, MVP, PLAYER_OF_THE_EVENING, NO_VALUE }

enum Value { GOLD, SILVER, BRONZE, NO_VALUE }

class Award {
  late int? id;
  late int practiceId;
  late String? description;
  late Type type;
  late Value value;
  late String? playerId;

  Award({
    this.id,
    required this.practiceId,
    this.description,
    required this.type,
    required this.value,
    this.playerId,
  });

  factory Award.fromJson(Map<String, dynamic> json) {
    print("DEBUG: Deserializing individual Award from JSON: $json");
    Map<String, dynamic>? practiceJson =
        json['practice'] as Map<String, dynamic>?;

    int pId = practiceJson?['id'] as int? ?? 0;

    return Award(
      id: json['id'] as int?,
      practiceId: pId,
      description: json['description'] as String?,
      type: _getType(json['type'] as String?),
      value: _getValue(json['value'] as String?),
      playerId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "practiceId": practiceId,
      "description": description ?? "",
      "type": type.name,
      "value": value.name,
      "user_id": playerId,
    };
  }

  static Type _getType(String? json) {
    if (json == null || json.isEmpty) {
      return Type.NO_VALUE;
    }
    switch (json.toUpperCase()) {
      case "GOAL":
        return Type.GOAL;
      case "MVP":
        return Type.MVP;
      case "PLAYER_OF_THE_EVENING":
        return Type.PLAYER_OF_THE_EVENING;
      default:
        return Type.NO_VALUE;
    }
  }

  static Value _getValue(json) {
    if (json == null || json.isEmpty) {
      return Value.NO_VALUE;
    }
    switch (json.toUpperCase()) {
      case "GOLD":
        return Value.GOLD;
      case "SILVER":
        return Value.SILVER;
      case "BRONZE":
        return Value.BRONZE;
      default:
        return Value.NO_VALUE;
    }
  }
}

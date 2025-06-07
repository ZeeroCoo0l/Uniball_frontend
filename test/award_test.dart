import 'package:test/test.dart' as test;
import 'package:uniball_frontend_2/entities/award.dart';

void main() {
  test.test("Create award", () {
    Award award = Award(
      practiceId: 1,
      type: Type.MVP,
      value: Value.BRONZE,
    );
    print(award.toJson());
    test.expect(award, test.isNotNull, reason: "Award should not be null");
  });

  test.test("Create award from JSON", () {
    Map<String, dynamic> json = {
        "id": 1,
        "practice": {"id": 4},
        "description": "",
        "type": "MVP",
        "value": "GOLD",
        "user_id": null
    };
    
    Award award = Award.fromJson(json);
    print(award.toJson());
    
    // Verify the award was created correctly from JSON
    test.expect(award, test.isNotNull, reason: "Award should be created successfully from JSON");
    test.expect(award.id, test.equals(1));
    test.expect(award.practiceId, test.equals(4));
    test.expect(award.type, test.equals(Type.MVP));
    test.expect(award.value, test.equals(Value.GOLD));
    test.expect(award.playerId, test.isNull);
  });

  test.test("Convert award to json", (){
    Map<String, dynamic> json = {
        "id": 1,
        "practiceId": 4,
        "description": "Description",
        "type": "MVP",
        "value": "GOLD",
        "user_id": "player123"
    };

    Award award = Award(id:1, practiceId: 4, description: "Description", type: Type.MVP, value: Value.GOLD, playerId: "player123");
    print(award.toJson());
    test.expect(award, test.isNotNull);
    test.expect(award.toJson(), json, reason: "Award to json should be in correct format");
  });

}



import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bassoon_scheduler_app/models/attendant.dart';

class BassoonLesson {
  BassoonLesson(this.lesson_id, this.bassoon_class, this.created_by_id,
      this.created_by_name,
      this.date, this.description, [this.lessons]);

  String lesson_id;
  String bassoon_class;
  String? created_by_id;
  String? created_by_name;
  Timestamp? date;
  String? description;

  List<SingleLesson>? lessons;

  Map<String, dynamic> toJson() {
    return {
      "lesson id": lesson_id,
      "bassoon class": bassoon_class,
      "created by id": created_by_id,
      "created by name": created_by_name,
      "date": date,
      "description": description,
      "lessons": lessons?.map((lesson) {
        return lesson.toJson();
      }).toList()
    };
  }

  Map<String, dynamic> lessonsToJson() {
    return {
      "lessons": lessons?.map((lesson) {
        return lesson.toJson();
      }).toList()
    };
  }

  static BassoonLesson fromJson(Map<String, dynamic> json) {
    if (json['lessons'] != null) {
      var lessonObjsJson = json['lessons'] as List;
      List<SingleLesson> lessonsList = lessonObjsJson.map((lessonsJson) =>
          SingleLesson.fromJson(lessonsJson)).toList();
      return BassoonLesson(
          json["lesson id"],
          json["bassoon class"],
          json["created by id"],
          json["created by name"],
          json["date"],
          json["description"],
          lessonsList
      );
    } else {
      return BassoonLesson(
          json["lesson id"],
          json["bassoon class"],
          json["created by id"],
          json["created by name"],
          json["date"],
          json["description"],
          []
      );
    }
  }

}

class SingleLesson {
  SingleLesson(this.attendants, this.time);

  List<Attendant>? attendants;
  Timestamp time;

  Map<String, dynamic> toJson() {
    return {
      "attendees": attendants?.map((attendant) {
        return attendant.toJson();
      }).toList(),
      "time": time
    };
  }

  static SingleLesson fromJson(Map<String, dynamic> json) {
    if (json['attendees'] != null) {
      var attendeesObjsJson = json['attendees'] as List;
      List<Attendant> attendants = attendeesObjsJson.map((attendantJson) =>
          Attendant.fromJson(attendantJson)).toList();
      return SingleLesson(
        attendants,
        json["time"],
      );
    } else {
      return SingleLesson(
          [],
          json["time"]);
    }
  }
}

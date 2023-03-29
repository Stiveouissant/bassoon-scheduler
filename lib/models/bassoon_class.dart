class BassoonClass {
  BassoonClass(this.class_name, this.attendees_count, this.created_by_name,
      this.created_by_id, [this.attendees]);

  String class_name;
  int attendees_count;
  String? created_by_name;
  String? created_by_id;
  List</*Map<String?, dynamic>*/dynamic>? attendees;

  Map<String, dynamic> toJson(bool withAttends) {
    if(withAttends) {
      return {
        "class name": class_name,
        "attendees count": attendees_count,
        "created by name": created_by_name,
        "created by id": created_by_id,
        "attendees": attendees
      };
    }else{
      return {
        "class name": class_name,
        "attendees count": attendees_count,
        "created by name": created_by_name,
        "created by id": created_by_id,
      };
    }
  }

  static BassoonClass fromJson(Map<String, dynamic> json, bool withAttends){
    if(withAttends)
      {
        return BassoonClass(
            json["class name"],
            json["attendees count"],
            json["created by name"],
            json["created by id"],
            json["attendees"]
        );
      }else{
      return BassoonClass(
          json["class name"],
          json["attendees count"],
          json["created by name"],
          json["created by id"],
      );
    }
  }
}

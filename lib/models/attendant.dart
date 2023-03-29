class Attendant{
  Attendant(this.uid, this.name);

  String? uid;
  String? name;

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name
    };
  }

  static Attendant fromJson(Map<String, dynamic> json){
    return Attendant(
      json["uid"],
      json["name"],
    );
  }
}
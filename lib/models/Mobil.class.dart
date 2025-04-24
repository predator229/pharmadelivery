class Mobil{
  String id;
  String digits;
  String indicatif;
  String title;
  Mobil({required this.id, required this.digits, required this.title, required this.indicatif});

  factory Mobil.fromJson(Map<String, dynamic> json) {
    return Mobil(
      id: json['_id'].toString(),
      digits: json['digits'],
      indicatif: json['indicatif'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'digits': digits,
      'indicatif': indicatif,
      'title': title,
    };
  }
}
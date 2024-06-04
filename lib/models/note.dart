class Note {
  String? id;
  String note;
  bool isFinished;

  Note({
    this.id,
    required this.note,
    this.isFinished = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'isFinished': isFinished,
    };
  }

  Note.fromJson(Map<String, dynamic> json, this.id)
      : note = json['note'],
        isFinished = json['isFinished'];
}

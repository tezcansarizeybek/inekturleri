class QuestionModel {
  QuestionModel({this.id, this.answer, this.email, this.name, this.question, this.datetime});
  String id;
  String name;
  String email;
  String question;
  String answer;
  String datetime;

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
      answer: json["answer"] ?? "",
      email: json["email"] ?? "",
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      question: json["question"] ?? "",
      datetime: json["datetime"] ?? "");

  Map<String, dynamic> toJson() => {
        "answer": answer,
        "email": email,
        "id": id,
        "name": name,
        "question": question,
        "datetime": datetime
      };
}

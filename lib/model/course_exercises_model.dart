
class CourseExerciseModel {


}

class CourseExerciseAnswerModel {

  String? title;
  bool? select;
  bool? submit;
  bool? isCorrect;

  CourseExerciseAnswerModel({
    this.title,
    this.submit,
    this.select,
    this.isCorrect
  });

  CourseExerciseAnswerModel.fromJson(Map<String, dynamic> json) {
    if (json["title"] is String) {
      title = json["title"];
    }
    if (json["isCorrect"] is bool) {
      isCorrect = json["isCorrect"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["title"] = title;
    _data["isCorrect"] = isCorrect;
    return _data;
  }
}
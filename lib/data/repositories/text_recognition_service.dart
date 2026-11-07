import 'package:ubantu/core/errors/app_result.dart';

abstract class ITextRecognitionService {
  Future<AppResult<String>> recognizeText(String imagePath);
}

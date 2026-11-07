import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/text_recognition_service.dart';

class MlKitTextRecognitionService implements ITextRecognitionService {
  @override
  Future<AppResult<String>> recognizeText(String imagePath) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return AppResult.failure('OCR hanya didukung pada platform Android dan iOS');
    }

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);
      return AppResult.success(recognizedText.text);
    } catch (e) {
      return AppResult.failure('Gagal memproses gambar: $e');
    } finally {
      await textRecognizer.close();
    }
  }
}

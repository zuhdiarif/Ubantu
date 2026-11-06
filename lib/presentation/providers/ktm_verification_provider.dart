import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/domain/models/ktm_ocr_result.dart';
import 'package:ubantu/domain/usecases/extract_ktm_data_usecase.dart';

class KtmVerificationProvider extends ChangeNotifier {
  final ExtractKtmDataUseCase _extractKtmDataUseCase;

  KtmVerificationProvider({ExtractKtmDataUseCase? extractKtmDataUseCase})
      : _extractKtmDataUseCase =
            extractKtmDataUseCase ?? ServiceLocator.instance.extractKtmDataUseCase;

  bool _isScanning = false;
  String? _scanningStatus;
  KtmOcrResult? _ocrResult;
  String? _recognizedNim;
  String? _bannerMessage;
  bool _isWarningBanner = false;
  bool _isInfoBanner = false;
  File? _selectedFile;

  bool get isScanning => _isScanning;
  String? get scanningStatus => _scanningStatus;
  KtmOcrResult? get ocrResult => _ocrResult;
  String? get recognizedNim => _recognizedNim;
  String? get bannerMessage => _bannerMessage;
  bool get isWarningBanner => _isWarningBanner;
  bool get isInfoBanner => _isInfoBanner;
  File? get selectedFile => _selectedFile;

  Future<KtmOcrResult?> scanKtm(File file) async {
    _selectedFile = file;
    _isScanning = true;
    _scanningStatus = 'Membaca KTM...';
    _bannerMessage = null;
    _isWarningBanner = false;
    _isInfoBanner = false;
    notifyListeners();

    try {
      final result = await _extractKtmDataUseCase.execute(file.path);
      _isScanning = false;
      _scanningStatus = null;

      if (result.isSuccess && result.data != null) {
        final data = result.data!;
        _ocrResult = data;
        _recognizedNim = data.nim;

        if (!data.looksLikeKtm) {
          _isWarningBanner = true;
          _bannerMessage = 'Foto tidak terlihat seperti KTM, pastikan foto jelas';
        } else if (data.nim == null || data.nim!.isEmpty) {
          _isInfoBanner = true;
          _bannerMessage =
              'NIM tidak terdeteksi otomatis. Silakan masukkan NIM secara manual.';
        }
        notifyListeners();
        return data;
      } else {
        _isInfoBanner = true;
        _bannerMessage =
            'Tidak dapat membaca teks otomatis. Silakan masukkan NIM secara manual.';
        notifyListeners();
        return null;
      }
    } catch (_) {
      _isScanning = false;
      _scanningStatus = null;
      _isInfoBanner = true;
      _bannerMessage =
          'Gagal memproses OCR. Silakan masukkan NIM secara manual.';
      notifyListeners();
      return null;
    }
  }

  void clearBanner() {
    _bannerMessage = null;
    _isWarningBanner = false;
    _isInfoBanner = false;
    notifyListeners();
  }

  void setSelectedFile(File? file) {
    _selectedFile = file;
    notifyListeners();
  }
}

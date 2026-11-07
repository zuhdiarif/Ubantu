import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/ktm_ocr_result.dart';
import 'package:ubantu/data/repositories/text_recognition_service.dart';

class ExtractKtmDataUseCase {
  final ITextRecognitionService _textRecognitionService;

  ExtractKtmDataUseCase(this._textRecognitionService);

  Future<AppResult<KtmOcrResult>> execute(String imagePath) async {
    final recognitionResult =
        await _textRecognitionService.recognizeText(imagePath);
    if (!recognitionResult.isSuccess) {
      return AppResult.failure(
        recognitionResult.errorMessage ?? 'Gagal membaca teks dari berkas KTM',
      );
    }

    final rawText = recognitionResult.data ?? '';
    final parsed = parseKtmText(rawText);
    return AppResult.success(parsed);
  }

  KtmOcrResult parseKtmText(String text) {
    final looksLikeKtm = _validateLooksLikeKtm(text);
    final nim = _extractNim(text);
    final name = _extractName(text);

    return KtmOcrResult(
      nim: nim,
      looksLikeKtm: looksLikeKtm,
      name: name,
      rawText: text,
    );
  }

  bool _validateLooksLikeKtm(String text) {
    final upper = text.toUpperCase();
    return upper.contains('UNIVERSITAS BRAWIJAYA') ||
        upper.contains('BRAWIJAYA') ||
        upper.contains('KARTU TANDA MAHASISWA') ||
        upper.contains('KTM') ||
        upper.contains('MAHASISWA');
  }

  String? _extractNim(String text) {
    if (text.trim().isEmpty) return null;

    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final keywordPattern = RegExp(
      r'(?:NIM|No\.?\s*Mahasiswa|Nomor\s*Mahasiswa)',
      caseSensitive: false,
    );

    final candidateMatches = <_ScoredNim>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isKeywordLine = keywordPattern.hasMatch(line);

      final lineCandidates = _findDigitSequences(line);
      for (final candidate in lineCandidates) {
        int score = 0;
        if (isKeywordLine) {
          score += 100;
        }
        if (candidate.length == 15) {
          score += 30;
        }
        if (_isTypicalUbYearPrefix(candidate)) {
          score += 15;
        }
        if (candidate.startsWith('08') && candidate.length <= 13) {
          score -= 40;
        }
        candidateMatches.add(_ScoredNim(candidate, score));
      }

      if (isKeywordLine) {
        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1];
          final nextCandidates = _findDigitSequences(nextLine);
          for (final candidate in nextCandidates) {
            int score = 80;
            if (candidate.length == 15) {
              score += 30;
            }
            if (_isTypicalUbYearPrefix(candidate)) {
              score += 15;
            }
            candidateMatches.add(_ScoredNim(candidate, score));
          }
        }
        if (i + 2 < lines.length) {
          final afterNextLine = lines[i + 2];
          final afterNextCandidates = _findDigitSequences(afterNextLine);
          for (final candidate in afterNextCandidates) {
            int score = 50;
            if (candidate.length == 15) {
              score += 30;
            }
            if (_isTypicalUbYearPrefix(candidate)) {
              score += 15;
            }
            candidateMatches.add(_ScoredNim(candidate, score));
          }
        }
      }
    }

    if (candidateMatches.isEmpty) {
      final allCandidates = _findDigitSequences(text);
      for (final candidate in allCandidates) {
        int score = 10;
        if (candidate.length == 15) {
          score += 30;
        }
        if (_isTypicalUbYearPrefix(candidate)) {
          score += 15;
        }
        if (candidate.startsWith('08') && candidate.length <= 13) {
          score -= 40;
        }
        candidateMatches.add(_ScoredNim(candidate, score));
      }
    }

    if (candidateMatches.isEmpty) return null;

    candidateMatches.sort((a, b) => b.score.compareTo(a.score));
    final best = candidateMatches.first;
    return best.score > 0 ? best.nim : null;
  }

  bool _isTypicalUbYearPrefix(String nim) {
    if (nim.length < 2) return false;
    final prefix = int.tryParse(nim.substring(0, 2));
    if (prefix == null) return false;
    return prefix >= 15 && prefix <= 30;
  }

  List<String> _findDigitSequences(String input) {
    final results = <String>[];
    final sequencePattern = RegExp(r'\b\d(?:[\s\.]*\d){9,14}\b');
    final matches = sequencePattern.allMatches(input);

    for (final match in matches) {
      final raw = match.group(0) ?? '';
      final normalized = raw.replaceAll(RegExp(r'[\s\.]'), '');
      if (normalized.length >= 10 && normalized.length <= 15) {
        if (!results.contains(normalized)) {
          results.add(normalized);
        }
      }
    }

    return results;
  }

  String? _extractName(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final namePattern = RegExp(
      r'^(?:Nama\s*Lengkap|Nama\s*Mahasiswa|Nama)\s*[:\-]?\s*(.*)$',
      caseSensitive: false,
    );

    for (int i = 0; i < lines.length; i++) {
      final match = namePattern.firstMatch(lines[i]);
      if (match != null) {
        String candidate = match.group(1)?.trim() ?? '';
        if (candidate.isEmpty && i + 1 < lines.length) {
          candidate = lines[i + 1].trim();
        }
        final cleaned = _sanitizeName(candidate);
        if (cleaned != null) return cleaned;
      }
    }
    return null;
  }

  String? _sanitizeName(String candidate) {
    if (candidate.length < 3) return null;
    final upper = candidate.toUpperCase();
    if (upper.contains('UNIVERSITAS') ||
        upper.contains('BRAWIJAYA') ||
        upper.contains('FAKULTAS') ||
        upper.contains('MAHASISWA') ||
        upper.contains('KARTU') ||
        upper.contains('NIM')) {
      return null;
    }
    final nameCleaned =
        candidate.replaceAll(RegExp(r'[^a-zA-Z\s\.\x27]'), '').trim();
    if (nameCleaned.length < 3) return null;
    return nameCleaned;
  }
}

class _ScoredNim {
  final String nim;
  final int score;

  const _ScoredNim(this.nim, this.score);
}

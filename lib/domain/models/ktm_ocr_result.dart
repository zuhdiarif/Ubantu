class KtmOcrResult {
  final String? nim;
  final bool looksLikeKtm;
  final String? name;
  final String? rawText;

  const KtmOcrResult({
    this.nim,
    required this.looksLikeKtm,
    this.name,
    this.rawText,
  });

  KtmOcrResult copyWith({
    String? nim,
    bool? looksLikeKtm,
    String? name,
    String? rawText,
  }) {
    return KtmOcrResult(
      nim: nim ?? this.nim,
      looksLikeKtm: looksLikeKtm ?? this.looksLikeKtm,
      name: name ?? this.name,
      rawText: rawText ?? this.rawText,
    );
  }
}

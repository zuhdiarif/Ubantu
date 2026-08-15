class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  static String? validateNim(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'NIM tidak boleh kosong';
    }
    if (value.trim().length < 10) {
      return 'NIM mahasiswa tidak valid';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor HP tidak boleh kosong';
    }
    if (!value.trim().startsWith('08') || value.trim().length < 10) {
      return 'Nomor HP tidak valid (harus diawali 08)';
    }
    return null;
  }
}

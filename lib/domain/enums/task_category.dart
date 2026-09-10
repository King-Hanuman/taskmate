import 'package:flutter/material.dart';

/// Kategori tugas yang disesuaikan untuk mahasiswa
enum TaskCategory {
  kuliah,
  kepanitiaan,
  personal,
  organisasi,
  lainnya;

  String get label {
    switch (this) {
      case TaskCategory.kuliah:
        return 'Kuliah';
      case TaskCategory.kepanitiaan:
        return 'Kepanitiaan';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.organisasi:
        return 'Organisasi';
      case TaskCategory.lainnya:
        return 'Lainnya';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskCategory.kuliah:
        return Icons.school_rounded;
      case TaskCategory.kepanitiaan:
        return Icons.groups_rounded;
      case TaskCategory.personal:
        return Icons.person_rounded;
      case TaskCategory.organisasi:
        return Icons.corporate_fare_rounded;
      case TaskCategory.lainnya:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TaskCategory.kuliah:
        return const Color(0xFF6C63FF);
      case TaskCategory.kepanitiaan:
        return const Color(0xFFFF6B6B);
      case TaskCategory.personal:
        return const Color(0xFF00D4AA);
      case TaskCategory.organisasi:
        return const Color(0xFFFFA726);
      case TaskCategory.lainnya:
        return const Color(0xFF8E8E9A);
    }
  }
}

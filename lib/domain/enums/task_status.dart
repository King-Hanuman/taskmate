/// Status pengerjaan tugas
enum TaskStatus {
  belumDikerjakan,
  sedangDikerjakan,
  selesai;

  String get label {
    switch (this) {
      case TaskStatus.belumDikerjakan:
        return 'Belum Dikerjakan';
      case TaskStatus.sedangDikerjakan:
        return 'Sedang Dikerjakan';
      case TaskStatus.selesai:
        return 'Selesai';
    }
  }

  String get icon {
    switch (this) {
      case TaskStatus.belumDikerjakan:
        return '⬜';
      case TaskStatus.sedangDikerjakan:
        return '🔄';
      case TaskStatus.selesai:
        return '✅';
    }
  }
}

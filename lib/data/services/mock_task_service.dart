import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/task_model.dart';

class MockTaskService {
  Future<AppResult<List<TaskModel>>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final dummyTasks = [
      const TaskModel(
        id: 't1',
        title: 'Bersih Kos',
        requesterName: 'Nasya',
        rating: 4.8,
        ratingCount: 23,
        category: ServiceCategory.bersihKos,
        location: 'Jl. Merpati No. 12, Yogyakarta',
        date: '2 Jun 2025',
        time: '10:00',
        notes: 'Bantu bersihkan kamar kos.',
      ),
      const TaskModel(
        id: 't2',
        title: 'Pindah Kos',
        requesterName: 'Dinda Putri',
        rating: 4.6,
        ratingCount: 18,
        category: ServiceCategory.pindahKos,
        location: 'Jl. Kaliurang Km 5, Yogyakarta',
        date: '1 Jun 2025',
        time: '14:30',
        notes: 'Bantu angkut barang kos.',
      ),
      const TaskModel(
        id: 't3',
        title: 'Antar Jemput',
        requesterName: 'Bima',
        rating: 4.9,
        ratingCount: 31,
        category: ServiceCategory.antarJemput,
        location: 'Jl. Seturan No. 45, Yogyakarta',
        date: '31 Mei 2025',
        time: '09:00',
        notes: 'Jemput dari stasiun.',
      ),
    ];
    return AppResult.success(dummyTasks);
  }
}

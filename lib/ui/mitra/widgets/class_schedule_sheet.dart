import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/theme/app_colors.dart';
import 'package:ubantu/core/theme/app_typography.dart';
import 'package:ubantu/data/models/student_schedule_model.dart';
import 'package:ubantu/ui/auth/auth_provider.dart';
import 'package:ubantu/ui/mitra/schedule_provider.dart';

class ClassScheduleSheet extends StatefulWidget {
  const ClassScheduleSheet({super.key});

  static Future<void> show(BuildContext context) {
    ScheduleProvider? scheduleProvider;
    try {
      scheduleProvider = context.read<ScheduleProvider>();
    } catch (_) {}

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        if (scheduleProvider != null) {
          return ChangeNotifierProvider<ScheduleProvider>.value(
            value: scheduleProvider,
            child: const ClassScheduleSheet(),
          );
        }
        return const ClassScheduleSheet();
      },
    );
  }

  @override
  State<ClassScheduleSheet> createState() => _ClassScheduleSheetState();
}

class _ClassScheduleSheetState extends State<ClassScheduleSheet> {
  int _selectedDay = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 40);
  final TextEditingController _courseController = TextEditingController();
  String? _validationError;
  bool _isFormExpanded = false;

  final List<Map<String, dynamic>> _days = const [
    {'day': 1, 'name': 'Senin'},
    {'day': 2, 'name': 'Selasa'},
    {'day': 3, 'name': 'Rabu'},
    {'day': 4, 'name': 'Kamis'},
    {'day': 5, 'name': 'Jumat'},
    {'day': 6, 'name': 'Sabtu'},
  ];

  @override
  void dispose() {
    _courseController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && mounted) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && mounted) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _submitSlot() async {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes <= startMinutes) {
      setState(() {
        _validationError = 'Jam selesai harus lebih besar dari jam mulai';
      });
      return;
    }

    final scheduleProvider = context.read<ScheduleProvider>();
    final hasOverlap = scheduleProvider.studentSchedules.any((slot) {
      if (slot.dayOfWeek != _selectedDay) return false;
      return startMinutes < slot.endMinutes && endMinutes > slot.startMinutes;
    });

    if (hasOverlap) {
      setState(() {
        _validationError = 'Jadwal bentrok dengan jam kuliah yang sudah ada';
      });
      return;
    }

    setState(() {
      _validationError = null;
    });

    AuthProvider? auth;
    try {
      auth = context.read<AuthProvider>();
    } catch (_) {}
    final userId = auth?.currentUser?.id ?? 'mitra_current';

    final newSchedule = StudentScheduleModel(
      id: 'cs_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      dayOfWeek: _selectedDay,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      courseName: _courseController.text.trim().isEmpty
          ? null
          : _courseController.text.trim(),
    );

    final success = await scheduleProvider.addStudentSchedule(newSchedule);
    if (!mounted) return;

    if (success) {
      _courseController.clear();
      setState(() {
        _isFormExpanded = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal kuliah berhasil ditambahkan'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else {
      setState(() {
        _validationError =
            scheduleProvider.errorMessage ?? 'Gagal menambahkan jadwal';
      });
    }
  }

  Future<void> _deleteSlot(String slotId) async {
    final scheduleProvider = context.read<ScheduleProvider>();
    final success = await scheduleProvider.deleteStudentSchedule(slotId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal kuliah berhasil dihapus'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final schedules = scheduleProvider.studentSchedules;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Jadwal Kuliah Mitra',
                      style: AppTypography.h5.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Atur jadwal kuliah mingguan untuk mendeteksi potensi bentrok dengan pesanan yang masuk.',
              style: AppTypography.caption.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            _buildAddSlotSection(context),
            const SizedBox(height: 16),
            Text(
              'Jadwal Mingguan (Senin - Sabtu)',
              style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            _buildSchedulesList(context, schedules),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulesList(
    BuildContext context,
    List<StudentScheduleModel> schedules,
  ) {
    if (schedules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                'Belum Ada Jadwal Kuliah',
                style: AppTypography.body2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tambahkan jadwal kuliah agar order masuk dapat terhindar dari bentrok.',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _days.length,
      itemBuilder: (context, index) {
        final dayInfo = _days[index];
        final dayNum = dayInfo['day'] as int;
        final dayName = dayInfo['name'] as String;
        final daySlots =
            schedules.where((s) => s.dayOfWeek == dayNum).toList();

        if (daySlots.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ...daySlots.map(
                (slot) => Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primarySage,
                      child: Icon(
                        Icons.school,
                        color: AppColors.primaryDark,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      slot.courseName ?? 'Mata Kuliah',
                      style: AppTypography.body2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      slot.formattedTime,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: IconButton(
                      key: ValueKey('delete_${slot.id}'),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteSlot(slot.id),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddSlotSection(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isFormExpanded = !_isFormExpanded;
                _validationError = null;
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isFormExpanded
                            ? Icons.remove_circle_outline
                            : Icons.add_circle_outline,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tambah Jadwal Kuliah',
                        style: AppTypography.body2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isFormExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (_isFormExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedDay,
                    decoration: InputDecoration(
                      labelText: 'Pilih Hari',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _days.map((d) {
                      return DropdownMenuItem<int>(
                        value: d['day'] as int,
                        child: Text(d['name'] as String),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedDay = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('start_time_btn'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.access_time, size: 16),
                          label: Text('Mulai: ${_formatTime(_startTime)}'),
                          onPressed: _pickStartTime,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('end_time_btn'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.access_time_filled, size: 16),
                          label: Text('Selesai: ${_formatTime(_endTime)}'),
                          onPressed: _pickEndTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const ValueKey('course_name_field'),
                    controller: _courseController,
                    decoration: InputDecoration(
                      labelText: 'Nama Mata Kuliah (Opsional)',
                      hintText: 'Contoh: Pemrograman Mobile',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  if (_validationError != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _validationError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      key: const ValueKey('save_slot_btn'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text(
                        'Simpan Jadwal Kuliah',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: _submitSlot,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

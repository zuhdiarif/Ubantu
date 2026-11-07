import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/custom_button.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/sos_report_model.dart';
import 'package:ubantu/presentation/providers/sos_provider.dart';

extension SosProviderTrackingExtension on SosProvider {
  SosReportModel? get currentReport => activeReport;

  Future<void> cancelActiveSos() async {
    await updateStatus(SosStatus.completed);
  }
}

extension SosReportModelDetailsExtension on SosReportModel {
  String get details => issueType;
}

class SosActiveTrackingView extends StatelessWidget {
  const SosActiveTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryDark,
          ),
          tooltip: 'Kembali',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.home);
            }
          },
        ),
        title: Text(
          'SOS Aktif',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<SosProvider>(
          builder: (context, sosProvider, _) {
            final report = sosProvider.currentReport;
            final status = report?.status ?? SosStatus.received;
            final isResolved = status == SosStatus.completed || status.name == 'resolved';

            final createdAt = report?.createdAt ?? DateTime.now();
            final receivedTime =
                '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
            final handledDt = createdAt.add(const Duration(minutes: 2));
            final handledTime =
                '${handledDt.hour.toString().padLeft(2, '0')}:${handledDt.minute.toString().padLeft(2, '0')}';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.campaign_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SOS AKTIF',
                                style: AppTypography.body1.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tim kami telah menerima laporanmu dan sedang memproses bantuan.',
                                style: AppTypography.body2.copyWith(
                                  color: const Color(0xFFC62828),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (report?.details != null && report!.details.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primaryDark),
                              const SizedBox(width: 6),
                              Text(
                                'Detail Laporan SOS',
                                style: AppTypography.body2.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            report.details,
                            style: AppTypography.body2.copyWith(
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Status Bantuan',
                    style: AppTypography.h5.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStatusTimeline(
                    status: status,
                    isResolved: isResolved,
                    receivedTime: receivedTime,
                    handledTime: handledTime,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shield_rounded,
                          color: AppColors.primaryGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tetap tenang, tim kami sedang bekerja untuk memastikan kamu aman.',
                            style: AppTypography.body2.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Akhiri Sinyal Darurat (Saya Aman)',
                    type: CustomButtonType.outline,
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: () async {
                      await context.read<SosProvider>().cancelActiveSos();
                      if (context.mounted) {
                        context.go(AppRouter.home);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Hubungi Bantuan',
                    icon: Icons.phone_in_talk_rounded,
                    onPressed: () => context.push(AppRouter.sosFinish),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusTimeline({
    required SosStatus status,
    required bool isResolved,
    required String receivedTime,
    required String handledTime,
  }) {
    return Column(
      children: [
        _buildTimelineStep(
          title: 'Sinyal Darurat Diterima',
          subtitle: 'Laporan kamu telah diterima oleh tim bantuan.',
          time: receivedTime,
          isDone: true,
          isCurrent: status == SosStatus.received,
          isLast: false,
        ),
        _buildTimelineStep(
          title: 'Tim Keamanan Merespons',
          subtitle: 'Tim bantuan sedang memproses laporan dan segera ke lokasi.',
          time: (status == SosStatus.handling || isResolved) ? handledTime : '',
          isDone: status == SosStatus.handling || isResolved,
          isCurrent: status == SosStatus.handling,
          isLast: false,
        ),
        _buildTimelineStep(
          title: 'Tiba di Lokasi & Penanganan Selesai',
          subtitle: 'Bantuan telah diberikan dan situasi dinyatakan aman terkendali.',
          time: '',
          isDone: isResolved,
          isCurrent: isResolved,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required String time,
    required bool isDone,
    required bool isCurrent,
    required bool isLast,
  }) {
    Widget indicator;
    if (isDone && !isCurrent) {
      indicator = Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    } else if (isCurrent) {
      indicator = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: const Center(
          child: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.red,
            ),
          ),
        ),
      );
    } else {
      indicator = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              indicator,
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? Colors.red : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: AppTypography.body2.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.body2.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

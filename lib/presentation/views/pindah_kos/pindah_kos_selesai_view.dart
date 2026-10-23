import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/presentation/providers/rating_provider.dart';

class PindahKosSelesaiView extends StatefulWidget {
  const PindahKosSelesaiView({super.key});

  @override
  State<PindahKosSelesaiView> createState() => _PindahKosSelesaiViewState();
}

class _PindahKosSelesaiViewState extends State<PindahKosSelesaiView> {
  int _rating = 5;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

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
            color: Color(0xFF1E281C),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/pindah_kos_flow/bi_check-circle-fill.svg',
                width: 90,
                height: 90,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF23A23F),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Terimakasih!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.20,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bantuan telah selesai.\nSemoga pengalamanmu menyenangkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.20,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Berikan ulasan',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                        height: 1.20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starNumber = index + 1;
                        final isFilled = starNumber <= _rating;
                        return GestureDetector(
                          onTap: () => setState(() => _rating = starNumber),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: SvgPicture.asset(
                              isFilled
                                  ? 'assets/pindah_kos_flow/bintang-kuning-filled.svg'
                                  : 'assets/pindah_kos_flow/material-symbols_star-rounded.svg',
                              width: 34,
                              height: 34,
                              colorFilter: isFilled
                                  ? null
                                  : const ColorFilter.mode(
                                      Color(0xFFD9D9D9),
                                      BlendMode.srcIn,
                                    ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 0.50,
                            color: Color(0xFF263225),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _reviewController,
                            maxLines: 4,
                            maxLength: 200,
                            onChanged: (_) => setState(() {}),
                            buildCounter: (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) =>
                                Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                '$currentLength/$maxLength',
                                style: const TextStyle(
                                  color: Color(0xFFBFC3BE),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Tulis ulasan kamu (opsional)',
                              hintStyle: TextStyle(
                                color: Color(0xFFBFC3BE),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_reviewController.text.trim().isNotEmpty) {
                      await context.read<RatingProvider>().submitRating(
                        'helper-pindah-kos',
                        _rating.toDouble(),
                        _reviewController.text.trim(),
                      );
                    }
                    if (context.mounted) {
                      context.go(AppRouter.home);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF263225),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:tapps/services/firebase_service.dart';
import 'package:tapps/views/gradient_container.dart';

// Mock Stream Data for GrandTotalRecord
class GrandTotalRecord {
  final double? thisWeekLevel;
  final double? lastWeekLevel;
  final double? lastYearLevel;

  GrandTotalRecord({
    this.thisWeekLevel,
    this.lastWeekLevel,
    this.lastYearLevel,
  });
}

class DamLevelsScreen extends ConsumerWidget {
  const DamLevelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final damLevelsAsync = ref.watch(damLevelsStreamProvider);

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientContainer(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Total for All Dams',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: Lottie.network(
                        'https://assets6.lottiefiles.com/packages/lf20_8opq8ij6.json',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.water_drop,
                            size: 100,
                            color: Colors.white,
                          );
                        },
                        frameBuilder: (context, child, composition) {
                          if (composition == null) {
                            return const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            );
                          }
                          return child;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Dam Level %',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    damLevelsAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      error: (error, stack) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Error loading data',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error.toString(),
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      data: (record) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLevelCard(
                            'Level This Week',
                            record.thisWeekLevel,
                            Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          _buildLevelCard(
                            'Level Last Week',
                            record.lastWeekLevel,
                            Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          _buildLevelCard(
                            'Level Last Year',
                            record.lastYearLevel,
                            Colors.blue,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(String label, double? value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value != null ? '${value.toStringAsFixed(1)}%' : '-',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

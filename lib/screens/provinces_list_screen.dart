import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tapps/constants/app_colors.dart';
import 'package:tapps/models/province.dart';
import 'package:tapps/services/firebase_service.dart';
import 'package:tapps/views/gradient_container.dart';
import 'package:tapps/screens/province_details_screen.dart';

final provincesProvider = StreamProvider<List<Province>>((ref) {
  return ref.watch(firebaseServiceProvider).getProvinces();
});

class ProvincesListScreen extends ConsumerWidget {
  const ProvincesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provincesAsync = ref.watch(provincesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: Text(
          'Provinces',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GradientContainer(
        children: [
          Expanded(
            child: provincesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading provinces: ${error.toString()}',
                      style: GoogleFonts.outfit(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: () => ref.refresh(provincesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (provinces) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provinces.length,
                itemBuilder: (context, index) {
                  final province = provinces[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.white.withOpacity(0.1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProvinceDetailsScreen(
                              provinceName: province.name,
                              provinceCode: province.code,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    province.name,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total: ${province.total.toStringAsFixed(1)}%',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white70,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

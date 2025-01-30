import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:tapps/constants/app_colors.dart';
import 'package:tapps/screens/ec_dams_screen.dart';
import 'package:tapps/screens/fs_dams_screen.dart';
import 'package:tapps/screens/gp_dams_screen.dart';
import 'package:tapps/screens/kzn_dams_screen.dart';
import 'package:tapps/screens/lp_dams_screen.dart';
import 'package:tapps/screens/mp_dams_screen.dart';
import 'package:tapps/screens/nc_dams_screen.dart';
import 'package:tapps/screens/nw_dams_screen.dart';
import 'package:tapps/screens/province_dams_screen.dart';
import 'package:tapps/screens/wc_dams_screen.dart';
import 'package:tapps/services/firebase_service.dart';
import 'package:tapps/views/gradient_container.dart';

class ProvinceDetailsScreen extends ConsumerWidget {
  final String provinceName;
  final String provinceCode;

  const ProvinceDetailsScreen({
    super.key,
    required this.provinceName,
    required this.provinceCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provinceTotalsAsync = ref.watch(provinceTotalsProvider(provinceCode));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: Text(
          provinceName,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: GradientContainer(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Total for $provinceName',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Lottie.network(
                'https://assets6.lottiefiles.com/packages/lf20_8opq8ij6.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Dam Level %',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            provinceTotalsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading data: ${error.toString()}',
                  style: GoogleFonts.outfit(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (record) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
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
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: _buildButton(
                            context,
                            'View All Dams',
                            () {
                              if (provinceCode == 'WC') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WCDamsScreen(),
                                  ),
                                );
                              } else if (provinceCode == 'EC') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ECDamsScreen(),
                                  ),
                                );
                              } else if (provinceCode == 'FS') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FSDamsScreen(),
                                  ),
                                );
                              } else if (provinceCode == 'NC') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NCDamsScreen(),
                                  ),
                                );
                              } else if (provinceCode == 'KZN') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const KZNDamsScreen(),
                                  ),
                                );
                              } else if (provinceCode == 'GP') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GPDamsScreen(),
                                  ),
                                );
                              } else if (provinceCode == 'MP') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MPDamsScreen(),
                                  ),
                                );
                              } else if (provinceCode == 'LP') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LPDamsScreen(),
                                  ),
                                );
                              } else if (provinceCode == 'NW') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NWDamsScreen(),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProvinceDamsScreen(
                                      provinceName: provinceName,
                                      provinceCode: provinceCode,
                                    ),
                                  ),
                                );
                              }
                            },
                            isSecondary: true,
                          ),
                        ),
                        if (provinceCode == 'EC') ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: _buildButton(
                              context,
                              'Nelson Mandela Metro',
                              () {
                                // TODO: Navigate to Nelson Mandela Metro screen
                              },
                              isSecondary: false,
                            ),
                          ),
                        ],
                        if (provinceCode == 'KZN') ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: _buildButton(
                              context,
                              'eThekwini Municipality',
                              () {
                                // TODO: Navigate to eThekwini Municipality screen
                              },
                              isSecondary: false,
                            ),
                          ),
                        ],
                        if (provinceCode == 'WC') ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: _buildButton(
                              context,
                              'City of Cape Town',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WCDamsScreen(),
                                  ),
                                );
                              },
                              isSecondary: false,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(String label, double value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
            '${value.toStringAsFixed(1)}%',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    VoidCallback onPressed, {
    bool isSecondary = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: isSecondary ? Colors.white : AppColors.primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSecondary
              ? const BorderSide(color: AppColors.primaryBlue)
              : BorderSide.none,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: isSecondary ? AppColors.primaryBlue : Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

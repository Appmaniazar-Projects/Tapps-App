import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tapps/screens/province_details_screen.dart';
import 'package:tapps/services/firebase_service.dart';
import 'package:tapps/views/gradient_container.dart';

class Province {
  final String name;
  final String code;
  final String imagePath;

  const Province({
    required this.name,
    required this.code,
    required this.imagePath,
  });
}

class ProvincesScreen extends ConsumerWidget {
  const ProvincesScreen({super.key});

  static const List<Province> provinces = [
    Province(
      name: 'Western Cape',
      code: 'WC',
      imagePath: 'assets/images/western_cape.jpg',
    ),
    Province(
      name: 'Eastern Cape',
      code: 'EC',
      imagePath: 'assets/images/eastern_cape.jpg',
    ),
    Province(
      name: 'Northern Cape',
      code: 'NC',
      imagePath: 'assets/images/northern_cape.jpg',
    ),
    Province(
      name: 'Free State',
      code: 'FS',
      imagePath: 'assets/images/free_state.jpg',
    ),
    Province(
      name: 'KwaZulu-Natal',
      code: 'KZN',
      imagePath: 'assets/images/kwazulu_natal.jpg',
    ),
    Province(
      name: 'Gauteng',
      code: 'GP',
      imagePath: 'assets/images/gauteng.jpg',
    ),
    Province(
      name: 'Mpumalanga',
      code: 'MP',
      imagePath: 'assets/images/mpumalanga.jpg',
    ),
    Province(
      name: 'Limpopo',
      code: 'LP',
      imagePath: 'assets/images/limpopo.jpg',
    ),
    Province(
      name: 'North West',
      code: 'NW',
      imagePath: 'assets/images/north_west.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Provinces',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${provinces.length} Provinces',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: provinces.length,
                    itemBuilder: (context, index) {
                      final province = provinces[index];
                      final damsAsyncValue =
                          ref.watch(provinceDamsProvider(province.code));
                      return _buildProvinceCard(
                          context, province, damsAsyncValue);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvinceCard(BuildContext context, Province province,
      AsyncValue<List<Map<String, dynamic>>> damsAsyncValue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        province.name,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      damsAsyncValue.when(
                        data: (dams) => Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${dams.length} Dams',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        loading: () => Row(
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue.withOpacity(0.5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Loading...',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.black38,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        error: (_, __) => Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Error loading dams',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.black26,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

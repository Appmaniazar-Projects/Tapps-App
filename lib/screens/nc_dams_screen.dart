import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tapps/constants/app_colors.dart';
import 'package:tapps/constants/text_styles.dart';
import 'package:tapps/services/firebase_service.dart';
import 'package:tapps/views/gradient_container.dart';

class NCDamsScreen extends ConsumerWidget {
  const NCDamsScreen({super.key});

  // Dummy list of Northern Cape dams
  static final List<Map<String, dynamic>> _dummyDams = [
    {
      'id': '2',
      'name': 'Vaal Gamagara Dam',
      'this_week_level': 62.3,
      'location': 'Postmasburg',
      'capacity': '250 million m³',
    },
    {
      'id': '3',
      'name': 'Boegoeberg Dam',
      'this_week_level': 51.2,
      'location': 'Orange River',
      'capacity': '110 million m³',
    },
    {
      'id': '4',
      'name': 'Spitskop Dam',
      'this_week_level': 73.7,
      'location': 'Kimberley',
      'capacity': '180 million m³',
    },
  ];

  Color _getLevelColor(double level) {
    if (level >= 80) {
      return Colors.green;
    } else if (level >= 60) {
      return Colors.yellow.shade700;
    } else if (level >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using Firebase data for Northern Cape dams
    final ncDamsAsync = ref.watch(provinceDamsProvider('NC'));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: Text(
          'Northern Cape Dams',
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
            ncDamsAsync.when(
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
                      'Error Loading Dams',
                      style: TextStyles.subtitleText.copyWith(color: Colors.white),
                    ),
                    Text(
                      error.toString(),
                      style: TextStyles.subtitleText.copyWith(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              data: (dams) {
                // Combine Firebase dams with dummy dams
                final combinedDams = [
                  ...dams,
                  ..._dummyDams,
                ];

                return dams.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop_outlined,
                              color: Colors.white.withOpacity(0.6),
                              size: 100,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No Dams Found',
                              style: TextStyles.subtitleText.copyWith(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemCount: combinedDams.length,
                        separatorBuilder: (context, index) => const Divider(
                          color: Colors.white24,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final dam = combinedDams[index];
                          final level = (dam['this_week_level'] ?? 0.0).toDouble();
                          
                          return ExpansionTile(
                            title: Text(
                              dam['name'] ?? 'Unknown Dam',
                              style: TextStyles.subtitleText.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              '${level.toStringAsFixed(1)}%',
                              style: TextStyles.subtitleText.copyWith(
                                color: _getLevelColor(level),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow('Location', dam['location'] ?? 'N/A'),
                                    _buildDetailRow('Capacity', dam['capacity'] ?? 'N/A'),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyles.subtitleText.copyWith(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyles.subtitleText.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

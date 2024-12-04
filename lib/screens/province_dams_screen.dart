import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapps/views/gradient_container.dart';
import 'package:tapps/constants/text_styles.dart';
import 'package:tapps/services/firebase_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ProvinceDamsScreen extends ConsumerWidget {
  final String provinceName;
  final String provinceCode;

  const ProvinceDamsScreen({
    super.key,
    required this.provinceName,
    required this.provinceCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final damsAsync = ref.watch(provinceDamsProvider(provinceCode));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          provinceName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: GradientContainer(
          children: [
            const SizedBox(height: 20),
            damsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading dams: ${error.toString()}',
                  style: GoogleFonts.outfit(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (dams) => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: dams.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.white24,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final dam = dams[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    title: Text(
                      dam['name'] ?? '',
                      style: TextStyles.subtitleText.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      '${(dam['this_week_level'] ?? 0.0).toStringAsFixed(1)}%',
                      style: TextStyles.subtitleText.copyWith(
                        color: _getLevelColor(dam['this_week_level'] ?? 0.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(double level) {
    if (level >= 80) {
      return Colors.green;
    } else if (level >= 60) {
      return Colors.yellow;
    } else if (level >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

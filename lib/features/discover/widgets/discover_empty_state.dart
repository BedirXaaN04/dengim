import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/discovery_provider.dart';

class DiscoverEmptyState extends StatelessWidget {
  final VoidCallback onShowFilters;

  const DiscoverEmptyState({
    super.key,
    required this.onShowFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                ],
              ),
              child: const Icon(Icons.explore_rounded, size: 60, color: Colors.black),
            ),
            const SizedBox(height: 32),
            Text(
              "ŞU AN İÇİN BU KADAR! 🎉",
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "YAKINDAKİ TÜM PROFİLLERİ GÖRDÜN.\nDAHA FAZLA KİŞİ İÇİN FİLTRELERİNİ GENİŞLET\nVEYA DAHA SONRA TEKRAR DENE.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.black.withOpacity(0.5),
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onShowFilters,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 2.5),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "FİLTRELER",
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.read<DiscoveryProvider>().loadDiscoveryUsers(),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 2.5),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "YENİLE",
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

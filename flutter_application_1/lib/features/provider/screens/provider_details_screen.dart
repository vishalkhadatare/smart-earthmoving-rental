import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:equippro/features/home/models/equipment_model.dart';
import 'package:equippro/features/home/screens/equipment_details_screen.dart';
import 'package:equippro/features/home/widgets/equipment_image.dart';
import 'package:equippro/features/equipment/services/equipment_service.dart' as equip_svc;

class ProviderDetailsScreen extends StatefulWidget {
  final dynamic provider; // Accept provider info from EquipmentModel or ProviderModel
  const ProviderDetailsScreen({super.key, required this.provider});

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  static const Color _accent = Color(0xFFFF6B00);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _sub = Color(0xFF8F90A6);
  static const Color _card = Colors.white;
  static const Color _bg = Color(0xFFF7F7F7);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<equip_svc.EquipmentProvider>().loadAllEquipment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<equip_svc.EquipmentProvider>().allEquipment
      .map((fs) => EquipmentModel.fromFirestoreModel(fs))
      .where((e) => e.provider.id == widget.provider.id)
      .toList();

    final providerName = widget.provider.name ?? 'Provider';
    final providerPhone = widget.provider.phone ?? '';
    final providerLocation = widget.provider.location ?? 'Location not available';
    final providerRating = widget.provider.rating ?? 0.0;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          providerName,
          style: GoogleFonts.poppins(
            color: _dark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Provider Information Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Provider name and rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  providerName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _dark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      providerRating.toStringAsFixed(1),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: _dark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: _accent.withOpacity(0.1),
                            child: Text(
                              providerName.isNotEmpty
                                  ? providerName[0].toUpperCase()
                                  : 'P',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: _accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: _accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              providerLocation,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: _sub,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Phone
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            size: 18,
                            color: _accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              providerPhone,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: _dark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Equipment List Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Equipment',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _dark,
                      ),
                    ),
                    Text(
                      '${all.length} available',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: _sub,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            if (all.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No equipment available',
                      style: GoogleFonts.poppins(
                        color: _sub,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final e = all[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EquipmentDetailsScreen(equipment: e),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 72,
                                  height: 56,
                                  child: EquipmentImage(
                                    imageUrls: e.imageUrls,
                                    fallbackAsset: e.imageAsset,
                                    fit: BoxFit.cover,
                                    width: 72,
                                    height: 56,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.name,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: _dark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      e.category,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: _sub,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${e.pricePerHour.toStringAsFixed(0)}',
                                    style: GoogleFonts.poppins(
                                      color: _accent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '/hour',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: _sub,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: all.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Dropdown widget for filtering
class FilterDropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.items,
    this.selectedItem,
    required this.onChanged,
  });

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: widget.label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingMedium,
        ),
      ),
      initialValue: widget.selectedItem,
      items: [
        DropdownMenuItem(value: null, child: Text('Select ${widget.label}')),
        ...widget.items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }),
      ],
      onChanged: widget.onChanged,
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
    );
  }
}

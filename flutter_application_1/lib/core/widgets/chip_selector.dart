import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Widget for selecting chips with animation
class ChipSelector extends StatefulWidget {
  final List<String> items;
  final String selectedItem;
  final ValueChanged<String> onSelected;
  final bool multiSelect;
  final List<String> selectedItems;
  final ValueChanged<List<String>>? onMultiSelected;

  const ChipSelector({
    super.key,
    required this.items,
    this.selectedItem = '',
    required this.onSelected,
    this.multiSelect = false,
    this.selectedItems = const [],
    this.onMultiSelected,
  });

  @override
  State<ChipSelector> createState() => _ChipSelectorState();
}

class _ChipSelectorState extends State<ChipSelector> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedItems);
  }

  void _onChipTap(String item) {
    setState(() {
      if (widget.multiSelect) {
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          _selectedItems.add(item);
        }
        widget.onMultiSelected?.call(_selectedItems);
      } else {
        widget.onSelected(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.chipHeight + AppSizes.paddingMedium,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isSelected = widget.multiSelect
              ? _selectedItems.contains(item)
              : item == widget.selectedItem;

          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.paddingMedium),
            child: GestureDetector(
              onTap: () => _onChipTap(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppSizes.chipRadius),
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.border, width: 1),
                ),
                child: Center(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

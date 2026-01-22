import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MenuFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;
  final Color selectedColor;
  const MenuFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.selectedColor,
  });

  @override
  State<MenuFilterChip> createState() => _MenuFilterChipState();
}

class _MenuFilterChipState extends State<MenuFilterChip> {
  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        widget.label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      side: BorderSide(color: widget.selectedColor),
      checkmarkColor: widget.selectedColor,
      selectedColor: AppTheme.cardColor,
      selected: widget.isSelected,
      onSelected: (selected) {
        widget.onSelected(selected);
      },
      labelStyle: TextStyle(
        color: widget.isSelected ? widget.selectedColor : AppTheme.primaryGrey,
      ),
    );
  }
}

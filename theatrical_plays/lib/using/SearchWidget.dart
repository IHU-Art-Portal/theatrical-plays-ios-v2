import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class SearchWidget extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String? hintText; // Nullable, as hintText may be optional

  const SearchWidget({
    Key? key, // Nullable Key
    required this.text, // Marked as required since it shouldn't be nullable
    required this.onChanged, // Marked as required since it shouldn't be nullable
    this.hintText, // Can be null
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    final styleActive = TextStyle(color: colors.accent);
    final styleHint = TextStyle(color: colors.secondaryText);
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
      height: 42,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colors.background,
        border: Border.all(color: colors.accent),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: colors.accent),
          suffixIcon: widget.text.isNotEmpty
              ? GestureDetector(
                  child: Icon(Icons.close, color: colors.accent),
                  onTap: () {
                    controller.clear();
                    widget.onChanged(''); // Clear text and notify the parent
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                )
              : null,
          hintText: widget.hintText ??
              '', // Provide an empty string if hintText is null
          hintStyle: style,
          border: InputBorder.none,
        ),
        style: style,
        onChanged: widget.onChanged,
      ),
    );
  }
}

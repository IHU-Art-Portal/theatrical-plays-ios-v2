import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class SearchWidget extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String? hintText;

  const SearchWidget({
    Key? key,
    required this.text,
    required this.onChanged,
    this.hintText,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(covariant SearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    final isEmpty = controller.text.isEmpty;
    final styleActive = TextStyle(color: colors.accent);
    final styleHint = TextStyle(color: colors.secondaryText);
    final style = isEmpty ? styleHint : styleActive;

    return Container(
      height: 42,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colors.background,
        border: Border.all(color: colors.accent),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: colors.accent),
          suffixIcon: !isEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    widget.onChanged('');
                    FocusScope.of(context).unfocus();
                  },
                  child: Icon(Icons.close, color: colors.accent),
                )
              : null,
          hintText: widget.hintText ?? 'Αναζήτηση...',
          hintStyle: styleHint,
          border: InputBorder.none,
        ),
        style: style,
        onChanged: widget.onChanged,
      ),
    );
  }
}

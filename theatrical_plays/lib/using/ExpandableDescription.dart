import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';

/// Περιγραφή που επεκτείνεται εφόσον είναι μεγάλη
class ExpandableDescription extends StatefulWidget {
  final String description;

  const ExpandableDescription({Key? key, required this.description})
      : super(key: key);

  @override
  _ExpandableDescriptionState createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription>
    with TickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.brightness == Brightness.dark ? MyColors.dark : MyColors.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedCrossFade(
            firstChild: Text(
              widget.description,
              maxLines: 7,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            secondChild: Text(
              widget.description,
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 300),
          ),
        ),
        SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? "Λιγότερα ▲" : "Διαβάστε περισσότερα ▼",
            style: TextStyle(
              color: Colors.white70, // ⬅️ Απαλό γκρι, όχι κόκκινο
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

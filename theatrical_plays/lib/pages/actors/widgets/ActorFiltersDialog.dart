import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class ActorFiltersDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;

  const ActorFiltersDialog({Key? key, required this.onApply}) : super(key: key);

  @override
  State<ActorFiltersDialog> createState() => _ActorFiltersDialogState();
}

class _ActorFiltersDialogState extends State<ActorFiltersDialog> {
  RangeValues ageRange = const RangeValues(18, 70);
  RangeValues heightRange = const RangeValues(150, 200);
  RangeValues weightRange = const RangeValues(40, 120);
  String claimStatus = 'any'; // any, claimed, available

  bool enableAge = false;
  bool enableHeight = false;
  bool enableWeight = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final clr = isDark ? MyColors.dark : MyColors.light;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: clr.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Wrap(
        runSpacing: 24,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Ηλικία
          _buildFilterBlock(
            label: "Ηλικία",
            enabled: enableAge,
            onToggle: (val) => setState(() => enableAge = val),
            slider: RangeSlider(
              values: ageRange,
              min: 0,
              max: 100,
              divisions: 100,
              labels: RangeLabels(
                ageRange.start.round().toString(),
                ageRange.end.round().toString(),
              ),
              onChanged: (val) => setState(() => ageRange = val),
              activeColor: clr.accent,
              inactiveColor: clr.accent.withOpacity(0.3),
            ),
          ),

          // Ύψος
          _buildFilterBlock(
            label: "Ύψος (cm)",
            enabled: enableHeight,
            onToggle: (val) => setState(() => enableHeight = val),
            slider: RangeSlider(
              values: heightRange,
              min: 140,
              max: 220,
              divisions: 80,
              labels: RangeLabels(
                heightRange.start.round().toString(),
                heightRange.end.round().toString(),
              ),
              onChanged: (val) => setState(() => heightRange = val),
              activeColor: clr.accent,
              inactiveColor: clr.accent.withOpacity(0.3),
            ),
          ),

          // Βάρος
          _buildFilterBlock(
            label: "Βάρος (kg)",
            enabled: enableWeight,
            onToggle: (val) => setState(() => enableWeight = val),
            slider: RangeSlider(
              values: weightRange,
              min: 40,
              max: 150,
              divisions: 110,
              labels: RangeLabels(
                weightRange.start.round().toString(),
                weightRange.end.round().toString(),
              ),
              onChanged: (val) => setState(() => weightRange = val),
              activeColor: clr.accent,
              inactiveColor: clr.accent.withOpacity(0.3),
            ),
          ),

          // Claim status
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Κατάσταση διεκδίκησης",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: clr.accent)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: claimStatus,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: clr.background,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'any', child: Text("Όλοι")),
                  DropdownMenuItem(
                      value: 'claimed', child: Text("Μόνο διεκδικημένοι")),
                  DropdownMenuItem(
                      value: 'available', child: Text("Μόνο διαθέσιμοι")),
                ],
                onChanged: (value) =>
                    setState(() => claimStatus = value ?? 'any'),
              ),
            ],
          ),

          // Κουμπιά
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onApply({});
                },
                child: const Text("Καθαρισμός",
                    style: TextStyle(color: Colors.redAccent)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: clr.accent,
                  foregroundColor: clr.background,
                ),
                onPressed: () {
                  final filters = <String, dynamic>{
                    'claimStatus': claimStatus,
                  };

                  if (enableAge) {
                    filters['minAge'] = ageRange.start.round();
                    filters['maxAge'] = ageRange.end.round();
                  }
                  if (enableHeight) {
                    filters['minHeight'] = heightRange.start.round();
                    filters['maxHeight'] = heightRange.end.round();
                  }
                  if (enableWeight) {
                    filters['minWeight'] = weightRange.start.round();
                    filters['maxWeight'] = weightRange.end.round();
                  }

                  Navigator.pop(context); // 🟢 Πρώτα κλείνει το bottom sheet
                  Future.microtask(() =>
                      widget.onApply(filters)); // ✅ Μετά εφαρμόζονται τα φίλτρα
                },
                child: const Text("Εφαρμογή Φίλτρων"),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFilterBlock({
    required String label,
    required bool enabled,
    required void Function(bool) onToggle,
    required Widget slider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Switch(value: enabled, onChanged: onToggle),
          ],
        ),
        if (enabled) slider,
      ],
    );
  }
}

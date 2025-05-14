import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class TheaterSeatsLoading extends StatefulWidget {
  const TheaterSeatsLoading({Key? key}) : super(key: key);

  @override
  State<TheaterSeatsLoading> createState() => _TheaterSeatsLoadingState();
}

class _TheaterSeatsLoadingState extends State<TheaterSeatsLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.brightness == Brightness.dark ? MyColors.dark : MyColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (row) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (col) {
                    final progress = (_controller.value * 15).floor();
                    final index = row * 5 + col;
                    final isFilled = index <= progress;

                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isFilled
                              ? colors.accent
                              : colors.accent.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

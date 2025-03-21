import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';

// class ProfileWidget extends StatelessWidget {
//   final String imagePath;
//   final String actorName;
//   const ProfileWidget({key, this.imagePath, this.actorName}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // widget to build the profile style of an actor
//     return Center(
//         child: Column(
//       children: [
//         buildImage(),
//         Center(
//             child: Padding(
//           padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
//           child: Text(
//             actorName,
//             style: TextStyle(color: MyColors().cyan, fontSize: 22),
//           ),
//         )),
//         Divider(color: MyColors().gray)
//       ],
//     ));
//   }
//
//   Widget buildImage() {
//     final image = NetworkImage(imagePath);
//
//     return ClipOval(
//       child: Material(
//         color: Colors.transparent,
//         child: Ink.image(
//           image: image,
//           fit: BoxFit.cover,
//           width: 128,
//           height: 128,
//         ),
//       ),
//     );
//   }
// }
class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final String actorName;

  const ProfileWidget(
      {Key? key, required this.imagePath, required this.actorName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    // Widget to build the profile style of an actor
    return Center(
        child: Column(
      children: [
        buildImage(),
        Center(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Text(
            actorName,
            style: TextStyle(color: colors.accent, fontSize: 22),
          ),
        )),
        Divider(color: colors.secondaryText)
      ],
    ));
  }

  Widget buildImage() {
    final image = NetworkImage(imagePath);

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
        ),
      ),
    );
  }
}

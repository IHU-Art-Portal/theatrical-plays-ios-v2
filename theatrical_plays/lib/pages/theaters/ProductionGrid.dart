import 'package:flutter/material.dart';
import 'package:theatrical_plays/pages/movies/MovieInfo.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class ProductionGrid extends StatelessWidget {
  final List<Map<String, dynamic>> productions;

  const ProductionGrid({Key? key, required this.productions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.brightness == Brightness.dark ? MyColors.dark : MyColors.light;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: productions.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final prod = productions[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieInfo(prod['id']),
                ),
              );
            },
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(milliseconds: 500),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                        child: (prod['mediaUrl'] != null &&
                                prod['mediaUrl'].isNotEmpty)
                            ? Image.network(
                                prod['mediaUrl'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.image_not_supported,
                                        size: 50, color: Colors.grey),
                              )
                            : Icon(Icons.image_not_supported,
                                size: 50, color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        prod['title'],
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

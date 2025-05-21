import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MoviesService.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/pages/actors/ActorProfilePage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class MoviePeopleSection extends StatefulWidget {
  final int movieId;

  const MoviePeopleSection({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MoviePeopleSection> createState() => _MoviePeopleSectionState();
}

class _MoviePeopleSectionState extends State<MoviePeopleSection> {
  bool isLoading = true;
  List<Map<String, dynamic>> peopleDetails = [];

  @override
  void initState() {
    super.initState();
    loadPeopleForProduction();
  }

  Future<void> loadPeopleForProduction() async {
    final allContributions = await MoviesService.getRawContributions();
    final allRoles = await MoviesService.getAllRoles(); // Νέα μέθοδος
    final productionContributions = allContributions
        .where((e) => e['productionId'] == widget.movieId)
        .toList();

    final uniquePeopleIds = productionContributions
        .map((e) => e['peopleId'])
        .toSet()
        .cast<int>()
        .toList();

    List<Map<String, dynamic>> details = [];

    for (final id in uniquePeopleIds) {
      final person = await MoviesService.getPersonById(id);
      if (person != null) {
        final roles = productionContributions
            .where((e) => e['peopleId'] == id)
            .map((e) {
              final roleId = e['roleId'];
              final roleName = allRoles[roleId] ?? 'Άγνωστος Ρόλος';
              final subRole = e['subRole'] ?? '';
              return subRole.isNotEmpty ? '$roleName - $subRole' : roleName;
            })
            .toSet()
            .toList();

        final images = person['images'] as List<dynamic>? ?? [];
        final imageUrl = images.isNotEmpty ? images.first['imageUrl'] : null;

        details.add({
          'id': id, // 👈 για να το βρίσκει το onTap
          'fullname': person['fullname'] ?? 'Άγνωστο Όνομα',
          'roles': roles,
          'image': imageUrl,
        });
      }
    }

    setState(() {
      peopleDetails = details;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (peopleDetails.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Δεν υπάρχουν διαθέσιμοι ηθοποιοί.',
          style: TextStyle(
              color: colors.secondaryText, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Συντελεστές',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: peopleDetails.length,
          itemBuilder: (context, index) {
            final person = peopleDetails[index];
            final fullName = person['fullname'];
            final roles = (person['roles'] as List<dynamic>).join(', ');
            final imageUrl = person['image'];
            print("👤 $fullName | image: $imageUrl | roles: $roles");

            return GestureDetector(
              onTap: () {
                final image = person['image'];
                final roles = person['roles'];
                final fullName = person['fullname'] ?? 'Άγνωστο Όνομα';

                final isEmptyProfile = (roles == null || roles.isEmpty) &&
                    (image == null || image.toString().isEmpty);

                if (isEmptyProfile) {
                  AwesomeNotifications().createNotification(
                    content: NotificationContent(
                      id: DateTime.now()
                          .millisecondsSinceEpoch
                          .remainder(100000),
                      channelKey: 'basic_channel',
                      title: '🧍‍♂️ Συντελεστής χωρίς προφίλ',
                      body:
                          'Δεν υπάρχουν διαθέσιμα στοιχεία για τον συντελεστή "$fullName".',
                      notificationLayout: NotificationLayout.Default,
                    ),
                  );
                  return;
                }

                final actor = Actor(
                  id: person['id'],
                  fullName: fullName,
                  image: image?.toString() ?? '',
                  isClaimed: false,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActorProfilePage(actor: actor),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: ClipOval(
                        child: imageUrl != null
                            ? FadeInImage.assetNetwork(
                                placeholder:
                                    'assets/images/avatar_placeholder.png',
                                image: imageUrl ?? '',
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                imageErrorBuilder:
                                    (context, error, stackTrace) {
                                  print("❌ Αποτυχία φόρτωσης εικόνας: $error");
                                  return const Icon(Icons.person,
                                      size: 48, color: Colors.white70);
                                },
                              )
                            : const Icon(Icons.person,
                                size: 48, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fullName,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roles,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void showAwesomeNotification(String body,
      {String title = '🔔 Ειδοποίηση',
      NotificationLayout layout = NotificationLayout.Default}) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        notificationLayout: layout,
      ),
    );
  }
}

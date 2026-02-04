

class NearbyUser {
  final String id;
  final String name;
  final int age;
  final String avatarUrl;
  final double latitude;
  final double longitude;
  final double distance;
  final bool isOnline;

  NearbyUser({
    required this.id,
    required this.name,
    required this.age,
    required this.avatarUrl,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.isOnline,
  });
}

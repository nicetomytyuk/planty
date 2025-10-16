class Plant {
  final String id;
  final String name;
  final String species;
  final String imageUrl;
  final double minHumidity; // Percentage (0-100)
  final double maxHumidity; // Percentage (0-100)
  final Duration irrigationFrequency; // How often to water
  final int waterAmount; // Water amount in milliliters
  final double minLightHours; // Recommended minimum daily light (hours)
  final double maxLightHours; // Recommended maximum daily light (hours)
  final double preferredLightIntensity; // Target light intensity in lux
  final String description;
  final String careInstructions;

  Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.imageUrl,
    required this.minHumidity,
    required this.maxHumidity,
    required this.irrigationFrequency,
    required this.waterAmount,
    required this.minLightHours,
    required this.maxLightHours,
    required this.preferredLightIntensity,
    required this.description,
    required this.careInstructions,
  });

  /// Create a Plant from JSON (for API responses)
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      imageUrl: json['imageUrl'] as String,
      minHumidity: (json['minHumidity'] as num).toDouble(),
      maxHumidity: (json['maxHumidity'] as num).toDouble(),
      irrigationFrequency: Duration(
        hours: json['irrigationFrequencyHours'] as int,
      ),
      waterAmount: json['waterAmount'] as int,
      minLightHours: (json['minLightHours'] as num).toDouble(),
      maxLightHours: (json['maxLightHours'] as num).toDouble(),
      preferredLightIntensity:
          (json['preferredLightLux'] as num).toDouble(),
      description: json['description'] as String,
      careInstructions: json['careInstructions'] as String,
    );
  }

  /// Convert Plant to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'imageUrl': imageUrl,
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
      'irrigationFrequencyHours': irrigationFrequency.inHours,
      'waterAmount': waterAmount,
      'minLightHours': minLightHours,
      'maxLightHours': maxLightHours,
      'preferredLightLux': preferredLightIntensity,
      'description': description,
      'careInstructions': careInstructions,
    };
  }

  /// Create a copy of Plant with some fields updated
  Plant copyWith({
    String? id,
    String? name,
    String? species,
    String? imageUrl,
    double? minHumidity,
    double? maxHumidity,
    Duration? irrigationFrequency,
    int? waterAmount,
    double? minLightHours,
    double? maxLightHours,
    double? preferredLightIntensity,
    String? description,
    String? careInstructions,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      imageUrl: imageUrl ?? this.imageUrl,
      minHumidity: minHumidity ?? this.minHumidity,
      maxHumidity: maxHumidity ?? this.maxHumidity,
      irrigationFrequency: irrigationFrequency ?? this.irrigationFrequency,
      waterAmount: waterAmount ?? this.waterAmount,
      minLightHours: minLightHours ?? this.minLightHours,
      maxLightHours: maxLightHours ?? this.maxLightHours,
      preferredLightIntensity:
          preferredLightIntensity ?? this.preferredLightIntensity,
      description: description ?? this.description,
      careInstructions: careInstructions ?? this.careInstructions,
    );
  }

  @override
  String toString() {
    return 'Plant(id: $id, name: $name, species: $species)';
  }
}

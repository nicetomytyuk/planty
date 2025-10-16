import 'plant.dart';
import 'irrigation_event.dart';
import 'lighting_event.dart';

class Vase {
  final String id;
  final int valveId; // Physical valve number
  final String name; // User-customizable name
  final Plant? plant; // null if vase is empty
  final double currentHumidity; // Current soil humidity (0-100%)
  final double? currentTemperature; // Optional temperature sensor
  final DateTime lastUpdated; // Last sensor reading
  final DateTime? lastIrrigation; // When was it last watered
  final DateTime? nextIrrigation; // Scheduled next watering
  final double? currentLightLevel; // Ambient light in lux
  final double dailyLightExposure; // Hours of light accumulated today
  final double? averageLightExposure; // Average daily light (7-day rolling)
  final bool isLightOn; // Grow light currently active?
  final int? activeLightIntensity; // Active light intensity (0-100%)
  final DateTime? lastLighting; // Last lighting adjustment event
  final DateTime? nextLighting; // Scheduled lighting adjustment
  final List<IrrigationEvent> irrigationHistory;
  final List<LightingEvent> lightingHistory;
  final bool isActive; // Is the valve operational?
  final bool isOnline; // Is the sensor responding?

  Vase({
    required this.id,
    required this.valveId,
    required this.name,
    this.plant,
    required this.currentHumidity,
    this.currentTemperature,
    required this.lastUpdated,
    this.lastIrrigation,
    this.nextIrrigation,
    this.currentLightLevel,
    this.dailyLightExposure = 0,
    this.averageLightExposure,
    this.isLightOn = false,
    this.activeLightIntensity,
    this.lastLighting,
    this.nextLighting,
    required this.irrigationHistory,
    required this.lightingHistory,
    this.isActive = true,
    this.isOnline = true,
  });

  /// Check if vase needs watering based on plant requirements
  bool get needsWatering {
    if (plant == null) return false;
    return currentHumidity < plant!.minHumidity;
  }

  /// Check if vase has a plant
  bool get isEmpty => plant == null;

  /// Get humidity status: low, optimal, high
  String get humidityStatus {
    if (plant == null) return 'No plant';
    if (currentHumidity < plant!.minHumidity) return 'Low';
    if (currentHumidity > plant!.maxHumidity) return 'High';
    return 'Optimal';
  }

  /// Calculate total water used (in liters)
  double get totalWaterUsed {
    return irrigationHistory.fold(
          0.0,
          (sum, event) => sum + event.waterAmount,
        ) /
        1000;
  }

  /// Check if vase needs additional lighting based on plant needs
  bool get needsLighting {
    if (plant == null) return false;
    return dailyLightExposure < plant!.minLightHours;
  }

  /// Determine lighting status relative to plant requirements
  String get lightingStatus {
    if (plant == null) return 'No plant';
    if (dailyLightExposure < plant!.minLightHours) return 'Low';
    if (dailyLightExposure > plant!.maxLightHours) return 'High';
    return 'Optimal';
  }

  /// Total lighting hours delivered (manual + automatic)
  double get totalLightingHours {
    return lightingHistory.fold<double>(
      0.0,
      (sum, event) => sum + event.durationMinutes / 60.0,
    );
  }

  /// Total energy consumed by grow lights in kWh (if data available)
  double get totalLightingEnergyKWh {
    final totalWh = lightingHistory.fold<double>(
      0.0,
      (sum, event) => sum + (event.energyUsedWh ?? 0),
    );
    return totalWh / 1000.0;
  }

  factory Vase.fromJson(Map<String, dynamic> json) {
    return Vase(
      id: json['id'] as String,
      valveId: json['valveId'] as int,
      name: json['name'] as String,
      plant: json['plant'] != null
          ? Plant.fromJson(json['plant'] as Map<String, dynamic>)
          : null,
      currentHumidity: (json['currentHumidity'] as num).toDouble(),
      currentTemperature: json['currentTemperature'] != null
          ? (json['currentTemperature'] as num).toDouble()
          : null,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      lastIrrigation: json['lastIrrigation'] != null
          ? DateTime.parse(json['lastIrrigation'] as String)
          : null,
      nextIrrigation: json['nextIrrigation'] != null
          ? DateTime.parse(json['nextIrrigation'] as String)
          : null,
      currentLightLevel: (json['currentLightLevel'] as num?)?.toDouble(),
      dailyLightExposure:
          (json['dailyLightExposure'] as num?)?.toDouble() ?? 0,
      averageLightExposure:
          (json['averageLightExposure'] as num?)?.toDouble(),
      isLightOn: json['isLightOn'] as bool? ?? false,
      activeLightIntensity: json['activeLightIntensity'] as int?,
      lastLighting: json['lastLighting'] != null
          ? DateTime.parse(json['lastLighting'] as String)
          : null,
      nextLighting: json['nextLighting'] != null
          ? DateTime.parse(json['nextLighting'] as String)
          : null,
      irrigationHistory:
          (json['irrigationHistory'] as List<dynamic>?)
              ?.map((e) => IrrigationEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lightingHistory:
          (json['lightingHistory'] as List<dynamic>?)
                  ?.map((e) => LightingEvent.fromJson(
                        e as Map<String, dynamic>,
                      ))
                  .toList() ??
              [],
      isActive: json['isActive'] as bool? ?? true,
      isOnline: json['isOnline'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'valveId': valveId,
      'name': name,
      'plant': plant?.toJson(),
      'currentHumidity': currentHumidity,
      'currentTemperature': currentTemperature,
      'lastUpdated': lastUpdated.toIso8601String(),
      'lastIrrigation': lastIrrigation?.toIso8601String(),
      'nextIrrigation': nextIrrigation?.toIso8601String(),
      'currentLightLevel': currentLightLevel,
      'dailyLightExposure': dailyLightExposure,
      'averageLightExposure': averageLightExposure,
      'isLightOn': isLightOn,
      'activeLightIntensity': activeLightIntensity,
      'lastLighting': lastLighting?.toIso8601String(),
      'nextLighting': nextLighting?.toIso8601String(),
      'irrigationHistory': irrigationHistory.map((e) => e.toJson()).toList(),
      'lightingHistory': lightingHistory.map((e) => e.toJson()).toList(),
      'isActive': isActive,
      'isOnline': isOnline,
    };
  }

  Vase copyWith({
    String? id,
    int? valveId,
    String? name,
    Plant? plant,
    bool clearPlant = false,
    double? currentHumidity,
    double? currentTemperature,
    DateTime? lastUpdated,
    DateTime? lastIrrigation,
    DateTime? nextIrrigation,
    double? currentLightLevel,
    double? dailyLightExposure,
    double? averageLightExposure,
    bool? isLightOn,
    int? activeLightIntensity,
    DateTime? lastLighting,
    DateTime? nextLighting,
    List<IrrigationEvent>? irrigationHistory,
    List<LightingEvent>? lightingHistory,
    bool? isActive,
    bool? isOnline,
  }) {
    return Vase(
      id: id ?? this.id,
      valveId: valveId ?? this.valveId,
      name: name ?? this.name,
      plant: clearPlant ? null : (plant ?? this.plant),
      currentHumidity: currentHumidity ?? this.currentHumidity,
      currentTemperature: currentTemperature ?? this.currentTemperature,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastIrrigation: lastIrrigation ?? this.lastIrrigation,
      nextIrrigation: nextIrrigation ?? this.nextIrrigation,
      currentLightLevel: currentLightLevel ?? this.currentLightLevel,
      dailyLightExposure: dailyLightExposure ?? this.dailyLightExposure,
      averageLightExposure: averageLightExposure ?? this.averageLightExposure,
      isLightOn: isLightOn ?? this.isLightOn,
      activeLightIntensity:
          activeLightIntensity ?? this.activeLightIntensity,
      lastLighting: lastLighting ?? this.lastLighting,
      nextLighting: nextLighting ?? this.nextLighting,
      irrigationHistory: irrigationHistory ?? this.irrigationHistory,
      lightingHistory: lightingHistory ?? this.lightingHistory,
      isActive: isActive ?? this.isActive,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  String toString() {
    return 'Vase(id: $id, valveId: $valveId, name: $name, plant: ${plant?.name ?? "empty"})';
  }
}

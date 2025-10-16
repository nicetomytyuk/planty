class LightingEvent {
  final String id;
  final String vaseId;
  final DateTime timestamp;
  final int durationMinutes; // Duration of artificial lighting
  final int intensityPercentage; // Light output as percentage (0-100)
  final bool isManual; // Manual vs automatic trigger
  final double? lightLevelBefore; // Ambient light in lux before activation
  final double? lightLevelAfter; // Ambient light in lux after activation
  final double? energyUsedWh; // Energy consumed during the event

  const LightingEvent({
    required this.id,
    required this.vaseId,
    required this.timestamp,
    required this.durationMinutes,
    required this.intensityPercentage,
    required this.isManual,
    this.lightLevelBefore,
    this.lightLevelAfter,
    this.energyUsedWh,
  });

  factory LightingEvent.fromJson(Map<String, dynamic> json) {
    return LightingEvent(
      id: json['id'] as String,
      vaseId: json['vaseId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationMinutes: json['durationMinutes'] as int,
      intensityPercentage: json['intensityPercentage'] as int,
      isManual: json['isManual'] as bool,
      lightLevelBefore: (json['lightLevelBefore'] as num?)?.toDouble(),
      lightLevelAfter: (json['lightLevelAfter'] as num?)?.toDouble(),
      energyUsedWh: (json['energyUsedWh'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaseId': vaseId,
      'timestamp': timestamp.toIso8601String(),
      'durationMinutes': durationMinutes,
      'intensityPercentage': intensityPercentage,
      'isManual': isManual,
      'lightLevelBefore': lightLevelBefore,
      'lightLevelAfter': lightLevelAfter,
      'energyUsedWh': energyUsedWh,
    };
  }

  LightingEvent copyWith({
    String? id,
    String? vaseId,
    DateTime? timestamp,
    int? durationMinutes,
    int? intensityPercentage,
    bool? isManual,
    double? lightLevelBefore,
    double? lightLevelAfter,
    double? energyUsedWh,
  }) {
    return LightingEvent(
      id: id ?? this.id,
      vaseId: vaseId ?? this.vaseId,
      timestamp: timestamp ?? this.timestamp,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensityPercentage: intensityPercentage ?? this.intensityPercentage,
      isManual: isManual ?? this.isManual,
      lightLevelBefore: lightLevelBefore ?? this.lightLevelBefore,
      lightLevelAfter: lightLevelAfter ?? this.lightLevelAfter,
      energyUsedWh: energyUsedWh ?? this.energyUsedWh,
    );
  }
}

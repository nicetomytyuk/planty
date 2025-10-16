class IrrigationEvent {
  final String id;
  final String vaseId;
  final DateTime timestamp;
  final int duration; // Duration in seconds
  final int waterAmount; // Amount in milliliters
  final bool isManual; // Was it triggered manually or automatically?
  final double humidityBefore;
  final double? humidityAfter; // Might not be available immediately

  IrrigationEvent({
    required this.id,
    required this.vaseId,
    required this.timestamp,
    required this.duration,
    required this.waterAmount,
    required this.isManual,
    required this.humidityBefore,
    this.humidityAfter,
  });

  factory IrrigationEvent.fromJson(Map<String, dynamic> json) {
    return IrrigationEvent(
      id: json['id'] as String,
      vaseId: json['vaseId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      duration: json['duration'] as int,
      waterAmount: json['waterAmount'] as int,
      isManual: json['isManual'] as bool,
      humidityBefore: (json['humidityBefore'] as num).toDouble(),
      humidityAfter: json['humidityAfter'] != null
          ? (json['humidityAfter'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaseId': vaseId,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration,
      'waterAmount': waterAmount,
      'isManual': isManual,
      'humidityBefore': humidityBefore,
      'humidityAfter': humidityAfter,
    };
  }

  IrrigationEvent copyWith({
    String? id,
    String? vaseId,
    DateTime? timestamp,
    int? duration,
    int? waterAmount,
    bool? isManual,
    double? humidityBefore,
    double? humidityAfter,
  }) {
    return IrrigationEvent(
      id: id ?? this.id,
      vaseId: vaseId ?? this.vaseId,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      waterAmount: waterAmount ?? this.waterAmount,
      isManual: isManual ?? this.isManual,
      humidityBefore: humidityBefore ?? this.humidityBefore,
      humidityAfter: humidityAfter ?? this.humidityAfter,
    );
  }
}

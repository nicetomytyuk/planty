import '../../models/irrigation_event.dart';
import '../../models/lighting_event.dart';
import '../../models/plant.dart';
import '../../models/vase.dart';

/// Helpers to translate Supabase rows (typically snake_case) into
/// the strongly-typed domain models used by the UI layer.
class SupabaseRowMapper {
  const SupabaseRowMapper._();

  static Plant plantFromRow(Map<String, dynamic> row) {
    final id = _string(row, ['id']) ?? '';
    return Plant(
      id: id,
      name: _string(row, ['name']) ?? 'Unknown Plant',
      species: _string(row, ['species', 'botanical_name']) ?? 'Unknown species',
      imageUrl: _string(row, ['imageUrl', 'image_url']) ?? '',
      minHumidity: _double(row, ['minHumidity', 'min_humidity']) ?? 0,
      maxHumidity: _double(row, ['maxHumidity', 'max_humidity']) ?? 0,
      irrigationFrequency: Duration(
        hours: _int(row, [
              'irrigationFrequencyHours',
              'irrigation_frequency_hours',
              'watering_interval_hours',
            ]) ??
            24,
      ),
      waterAmount: _int(row, ['waterAmount', 'water_amount']) ?? 0,
      minLightHours: _double(row, ['minLightHours', 'min_light_hours']) ?? 0,
      maxLightHours: _double(row, ['maxLightHours', 'max_light_hours']) ?? 0,
      preferredLightIntensity: _double(
            row,
            ['preferredLightLux', 'preferred_light_lux', 'preferred_light'],
          ) ??
          0,
      description: _string(row, ['description']) ?? '',
      careInstructions:
          _string(row, ['careInstructions', 'care_instructions']) ?? '',
    );
  }

  static IrrigationEvent irrigationEventFromRow(Map<String, dynamic> row) {
    final id = _string(row, ['id']) ?? '';
    final vaseId = _string(row, ['vaseId', 'vase_id']) ?? '';
    return IrrigationEvent(
      id: id,
      vaseId: vaseId,
      timestamp: _dateTime(
            row,
            ['timestamp', 'event_time', 'created_at', 'logged_at'],
          ) ??
          DateTime.now(),
      duration:
          _int(row, ['duration', 'durationSeconds', 'duration_seconds']) ?? 0,
      waterAmount:
          _int(row, ['waterAmount', 'water_amount', 'volume_ml']) ?? 0,
      isManual: _bool(row, ['isManual', 'is_manual']) ?? false,
      humidityBefore:
          _double(row, ['humidityBefore', 'humidity_before']) ?? 0.0,
      humidityAfter: _double(
        row,
        ['humidityAfter', 'humidity_after'],
      ),
    );
  }

  static LightingEvent lightingEventFromRow(Map<String, dynamic> row) {
    final id = _string(row, ['id']) ?? '';
    final vaseId = _string(row, ['vaseId', 'vase_id']) ?? '';
    return LightingEvent(
      id: id,
      vaseId: vaseId,
      timestamp: _dateTime(
            row,
            ['timestamp', 'event_time', 'created_at', 'logged_at'],
          ) ??
          DateTime.now(),
      durationMinutes: _int(
            row,
            ['durationMinutes', 'duration_minutes', 'duration'],
          ) ??
          0,
      intensityPercentage: _int(
            row,
            [
              'intensityPercentage',
              'intensity_percentage',
              'intensity',
            ],
          ) ??
          0,
      isManual: _bool(row, ['isManual', 'is_manual']) ?? false,
      lightLevelBefore:
          _double(row, ['lightLevelBefore', 'light_level_before']),
      lightLevelAfter:
          _double(row, ['lightLevelAfter', 'light_level_after']),
      energyUsedWh:
          _double(row, ['energyUsedWh', 'energy_used_wh', 'energy_wh']),
    );
  }

  static Vase vaseFromRow(
    Map<String, dynamic> row, {
    Plant? plant,
    List<IrrigationEvent>? irrigationHistory,
    List<LightingEvent>? lightingHistory,
  }) {
    final embeddedPlant = plant ?? _extractPlant(row);
    final irrigation = irrigationHistory ??
        _extractIrrigationEvents(row).map(irrigationEventFromRow).toList();
    final lighting = lightingHistory ??
        _extractLightingEvents(row).map(lightingEventFromRow).toList();

    final id = _string(row, ['id']) ?? '';
    return Vase(
      id: id,
      valveId: _int(row, ['valveId', 'valve_id']) ?? 0,
      name: _string(row, ['name', 'label']) ?? 'Vase',
      plant: embeddedPlant,
      currentHumidity:
          _double(row, ['currentHumidity', 'current_humidity']) ?? 0.0,
      currentTemperature:
          _double(row, ['currentTemperature', 'current_temperature']),
      lastUpdated: _dateTime(
            row,
            ['lastUpdated', 'last_updated', 'updated_at', 'created_at'],
          ) ??
          DateTime.now(),
      lastIrrigation: _dateTime(
        row,
        ['lastIrrigation', 'last_irrigation'],
      ),
      nextIrrigation: _dateTime(
        row,
        ['nextIrrigation', 'next_irrigation', 'scheduled_irrigation'],
      ),
      currentLightLevel:
          _double(row, ['currentLightLevel', 'current_light_level']),
      dailyLightExposure:
          _double(row, ['dailyLightExposure', 'daily_light_exposure']) ?? 0.0,
      averageLightExposure: _double(
        row,
        ['averageLightExposure', 'average_light_exposure'],
      ),
      isLightOn: _bool(row, ['isLightOn', 'is_light_on']) ?? false,
      activeLightIntensity: _int(
        row,
        ['activeLightIntensity', 'active_light_intensity'],
      ),
      lastLighting: _dateTime(
        row,
        ['lastLighting', 'last_lighting'],
      ),
      nextLighting: _dateTime(
        row,
        ['nextLighting', 'next_lighting', 'scheduled_lighting'],
      ),
      irrigationHistory: irrigation,
      lightingHistory: lighting,
      isActive: _bool(row, ['isActive', 'is_active']) ?? true,
      isOnline: _bool(row, ['isOnline', 'is_online']) ?? true,
    );
  }

  static Plant? _extractPlant(Map<String, dynamic> row) {
    final plantData = _map(row, ['plant', 'plant_data', 'plants']);
    if (plantData != null) {
      return plantFromRow(plantData);
    }

    final plantId = _string(row, ['plantId', 'plant_id']);
    if (plantId != null && plantId.isNotEmpty) {
      return Plant(
        id: plantId,
        name: 'Loading plant...',
        species: '',
        imageUrl: '',
        minHumidity: 0,
        maxHumidity: 0,
        irrigationFrequency: const Duration(hours: 24),
        waterAmount: 0,
        minLightHours: 0,
        maxLightHours: 0,
        preferredLightIntensity: 0,
        description: '',
        careInstructions: '',
      );
    }
    return null;
  }

  static Iterable<Map<String, dynamic>> _extractIrrigationEvents(
    Map<String, dynamic> row,
  ) {
    final list = _list(row, [
      'irrigationHistory',
      'irrigation_history',
      'irrigationEvents',
      'irrigation_events',
    ]);
    if (list == null) return const [];
    return list
        .whereType<Map>()
        .map((event) => Map<String, dynamic>.from(event));
  }

  static Iterable<Map<String, dynamic>> _extractLightingEvents(
    Map<String, dynamic> row,
  ) {
    final list = _list(row, [
      'lightingHistory',
      'lighting_history',
      'lightingEvents',
      'lighting_events',
    ]);
    if (list == null) return const [];
    return list
        .whereType<Map>()
        .map((event) => Map<String, dynamic>.from(event));
  }
}

T? _value<T>(Map<String, dynamic> row, List<String> keys) {
  for (final key in keys) {
    if (row.containsKey(key) && row[key] != null) {
      return row[key] as T?;
    }
  }
  return null;
}

String? _string(Map<String, dynamic> row, List<String> keys) {
  final value = _value<dynamic>(row, keys);
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

int? _int(Map<String, dynamic> row, List<String> keys) {
  final value = _value<dynamic>(row, keys);
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _double(Map<String, dynamic> row, List<String> keys) {
  final value = _value<dynamic>(row, keys);
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool? _bool(Map<String, dynamic> row, List<String> keys) {
  final value = _value<dynamic>(row, keys);
  if (value == null) return null;
  if (value is bool) return value;

  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'true' || normalized == 't' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == 'f' || normalized == '0') {
      return false;
    }
  }
  return null;
}

DateTime? _dateTime(Map<String, dynamic> row, List<String> keys) {
  final value = _value<dynamic>(row, keys);
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

Map<String, dynamic>? _map(Map<String, dynamic> row, List<String> keys) {
  final value = _value<dynamic>(row, keys);
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<dynamic>? _list(Map<String, dynamic> row, List<String> keys) {
  final value = _value<dynamic>(row, keys);
  if (value == null) return null;
  if (value is List<dynamic>) return value;
  if (value is Iterable<dynamic>) return value.toList();
  return null;
}

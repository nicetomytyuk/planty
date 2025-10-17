import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/irrigation_event.dart';
import '../models/lighting_event.dart';
import '../models/plant.dart';
import '../models/vase.dart';
import 'mappers/supabase_row_mapper.dart';
import 'static_data_service.dart';
import 'vase_data_service.dart';

/// Supabase-backed implementation of [VaseDataService].
///
/// If Supabase is unavailable (for instance during offline development),
/// methods gracefully fall back to the static mock data so the UI continues
/// to function.
class SupabaseDataService implements VaseDataService {
  SupabaseDataService({
    SupabaseClient? client,
    StaticDataService? fallbackService,
  })  : _client = client,
        _fallback = fallbackService ?? StaticDataService();

  final StaticDataService _fallback;
  SupabaseClient? _client;

  SupabaseClient? get _resolvedClient {
    if (_client != null) return _client;
    try {
      _client = Supabase.instance.client;
    } catch (_) {
      _client = null;
    }
    return _client;
  }

  @override
  Future<List<Plant>> getPlantLibrary() async {
    final client = _resolvedClient;
    if (client == null) {
      return _fallback.getPlantLibrary();
    }

    try {
      final List<dynamic> rows =
          await client.from('plants').select('*').order('name');

      final plants = rows
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .map(SupabaseRowMapper.plantFromRow)
          .toList();

      if (plants.isEmpty) {
        return _fallback.getPlantLibrary();
      }
      return plants;
    } catch (error, stackTrace) {
      debugPrint('Supabase getPlantLibrary failed: $error\n$stackTrace');
      return _fallback.getPlantLibrary();
    }
  }

  @override
  Future<List<Vase>> getVases() async {
    final client = _resolvedClient;
    if (client == null) {
      return _fallback.getVases();
    }

    try {
      final plantMap = await _loadPlantsById(client);
      final irrigationByVase = await _loadIrrigationEvents(client);
      final lightingByVase = await _loadLightingEvents(client);

      final List<dynamic> rows =
          await client.from('vases').select('*').order('valve_id');

      final vases = <Vase>[];
      for (final dynamic row in rows) {
        if (row is! Map) continue;
        final map = Map<String, dynamic>.from(row);
        final vaseId = (map['id'] ?? map['vase_id'] ?? '').toString();
        final plantId = (map['plant_id'] ?? map['plantId'])?.toString();
        final plant = plantId != null ? plantMap[plantId] : null;

        final irrigationHistory = List<IrrigationEvent>.from(
          (irrigationByVase[vaseId] ?? const <IrrigationEvent>[]),
        );
        final lightingHistory = List<LightingEvent>.from(
          (lightingByVase[vaseId] ?? const <LightingEvent>[]),
        );

        vases.add(
          SupabaseRowMapper.vaseFromRow(
            map,
            plant: plant,
            irrigationHistory: irrigationHistory,
            lightingHistory: lightingHistory,
          ),
        );
      }

      if (vases.isEmpty) {
        return _fallback.getVases();
      }
      return vases;
    } catch (error, stackTrace) {
      debugPrint('Supabase getVases failed: $error\n$stackTrace');
      return _fallback.getVases();
    }
  }

  @override
  Future<bool> assignPlantToVase(String vaseId, String plantId) async {
    final client = _resolvedClient;
    if (client == null) {
      return _fallback.assignPlantToVase(vaseId, plantId);
    }

    try {
      final response = await client
          .from('vases')
          .update({
            'plant_id': plantId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vaseId)
          .select()
          .maybeSingle();
      return response != null;
    } on PostgrestException catch (error) {
      debugPrint('Supabase assignPlantToVase failed: ${error.message}');
    } catch (error, stackTrace) {
      debugPrint('Supabase assignPlantToVase failed: $error\n$stackTrace');
    }
    return _fallback.assignPlantToVase(vaseId, plantId);
  }

  @override
  Future<bool> removePlantFromVase(String vaseId) async {
    final client = _resolvedClient;
    if (client == null) {
      return _fallback.removePlantFromVase(vaseId);
    }

    try {
      final response = await client
          .from('vases')
          .update({
            'plant_id': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vaseId)
          .select()
          .maybeSingle();
      return response != null;
    } on PostgrestException catch (error) {
      debugPrint('Supabase removePlantFromVase failed: ${error.message}');
    } catch (error, stackTrace) {
      debugPrint('Supabase removePlantFromVase failed: $error\n$stackTrace');
    }
    return _fallback.removePlantFromVase(vaseId);
  }

  @override
  Future<bool> triggerManualIrrigation(
    String vaseId,
    int durationSeconds,
  ) async {
    final client = _resolvedClient;
    if (client == null) {
      return _fallback.triggerManualIrrigation(vaseId, durationSeconds);
    }

    try {
      await client.from('irrigation_events').insert({
        'vase_id': vaseId,
        'duration_seconds': durationSeconds,
        'water_amount': 0,
        'is_manual': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return true;
    } on PostgrestException catch (error) {
      debugPrint('Supabase triggerManualIrrigation failed: ${error.message}');
    } catch (error, stackTrace) {
      debugPrint('Supabase triggerManualIrrigation failed: $error\n$stackTrace');
    }
    return _fallback.triggerManualIrrigation(vaseId, durationSeconds);
  }

  @override
  Future<bool> triggerManualLighting(
    String vaseId,
    int durationMinutes, {
    int intensityPercentage = 80,
  }) async {
    final client = _resolvedClient;
    if (client == null) {
      return _fallback.triggerManualLighting(
        vaseId,
        durationMinutes,
        intensityPercentage: intensityPercentage,
      );
    }

    try {
      await client.from('lighting_events').insert({
        'vase_id': vaseId,
        'duration_minutes': durationMinutes,
        'intensity_percentage': intensityPercentage,
        'is_manual': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return true;
    } on PostgrestException catch (error) {
      debugPrint('Supabase triggerManualLighting failed: ${error.message}');
    } catch (error, stackTrace) {
      debugPrint('Supabase triggerManualLighting failed: $error\n$stackTrace');
    }
    return _fallback.triggerManualLighting(
      vaseId,
      durationMinutes,
      intensityPercentage: intensityPercentage,
    );
  }

  @override
  Future<bool> updateVaseConfig(
    String vaseId,
    Map<String, dynamic> config,
  ) async {
    final client = _resolvedClient;
    if (client == null) {
      return _fallback.updateVaseConfig(vaseId, config);
    }

    try {
      final response = await client
          .from('vases')
          .update(_normalizePayload(config))
          .eq('id', vaseId)
          .select()
          .maybeSingle();
      return response != null;
    } on PostgrestException catch (error) {
      debugPrint('Supabase updateVaseConfig failed: ${error.message}');
    } catch (error, stackTrace) {
      debugPrint('Supabase updateVaseConfig failed: $error\n$stackTrace');
    }
    return _fallback.updateVaseConfig(vaseId, config);
  }

  Future<Map<String, Plant>> _loadPlantsById(SupabaseClient client) async {
    try {
      final List<dynamic> rows =
          await client.from('plants').select('*').order('name');
      final map = <String, Plant>{};
      for (final dynamic row in rows) {
        if (row is! Map) continue;
        final plantRow = Map<String, dynamic>.from(row);
        final plant = SupabaseRowMapper.plantFromRow(plantRow);
        map[plant.id] = plant;
      }
      return map;
    } catch (error, stackTrace) {
      debugPrint('Supabase _loadPlantsById failed: $error\n$stackTrace');
      return {};
    }
  }

  Future<Map<String, List<IrrigationEvent>>> _loadIrrigationEvents(
    SupabaseClient client,
  ) async {
    final eventsByVase = <String, List<IrrigationEvent>>{};
    try {
      final List<dynamic> rows = await client
          .from('irrigation_events')
          .select('*')
          .order('timestamp', ascending: false)
          .limit(100);
      for (final dynamic row in rows) {
        if (row is! Map) continue;
        final map = Map<String, dynamic>.from(row);
        final vaseId = (map['vase_id'] ?? map['vaseId'])?.toString();
        if (vaseId == null || vaseId.isEmpty) continue;
        final event = SupabaseRowMapper.irrigationEventFromRow(map);
        eventsByVase.putIfAbsent(vaseId, () => <IrrigationEvent>[]).add(event);
      }
      for (final list in eventsByVase.values) {
        list.sort(
          (a, b) => b.timestamp.compareTo(a.timestamp),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Supabase _loadIrrigationEvents failed: $error\n$stackTrace');
    }
    return eventsByVase;
  }

  Future<Map<String, List<LightingEvent>>> _loadLightingEvents(
    SupabaseClient client,
  ) async {
    final eventsByVase = <String, List<LightingEvent>>{};
    try {
      final List<dynamic> rows = await client
          .from('lighting_events')
          .select('*')
          .order('timestamp', ascending: false)
          .limit(100);
      for (final dynamic row in rows) {
        if (row is! Map) continue;
        final map = Map<String, dynamic>.from(row);
        final vaseId = (map['vase_id'] ?? map['vaseId'])?.toString();
        if (vaseId == null || vaseId.isEmpty) continue;
        final event = SupabaseRowMapper.lightingEventFromRow(map);
        eventsByVase.putIfAbsent(vaseId, () => <LightingEvent>[]).add(event);
      }
      for (final list in eventsByVase.values) {
        list.sort(
          (a, b) => b.timestamp.compareTo(a.timestamp),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Supabase _loadLightingEvents failed: $error\n$stackTrace');
    }
    return eventsByVase;
  }

  Map<String, dynamic> _normalizePayload(Map<String, dynamic> config) {
    final normalized = <String, dynamic>{};
    for (final entry in config.entries) {
      final key = entry.key;
      normalized[_toSnakeCase(key)] = entry.value;
    }
    normalized['updated_at'] = DateTime.now().toIso8601String();
    return normalized;
  }

  String _toSnakeCase(String key) {
    final buffer = StringBuffer();
    for (var i = 0; i < key.length; i++) {
      final char = key[i];
      final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
      if (isUpper && i != 0) {
        buffer.write('_');
      }
      buffer.write(char.toLowerCase());
    }
    return buffer.toString();
  }
}

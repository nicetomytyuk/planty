import 'package:flutter/foundation.dart';
import '../models/vase.dart';
import '../models/plant.dart';
import '../services/supabase_data_service.dart';
import '../services/vase_data_service.dart';
import '../utils/constants.dart';

/// Manages the state of all vases in the application
class VaseProvider with ChangeNotifier {
  VaseProvider({VaseDataService? dataService})
      : _dataService = dataService ?? SupabaseDataService();

  final VaseDataService _dataService;

  // State
  List<Vase> _vases = [];
  List<Plant> _plantLibrary = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Vase> get vases => _vases;
  List<Plant> get plantLibrary => _plantLibrary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get vases that have plants
  List<Vase> get occupiedVases => _vases.where((v) => !v.isEmpty).toList();

  /// Get empty vases
  List<Vase> get emptyVases => _vases.where((v) => v.isEmpty).toList();

  /// Get vases that need watering
  List<Vase> get vasesNeedingWater =>
      _vases.where((v) => v.needsWatering).toList();

  /// Get vases that need supplemental lighting
  List<Vase> get vasesNeedingLight =>
      _vases.where((v) => v.needsLighting).toList();

  /// Initialize data - fetch vases and plant library
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch data in parallel
      final results = await Future.wait([
        _dataService.getVases(),
        _dataService.getPlantLibrary(),
      ]);

      final fetchedVases = results[0] as List<Vase>;
      final plants = results[1] as List<Plant>;
      _plantLibrary = plants;
      _vases = _linkPlantDetails(fetchedVases);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
      debugPrint('Error initializing: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh vases data
  Future<void> refreshVases() async {
    try {
      final vases = await _dataService.getVases();
      _vases = _linkPlantDetails(vases);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to refresh: $e';
      debugPrint('Error refreshing vases: $e');
      notifyListeners();
    }
  }

  /// Get a specific vase by ID
  Vase? getVaseById(String vaseId) {
    try {
      return _vases.firstWhere((v) => v.id == vaseId);
    } catch (e) {
      return null;
    }
  }

  /// Get a specific plant by ID
  Plant? getPlantById(String plantId) {
    try {
      return _plantLibrary.firstWhere((p) => p.id == plantId);
    } catch (e) {
      return null;
    }
  }

  /// Assign a plant to a vase
  Future<bool> assignPlant(String vaseId, String plantId) async {
    try {
      final success = await _dataService.assignPlantToVase(vaseId, plantId);

      if (success) {
        // Update local state
        final vaseIndex = _vases.indexWhere((v) => v.id == vaseId);
        final plant = getPlantById(plantId);

        if (vaseIndex != -1 && plant != null) {
          _vases[vaseIndex] = _vases[vaseIndex].copyWith(
            plant: plant,
            nextIrrigation: DateTime.now().add(plant.irrigationFrequency),
            nextLighting: DateTime.now().add(const Duration(hours: 2)),
            dailyLightExposure: 0.0,
          );
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to assign plant: $e';
      debugPrint('Error assigning plant: $e');
      notifyListeners();
      return false;
    }
  }

  /// Remove plant from a vase
  Future<bool> removePlant(String vaseId) async {
    try {
      final success = await _dataService.removePlantFromVase(vaseId);

      if (success) {
        // Update local state
        final vaseIndex = _vases.indexWhere((v) => v.id == vaseId);

        if (vaseIndex != -1) {
          _vases[vaseIndex] = _vases[vaseIndex].copyWith(
            clearPlant: true,
            nextIrrigation: null,
            nextLighting: null,
            dailyLightExposure: 0.0,
          );
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to remove plant: $e';
      debugPrint('Error removing plant: $e');
      notifyListeners();
      return false;
    }
  }

  /// Trigger manual irrigation for a vase
  Future<bool> waterVase(String vaseId, {int? durationSeconds}) async {
    try {
      final vase = getVaseById(vaseId);
      if (vase == null) return false;

      final duration =
          durationSeconds ??
          (vase.plant != null ? (vase.plant!.waterAmount / 10).round() : 30);

      final success = await _dataService.triggerManualIrrigation(
        vaseId,
        duration,
      );

      if (success) {
        // Refresh to get updated data
        await refreshVases();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to water vase: $e';
      debugPrint('Error watering vase: $e');
      notifyListeners();
      return false;
    }
  }

  /// Trigger manual lighting boost for a vase
  Future<bool> boostLighting(
    String vaseId, {
    int? durationMinutes,
    int intensityPercentage = AppConstants.defaultLightIntensityPercent,
  }) async {
    try {
      final vase = getVaseById(vaseId);
      if (vase == null) return false;

      final computedDuration = vase.plant != null
          ? (vase.plant!.minLightHours * 10).round()
          : AppConstants.defaultLightDurationMinutes;
      final normalizedDuration =
          computedDuration.clamp(30, 180).toInt();
      final duration = durationMinutes ?? normalizedDuration;

      final success = await _dataService.triggerManualLighting(
        vaseId,
        duration,
        intensityPercentage: intensityPercentage,
      );

      if (success) {
        await refreshVases();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to adjust lighting: $e';
      debugPrint('Error adjusting lighting: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update vase name
  Future<bool> updateVaseName(String vaseId, String newName) async {
    try {
      final success = await _dataService.updateVaseConfig(vaseId, {
        'name': newName,
      });

      if (success) {
        final vaseIndex = _vases.indexWhere((v) => v.id == vaseId);
        if (vaseIndex != -1) {
          _vases[vaseIndex] = _vases[vaseIndex].copyWith(name: newName);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update vase name: $e';
      debugPrint('Error updating vase name: $e');
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  List<Vase> _linkPlantDetails(List<Vase> vases) {
    if (_plantLibrary.isEmpty) return vases;
    final plantLookup = {
      for (final plant in _plantLibrary) plant.id: plant,
    };
    return vases
        .map((vase) {
          final plant = vase.plant;
          if (plant == null) return vase;
          final resolved = plantLookup[plant.id];
          if (resolved == null) return vase;
          return vase.copyWith(plant: resolved);
        })
        .toList();
  }
}

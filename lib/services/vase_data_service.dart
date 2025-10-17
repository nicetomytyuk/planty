import '../models/plant.dart';
import '../models/vase.dart';

/// Contract for data sources that provide vase and plant information.
///
/// This abstraction allows the UI layer to remain agnostic about whether data
/// comes from Supabase, mock fixtures, or any other backend implementation.
abstract class VaseDataService {
  /// Fetch all vases with their latest sensor readings and histories.
  Future<List<Vase>> getVases();

  /// Fetch the available plant library that can be assigned to vases.
  Future<List<Plant>> getPlantLibrary();

  /// Assign a plant to the specified vase.
  Future<bool> assignPlantToVase(String vaseId, String plantId);

  /// Remove the currently assigned plant from the vase.
  Future<bool> removePlantFromVase(String vaseId);

  /// Trigger a manual irrigation run for the vase.
  Future<bool> triggerManualIrrigation(String vaseId, int durationSeconds);

  /// Trigger a manual lighting boost for the vase.
  Future<bool> triggerManualLighting(
    String vaseId,
    int durationMinutes, {
    int intensityPercentage,
  });

  /// Update mutable configuration fields on the vase.
  Future<bool> updateVaseConfig(
    String vaseId,
    Map<String, dynamic> config,
  );
}

import '../models/plant.dart';
import '../models/vase.dart';
import '../models/irrigation_event.dart';
import '../models/lighting_event.dart';

/// Service that provides static mock data for development
/// This will be replaced with real API calls later
class StaticDataService {
  /// Simulates network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Get all available plants in the library
  Future<List<Plant>> getPlantLibrary() async {
    await _simulateDelay();

    return [
      Plant(
        id: 'plant_1',
        name: 'Basil',
        species: 'Ocimum basilicum',
        imageUrl:
            'https://images.unsplash.com/photo-1618375569909-3c8616cf7733?w=400',
        minHumidity: 60.0,
        maxHumidity: 80.0,
        irrigationFrequency: const Duration(hours: 24),
        waterAmount: 200,
        minLightHours: 6.0,
        maxLightHours: 8.0,
        preferredLightIntensity: 12000,
        description: 'Popular culinary herb with aromatic leaves',
        careInstructions:
            'Keep soil consistently moist. Requires 6-8 hours of sunlight daily.',
      ),
      Plant(
        id: 'plant_2',
        name: 'Tomato',
        species: 'Solanum lycopersicum',
        imageUrl:
            'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=400',
        minHumidity: 65.0,
        maxHumidity: 85.0,
        irrigationFrequency: const Duration(hours: 12),
        waterAmount: 300,
        minLightHours: 8.0,
        maxLightHours: 12.0,
        preferredLightIntensity: 15000,
        description: 'Fruit-bearing plant, requires consistent watering',
        careInstructions:
            'Water deeply and regularly. Needs full sun exposure.',
      ),
      Plant(
        id: 'plant_3',
        name: 'Lavender',
        species: 'Lavandula',
        imageUrl:
            'https://images.unsplash.com/photo-1611251185290-9ef58c34f906?w=400',
        minHumidity: 40.0,
        maxHumidity: 60.0,
        irrigationFrequency: const Duration(hours: 48),
        waterAmount: 150,
        minLightHours: 6.0,
        maxLightHours: 10.0,
        preferredLightIntensity: 9000,
        description: 'Aromatic flowering plant, drought-tolerant',
        careInstructions:
            'Prefers well-drained soil. Water when soil is dry to touch.',
      ),
      Plant(
        id: 'plant_4',
        name: 'Mint',
        species: 'Mentha',
        imageUrl:
            'https://images.unsplash.com/photo-1628556270448-4d4e4148e1b1?w=400',
        minHumidity: 70.0,
        maxHumidity: 90.0,
        irrigationFrequency: const Duration(hours: 24),
        waterAmount: 250,
        minLightHours: 4.0,
        maxLightHours: 8.0,
        preferredLightIntensity: 6000,
        description: 'Fast-growing herb, loves moisture',
        careInstructions:
            'Keep soil moist at all times. Partial shade is ideal.',
      ),
      Plant(
        id: 'plant_5',
        name: 'Rosemary',
        species: 'Rosmarinus officinalis',
        imageUrl:
            'https://images.unsplash.com/photo-1583909842271-05777a54bc1e?w=400',
        minHumidity: 45.0,
        maxHumidity: 65.0,
        irrigationFrequency: const Duration(hours: 36),
        waterAmount: 180,
        minLightHours: 6.0,
        maxLightHours: 10.0,
        preferredLightIntensity: 11000,
        description: 'Woody, perennial herb with fragrant leaves',
        careInstructions:
            'Allow soil to dry between waterings. Needs full sun.',
      ),
      Plant(
        id: 'plant_6',
        name: 'Strawberry',
        species: 'Fragaria × ananassa',
        imageUrl:
            'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=400',
        minHumidity: 60.0,
        maxHumidity: 75.0,
        irrigationFrequency: const Duration(hours: 24),
        waterAmount: 220,
        minLightHours: 8.0,
        maxLightHours: 10.0,
        preferredLightIntensity: 14000,
        description: 'Sweet berry-producing plant',
        careInstructions:
            'Regular watering is essential. Mulch to retain moisture.',
      ),
      Plant(
        id: 'plant_7',
        name: 'Cilantro',
        species: 'Coriandrum sativum',
        imageUrl:
            'https://images.unsplash.com/photo-1620574387735-3624d75b2dbe?w=400',
        minHumidity: 55.0,
        maxHumidity: 75.0,
        irrigationFrequency: const Duration(hours: 24),
        waterAmount: 190,
        minLightHours: 4.0,
        maxLightHours: 6.0,
        preferredLightIntensity: 5000,
        description: 'Flavorful herb used in many cuisines',
        careInstructions: 'Keep soil moist. Prefers cooler temperatures.',
      ),
      Plant(
        id: 'plant_8',
        name: 'Chili Pepper',
        species: 'Capsicum annuum',
        imageUrl:
            'https://images.unsplash.com/photo-1583663848850-46af132dc58e?w=400',
        minHumidity: 60.0,
        maxHumidity: 80.0,
        irrigationFrequency: const Duration(hours: 18),
        waterAmount: 280,
        minLightHours: 8.0,
        maxLightHours: 12.0,
        preferredLightIntensity: 15000,
        description: 'Spicy fruit-bearing plant',
        careInstructions:
            'Consistent moisture is key. Loves warm temperatures.',
      ),
    ];
  }

  /// Get all vases from the irrigation system
  Future<List<Vase>> getVases() async {
    await _simulateDelay();

    final now = DateTime.now();

    return [
      Vase(
        id: 'vase_1',
        valveId: 1,
        name: 'Kitchen Herbs',
        plant: Plant(
          id: 'plant_1',
          name: 'Basil',
          species: 'Ocimum basilicum',
          imageUrl:
              'https://images.unsplash.com/photo-1618375569909-3c8616cf7733?w=400',
          minHumidity: 60.0,
          maxHumidity: 80.0,
          irrigationFrequency: const Duration(hours: 24),
          waterAmount: 200,
          minLightHours: 6.0,
          maxLightHours: 8.0,
          preferredLightIntensity: 12000,
          description: 'Popular culinary herb with aromatic leaves',
          careInstructions:
              'Keep soil consistently moist. Requires 6-8 hours of sunlight daily.',
        ),
        currentHumidity: 72.5,
        currentTemperature: 22.3,
        lastUpdated: now.subtract(const Duration(minutes: 5)),
        lastIrrigation: now.subtract(const Duration(hours: 8)),
        nextIrrigation: now.add(const Duration(hours: 16)),
        currentLightLevel: 8500,
        dailyLightExposure: 5.5,
        averageLightExposure: 6.2,
        isLightOn: false,
        activeLightIntensity: null,
        lastLighting: now.subtract(const Duration(hours: 2)),
        nextLighting: now.add(const Duration(hours: 6)),
        irrigationHistory: [
          IrrigationEvent(
            id: 'event_1',
            vaseId: 'vase_1',
            timestamp: now.subtract(const Duration(hours: 8)),
            duration: 30,
            waterAmount: 200,
            isManual: false,
            humidityBefore: 58.0,
            humidityAfter: 72.5,
          ),
          IrrigationEvent(
            id: 'event_2',
            vaseId: 'vase_1',
            timestamp: now.subtract(const Duration(days: 1, hours: 8)),
            duration: 30,
            waterAmount: 200,
            isManual: false,
            humidityBefore: 59.5,
            humidityAfter: 73.0,
          ),
        ],
        lightingHistory: [
          LightingEvent(
            id: 'light_1',
            vaseId: 'vase_1',
            timestamp: now.subtract(const Duration(hours: 2)),
            durationMinutes: 45,
            intensityPercentage: 75,
            isManual: false,
            lightLevelBefore: 4200,
            lightLevelAfter: 9100,
            energyUsedWh: 56,
          ),
          LightingEvent(
            id: 'light_2',
            vaseId: 'vase_1',
            timestamp: now.subtract(const Duration(days: 1, hours: 3)),
            durationMinutes: 60,
            intensityPercentage: 80,
            isManual: false,
            lightLevelBefore: 3800,
            lightLevelAfter: 9500,
            energyUsedWh: 72,
          ),
        ],
        isActive: true,
        isOnline: true,
      ),
      Vase(
        id: 'vase_2',
        valveId: 2,
        name: 'Balcony Garden',
        plant: Plant(
          id: 'plant_2',
          name: 'Tomato',
          species: 'Solanum lycopersicum',
          imageUrl:
              'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=400',
          minHumidity: 65.0,
          maxHumidity: 85.0,
          irrigationFrequency: const Duration(hours: 12),
          waterAmount: 300,
          minLightHours: 8.0,
          maxLightHours: 12.0,
          preferredLightIntensity: 15000,
          description: 'Fruit-bearing plant, requires consistent watering',
          careInstructions:
              'Water deeply and regularly. Needs full sun exposure.',
        ),
        currentHumidity: 62.0,
        currentTemperature: 24.1,
        lastUpdated: now.subtract(const Duration(minutes: 2)),
        lastIrrigation: now.subtract(const Duration(hours: 4)),
        nextIrrigation: now.add(const Duration(hours: 8)),
        currentLightLevel: 9800,
        dailyLightExposure: 7.8,
        averageLightExposure: 8.4,
        isLightOn: true,
        activeLightIntensity: 85,
        lastLighting: now.subtract(const Duration(hours: 1)),
        nextLighting: now.add(const Duration(hours: 5)),
        irrigationHistory: [
          IrrigationEvent(
            id: 'event_3',
            vaseId: 'vase_2',
            timestamp: now.subtract(const Duration(hours: 4)),
            duration: 45,
            waterAmount: 300,
            isManual: false,
            humidityBefore: 61.0,
            humidityAfter: 75.0,
          ),
        ],
        lightingHistory: [
          LightingEvent(
            id: 'light_3',
            vaseId: 'vase_2',
            timestamp: now.subtract(const Duration(hours: 1)),
            durationMinutes: 90,
            intensityPercentage: 85,
            isManual: true,
            lightLevelBefore: 4600,
            lightLevelAfter: 10200,
            energyUsedWh: 110,
          ),
        ],
        isActive: true,
        isOnline: true,
      ),
      Vase(
        id: 'vase_3',
        valveId: 3,
        name: 'Window Sill',
        plant: null, // Empty vase
        currentHumidity: 45.0,
        lastUpdated: now.subtract(const Duration(minutes: 10)),
        lastIrrigation: null,
        nextIrrigation: null,
        currentLightLevel: 3200,
        dailyLightExposure: 1.2,
        averageLightExposure: 2.0,
        isLightOn: false,
        activeLightIntensity: null,
        lastLighting: now.subtract(const Duration(days: 1, hours: 5)),
        nextLighting: now.add(const Duration(hours: 12)),
        irrigationHistory: [],
        lightingHistory: [],
        isActive: true,
        isOnline: true,
      ),
      Vase(
        id: 'vase_4',
        valveId: 4,
        name: 'Patio Pot',
        plant: null, // Empty vase
        currentHumidity: 38.0,
        lastUpdated: now.subtract(const Duration(minutes: 15)),
        lastIrrigation: null,
        nextIrrigation: null,
        currentLightLevel: 2800,
        dailyLightExposure: 0.5,
        averageLightExposure: 1.1,
        isLightOn: false,
        activeLightIntensity: null,
        lastLighting: now.subtract(const Duration(days: 2)),
        nextLighting: now.add(const Duration(hours: 10)),
        irrigationHistory: [],
        lightingHistory: [],
        isActive: true,
        isOnline: true,
      ),
    ];
  }

  /// Assign a plant to a vase
  Future<bool> assignPlantToVase(String vaseId, String plantId) async {
    await _simulateDelay();
    // Simulate success
    return true;
  }

  /// Remove plant from a vase
  Future<bool> removePlantFromVase(String vaseId) async {
    await _simulateDelay();
    return true;
  }

  /// Trigger manual irrigation
  Future<bool> triggerManualIrrigation(
    String vaseId,
    int durationSeconds,
  ) async {
    await _simulateDelay();
    return true;
  }

  /// Trigger manual lighting adjustment
  Future<bool> triggerManualLighting(
    String vaseId,
    int durationMinutes, {
    int intensityPercentage = 80,
  }) async {
    await _simulateDelay();
    return true;
  }

  /// Update vase configuration
  Future<bool> updateVaseConfig(
    String vaseId,
    Map<String, dynamic> config,
  ) async {
    await _simulateDelay();
    return true;
  }
}

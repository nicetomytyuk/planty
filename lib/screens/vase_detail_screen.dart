// lib/screens/vase_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/vase_provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../models/irrigation_event.dart';
import '../models/lighting_event.dart';

class VaseDetailScreen extends StatelessWidget {
  final String vaseId;

  const VaseDetailScreen({super.key, required this.vaseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vase Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'rename') {
                _showRenameDialog(context);
              } else if (value == 'remove_plant') {
                _showRemovePlantDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Rename Vase'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove_plant',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Remove Plant'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<VaseProvider>(
        builder: (context, provider, child) {
          final vase = provider.getVaseById(vaseId);

          if (vase == null) {
            return const Center(child: Text('Vase not found'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshVases(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vase header card
                  _buildHeaderCard(context, vase),

                  const SizedBox(height: 16),

                  // Plant info (if exists)
                  if (vase.plant != null) ...[
                    _buildPlantInfoCard(context, vase),
                    const SizedBox(height: 16),
                  ],

                  // Current status
                  _buildStatusCard(context, vase),

                  const SizedBox(height: 16),

                  // Quick actions
                  _buildQuickActions(context, provider, vase),

                  const SizedBox(height: 16),

                  // Irrigation history
                  _buildIrrigationHistory(context, vase),

                  const SizedBox(height: 16),

                  // Lighting history
                  _buildLightingHistory(context, vase),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, vase) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    vase.isEmpty
                        ? Icons.local_florist_outlined
                        : Icons.local_florist,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vase.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Valve ${vase.valveId}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: vase.isOnline
                        ? AppTheme.statusOptimal.withValues(alpha: 0.1)
                        : AppTheme.statusOffline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: vase.isOnline
                              ? AppTheme.statusOptimal
                              : AppTheme.statusOffline,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        vase.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: vase.isOnline
                              ? AppTheme.statusOptimal
                              : AppTheme.statusOffline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantInfoCard(BuildContext context, vase) {
    final plant = vase.plant!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Plant',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Plant image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: plant.imageUrl.isNotEmpty
                        ? Image.network(
                            plant.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.local_florist,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              );
                            },
                          )
                        : Icon(
                            Icons.local_florist,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plant.species,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plant.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Plant requirements
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildRequirementChip(
                  context,
                  Icons.water_drop,
                  'Humidity',
                  '${plant.minHumidity.toInt()}-${plant.maxHumidity.toInt()}%',
                ),
                _buildRequirementChip(
                  context,
                  Icons.schedule,
                  'Frequency',
                  '${plant.irrigationFrequency.inHours}h',
                ),
                _buildRequirementChip(
                  context,
                  Icons.local_drink,
                  'Water',
                  '${plant.waterAmount}ml',
                ),
                _buildRequirementChip(
                  context,
                  Icons.light_mode,
                  'Light',
                  '${plant.minLightHours.toStringAsFixed(1)}-${plant.maxLightHours.toStringAsFixed(1)}h',
                ),
                _buildRequirementChip(
                  context,
                  Icons.wb_incandescent_outlined,
                  'Intensity',
                  '${plant.preferredLightIntensity.toStringAsFixed(0)} lux',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, vase) {
    final statusColor = AppTheme.getStatusColor(vase.humidityStatus);
    final lightStatusColor = AppTheme.getStatusColor(vase.lightingStatus);
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Humidity
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.water_drop, color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soil Humidity',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vase.currentHumidity.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: statusColor),
                      ),
                      Text(
                        vase.humidityStatus,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[600]?.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: lightStatusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    vase.isLightOn ? Icons.wb_incandescent : Icons.light_mode,
                    color: lightStatusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Light Exposure',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vase.currentLightLevel != null
                            ? '${vase.currentLightLevel!.toStringAsFixed(0)} lux'
                            : 'No sensor data',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: lightStatusColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vase.plant != null
                            ? 'Today ${vase.dailyLightExposure.toStringAsFixed(1)}h / Target ${vase.plant!.minLightHours.toStringAsFixed(1)}-${vase.plant!.maxLightHours.toStringAsFixed(1)}h'
                            : 'No plant assigned',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (vase.averageLightExposure != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '7-day avg: ${vase.averageLightExposure!.toStringAsFixed(1)}h',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        vase.lightingStatus,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: lightStatusColor,
                        ),
                      ),
                      if (vase.isLightOn) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Grow light active at ${vase.activeLightIntensity ?? 100}%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: lightStatusColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (vase.currentTemperature != null) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.grey[600]?.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              // Temperature
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.thermostat,
                      color: Colors.orange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Temperature',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${vase.currentTemperature!.toStringAsFixed(1)}°C',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Divider(color: Colors.grey[600]?.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            // Last update
            Row(
              children: [
                Icon(Icons.update, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${dateFormat.format(vase.lastUpdated)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            if (vase.nextIrrigation != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Next watering: ${dateFormat.format(vase.nextIrrigation!)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (vase.lastLighting != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last lighting: ${dateFormat.format(vase.lastLighting!)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (vase.nextLighting != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.light_mode, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Next lighting: ${dateFormat.format(vase.nextLighting!)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, provider, vase) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (!vase.isEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: vase.isOnline
                      ? () => _waterVase(context, provider, vase)
                      : null,
                  icon: const Icon(Icons.water_drop),
                  label: const Text('Water Now'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: vase.isOnline
                      ? () => _boostLighting(context, provider, vase)
                      : null,
                  icon: const Icon(Icons.light_mode),
                  label: const Text('Light Boost'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => provider.refreshVases(),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIrrigationHistory(BuildContext context, vase) {
    final history = vase.irrigationHistory;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Irrigation History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${history.length} events',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No irrigation history yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length > 5 ? 5 : history.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[600]?.withValues(alpha: 0.2),
                  height: 24,
                ),
                itemBuilder: (context, index) {
                  final event = history[index];
                  return _buildHistoryItem(context, event);
                },
              ),
            if (history.length > 5) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to full history screen
                  },
                  child: const Text('View All History'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, IrrigationEvent event) {
    final dateFormat = DateFormat('MMM dd, HH:mm');

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: event.isManual
                ? Colors.blue.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            event.isManual ? Icons.touch_app : Icons.schedule,
            color: event.isManual
                ? Colors.blue
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.isManual ? 'Manual Watering' : 'Automatic Watering',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                dateFormat.format(event.timestamp),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${event.waterAmount}ml',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${event.duration}s',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLightingHistory(BuildContext context, vase) {
    final history = vase.lightingHistory;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lighting History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${history.length} events',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No lighting events yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length > 5 ? 5 : history.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[600]?.withValues(alpha: 0.2),
                  height: 24,
                ),
                itemBuilder: (context, index) {
                  final event = history[index];
                  return _buildLightingHistoryItem(context, event);
                },
              ),
            if (history.length > 5) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to full history screen
                  },
                  child: const Text('View All Lighting Activity'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLightingHistoryItem(BuildContext context, LightingEvent event) {
    final dateFormat = DateFormat('MMM dd, HH:mm');
    final Color accentColor = event.isManual
        ? Colors.amber
        : Colors.orangeAccent;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            event.isManual ? Icons.touch_app : Icons.light_mode,
            color: accentColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.isManual ? 'Manual Light Boost' : 'Scheduled Lighting',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                dateFormat.format(event.timestamp),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildLightingDetailChip(
                    context,
                    Icons.schedule,
                    '${event.durationMinutes} min',
                  ),
                  _buildLightingDetailChip(
                    context,
                    Icons.flash_on,
                    '${event.intensityPercentage}% intensity',
                  ),
                  if (event.lightLevelAfter != null)
                    _buildLightingDetailChip(
                      context,
                      Icons.lightbulb_outline,
                      event.lightLevelBefore != null
                          ? '${event.lightLevelBefore!.round()}→${event.lightLevelAfter!.round()} lux'
                          : '${event.lightLevelAfter!.round()} lux',
                    ),
                  if (event.energyUsedWh != null)
                    _buildLightingDetailChip(
                      context,
                      Icons.bolt,
                      '${(event.energyUsedWh! / 1000).toStringAsFixed(2)} kWh',
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLightingDetailChip(
    BuildContext context,
    IconData icon,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _waterVase(BuildContext context, provider, vase) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Water Plant'),
        content: Text(
          'Start manual irrigation for ${vase.name}?\n\n'
          'Duration: ${vase.plant?.waterAmount != null ? (vase.plant!.waterAmount / 10).round() : 30} seconds\n'
          'Amount: ${vase.plant?.waterAmount ?? 200}ml',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Water'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await provider.waterVase(vase.id);

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Watering ${vase.name}...' : 'Failed to start watering',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _boostLighting(BuildContext context, provider, vase) async {
    final computedDuration = vase.plant != null
        ? (vase.plant!.minLightHours * 10).round()
        : AppConstants.defaultLightDurationMinutes;
    final recommendedDuration = computedDuration.clamp(30, 180).toInt();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Boost Lighting'),
        content: Text(
          'Activate grow lights for ${vase.name}?\n\n'
          'Duration: $recommendedDuration minutes\n'
          'Intensity: ${AppConstants.defaultLightIntensityPercent}%',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Boost'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await provider.boostLighting(
        vase.id,
        durationMinutes: recommendedDuration,
      );

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Lighting ${vase.name}...'
                  : 'Failed to activate lighting',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _showRenameDialog(BuildContext context) {
    final provider = context.read<VaseProvider>();
    final vase = provider.getVaseById(vaseId);
    if (vase == null) return;

    final controller = TextEditingController(text: vase.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Vase'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Vase Name',
            hintText: 'Enter new name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              final success = await provider.updateVaseName(
                vaseId,
                controller.text.trim(),
              );

              if (context.mounted) Navigator.pop(context);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Vase renamed successfully'
                          : 'Failed to rename vase',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showRemovePlantDialog(BuildContext context) {
    final provider = context.read<VaseProvider>();
    final vase = provider.getVaseById(vaseId);
    if (vase == null || vase.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Plant'),
        content: Text(
          'Are you sure you want to remove ${vase.plant!.name} from ${vase.name}?\n\n'
          'This will stop automatic irrigation for this vase.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              final success = await provider.removePlant(vaseId);

              if (context.mounted) Navigator.pop(context);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Plant removed successfully'
                          : 'Failed to remove plant',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

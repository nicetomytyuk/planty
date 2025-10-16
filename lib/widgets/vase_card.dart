import 'package:flutter/material.dart';
import '../models/vase.dart';
import '../utils/theme.dart';
import 'package:intl/intl.dart';

class VaseCard extends StatelessWidget {
  final Vase vase;
  final VoidCallback onTap;
  final VoidCallback? onPlantTap;
  final VoidCallback? onWaterTap;
  final VoidCallback? onLightTap;
  final bool compact;

  const VaseCard({
    super.key,
    required this.vase,
    required this.onTap,
    this.onPlantTap,
    this.onWaterTap,
    this.onLightTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        child: Container(
          padding: EdgeInsets.all(compact ? 14 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              _buildHeader(context, theme),

              const SizedBox(height: 20),

              // Main content - vase visualization
              Expanded(child: _buildVaseVisualization(context, theme)),

              const SizedBox(height: 16),

              // Stats section
              if (!vase.isEmpty && !compact) _buildStats(context, theme),

              SizedBox(height: compact ? 6 : 12),

              // Action buttons
              _buildActions(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final small = compact; // shorthand

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vase.name,
                style: small
                    ? theme.textTheme.titleMedium
                    : theme.textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!small) ...[
                const SizedBox(height: 4),
                Text(
                  'Valve ${vase.valveId}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 2),
                Text(
                  'Valve ${vase.valveId}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        // Status: pill (normal) → dot (compact)
        if (!small)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: vase.isOnline
                  ? AppTheme.statusOptimal.withValues(alpha: 0.1)
                  : AppTheme.statusOffline.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _statusDot(vase.isOnline),
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
          )
        else
          _statusDot(vase.isOnline),
      ],
    );
  }

  Widget _statusDot(bool online) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: online ? AppTheme.statusOptimal : AppTheme.statusOffline,
      shape: BoxShape.circle,
    ),
  );

  Widget _buildVaseVisualization(BuildContext context, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (vase.isEmpty) return _buildEmptyVase(context, theme);

        // planted → center + scale down if needed
        if (compact) {
          return _buildPlantedVaseCompact(context, theme);
        }

        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _buildPlantedVase(context, theme),
          ),
        );
      },
    );
  }

  Widget _buildEmptyVase(BuildContext context, ThemeData theme) {
    return LayoutBuilder(
      builder: (_, c) {
        return Center(
          child: FittedBox(
            // lets the whole block scale down if needed
            fit: BoxFit.scaleDown,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: c.maxWidth, // text wraps to tile width
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_florist_outlined,
                      size: 60,
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 200, // keeps text from expanding oddly in FittedBox
                    child: Text(
                      'Empty Vase',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 200,
                    child: Text(
                      'Tap to add a plant',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlantedVase(BuildContext context, ThemeData theme) {
    final statusColor = AppTheme.getStatusColor(vase.humidityStatus);

    return LayoutBuilder(
      builder: (context, c) {
        // available height for this section (fallback for unconstrained)
        final h = c.maxHeight.isFinite ? c.maxHeight : 260.0;

        // responsive sizes
        final img = (h * 0.42).clamp(90.0, 120.0);
        final ring = img + 12; // ring diameter (outer)
        final gapM = (h * 0.06).clamp(8.0, 16.0);
        final gapS = (h * 0.03).clamp(4.0, 10.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with moisture ring
            _MoistureRing(
              size: ring,
              value: (vase.currentHumidity / 100.0).clamp(0.0, 1.0),
              color: statusColor,
              child: Container(
                width: img,
                height: img,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: vase.plant!.imageUrl.isNotEmpty
                      ? Image.network(
                          vase.plant!.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.local_florist,
                            size: img * 0.5,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.local_florist,
                          size: img * 0.5,
                          color: theme.colorScheme.primary,
                        ),
                ),
              ),
            ),

            SizedBox(height: gapM),

            // Name + species
            Text(
              vase.plant!.name,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: gapS * 0.6),
            Text(
              vase.plant!.species,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: gapM),

            // Humidity chip (contextual, compact)
            _buildHumidityChip(
              theme: theme,
              color: statusColor,
              humidity: vase.currentHumidity,
              status: vase.humidityStatus,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlantedVaseCompact(BuildContext context, ThemeData theme) {
    final color = AppTheme.getStatusColor(vase.humidityStatus);

    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight.isFinite ? c.maxHeight : 220.0;
        final img = (h * 0.7).clamp(68.0, 90.0);
        final gap = (h * 0.06).clamp(6.0, 12.0);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // image with overlay humidity pill
              SizedBox(
                width: img,
                height: img,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.withValues(alpha: 0.45),
                            width: 3,
                          ),
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.06,
                          ),
                        ),
                        child: ClipOval(
                          child: vase.plant!.imageUrl.isNotEmpty
                              ? Image.network(
                                  vase.plant!.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.local_florist,
                                    size: img * 0.45,
                                    color: theme.colorScheme.primary,
                                  ),
                                )
                              : Icon(
                                  Icons.local_florist,
                                  size: img * 0.45,
                                  color: theme.colorScheme.primary,
                                ),
                        ),
                      ),
                    ),
                    // overlay pill (top-right, slightly outside)
                    Positioned(
                      right: -15,
                      top: -6,
                      child: _miniHumidityPill(
                        theme,
                        color,
                        vase.currentHumidity,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: gap),

              // name (1 line) and optional species on roomy tiles
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(
                  vase.plant!.name,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (h > 235) ...[
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    vase.plant!.species,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _miniHumidityPill(ThemeData theme, Color color, double humidity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(blurRadius: 6, color: Colors.black.withValues(alpha: 0.06)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.water_drop, size: 14),
          const SizedBox(width: 4),
          Text(
            '${humidity.toStringAsFixed(0)}%',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHumidityChip({
    required ThemeData theme,
    required Color color,
    required double humidity,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.water_drop, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '${humidity.toStringAsFixed(0)}%',
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, ThemeData theme) {
    final dateFormat = DateFormat('MMM dd, HH:mm');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            Icons.access_time,
            'Last Watered',
            vase.lastIrrigation != null
                ? dateFormat.format(vase.lastIrrigation!)
                : 'Never',
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          _buildStatItem(
            context,
            Icons.water,
            'Total Used',
            '${vase.totalWaterUsed.toStringAsFixed(1)}L',
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          _buildStatItem(
            context,
            vase.isLightOn ? Icons.wb_incandescent : Icons.light_mode,
            'Light ${vase.lightingStatus}',
            '${vase.dailyLightExposure.toStringAsFixed(1)}h',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    if (vase.isEmpty) {
      if (compact) {
        return Align(
          alignment: Alignment.centerRight,
          child: IconButton.filled(
            onPressed: onPlantTap,
            icon: const Icon(Icons.add),
            style: ElevatedButton.styleFrom(
              iconColor: theme.colorScheme.onInverseSurface,
            ),
          ),
        );
      }
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPlantTap,
          icon: const Icon(Icons.add),
          label: const Text('Add Plant'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
    } else {
      if (compact) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton.outlined(
              onPressed: onWaterTap,
              icon: const Icon(Icons.water_drop),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(width: 6),
            IconButton.outlined(
              onPressed: onLightTap,
              icon: const Icon(Icons.light_mode),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.secondary),
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filled(
              onPressed: onTap,
              icon: const Icon(Icons.info_outline),
              style: OutlinedButton.styleFrom(
                iconColor: theme.colorScheme.onInverseSurface,
              ),
            ),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onWaterTap,
                  icon: const Icon(Icons.water_drop, size: 18),
                  label: const Text('Water Now'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onLightTap,
                  icon: const Icon(Icons.light_mode, size: 18),
                  label: const Text('Light Boost'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: theme.colorScheme.secondary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Details'),
            ),
          ),
        ],
      );
    }
  }
}

class _MoistureRing extends StatelessWidget {
  final double size; // outer size
  final double value; // 0..1
  final Color color;
  final Widget child;

  const _MoistureRing({
    required this.size,
    required this.value,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color.withValues(alpha: 0.12);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // background track
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(bg),
            ),
          ),
          // animated progress
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) {
              return SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: v,
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  backgroundColor: Colors.transparent,
                ),
              );
            },
          ),
          // center content (the image)
          child,
        ],
      ),
    );
  }
}

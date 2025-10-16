// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../providers/vase_provider.dart';
import '../widgets/vase_card.dart';
import '../models/vase.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../utils/system_ui.dart';

import 'plant_selection_screen.dart';
import 'vase_detail_screen.dart';

enum ViewMode { carousel, grid }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ViewMode _viewMode = ViewMode.carousel;
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<VaseProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final overlayStyle = adaptiveSystemUiOverlayStyle(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: overlayStyle,
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text('Planty'),
          ),
          actions: [
            // View mode toggle
            IconButton(
              icon: Icon(
                _viewMode == ViewMode.carousel
                    ? Icons.grid_view_rounded
                    : Icons.view_carousel_rounded,
              ),
              onPressed: () {
                setState(() {
                  _viewMode = _viewMode == ViewMode.carousel
                      ? ViewMode.grid
                      : ViewMode.carousel;
                });
              },
              tooltip: 'Toggle view',
            ),
            // Refresh button
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<VaseProvider>().refreshVases();
              },
              tooltip: 'Refresh',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Consumer<VaseProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.vases.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.initialize(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (provider.vases.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () => provider.refreshVases(),
              child: Column(
                children: [
                  // Summary header
                  _buildSummaryHeader(context, provider),

                  // Main content
                  Expanded(
                    child: _viewMode == ViewMode.carousel
                        ? _buildCarouselView(context, provider)
                        : _buildGridView(context, provider),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, VaseProvider provider) {
    final totalVases = provider.vases.length;
    final activeVases = provider.occupiedVases.length;
    final needsWater = provider.vasesNeedingWater.length;
    final needsLight = provider.vasesNeedingLight.length;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final stats = [
      _SummaryStat(
        icon: Icons.water_drop,
        value: '$needsWater',
        label: 'Needs Water',
        caption: needsWater > 0 ? 'Requires attention' : 'All hydrated',
        color: needsWater > 0
            ? AppTheme.statusLow
            : theme.colorScheme.secondary,
      ),
      _SummaryStat(
        icon: Icons.light_mode,
        value: '$needsLight',
        label: 'Needs Light',
        caption: needsLight > 0 ? 'Boost recommended' : 'Lighting ok',
        color: needsLight > 0
            ? AppTheme.statusHigh
            : theme.colorScheme.tertiary,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'My Garden',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$activeVases / $totalVases active',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                Expanded(child: _buildSummaryCard(context, stats[i])),
                if (i != stats.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, _SummaryStat stat) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final iconTint = stat.color.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.22 : 0.14,
    );
    final labelColor =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconTint,
                shape: BoxShape.circle,
              ),
              child: Icon(stat.icon, color: stat.color, size: 22),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stat.value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: stat.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselView(BuildContext context, VaseProvider provider) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sliderHeight = constraints.maxHeight;
              const horizontalPadding = 16.0;
              const itemGap = 12.0;
              final availableWidth = constraints.maxWidth;
              final contentWidth = (availableWidth - horizontalPadding * 2)
                  .clamp(0.0, availableWidth);
              final viewportWidth = (contentWidth + itemGap).clamp(
                0.0,
                availableWidth,
              );
              final viewportFraction = availableWidth == 0
                  ? 1.0
                  : (viewportWidth / availableWidth).clamp(0.0, 1.0);

              return CarouselSlider.builder(
                itemCount: provider.vases.length,
                itemBuilder: (context, index, realIndex) {
                  final vase = provider.vases[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: itemGap / 2),
                    child: SizedBox(
                      width: contentWidth,
                      child: VaseCard(
                        vase: vase,
                        onTap: () => _navigateToDetail(context, vase),
                        onPlantTap: () =>
                            _navigateToPlantSelection(context, vase),
                        onWaterTap: () => _waterVase(context, provider, vase),
                        onLightTap: () =>
                            _boostLighting(context, provider, vase),
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: sliderHeight,
                  viewportFraction: viewportFraction,
                  enlargeCenterPage: false,
                  enableInfiniteScroll: false,
                  padEnds: true,
                  disableCenter: false,
                  pageSnapping: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentCarouselIndex = index;
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Carousel indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: provider.vases.asMap().entries.map((entry) {
            return Container(
              width: _currentCarouselIndex == entry.key ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentCarouselIndex == entry.key
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGridView(BuildContext context, VaseProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: provider.vases.length,
      itemBuilder: (context, index) {
        final vase = provider.vases[index];
        return VaseCard(
          vase: vase,
          compact: true,
          onTap: () => _navigateToDetail(context, vase),
          onPlantTap: () => _navigateToPlantSelection(context, vase),
          onWaterTap: () => _waterVase(context, provider, vase),
          onLightTap: () => _boostLighting(context, provider, vase),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.spa_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text('No vases found', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Connect your irrigation system to get started',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Vase vase) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaseDetailScreen(vaseId: vase.id),
      ),
    );
  }

  void _navigateToPlantSelection(BuildContext context, Vase vase) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantSelectionScreen(vaseId: vase.id),
      ),
    );
  }

  Future<void> _waterVase(
    BuildContext context,
    VaseProvider provider,
    Vase vase,
  ) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Water Plant'),
        content: Text(
          'Start manual irrigation for ${vase.name}?\n\n'
          'Duration: ${vase.plant?.waterAmount != null ? (vase.plant!.waterAmount / 10).round() : 30} seconds',
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
      // Show loading

      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await provider.waterVase(vase.id);

      // Hide loading
      if (context.mounted) Navigator.pop(context);

      // Show result
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

  Future<void> _boostLighting(
    BuildContext context,
    VaseProvider provider,
    Vase vase,
  ) async {
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
}

class _SummaryStat {
  final IconData icon;
  final String value;
  final String label;
  final String caption;
  final Color color;

  const _SummaryStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.caption,
    required this.color,
  });
}

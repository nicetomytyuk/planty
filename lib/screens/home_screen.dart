// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../providers/vase_provider.dart';
import '../widgets/vase_card.dart';
import '../models/vase.dart';
import '../utils/constants.dart';

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
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text('Planty'),
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
                  Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
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
    );
  }

  Widget _buildSummaryHeader(BuildContext context, VaseProvider provider) {
    final totalVases = provider.vases.length;
    final activeVases = provider.occupiedVases.length;
    final needsWater = provider.vasesNeedingWater.length;
    final needsLight = provider.vasesNeedingLight.length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context,
              Icons.local_florist,
              '$activeVases/$totalVases',
              'Active',
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              Icons.water_drop,
              '$needsWater',
              'Needs Water',
              needsWater > 0 ? Colors.orange : Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              Icons.light_mode,
              '$needsLight',
              'Needs Light',
              needsLight > 0 ? Colors.amber : Colors.yellow[700]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselView(BuildContext context, VaseProvider provider) {
    return Column(
      children: [
        Expanded(
          child: CarouselSlider.builder(
            itemCount: provider.vases.length,
            itemBuilder: (context, index, realIndex) {
              final vase = provider.vases[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: VaseCard(
                  vase: vase,
                  onTap: () => _navigateToDetail(context, vase),
                  onPlantTap: () => _navigateToPlantSelection(context, vase),
                  onWaterTap: () => _waterVase(context, provider, vase),
                  onLightTap: () => _boostLighting(context, provider, vase),
                ),
              );
            },
            options: CarouselOptions(
              height: 500,
              viewportFraction: 0.85,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
            ),
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

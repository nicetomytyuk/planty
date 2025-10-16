// lib/screens/plant_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vase_provider.dart';
import '../models/plant.dart';

class PlantSelectionScreen extends StatefulWidget {
  final String vaseId;

  const PlantSelectionScreen({super.key, required this.vaseId});

  @override
  State<PlantSelectionScreen> createState() => _PlantSelectionScreenState();
}

class _PlantSelectionScreenState extends State<PlantSelectionScreen> {
  String _searchQuery = '';
  Plant? _selectedPlant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Plant')),
      body: Consumer<VaseProvider>(
        builder: (context, provider, child) {
          final vase = provider.getVaseById(widget.vaseId);

          if (vase == null) {
            return const Center(child: Text('Vase not found'));
          }

          final filteredPlants = _searchQuery.isEmpty
              ? provider.plantLibrary
              : provider.plantLibrary
                    .where(
                      (plant) =>
                          plant.name.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ||
                          plant.species.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search plants...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Info banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select a plant for ${vase.name}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Plant list
              Expanded(
                child: filteredPlants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No plants found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredPlants.length,
                        itemBuilder: (context, index) {
                          final plant = filteredPlants[index];
                          final isSelected = _selectedPlant?.id == plant.id;

                          return _buildPlantItem(context, plant, isSelected);
                        },
                      ),
              ),

              // Bottom action button
              if (_selectedPlant != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _confirmSelection(context, provider),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Plant Selected Seed',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlantItem(BuildContext context, Plant plant, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPlant = isSelected ? null : plant;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Plant image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
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

              const SizedBox(width: 12),

              // Plant info
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildInfoChip(
                          context,
                          Icons.water_drop,
                          '${plant.minHumidity.toInt()}-${plant.maxHumidity.toInt()}%',
                        ),
                        _buildInfoChip(
                          context,
                          Icons.schedule,
                          '${plant.irrigationFrequency.inHours}h',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: Colors.grey[400],
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSelection(
    BuildContext context,
    VaseProvider provider,
  ) async {
    if (_selectedPlant == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await provider.assignPlant(
      widget.vaseId,
      _selectedPlant!.id,
    );

    // Hide loading
    if (context.mounted) Navigator.pop(context);

    if (success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedPlant!.name} planted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to plant. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

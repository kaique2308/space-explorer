import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/apod_model.dart';
import '../providers/apod_provider.dart';
import '../services/nasa_api_service.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import 'detail_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final NasaApiService _nasaService = NasaApiService();
  List<ApodModel> _apods = [];
  bool _loading = true;
  String? _error;
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _loadDefault();
    context.read<ApodProvider>().firebaseService.logScreenView('gallery');
  }

  Future<void> _loadDefault() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _nasaService.fetchRecentApods(count: 20);
      if (mounted) setState(() { _apods = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1995, 6, 16),
      lastDate: now,
      initialDateRange: _selectedRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 14)), end: now),
      helpText: 'Selecione o período',
      saveText: 'Confirmar',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accent,
            surface: AppTheme.card,
            background: AppTheme.background,
            onBackground: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() { _selectedRange = picked; _loading = true; _error = null; });
      try {
        final list = await _nasaService.fetchApodsBetween(picked.start, picked.end);
        if (mounted) setState(() { _apods = list; _loading = false; });
      } catch (e) {
        if (mounted) setState(() { _error = e.toString(); _loading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_rounded, color: AppTheme.accent),
            tooltip: 'Filtrar por data',
            onPressed: _pickDateRange,
          ),
          if (_selectedRange != null)
            IconButton(
              icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondary),
              tooltip: 'Limpar filtro',
              onPressed: () { setState(() => _selectedRange = null); _loadDefault(); },
            ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedRange != null) _FilterBanner(range: _selectedRange!),
          Expanded(
            child: _loading
                ? _buildShimmerGrid()
                : _error != null
                    ? ErrorStateWidget(message: _error!, onRetry: _loadDefault)
                    : _apods.isEmpty
                        ? const Center(
                            child: Text('Nenhuma imagem encontrada para este período.',
                                style: TextStyle(color: AppTheme.textSecondary)))
                        : _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return RefreshIndicator(
      color: AppTheme.accent,
      backgroundColor: AppTheme.surface,
      onRefresh: _loadDefault,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.78,
        ),
        itemCount: _apods.length,
        itemBuilder: (context, index) => _GalleryCard(apod: _apods[index]),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.78,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => const ShimmerCard(height: 200),
    );
  }
}

class _FilterBanner extends StatelessWidget {
  final DateTimeRange range;
  const _FilterBanner({required this.range});

  @override
  Widget build(BuildContext context) {
    String fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded, color: AppTheme.accent, size: 16),
          const SizedBox(width: 8),
          Text('${fmt(range.start)} → ${fmt(range.end)}',
              style: const TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final ApodModel apod;
  const _GalleryCard({required this.apod});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => DetailScreen(apod: apod))),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: apod.isImage
                  ? SpaceImage(url: apod.url,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)))
                  : Container(
                      color: AppTheme.surface,
                      child: const Center(
                        child: Icon(Icons.play_circle_fill_rounded, color: AppTheme.accent, size: 40),
                      ),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(apod.formattedDate, style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(apod.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary, fontSize: 12),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    if (!apod.isImage)
                      const GlowChip(label: 'VÍDEO', icon: Icons.play_arrow_rounded, color: AppTheme.nebulaGreen),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

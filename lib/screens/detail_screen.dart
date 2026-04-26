import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/apod_model.dart';
import '../providers/apod_provider.dart';
import '../services/translation_service.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class DetailScreen extends StatefulWidget {
  final ApodModel apod;
  const DetailScreen({super.key, required this.apod});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;
  bool _loadingFav = true;
  String? _translatedExplanation;
  bool _translating = true;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
    _translateExplanation();
    context.read<ApodProvider>().firebaseService.logApodViewed(
          widget.apod.title, widget.apod.date);
  }

  Future<void> _translateExplanation() async {
    setState(() => _translating = true);
    final translated = await TranslationService.translateToPtBr(widget.apod.explanation);
    if (mounted) {
      setState(() {
        _translatedExplanation = translated;
        _translating = false;
      });
    }
  }

  Future<void> _checkFavorite() async {
    final fav = await context.read<ApodProvider>().isFavorite(widget.apod.date);
    if (mounted) setState(() { _isFavorite = fav; _loadingFav = false; });
  }

  Future<void> _toggleFavorite() async {
    setState(() => _loadingFav = true);
    await context.read<ApodProvider>().toggleFavorite(widget.apod);
    final fav = await context.read<ApodProvider>().isFavorite(widget.apod.date);
    if (mounted) setState(() { _isFavorite = fav; _loadingFav = false; });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fav ? '⭐ Adicionado aos favoritos!' : 'Removido dos favoritos'),
          backgroundColor: fav ? AppTheme.gold : AppTheme.textSecondary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _openHdImage() async {
    final url = widget.apod.hdUrl ?? widget.apod.url;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apod = widget.apod;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppTheme.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.background.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.divider),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.background.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: _loadingFav
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.gold))
                      : Icon(
                          _isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: _isFavorite ? AppTheme.gold : AppTheme.textPrimary,
                          size: 18),
                ),
                onPressed: _loadingFav ? null : _toggleFavorite,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: apod.isImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        SpaceImage(url: apod.url, height: 320, borderRadius: BorderRadius.zero),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, AppTheme.background],
                                stops: const [0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: AppTheme.surface,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_circle_fill_rounded,
                                color: AppTheme.accent, size: 72),
                            const SizedBox(height: 8),
                            Text('Conteúdo em vídeo',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chips de data e tipo
                  Row(
                    children: [
                      GlowChip(label: apod.formattedDate, icon: Icons.calendar_today_outlined),
                      const SizedBox(width: 8),
                      GlowChip(
                        label: apod.isImage ? 'IMAGEM' : 'VÍDEO',
                        icon: apod.isImage ? Icons.image_outlined : Icons.play_arrow_rounded,
                        color: AppTheme.nebulaGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Título (mantém em inglês pois é nome próprio)
                  Text(apod.title, style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 8),

                  // Copyright
                  if (apod.copyright != null)
                    Row(
                      children: [
                        const Icon(Icons.camera_alt_outlined,
                            color: AppTheme.textSecondary, size: 14),
                        const SizedBox(width: 6),
                        Text(apod.copyright!.trim(),
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // Divisor
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [AppTheme.accent.withOpacity(0.5), Colors.transparent]),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Seção "Sobre" com tradução
                  Row(
                    children: [
                      Text('Sobre',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppTheme.accent)),
                      const SizedBox(width: 8),
                      // Badge de tradução
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.nebulaGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.nebulaGreen.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _translating ? Icons.sync_rounded : Icons.translate_rounded,
                              color: AppTheme.nebulaGreen,
                              size: 11,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _translating ? 'Traduzindo...' : 'Traduzido',
                              style: TextStyle(
                                color: AppTheme.nebulaGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Texto da explicação — traduzido ou carregando
                  if (_translating)
                    Column(
                      children: [
                        const ShimmerCard(height: 16),
                        const SizedBox(height: 8),
                        const ShimmerCard(height: 16),
                        const SizedBox(height: 8),
                        const ShimmerCard(height: 16),
                        const SizedBox(height: 8),
                        const ShimmerCard(height: 16),
                      ],
                    )
                  else
                    Text(
                      _translatedExplanation ?? apod.explanation,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),

                  const SizedBox(height: 28),

                  // Botões de ação
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: _isFavorite ? 'Salvo' : 'Salvar',
                          icon: _isFavorite
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: _isFavorite ? AppTheme.gold : AppTheme.accent,
                          onTap: _toggleFavorite,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          label: 'Ver em HD',
                          icon: Icons.open_in_new_rounded,
                          color: AppTheme.nebulaGreen,
                          onTap: _openHdImage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

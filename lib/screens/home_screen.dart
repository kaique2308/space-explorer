import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/apod_provider.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import 'detail_screen.dart';
import 'gallery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _random = Random(42);
  late final List<Offset> _stars;
  late final List<double> _starSizes;

  @override
  void initState() {
    super.initState();
    _stars = List.generate(80, (_) => Offset(_random.nextDouble(), _random.nextDouble()));
    _starSizes = List.generate(5, (_) => _random.nextDouble() * 1.5 + 0.3);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ApodProvider>();
      provider.loadTodayApod();
      provider.loadRecentApods();
      provider.firebaseService.logScreenView('home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: StarsPainter(stars: _stars, sizes: _starSizes),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: AppTheme.accent,
              backgroundColor: AppTheme.surface,
              onRefresh: () async {
                await context.read<ApodProvider>().loadTodayApod();
                await context.read<ApodProvider>().refreshRecentApods();
              },
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  _buildTodaySection(),
                  _buildRecentSection(),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: false,
      floating: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [AppTheme.accent, AppTheme.background],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Explorador Espacial',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary, fontSize: 16)),
                  Text('Astronomia da NASA',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11, color: AppTheme.accent)),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search_rounded, color: AppTheme.textPrimary),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
            ),
          ],
        ),
      ),
      toolbarHeight: 64,
    );
  }

  Widget _buildTodaySection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const GlowChip(
                  label: 'FOTO DO DIA',
                  icon: Icons.auto_awesome,
                  color: AppTheme.gold,
                ),
                const Spacer(),
                Text(_todayDateString(),
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<ApodProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.todayApod == null) {
                  return const ShimmerCard(height: 380);
                }
                if (provider.status == ApodStatus.error && provider.todayApod == null) {
                  return ErrorStateWidget(
                    message: provider.errorMessage,
                    onRetry: () => provider.loadTodayApod(),
                  );
                }
                final apod = provider.todayApod;
                if (apod == null) return const SizedBox();
                return _TodayCard(apod: apod);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Descobertas Recentes',
              subtitle: 'Últimos 12 dias da NASA',
              onSeeAll: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
            ),
            const SizedBox(height: 12),
            Consumer<ApodProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.recentApods.isEmpty) {
                  return SizedBox(
                    height: 170,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, __) => const ShimmerCard(height: 170),
                    ),
                  );
                }
                if (provider.recentApods.isEmpty) return const SizedBox();
                return SizedBox(
                  height: 185,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.recentApods.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final apod = provider.recentApods[index];
                      return _RecentCard(apod: apod);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _todayDateString() {
    final now = DateTime.now();
    const months = [
      '', 'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return '${now.day} de ${months[now.month]} de ${now.year}';
  }
}

class _TodayCard extends StatelessWidget {
  final dynamic apod;
  const _TodayCard({required this.apod});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => DetailScreen(apod: apod))),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(color: AppTheme.accent.withOpacity(0.08), blurRadius: 24, spreadRadius: 4)
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              if (apod.isImage)
                SpaceImage(url: apod.url, height: 360)
              else
                Container(
                  height: 360,
                  color: AppTheme.card,
                  child: const Center(
                    child: Icon(Icons.play_circle_fill_rounded, color: AppTheme.accent, size: 64),
                  ),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.background.withOpacity(0.5),
                        AppTheme.background.withOpacity(0.95),
                      ],
                      stops: const [0.3, 0.65, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (apod.copyright != null)
                        GlowChip(
                          label: '© ${apod.copyright!.trim()}',
                          icon: Icons.camera_alt_outlined,
                        ),
                      const SizedBox(height: 8),
                      Text(apod.title,
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 22,
                                shadows: [Shadow(blurRadius: 8, color: Colors.black.withOpacity(0.5))],
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Text(apod.explanation,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.arrow_forward_rounded, color: AppTheme.accent, size: 16),
                          const SizedBox(width: 4),
                          Text('Explorar',
                              style: TextStyle(
                                  color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final dynamic apod;
  const _RecentCard({required this.apod});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => DetailScreen(apod: apod))),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (apod.isImage)
              SpaceImage(url: apod.url, height: 100, borderRadius: BorderRadius.zero)
            else
              Container(
                height: 100,
                color: AppTheme.surface,
                child: const Center(
                  child: Icon(Icons.play_circle_outline_rounded, color: AppTheme.accent, size: 36),
                ),
              ),
            Expanded(
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
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

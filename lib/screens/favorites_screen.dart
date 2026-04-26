import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorite_model.dart';
import '../providers/apod_provider.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ApodProvider>().firebaseService.logScreenView('favorites');
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = context.read<ApodProvider>().firebaseService;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Missões Salvas'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<FavoriteModel>>(
        stream: firebaseService.favoritesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, color: AppTheme.nebulaPink, size: 56),
                    const SizedBox(height: 16),
                    Text('Erro no Firebase', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          final favorites = snapshot.data ?? [];
          if (favorites.isEmpty) return _EmptyFavorites();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final fav = favorites[index];
              return _FavoriteCard(
                favorite: fav,
                onDelete: () async {
                  await firebaseService.removeFavorite(fav.id);
                  await firebaseService.logFavoriteRemoved(fav.title);
                  context.read<ApodProvider>().invalidateFavoriteCache(fav.date);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Removido dos favoritos'),
                        backgroundColor: AppTheme.textSecondary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.gold.withOpacity(0.1),
                border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
              ),
              child: const Icon(Icons.bookmark_border_rounded, color: AppTheme.gold, size: 48),
            ),
            const SizedBox(height: 24),
            Text('Nenhuma missão salva', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Toque no ícone de favorito em\nqualquer imagem para salvá-la aqui.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteModel favorite;
  final VoidCallback onDelete;

  const _FavoriteCard({required this.favorite, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(favorite.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.nebulaPink.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.nebulaPink.withOpacity(0.3)),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppTheme.nebulaPink, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            SpaceImage(url: favorite.imageUrl, height: 100,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlowChip(label: favorite.date, icon: Icons.calendar_today_outlined),
                    const SizedBox(height: 6),
                    Text(favorite.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.swipe_left_rounded, color: AppTheme.textSecondary, size: 12),
                        const SizedBox(width: 4),
                        Text('Deslize para remover',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10)),
                      ],
                    ),
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

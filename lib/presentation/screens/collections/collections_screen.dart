import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:notchnco_task/core/di/injection_container.dart';
import 'package:notchnco_task/domain/entities/movie.dart';
import 'package:notchnco_task/domain/entities/movie_collection.dart';
import 'package:notchnco_task/core/base_state/base_state.dart';
import 'package:notchnco_task/presentation/cubit/collections/collections_cubit.dart';
import 'package:notchnco_task/routes/app_routes.dart';
import 'package:notchnco_task/widgets/custom_bottom_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CollectionsCubit>(
      create: (_) => sl<CollectionsCubit>()..loadCollections(),
      child: const _CollectionsView(),
    );
  }
}

class _CollectionsView extends StatelessWidget {
  const _CollectionsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Movie Categories',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      body: BlocBuilder<CollectionsCubit, BaseState<List<MovieCollection>>>(
        builder: (context, state) {
          if (state is BaseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BaseError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                  SizedBox(height: 2.h),
                  Text((state as BaseError).message, style: theme.textTheme.titleMedium),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: () => context.read<CollectionsCubit>().loadCollections(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is BaseSuccess<List<MovieCollection>>) {
            final collections = state.data;
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                return _buildCollectionSection(context, collection, theme);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),

      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.popularMovies);
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, AppRoutes.genres);
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, AppRoutes.favorites);
          }
        },
      ),
    );
  }

  Widget _buildCollectionSection(BuildContext context, MovieCollection collection, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (collection.overview.isNotEmpty)
                      Text(
                        collection.overview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {}, // Could navigate to a specialized collection screen
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 35.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 4.w),
            itemCount: collection.movies.length,
            itemBuilder: (context, index) {
              final movie = collection.movies[index];
              return Container(
                width: 45.w,
                margin: EdgeInsets.only(right: 4.w),
                child: _buildSmallMovieCard(context, movie, theme),
              );
            },
          ),
        ),
        Divider(height: 4.h, indent: 4.w, endIndent: 4.w),
      ],
    );
  }

  Widget _buildSmallMovieCard(BuildContext context, Movie movie, ThemeData theme) {
    final posterUrl = 'https://image.tmdb.org/t/p/w500${movie.posterPath}';
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.movieDetails,
          arguments: movie.id,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.movie_outlined),
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

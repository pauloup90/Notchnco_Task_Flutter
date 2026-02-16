import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import 'package:notchnco_task/core/di/injection_container.dart';
import 'package:notchnco_task/core/utils/image_helper.dart';
import 'package:notchnco_task/core/base_state/base_state.dart';
import 'package:notchnco_task/presentation/cubit/movie_details/movie_details_cubit.dart';

class MovieDetailsScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MovieDetailsCubit>(
      create: (_) => sl<MovieDetailsCubit>()..loadMovieDetails(movieId),
      child: _MovieDetailsView(movieId: movieId),
    );
  }
}

class _MovieDetailsView extends StatelessWidget {
  final int movieId;

  const _MovieDetailsView({required this.movieId});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<MovieDetailsCubit, BaseState<MovieDetailsData>>(
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
                    onPressed: () => context.read<MovieDetailsCubit>().loadMovieDetails(movieId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is BaseSuccess<MovieDetailsData>) {
            final data = state.data;
            final details = data.movieDetails;
            final isFavorite = data.isFavorite;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 40.h,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: ImageHelper.getOriginalBackdropUrl(details.backdropPath),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[300]),
                          errorWidget: (context, url, error) => Container(color: Colors.grey[400]),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                details.title,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                context.read<MovieDetailsCubit>().toggleMovieFavorite();
                              },
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: details.genres.map((genre) => Chip(
                            label: Text(genre.name),
                            backgroundColor: theme.chipTheme.backgroundColor,
                            labelStyle: theme.textTheme.bodySmall,
                          )).toList(),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                             _buildInfoItem(context, Icons.calendar_today, details.releaseYear),
                             SizedBox(width: 4.w),
                             _buildInfoItem(context, Icons.star, details.formattedRating),
                             SizedBox(width: 4.w),
                             _buildInfoItem(context, Icons.access_time, details.formattedRuntime),
                          ],
                        ),
                         if (details.tagline != null && details.tagline!.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            '"${details.tagline}"',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        SizedBox(height: 2.h),
                        Text(
                          'Overview',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          details.overview.isEmpty 
                              ? 'No overview available.' 
                              : details.overview,
                          style: theme.textTheme.bodyLarge,
                        ),
                         SizedBox(height: 4.h), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
           return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        SizedBox(width: 1.w),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

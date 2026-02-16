import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sizer/sizer.dart';
import 'package:notchnco_task/core/di/injection_container.dart';
import 'package:notchnco_task/domain/entities/genre.dart';
import 'package:notchnco_task/core/base_state/base_state.dart';
import 'package:notchnco_task/presentation/cubit/genre_movies/genre_movies_cubit.dart';
import 'package:notchnco_task/presentation/widgets/movie_card_widget.dart';
import 'package:notchnco_task/routes/app_routes.dart';

class GenreMoviesScreen extends StatelessWidget {
  final Genre genre;

  const GenreMoviesScreen({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GenreMoviesCubit>(
      create: (_) => sl<GenreMoviesCubit>()..loadMoviesByGenre(genre.id),
      child: _GenreMoviesView(genre: genre),
    );
  }
}

class _GenreMoviesView extends StatefulWidget {
  final Genre genre;
  const _GenreMoviesView({required this.genre});

  @override
  State<_GenreMoviesView> createState() => _GenreMoviesViewState();
}

class _GenreMoviesViewState extends State<_GenreMoviesView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      context.read<GenreMoviesCubit>().loadMoreMovies(widget.genre.id);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.genre.name,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<GenreMoviesCubit, BaseState<GenreMoviesData>>(
        builder: (context, state) {
          if (state is BaseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BaseError) {
            return Center(child: Text((state as BaseError).message));
          } else if (state is BaseSuccess<GenreMoviesData>) {
            final data = state.data;
            return RefreshIndicator(
              onRefresh: () => context.read<GenreMoviesCubit>().loadMoviesByGenre(widget.genre.id),
              child: AnimationLimiter(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                  itemCount: data.movies.length + (data.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= data.movies.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final movie = data.movies[index];
                    final isFavorite = data.favoriteStatus[movie.id] ?? false;

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: MovieCardWidget(
                            movie: movie,
                            isFavorite: isFavorite,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.movieDetails,
                                arguments: movie.id,
                              );
                            },
                            onFavoriteToggle: () {
                              context.read<GenreMoviesCubit>().toggleMovieFavorite(movie);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

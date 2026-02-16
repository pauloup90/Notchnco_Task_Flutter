import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:notchnco_task/core/di/injection_container.dart';
import 'package:notchnco_task/domain/entities/genre.dart';
import 'package:notchnco_task/core/base_state/base_state.dart';
import 'package:notchnco_task/presentation/cubit/genres/genres_cubit.dart';
import 'package:notchnco_task/routes/app_routes.dart';
import 'package:notchnco_task/widgets/custom_bottom_bar.dart';

class GenresScreen extends StatelessWidget {
  const GenresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GenresCubit>(
      create: (_) => sl<GenresCubit>()..loadGenres(),
      child: const _GenresView(),
    );
  }
}

class _GenresView extends StatelessWidget {
  const _GenresView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,

        title: Text(
          'Categories',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6F35A1), // Purple color from image
          ),
        ),
      ),
      body: BlocBuilder<GenresCubit, BaseState<List<Genre>>>(
        builder: (context, state) {
          if (state is BaseLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6F35A1)));
          } else if (state is BaseError) {
            return Center(child: Text((state as BaseError).message));
          } else if (state is BaseSuccess<List<Genre>>) {
            final genres = state.data;
            return GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 5.w,
                mainAxisSpacing: 5.w,
              ),
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                return _buildCreativeCard(context, genre, index);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, AppRoutes.favorites);
          }
        },
      ),
    );
  }

  Widget _buildCreativeCard(BuildContext context, Genre genre, int index) {
    final List<List<Color>> internalGradients = [
      [const Color(0xFF5A57FF), const Color(0xFF8E8CFF)], // Blue
      [const Color(0xFFFF8E72), const Color(0xFFFFB09C)], // Orange
      [const Color(0xFF23CF8B), const Color(0xFF4EE2A8)], // Green
      [const Color(0xFFC330FF), const Color(0xFFD97BFF)], // Purple
      [const Color(0xFFFFB84D), const Color(0xFFFFD48C)], // Amber
      [const Color(0xFFFF4D4D), const Color(0xFFFF8C8C)], // Red
      [const Color(0xFF4DCCFF), const Color(0xFF8CE4FF)], // Cyan
      [const Color(0xFFFF308E), const Color(0xFFFF7BB5)], // Pink
    ];

    final colors = internalGradients[index % internalGradients.length];
    final icon = _getGenreIcon(genre.name);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.genreMovies,
          arguments: genre,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.35),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Watermark Icon
            Positioned(
              bottom: -20,
              right: -20,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  icon,
                  size: 100.sp,
                  color: Colors.white,
                ),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon at Top Left
                  Icon(
                    icon,
                    size: 28.sp,
                    color: Colors.white,
                  ),
                  
                  // Text at Bottom Left
                  Text(
                    genre.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGenreIcon(String name) {
    name = name.toLowerCase();
    if (name.contains('action')) return Icons.bolt_rounded;
    if (name.contains('adventure')) return Icons.explore_rounded;
    if (name.contains('animation')) return Icons.auto_awesome_rounded;
    if (name.contains('comedy')) return Icons.sentiment_very_satisfied_rounded;
    if (name.contains('crime')) return Icons.security_rounded;
    if (name.contains('documentary')) return Icons.description_rounded;
    if (name.contains('drama')) return Icons.theater_comedy_rounded;
    if (name.contains('family')) return Icons.group_rounded;
    if (name.contains('fantasy')) return Icons.auto_fix_high_rounded;
    if (name.contains('history')) return Icons.menu_book_rounded;
    if (name.contains('horror')) return Icons.new_releases_rounded;
    if (name.contains('music')) return Icons.music_note_rounded;
    if (name.contains('mystery')) return Icons.psychology_rounded;
    if (name.contains('romance')) return Icons.favorite_rounded;
    if (name.contains('science fiction')) return Icons.rocket_launch_rounded;
    if (name.contains('tv movie')) return Icons.live_tv_rounded;
    if (name.contains('thriller')) return Icons.warning_amber_rounded;
    if (name.contains('war')) return Icons.military_tech_rounded;
    if (name.contains('western')) return Icons.agriculture_rounded;
    return Icons.movie_filter_rounded;
  }
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:movie_app_ui/api/movie_api.dart';
import 'package:movie_app_ui/models/movie_model.dart';

import '../../../core/constants/constants.dart';
import '../../../features/movie/movie_page.dart';

class MoviesView extends StatefulWidget {
  const MoviesView({Key? key}) : super(key: key);

  @override
  State<MoviesView> createState() => _MoviesViewState();
}

class _MoviesViewState extends State<MoviesView>
    with SingleTickerProviderStateMixin {
  late final PageController _movieCardPageController;
  late final PageController _movieDetailPageController;

  double _movieCardPage = 0.0;
  double _movieDetailsPage = 0.0;
  int _movieCardIndex = 0;
  final _showMovieDetails = ValueNotifier(true);
  late Future<List<MovieModel>> getMovies = setMovies();

  Future<List<MovieModel>> setMovies() async {
    return MovieApi().fetchMovieModel();
  }

  @override
  void initState() {
    _movieCardPageController = PageController(viewportFraction: 0.77)
      ..addListener(_movieCardPagePercentListener);
    _movieDetailPageController = PageController()
      ..addListener(_movieDetailsPagePercentListener);

    super.initState();
  }

  _movieCardPagePercentListener() {
    setState(() {
      _movieCardPage = _movieCardPageController.page!;
      _movieCardIndex = _movieCardPageController.page!.round();
    });
  }

  _movieDetailsPagePercentListener() {
    setState(() {
      _movieDetailsPage = _movieDetailPageController.page!;
    });
  }

  @override
  void dispose() {
    _movieCardPageController
      ..removeListener(_movieCardPagePercentListener)
      ..dispose();
    _movieDetailPageController
      ..removeListener(_movieDetailsPagePercentListener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MovieModel>>(
      future: getMovies,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done &&
            snapshot.connectionState != ConnectionState.active) {
          List<MovieModel> movies = snapshot.data!;
          print(movies);
          return LayoutBuilder(
            builder: (_, constraints) {
              final h = constraints.maxHeight;
              final w = constraints.maxWidth;
              return Column(
                children: [
                  const Spacer(),

                  //* Movie Cards
                  SizedBox(
                    height: h * 0.65,
                    child: PageView.builder(
                      controller: _movieCardPageController,
                      clipBehavior: Clip.none,
                      itemCount: movies.length,
                      onPageChanged: (page) {
                        _movieDetailPageController.animateToPage(
                          page,
                          duration: const Duration(milliseconds: 50),
                          curve:
                              const Interval(0.25, 1, curve: Curves.decelerate),
                        );
                      },
                      itemBuilder: (_, index) {
                        final movie = movies[index];
                        final progress = (_movieCardPage - index);
                        final scale = ui.lerpDouble(1, .8, progress.abs())!;
                        final isCurrentPage = index == _movieCardIndex;
                        // final isScrolling = _movieCardPageController
                        //     .position.isScrollingNotifier.value;
                        // final isFirstPage = index == 0;

                        return Transform.scale(
                          alignment: Alignment.lerp(
                            Alignment.topLeft,
                            Alignment.center,
                            -progress,
                          ),
                          scale:
                              scale, //isScrolling && isFirstPage ? 1 - progress : scale,
                          child: GestureDetector(
                            onTap: () {
                              _showMovieDetails.value =
                                  !_showMovieDetails.value;
                              const transitionDuration =
                                  Duration(milliseconds: 55);
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: transitionDuration,
                                  reverseTransitionDuration: transitionDuration,
                                  pageBuilder: (_, animation, ___) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: MoviePage(movie: movie),
                                    );
                                  },
                                ),
                              );
                              Future.delayed(transitionDuration, () {
                                _showMovieDetails.value =
                                    !_showMovieDetails.value;
                              });
                            },
                            child: Hero(
                              tag: movie.mainImg,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                transform: Matrix4.identity()
                                  ..translate(
                                    isCurrentPage ? 0.0 : -20.0,
                                    isCurrentPage ? 0.0 : 60.0,
                                  ),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(70),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 25,
                                      offset: const Offset(0, 25),
                                      color: Colors.black.withOpacity(.2),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: NetworkImage(movie.mainImg),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                  //* Movie Details
                  SizedBox(
                    height: h * 0.22,
                    child: PageView.builder(
                      controller: _movieDetailPageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: movies.length,
                      itemBuilder: (_, index) {
                        final movie = movies[index];
                        final opacity =
                            (index - _movieDetailsPage).clamp(0.0, 1.0);

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                          child: Opacity(
                            opacity: 1 - opacity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Hero(
                                  tag: movie.title,
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: Text(
                                      movie.title.toUpperCase(),
                                      style: AppTextStyles.movieNameTextStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        }

        /// handles others as you did on question
        else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

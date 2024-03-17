import 'package:flutter/material.dart';
import 'package:movie_app_ui/models/movie_model.dart';

import '../../booking/booking_page.dart';
import '../../../../core/constants/constants.dart';

class BookButton extends StatelessWidget {
  const BookButton({Key? key, required this.movie}) : super(key: key);

  final MovieModel movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        const transitionDuration = Duration(milliseconds: 200);

        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: transitionDuration,
            reverseTransitionDuration: transitionDuration,
            pageBuilder: (_, animation, ___) {
              return FadeTransition(
                opacity: animation,
                child: BookingPage(movie: movie),
              );
            },
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}

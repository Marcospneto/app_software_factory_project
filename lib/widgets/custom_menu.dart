import 'package:flutter/material.dart';
import 'package:meu_tempo/config/app_routes.dart';
import 'package:meu_tempo/config/main_color.dart';

class CustomMenu extends StatelessWidget {
  const CustomMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 83,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.home);
            },
            icon: Icon(
              Icons.calendar_month,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.searchTask),
            icon: Icon(
              Icons.search,
              size: 28,
            ),
          ),
          Container(
            width: 70,
            height: 45,
            decoration: BoxDecoration(
              color: MainColor.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.task),
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context,
                AppRoutes.syntheticReport, ModalRoute.withName(AppRoutes.home)),
            icon: Icon(
              Icons.insert_chart_outlined,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.settingsPage),
            icon: Transform.rotate(
              angle: 90 * (3.141592653589793 / 180),
              child: const Icon(
                Icons.more_vert,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

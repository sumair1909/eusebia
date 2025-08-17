import 'package:eusebia_app/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key, this.radius = 20});
  final double? radius;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.settings),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        child: Text('A'),
      ),
    );
  }
}

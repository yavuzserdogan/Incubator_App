import 'package:flutter/material.dart';
import 'package:incubator/presentation/themes/text_style.dart';

import '../../core/constants/color_constant.dart';

class AppBarStyle extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final TextStyle? style;
  final List<Widget>? actions;

  const AppBarStyle({super.key, required this.title, this.style, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: DefaultTextStyle(style: style ?? headlineMedium, child: title),
      backgroundColor: Colors.indigo.shade800,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

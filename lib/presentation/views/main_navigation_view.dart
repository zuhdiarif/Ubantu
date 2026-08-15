import 'package:flutter/material.dart';
import 'package:ubantu/components/custom_bottom_nav_bar.dart';
import 'package:ubantu/presentation/views/aktivitas_view.dart';
import 'package:ubantu/presentation/views/chat_view.dart';
import 'package:ubantu/presentation/views/home_view.dart';
import 'package:ubantu/presentation/views/profil_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _views = const [
    HomeView(),
    ChatView(),
    AktivitasView(),
    ProfilView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

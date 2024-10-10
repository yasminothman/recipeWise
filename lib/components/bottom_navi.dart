import 'package:flutter/material.dart';
import 'package:recipewise/pages/favourite.dart';
import 'package:recipewise/pages/homepage.dart';
import 'package:recipewise/pages/profile.dart';

class bottomNavi extends StatefulWidget {
  const bottomNavi({super.key});

  @override
  State<bottomNavi> createState() => _bottomNaviState();
}

class _bottomNaviState extends State<bottomNavi> {
  int _page = 1; // Current index of the selected page
  final List<Widget> _pages = [Favourite(), HomePage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        //bottom navigation bar
        body: _pages[_page], // Display the selected page

        bottomNavigationBar: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: Offset(8, 20))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
                backgroundColor: Color(0xFF245651),
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.black,
                selectedFontSize: 12,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                currentIndex: _page,
                onTap: (index) {
                  setState(() {
                    _page = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.favorite, color: Colors.white),
                      label: 'Favourite'),
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.home,
                        color: Colors.white,
                      ),
                      label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person, color: Colors.white),
                      label: 'Profile')
                ]),
          ),
        ));
  }
}

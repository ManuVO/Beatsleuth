import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'package:beatsleuth2/utils/theme_util.dart';
import 'package:provider/provider.dart';
import 'package:beatsleuth2/data/models/homePage.dart';
import 'package:beatsleuth2/data/models/searchPage.dart';
import 'adv_search_page.dart';

class WrapperPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppNavigationState(),
      child: _WrapperPageContent(),
    );
  }
}

class AppNavigationState extends ChangeNotifier {
  int selectedIndex = 0;
  final List<int> navigationHistory = [0];

  void updateIndex(int index) {
    if (index == selectedIndex) {
      return;
    }
    selectedIndex = index;
    navigationHistory.add(index);
    notifyListeners();
  }

  bool onWillPop() {
    if (navigationHistory.length > 1) {
      navigationHistory.removeLast();
      selectedIndex = navigationHistory.last;
      notifyListeners();
      return false;
    } else {
      return true;
    }
  }
}

class _WrapperPageContent extends StatefulWidget {
  @override
  _WrapperPageContentState createState() => _WrapperPageContentState();
}

class _WrapperPageContentState extends State<_WrapperPageContent> {
  HomePageData homePageData = HomePageData();
  SearchPageData searchPageData = SearchPageData();

  @override
  void initState() {
    super.initState();
    homePageData.fetchData();
    searchPageData.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppNavigationState>(
        builder: (context, navigationState, _) {
          return WillPopScope(
            onWillPop: () async => navigationState.onWillPop(),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _buildCurrentPage(navigationState),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCurrentPage(AppNavigationState navigationState) {
    switch (navigationState.selectedIndex) {
      case 0:
        return HomePage(data: homePageData);
      case 1:
        return SearchPage(data: SearchPageData());
      case 2:
        return AdvancedSearchPage();
      default:
        return Container();
    }
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<AppNavigationState>(
      builder: (context, navigationState, _) {
        return BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: MediaQuery.of(context).size.width * 0.08),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: MediaQuery.of(context).size.width * 0.08),
              label: 'Búsqueda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_search, size: MediaQuery.of(context).size.width * 0.08),
              label: 'Búsqueda+',
            ),
          ],
          currentIndex: navigationState.selectedIndex,
          onTap: (index) => navigationState.updateIndex(index),
          selectedItemColor: Theme.of(context).focusColor,
          unselectedItemColor: Colors.grey,
          backgroundColor: navBarColor(),
          showUnselectedLabels: true,
          selectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
          unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
        );
      },
    );
  }
}

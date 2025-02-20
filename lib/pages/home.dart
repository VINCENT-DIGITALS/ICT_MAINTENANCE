import 'package:flutter/material.dart';
import 'package:servicetracker_app/components/bottom_bar.dart';
import 'package:servicetracker_app/components/custom_drawer.dart';

class HomePage extends StatefulWidget {
  final String currentPage;

  const HomePage({Key? key, this.currentPage = 'home'}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Home Page'),
          
        ),
        drawer: CustomDrawer(scaffoldKey: _scaffoldKey),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Scrollbar(
                controller: _scrollController,
                thickness: 5,
                thumbVisibility: true,
                radius: Radius.circular(5),
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                ),
              ),
        bottomNavigationBar: BottomNavBar(currentPage: widget.currentPage),
      ),
    );
  }
}

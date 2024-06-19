import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'favourite.dart';
import 'homepage.dart';
import 'profile.dart';

class RecipeView extends StatefulWidget {
  final String postUrl;
  String source, title, imgUrl;
  RecipeView(
      {required this.postUrl,
      required this.imgUrl,
      required this.source,
      required this.title,
      super.key});

  @override
  State<RecipeView> createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool isFavorited = false;
  late Uri finalUrl;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    finalUrl = Uri.parse(widget.postUrl);
    if (finalUrl.scheme == 'http') {
      finalUrl = finalUrl.replace(scheme: 'https');
      print(finalUrl.toString() + " - this is the final URL");
    }
  }

  Future isFavourite() async {
    print("Masuk isFavourite");
    if (isFavorited) {
      //add favourite to Firebase
      addFavDetails(widget.title, widget.imgUrl, widget.source, widget.postUrl);
    }
  }

  Future addFavDetails(
      String title, String imgUrl, String source, String url) async {
    print("Masuk addFavDetails");
    try {
      await FirebaseFirestore.instance.collection('favourite').add({
        'title': title,
        'imgUrl': imgUrl,
        'source': source,
        'url': url,
        // Add other recipe details as needed
      });
      print('Favorited recipe added to Firestore');
    } catch (e) {
      print('Error adding favorited recipe to Firestore: $e');
      // Handle error cases
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu),
              SizedBox(
                width: 10,
              ),
              Text('RecipeWise')
            ],
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                //tukar add recipe to favourites
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(Icons.lock_open_rounded))
        ],
      ),
      body: WebView(
        onPageFinished: (val) {
          print(val);
        },
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: finalUrl.toString(),
        onWebViewCreated: (WebViewController webViewController) {
          setState(() {
            _controller.complete(webViewController);
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            isFavorited = !isFavorited;
          });
          if (isFavorited) {
            await isFavourite();
          }
        },
        child: Icon(
          isFavorited ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: BottomAppBar(
            elevation: 10,
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () {
                      HomePage();
                    },
                    icon: Icon(
                      Icons.home_outlined,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()));
                    },
                    icon: Icon(
                      Icons.person_2_outlined,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Favourite(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.favorite_outline_outlined,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.white,
                    )),
              ],
            )),
      ),
    );
  }
}

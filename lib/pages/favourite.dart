import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipewise/pages/recipe_view.dart';
import 'package:url_launcher/url_launcher.dart';

class Favourite extends StatefulWidget {
  @override
  _FavouriteState createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6F6CB),
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
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(Icons.lock_open_rounded))
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('favourite').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No favourites found.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                onDismissed: ((direction) {
                  FirebaseFirestore.instance
                      .collection('favourite')
                      .doc(doc.id)
                      .delete();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('${doc['title']} removed from favourites')));
                }),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: FavouriteTile(
                  title: doc['title'],
                  imgUrl: doc['imgUrl'],
                  source: doc['source'],
                  url: doc['url'],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class FavouriteTile extends StatelessWidget {
  final String title, imgUrl, source, url;

  FavouriteTile({
    required this.title,
    required this.imgUrl,
    required this.source,
    required this.url,
  });

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeView(
                postUrl: url, imgUrl: imgUrl, source: source, title: title),
          ),
        );
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Image.network(
              imgUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    source,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: () => _launchURL(url),
            ),
          ],
        ),
      ),
    );
  }
}

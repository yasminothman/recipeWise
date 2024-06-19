import 'package:cloud_firestore/cloud_firestore.dart';
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
      appBar: AppBar(
        title: Text('Favourite Recipes'),
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
              return FavouriteTile(
                title: doc['title'],
                imgUrl: doc['imgUrl'],
                source: doc['source'],
                url: doc['url'],
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

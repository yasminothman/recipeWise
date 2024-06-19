import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:recipewise/pages/recipe_view.dart";
import "package:url_launcher/url_launcher.dart";

class RecipeCard extends StatefulWidget {
  String url, source, title, imgUrl;
  RecipeCard(
      {required this.url,
      required this.source,
      required this.title,
      required this.imgUrl});

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool isFavorited = false;

  _launchURL(String url) async {
    print(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future isFavourite() async {
    print("Masuk isFavourite");
    if (isFavorited) {
      //add favourite to Firebase
      addFavDetails(widget.title, widget.imgUrl, widget.source, widget.url);
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
    return Container(
      child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              if (kIsWeb) {
                _launchURL(widget.url);
              } else {
                print(widget.url + "this is what we are going to see");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RecipeView(
                            postUrl: widget.url,
                            imgUrl: widget.imgUrl,
                            source: widget.source,
                            title: widget.title)));
              }
            },
            child: Container(
              margin: const EdgeInsets.all(15),
              child: Stack(children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.imgUrl,
                    height: 200,
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: 300,
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey,
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black
                            .withOpacity(0.6), // Adjust opacity as needed
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10, bottom: 8, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.title,
                                style: GoogleFonts.jost(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.source,
                                style: GoogleFonts.jost(
                                    fontSize: 15, color: Colors.white),
                              )
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              isFavorited = !isFavorited;
                            });
                            await isFavourite();
                          },
                          icon: Icon(
                            isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorited ? Colors.red : Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ]),
            ),
          )),
    );
  }
}

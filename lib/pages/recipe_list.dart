import "dart:convert";
import "package:firebase_auth/firebase_auth.dart";
import "package:http/http.dart" as http;
import "package:flutter/material.dart";
import "package:recipewise/models/recipe_model.dart";
import "package:recipewise/pages/recipe_card.dart";

import "favourite.dart";
import "homepage.dart";
import "profile.dart";

class RecipeList extends StatefulWidget {
  final List<String> userQuery;
  const RecipeList({super.key, required this.userQuery});

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  List<RecipeModel> recipes = [];
  late String query;

  @override
  void initState() {
    super.initState();
    query = widget.userQuery
        .join(","); // Combine queries into a single string    getRecipes(
    getRecipes(query); // Fetch recipes using the combined query
  }

  getRecipes(String query) async {
    print("masuk get recipes");
    String url =
        "https://api.edamam.com/search?q=$query&app_id=04e7aefd&app_key=83430c44b46e218e117cc8d8955c05d1&health=alcohol-free";

    var response = await http.get(Uri.parse(url));
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    jsonData["hits"].forEach((element) {
      print(element.toString());

      RecipeModel recipeModel = RecipeModel.fromMap(element["recipe"]);

      recipes.add(recipeModel);
    });
    print("${recipes.toString()}");
    setState(() {}); // Update the UI with the fetched recipes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu),
            SizedBox(width: 10),
            Text('RecipeWise'), // Display the query
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.lock_open_rounded),
          ),
        ],
      ),
      body: recipes.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Show a loading indicator while fetching data
          : SingleChildScrollView(
              child: Container(
                height:
                    MediaQuery.of(context).size.height, // Set a bounded height
                child: ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return RecipeCard(
                      url: recipes[index].url,
                      source: recipes[index].source,
                      title: recipes[index].label,
                      imgUrl: recipes[index].image,
                    );
                  },
                ),
              ),
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

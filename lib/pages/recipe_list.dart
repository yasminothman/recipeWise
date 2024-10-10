import "dart:convert";
import "package:firebase_auth/firebase_auth.dart";
import "package:http/http.dart" as http;
import "package:flutter/material.dart";
import "package:recipewise/components/bottom_navi.dart";
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
      backgroundColor: Color(0xFFE6F6CB),
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: null, // Button is not clickable
                  child: Text(
                    'Breakfast',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: null, // Button is not clickable
                  child: Text('Lunch', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: null, // Button is not clickable
                  child: Text('Dinner', style: TextStyle(color: Colors.black)),
                ),
                IconButton(
                  onPressed: null, // Button is not clickable
                  icon: Icon(Icons.filter_list),
                ),
              ],
            ),
          ),
        ),
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
    );
  }
}

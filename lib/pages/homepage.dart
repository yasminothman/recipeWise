import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:http/http.dart" as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipewise/components/image_classifier.dart';
import 'package:recipewise/models/recipe_model.dart';
import 'package:recipewise/pages/profile.dart';
import 'package:recipewise/pages/recipe_card.dart';
import 'favourite.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  List<String> docIDs = [];
  TextEditingController _ingredientsController = TextEditingController();
  List<RecipeModel> recipes = [];
  bool _loading = false;
  File? _selectedImage;
  int _page = 1;

  final List<Widget> _pages = [
    Favourite(),
    HomePage(),
    ProfilePage(),
  ];
  // Define a list of  ingredients
  final List<String> sampleIngredients = [
    "carrot",
    "chilli",
    "eggplant",
    "onion",
    "pepper",
    "potato",
    "pumpkin",
    "zucchini"
  ];

  getRecipes(String query) async {
    setState(() {
      _loading = true; // Show loading indicator while fetching
      recipes.clear(); // Clear existing recipes before fetching new ones
    });
    String url =
        "https://api.edamam.com/search?q=$query&app_id=04e7aefd&app_key=83430c44b46e218e117cc8d8955c05d1&health=alcohol-free";

    var response = await http.get(Uri.parse(url));
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    jsonData["hits"].forEach((element) {
      print(element.toString());

      RecipeModel recipeModel = RecipeModel.fromMap(element["recipe"]);

      recipes.add(recipeModel);
    });
    //print("${recipes.toString()}");
    setState(() {
      _loading = false; // Hide loading indicator after fetching
    });
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              print(document.reference);
              docIDs.add(document.reference.id);
            }));
  }

  List<XFile> _selectedImages = [];

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles);
      });
    }

    _navigateToImageClassifier();
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(pickedFile);
      });
    }

    _navigateToImageClassifier();
  }

  void _navigateToImageClassifier() {
    if (_selectedImages.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageClassifier(
            imageFiles: _selectedImages.map((file) => File(file.path)).toList(),
            pickImageFromGallery: _pickImageFromGallery,
            pickImageFromCamera: _pickImageFromCamera,
            onImagesUpdated: (updatedImages) {
              setState(() {
                _selectedImages =
                    updatedImages.map((file) => XFile(file.path)).toList();
              });
            },
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    getDocId();
    // TODO: implement initState
    fetchRandomRecipes();
    super.initState();
  }

  void fetchRandomRecipes() {
    // Select a random ingredient from the list
    String randomIngredient =
        sampleIngredients[Random().nextInt(sampleIngredients.length)];
    getRecipes(randomIngredient);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(children: [
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Color(0xFF02332E),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
                      //insert username user
                      Text(
                        'Hello, ',
                        style: GoogleFonts.jost(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'What are you cooking today? ',
                        style: GoogleFonts.jost(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ],
                  )),
            ]),
            SizedBox(
              height: 30,
            ),
            //text field for user to search
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ingredientsController,
                        decoration: InputDecoration(
                            hintText: "Enter ingredients",
                            hintStyle: GoogleFonts.jost(
                              fontSize: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    InkWell(
                      onTap: () {
                        if (_ingredientsController.text.isNotEmpty) {
                          setState(() {
                            _loading = true;
                          });
                          getRecipes(_ingredientsController.text);
                        } else {
                          setState(() {
                            _loading = false;
                          });
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Color(0xFF245651),
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            //list of suggested recipes scrolled horizontally
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(recipes.length, (index) {
                  return RecipeCard(
                      url: recipes[index].url,
                      source: recipes[index].source,
                      title: recipes[index].label,
                      imgUrl: recipes[index].image);
                }),
              ),
            ),
          ],
        ),
      ),

      //bottom navigation bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: SizedBox(
          width: 80.0,
          height: 80.0,
          child: SpeedDial(
            icon: Icons.camera_alt,
            backgroundColor: Color(0xFF245651),
            overlayColor: Colors.white,
            foregroundColor: Colors.white,
            overlayOpacity: 0.4,
            children: [
              SpeedDialChild(
                  onTap: () async {
                    _pickImageFromCamera();
                  },
                  child: Icon(Icons.camera_enhance_outlined),
                  label: 'Open Camera'),
              SpeedDialChild(
                  onTap: () async {
                    _pickImageFromGallery();
                  },
                  child: Icon(Icons.image_outlined),
                  label: 'Upload Image')
            ],
          ),
        ),
      ),
    );
  }
}

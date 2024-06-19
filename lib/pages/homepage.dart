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
import 'package:recipewise/pages/calendar.dart';

import 'package:recipewise/pages/profile.dart';
import 'package:recipewise/pages/recipe_card.dart';

import 'favourite.dart';

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

  getRecipes(String query) async {
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
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    getDocId();
    // TODO: implement initState
    super.initState();
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
              height: 50,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SpeedDial(
        icon: Icons.camera_enhance_rounded,
        backgroundColor: Colors.green,
        overlayColor: Colors.white,
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF245651),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: BottomAppBar(
            elevation: 10,
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            notchMargin: 5.0,
            shape: CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Navigator.pushReplacement(
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Calendar(),
                        ),
                      );
                    },
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

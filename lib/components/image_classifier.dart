import "dart:io";
import "package:flutter_speed_dial/flutter_speed_dial.dart";
import 'package:flutter_vision/flutter_vision.dart';
import "package:flutter/material.dart";
import 'package:image/image.dart' as img; // Import the image library
import "package:recipewise/pages/profile.dart";
import "package:recipewise/pages/recipe_list.dart";

import "../pages/favourite.dart";
import "../pages/homepage.dart";

class ImageClassifier extends StatefulWidget {
  final List<File> imageFiles;
  final Function()? pickImageFromGallery;
  final Function()? pickImageFromCamera;
  const ImageClassifier(
      {super.key,
      required this.imageFiles,
      this.pickImageFromGallery,
      this.pickImageFromCamera});

  @override
  State<ImageClassifier> createState() => _ImageClassifierState();
}

class _ImageClassifierState extends State<ImageClassifier> {
  List<Map<String, dynamic>> _output = [];
  FlutterVision vision = FlutterVision();

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

//load model
  Future<void> loadModel() async {
    print("masuk load model");
    await vision.loadYoloModel(
        labels: 'assets/labelslatest.txt',
        modelPath: 'assets/best_float32latest.tflite',
        modelVersion: "yolov8",
        quantization: false,
        numThreads: 1,
        useGpu: false);

    classifyImages(widget.imageFiles);
  }

// loop nak classify image banyak kali
  Future<void> classifyImages(List<File> images) async {
    for (var image in images) {
      await classifyImage(image);
    }
  }

//classify image
  Future<void> classifyImage(File image) async {
    print('masuk classify image');
    // Convert image to bytes
    final bytes = await image.readAsBytes();
    if (bytes.isEmpty) {
      print('Error: Unable to read image bytes.');
      return;
    }
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      print('Error: Unable to decode image.');
      return;
    }
    print(
        'Image decoded successfully. Width: ${decodedImage.width}, Height: ${decodedImage.height}');
    final imageHeight = decodedImage!.height;
    final imageWidth = decodedImage.width;
    // Replace Tflite.detectObjectOnImage with vision.yoloOnImage
    // Call vision.yoloOnImage with the decoded image and its dimensions
    try {
      final output = await vision.yoloOnImage(
        bytesList: bytes,
        imageHeight: imageHeight,
        imageWidth: imageWidth,
        iouThreshold: 0.1,
        confThreshold: 0.1,
        classThreshold: 0.1,
      );

      if (output == null) {
        print('Error: No output from vision.yoloOnImage.');
        return;
      }

      print('Raw Output: $output');
      List<Map<String, dynamic>> processedOutput = [];
      for (var prediction in output) {
        if (prediction.containsKey('box') && prediction.containsKey('tag')) {
          var box = prediction['box'];
          var tag = prediction['tag'];
          setState(() {
            _output.add({'label': prediction['tag']});
          });
          if (box is List && box.length > 4) {
            processedOutput.add({
              'label': tag,
              'confidence': box[4],
            });
          }
        }
      }
      print('Processed Output: $processedOutput'); // Debug print
      setState(() {
        _output.addAll(processedOutput.map((output) {
          return {
            'index': widget.imageFiles.indexOf(image),
            'label': output['label'],
            'confidence': output['confidence'],
          };
        }));
      });
    } catch (e) {
      print('Error during vision.yoloOnImage call: $e');
    }
  }

  void addMoreImages(List<File> newImages) {
    setState(() {
      widget.imageFiles.addAll(newImages);
    });
    classifyImages(newImages);
  }

  void removeImage(int index) {
    setState(() {
      widget.imageFiles.removeAt(index);
      _output.removeWhere((output) => output['index'] == index);
    });
  }

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
      ),
      body: Column(children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView.builder(
              itemCount: widget.imageFiles.length,
              itemBuilder: (context, index) {
                List<Map<String, dynamic>> currentOutput = _output
                    .where((output) => output['index'] == index)
                    .toList();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(widget.imageFiles[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      if (currentOutput.isEmpty)
                        Text('There is no ingredient detected')
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var prediction in currentOutput.take(1))
                              if (prediction['confidence'] != null)
                                Text(
                                  'Label: ${prediction['label']}, Confidence: ${prediction['confidence']}',
                                ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  removeImage(index);
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SpeedDial(
                icon: Icons.camera_enhance_rounded,
                backgroundColor: Colors.green,
                overlayColor: Colors.white,
                overlayOpacity: 0.4,
                children: [
                  SpeedDialChild(
                      onTap: () async {
                        await widget.pickImageFromCamera?.call();
                      },
                      child: Icon(Icons.camera_enhance_outlined),
                      label: 'Open Camera'),
                  SpeedDialChild(
                      onTap: () async {
                        await widget.pickImageFromGallery?.call();
                      },
                      child: Icon(Icons.image_outlined),
                      label: 'Upload Image')
                ],
              ),
              ElevatedButton(
                  onPressed: () {
                    if (_output.isNotEmpty) {
                      List<String> labels =
                          _output.map((e) => e['label'].toString()).toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeList(userQuery: labels),
                        ),
                      );
                    } else {
                      Text("No recipes available");
                    }
                  },
                  child: Text('Display Recipes')),
            ],
          ),
        )
      ]),
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

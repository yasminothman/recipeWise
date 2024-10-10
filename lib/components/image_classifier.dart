import 'dart:io';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // Import the image library
import 'package:recipewise/pages/recipe_list.dart';
import 'package:recipewise/pages/homepage.dart'; // Import your home page

class ImageClassifier extends StatefulWidget {
  final List<File> imageFiles;
  final Function()? pickImageFromGallery;
  final Function()? pickImageFromCamera;
  final Function(List<File>) onImagesUpdated;

  const ImageClassifier(
      {super.key,
      required this.imageFiles,
      this.pickImageFromGallery,
      this.pickImageFromCamera,
      required this.onImagesUpdated});

  @override
  State<ImageClassifier> createState() => _ImageClassifierState();
}

class _ImageClassifierState extends State<ImageClassifier> {
  List<File> imageFiles = [];
  List<Map<String, dynamic>> _output = [];
  late List<bool> _isProcessing; // To track processing state of each image
  FlutterVision vision = FlutterVision();

  @override
  void initState() {
    super.initState();
    imageFiles = List.from(widget.imageFiles); // Initialize the state list

    // Create a growable list instead of a fixed-length list
    _isProcessing = List.filled(imageFiles.length, true, growable: true);

    loadModel().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // Load model
  Future<void> loadModel() async {
    print("Loading model");
    await vision.loadYoloModel(
      labels: 'assets/bestmodellabels.txt',
      modelPath: 'assets/bestmodel.tflite',
      modelVersion: "yolov8",
      quantization: true,
      numThreads: 1,
      useGpu: true,
    );

    classifyImages(imageFiles);
  }

  // Loop to classify multiple images
  Future<void> classifyImages(List<File> images) async {
    for (int i = 0; i < images.length; i++) {
      await classifyImage(images[i], i);
    }
  }

  // Classify a single image
  Future<void> classifyImage(File image, int index) async {
    print('Classifying image');
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
    final imageHeight = decodedImage.height;
    final imageWidth = decodedImage.width;

    try {
      final output = await vision.yoloOnImage(
        bytesList: bytes,
        imageHeight: imageHeight,
        imageWidth: imageWidth,
        iouThreshold: 0.5,
        confThreshold: 0.5,
        classThreshold: 0.5,
      );

      if (output == null) {
        print('Error: No output from vision.yoloOnImage.');
        return;
      }

      List<Map<String, dynamic>> processedOutput = [];
      for (var prediction in output) {
        if (prediction.containsKey('box') && prediction.containsKey('tag')) {
          var box = prediction['box'];
          var tag = prediction['tag'];
          if (box is List && box.length > 4) {
            processedOutput.add({
              'label': tag,
              'confidence': box[4],
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          _output.addAll(processedOutput.map((output) {
            return {
              'index': index,
              'label': output['label'],
              'confidence': output['confidence'],
            };
          }));

          _isProcessing[index] = false; // Mark processing as complete
        });
      }
    } catch (e) {
      print('Error during vision.yoloOnImage call: $e');
    }
  }

  void addMoreImages(List<File> newImages) {
    if (mounted) {
      setState(() {
        imageFiles.addAll(newImages);

        // Add to growable _isProcessing list
        _isProcessing.addAll(List.filled(newImages.length, true));
      });
      classifyImages(newImages);
      widget.onImagesUpdated(imageFiles);
    }
  }

  void removeImage(int index) {
    if (mounted) {
      setState(() {
        if (index < 0 || index >= imageFiles.length) {
          print('Error: Invalid index $index for removing image.');
          return;
        }

        imageFiles.removeAt(index);
        _output.removeWhere((output) => output['index'] == index);
        _isProcessing
            .removeAt(index); // This will now work as _isProcessing is growable

        // Update indices of remaining outputs
        for (var output in _output) {
          if (output['index'] != null && output['index'] > index) {
            output['index'] -= 1;
          }
        }

        // Debug prints to check current state
        print('Image removed at index: $index');
        print('Current imageFiles: ${imageFiles.length}');
        print('Current _output: $_output');
      });
      widget.onImagesUpdated(imageFiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Simply pop the current screen and go back to the previous one.
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFE6F6CB),
        appBar: AppBar(
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu),
                SizedBox(width: 10),
                Text('RecipeWise')
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView.builder(
                  itemCount: imageFiles.length,
                  itemBuilder: (context, index) {
                    if (index < 0 || index >= imageFiles.length) {
                      print('Error: Invalid index $index in builder.');
                      return SizedBox(); // or handle it appropriately
                    }

                    List<Map<String, dynamic>> currentOutput = _output
                        .where((output) => output['index'] == index)
                        .toList();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Rounded corners
                            ),
                            elevation: 5, // Add shadow for depth
                            clipBehavior: Clip
                                .antiAlias, // Clip the content to the border radius
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(imageFiles[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          if (_isProcessing[index])
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircularProgressIndicator(), // Show loading indicator
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    removeImage(index);
                                  },
                                ),
                              ],
                            )
                          else if (currentOutput.isEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'No ingredients detected',
                                  style: TextStyle(
                                    fontSize: 16, // Increase font size
                                    fontWeight:
                                        FontWeight.bold, // Make the text bold
                                    color: Colors.red, // Set text color
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    removeImage(index);
                                  },
                                ),
                              ],
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (var prediction in currentOutput.take(1))
                                  if (prediction['label'] != null)
                                    Expanded(
                                      child: Text(
                                        prediction['label'].replaceFirst(
                                            RegExp(r'^\d+\s*'), ''),
                                        style: TextStyle(
                                          fontSize: 16, // Increase font size
                                          fontWeight: FontWeight
                                              .bold, // Make the text bold
                                          color: Colors.black, // Set text color
                                        ),
                                      ),
                                    ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    removeImage(index);
                                  },
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
                    icon: Icons.camera_alt,
                    backgroundColor: Colors.green,
                    overlayColor: Colors.white,
                    overlayOpacity: 0.4,
                    children: [
                      SpeedDialChild(
                        onTap: () async {
                          await widget.pickImageFromCamera?.call();
                        },
                        child: Icon(Icons.camera_enhance_outlined),
                        label: 'Open Camera',
                      ),
                      SpeedDialChild(
                        onTap: () async {
                          await widget.pickImageFromGallery?.call();
                        },
                        child: Icon(Icons.image_outlined),
                        label: 'Upload Image',
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_output.isNotEmpty) {
                          List<String> labels = _output
                              .map((e) => e['label'].toString())
                              .toList();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipeList(userQuery: labels),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("No recipes available"),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF245651),
                      ),
                      child: Text(
                        'Display Recipes',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PlantDiseaseService {
  late Interpreter _interpreter;
  bool _isInit = false;

  final List<String> _labels = [
    // TODO: Please replace or fill with your 38 PlantVillage classes below
    "Apple Scab",
    "Apple Black rot",
    "Apple Cedar apple rust",
    "Apple healthy",
    "Blueberry healthy",
    "Cherry Powdery mildew",
    "Cherry healthy",
    "Corn Cercospora leaf spot",
    "Corn Common rust",
    "Corn Northern Leaf Blight",
    "Corn healthy",
    "Grape Black rot",
    "Grape Esca Black Measles",
    "Grape Leaf blight Isariopsis Leaf Spot",
    "Grape healthy",
    "Orange Haunglongbing Citrus greening",
    "Peach Bacterial spot",
    "Peach healthy",
    "Pepper bell Bacterial spot",
    "Pepper bell healthy",
    "Potato Early blight",
    "Potato Late blight",
    "Potato healthy",
    "Raspberry healthy",
    "Soybean healthy",
    "Squash Powdery mildew",
    "Strawberry Leaf scorch",
    "Strawberry healthy",
    "Tomato Bacterial spot",
    "Tomato Early blight",
    "Tomato Late blight",
    "Tomato Leaf Mold",
    "Tomato Septoria leaf spot",
    "Tomato Spider mites Two spotted spider mite",
    "Tomato Target Spot",
    "Tomato Yellow Leaf Curl Virus",
    "Tomato mosaic virus",
    "Tomato healthy",
  ];

  Future<void> init() async {
    if (_isInit) return;
    try {
      _interpreter = await Interpreter.fromAsset('assets/plant_disease_model.tflite');
      _interpreter.allocateTensors();
      _isInit = true;
      print('TFLite model loaded successfully.');
    } catch (e) {
      print('Failed to load TFLite model: $e');
    }
  }

  Future<String?> predict(String imagePath) async {
    if (!_isInit) await init();

    try {
      File imageFile = File(imagePath);
      Uint8List imageBytes = await imageFile.readAsBytes();
      
      img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) return null;

      // Resize the image as expected by MobileNetV2 (usually 224x224)
      img.Image resizedImage = img.copyResize(decodedImage, width: 224, height: 224);

      // Convert to float32 [1, 224, 224, 3] and normalize if required by the model (often /255.0)
      var input = List.generate(1, (i) => List.generate(224, (y) => List.generate(224, (x) => List.filled(3, 0.0))));
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          input[0][y][x][0] = pixel.r / 255.0; // r
          input[0][y][x][1] = pixel.g / 255.0; // g
          input[0][y][x][2] = pixel.b / 255.0; // b
        }
      }

      // Output tensor: [1, 38] assuming 38 classes
      var output = List.generate(1, (i) => List.filled(_labels.length, 0.0));

      _interpreter.run(input, output);

      List<double> probabilities = output[0];
      int maxIndex = 0;
      double maxProb = probabilities[0];
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      return _labels.length > maxIndex ? '${_labels[maxIndex]} (${(maxProb * 100).toStringAsFixed(1)}%)' : 'Unknown';
    } catch (e) {
      print('Error running prediction: $e');
      return null;
    }
  }

  void dispose() {
    _interpreter.close();
  }
}

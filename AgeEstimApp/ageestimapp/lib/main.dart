import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Age Estim App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  late Interpreter interpreter;
  bool _isLoaded = false;
  String _result = '';

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/model.tflite');
    setState(() {
      _isLoaded = true;
    });
  }

  Future<void> loadAssetImage() async {
    List<String> imageNames = [
      'sample_image_1.jpg',
      'sample_image_16.jpg',
      'sample_image_21.jpg',
      'sample_image_28.jpg',
      'sample_image_29.jpg',
      'sample_image_30.jpg',
      'sample_image_31.jpg',
      'sample_image_45.jpg',
      'sample_image_46.jpg',
      'sample_image_56.jpg',
      'sample_image_60.jpg',
    ];

    // randomly select an image name
    final random = Random();
    String selectedImageName = imageNames[random.nextInt(imageNames.length)];

    // load image
    final ByteData data = await rootBundle.load('assets/$selectedImageName');
    final Uint8List bytes = data.buffer.asUint8List();
    final Directory tempDir = await getTemporaryDirectory();
    final File file = File('${tempDir.path}/$selectedImageName');
    await file.writeAsBytes(bytes);

    setState(() {
      _image = file;
    });
  }

  Future pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _image = File(image.path);
    });
  }

  Uint8List imageToByteListFloat32(img.Image image, int inputSize) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = img.getRed(pixel).toDouble();
        buffer[pixelIndex++] = img.getGreen(pixel).toDouble();
        buffer[pixelIndex++] = img.getBlue(pixel).toDouble();
      }
    }

    return buffer.buffer.asUint8List();
  }

  Future<void> runInference() async {
    try {
      if (!_isLoaded || _image == null) return;
      var inputImage = img.decodeImage(File(_image!.path).readAsBytesSync())!;
      inputImage = img.copyResize(inputImage, width: 200, height: 200);
      var input = imageToByteListFloat32(inputImage, 200);

      var output = List.filled(1 * 1, 0).reshape([1, 1]);

      interpreter.run(input, output);

      setState(() {
        _result = 'Estimated Age: ${output[0][0].round()} years';
      });
    } catch (e) {
      print('Error during inference: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double frameSize = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Welcome to the Age Estimation App!\nUpload an image and let AI estimate the age.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt),
                  label: Text('Load from Device'),
                  onPressed: pickImage,
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.image),
                  label: Text('Load Sample Image'),
                  onPressed: loadAssetImage,
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              height: frameSize,
              width: frameSize,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Color.fromARGB(255, 163, 71, 255), width: 5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _image == null
                  ? Center(
                      child: Text('No image selected.',
                          style: TextStyle(fontSize: 16)))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: runInference,
              child: Text('Estimate Age'),
            ),
            SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              height: 50,
              child: Text(
                _result,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

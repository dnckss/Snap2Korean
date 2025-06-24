import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:vibration/vibration.dart';
import '../components/custom_button.dart';
import '../styles/text_styles.dart';
import '../constants/sizes.dart';
import '../data/sample_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  String _extractedText = '';
  String _translatedText = '';

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      // ✅ 시뮬레이터에서는 카메라/갤러리 진입만 되고 실제 선택은 제한됨
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked == null) {
        print('사용자가 이미지를 선택하지 않음');
        return;
      }

      final imageFile = File(picked.path);
      print('선택된 이미지 경로: ${imageFile.path}');

      setState(() {
        _image = imageFile;
        _extractedText = '';
        _translatedText = '';
      });

      // ✅ OCR
      final inputImage = InputImage.fromFile(imageFile);
      final recognizer = TextRecognizer();
      final result = await recognizer.processImage(inputImage);
      await recognizer.close();

      setState(() {
        _extractedText = result.text;
        _translatedText = dummyTranslation;
      });

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate();
      }
    } catch (e) {
      print("❌ 이미지 선택 중 에러 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Snap2Korean")),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: AppSizes.imageHeight)
                : const Placeholder(fallbackHeight: AppSizes.imageHeight),
            const SizedBox(height: 20),
            Text("인식된 영어 문장", style: AppTextStyles.subtitle),
            Text(_extractedText),
            const SizedBox(height: 20),
            Text("번역 결과 (한글)", style: AppTextStyles.subtitle),
            Text(_translatedText),
            const SizedBox(height: 20),
            CustomButton(
              label: "사진에서 번역하기 (갤러리)",
              onPressed: _pickImage,
            ),
          ],
        ),
      ),
    );
  }
}
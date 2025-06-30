import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/translation_record.dart';
import 'translation_api_service.dart';

class TranslationService {
  static final ImagePicker _picker = ImagePicker();

  // 이미지에서 텍스트 추출
  static Future<String> extractTextFromImage(XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final recognizer = TextRecognizer();
      final RecognizedText recognizedText = await recognizer.processImage(inputImage);
      await recognizer.close();
      
      String extractedText = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          extractedText += '${line.text}\n';
        }
      }
      
      return extractedText.trim();
    } catch (e) {
      debugPrint('텍스트 추출 에러: $e');
      return '텍스트를 추출할 수 없습니다.';
    }
  }

  // 텍스트 번역
  static Future<String> translateText(String text) async {
    try {
      if (text.trim().isEmpty) {
        return '번역할 텍스트가 없습니다.';
      }

      // 실제 API를 사용한 번역
      final translatedText = await TranslationApiService.translateText(text);
      return translatedText;
      
    } catch (e) {
      debugPrint('번역 에러: $e');
      return '번역 중 오류가 발생했습니다.';
    }
  }

  // 이미지 선택 (갤러리)
  static Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('갤러리에서 이미지 선택 에러: $e');
      return null;
    }
  }

  // 이미지 촬영 (카메라)
  static Future<XFile?> takePhotoWithCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('카메라 촬영 에러: $e');
      return null;
    }
  }

  // 번역 기록 저장
  static Future<void> saveTranslationRecord(TranslationRecord record) async {
    try {
      final records = await loadTranslationRecords();
      records.insert(0, record); // 최신 기록을 맨 위에 추가
      
      // 최대 100개까지만 저장
      if (records.length > 100) {
        records.removeRange(100, records.length);
      }
      
      await _saveToFile(records);
    } catch (e) {
      debugPrint('번역 기록 저장 에러: $e');
    }
  }

  // 번역 기록 로드
  static Future<List<TranslationRecord>> loadTranslationRecords() async {
    try {
      final file = File('translation_records.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => TranslationRecord.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('번역 기록 로드 에러: $e');
    }
    return [];
  }

  // 즐겨찾기 토글
  static Future<void> toggleFavorite(String id) async {
    try {
      final records = await loadTranslationRecords();
      final index = records.indexWhere((record) => record.id == id);
      
      if (index != -1) {
        records[index] = records[index].copyWith(isFavorite: !records[index].isFavorite);
        await _saveToFile(records);
      }
    } catch (e) {
      debugPrint('즐겨찾기 토글 에러: $e');
    }
  }

  // 번역 기록 삭제
  static Future<void> deleteTranslationRecord(String id) async {
    try {
      final records = await loadTranslationRecords();
      records.removeWhere((record) => record.id == id);
      await _saveToFile(records);
    } catch (e) {
      debugPrint('번역 기록 삭제 에러: $e');
    }
  }

  // 번역 기록 삭제 (별칭)
  static Future<void> deleteRecord(String id) async {
    await deleteTranslationRecord(id);
  }

  // 모든 번역 기록 삭제
  static Future<void> clearAllRecords() async {
    try {
      await _saveToFile([]);
    } catch (e) {
      debugPrint('모든 번역 기록 삭제 에러: $e');
    }
  }

  // 파일에 저장
  static Future<void> _saveToFile(List<TranslationRecord> records) async {
    try {
      final file = File('translation_records.json');
      final jsonString = json.encode(records.map((record) => record.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('파일 저장 에러: $e');
    }
  }
} 
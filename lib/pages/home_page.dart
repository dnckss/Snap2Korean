import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:vibration/vibration.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../components/custom_button.dart';
import '../components/info_card.dart';
import '../components/permission_dialog.dart';
import '../styles/text_styles.dart';
import '../styles/colors.dart';
import '../constants/sizes.dart';
import '../models/translation_record.dart';
import '../services/translation_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  File? _image;
  String _extractedText = '';
  String _translatedText = '';
  bool _isLoading = false;
  bool _isProcessing = false;

  final picker = ImagePicker();
  final Uuid _uuid = const Uuid();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required ImageSource source}) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 권한 체크 없이 바로 이미지 선택 시도
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (picked == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final imageFile = File(picked.path);
      
      setState(() {
        _image = imageFile;
        _extractedText = '';
        _translatedText = '';
        _isLoading = false;
        _isProcessing = true;
      });

      // 텍스트 인식 처리
      await _processImage(imageFile);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isProcessing = false;
      });
      
      // 권한 관련 에러인지 확인
      if (e.toString().contains('permission') || e.toString().contains('권한')) {
        _showErrorSnackBar('권한이 필요합니다. 설정에서 카메라/사진 라이브러리 권한을 허용해주세요.');
      } else {
        _showErrorSnackBar('이미지 처리 중 오류가 발생했습니다: $e');
      }
    }
  }

  Future<bool> _showCustomPermissionDialog(String title, String message, String iconType) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PermissionDialog(
          title: title,
          message: message,
          iconPath: iconType,
          onGrant: () {
            Navigator.of(context).pop(true);
          },
          onDeny: () {
            Navigator.of(context).pop(false);
          },
        );
      },
    ) ?? false;
  }

  void _showSettingsDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName 권한 필요'),
        content: Text('$permissionName 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  Future<void> _processImage(File imageFile) async {
    try {
      // 텍스트 추출
      final inputImage = InputImage.fromFile(imageFile);
      final recognizer = TextRecognizer();
      final result = await recognizer.processImage(inputImage);
      await recognizer.close();

      final extractedText = result.text.trim();
      
      if (extractedText.isEmpty) {
        setState(() {
          _extractedText = '';
          _translatedText = '텍스트를 인식할 수 없습니다.';
          _isProcessing = false;
        });
        return;
      }

      setState(() {
        _extractedText = extractedText;
        _translatedText = '번역 중...';
        _isProcessing = false;
      });

      // 실제 번역 API 호출
      final translatedText = await TranslationService.translateText(extractedText);
      
      setState(() {
        _translatedText = translatedText;
      });

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }

      // 번역 기록 저장
      await _saveTranslationRecord(imageFile.path);
      _showSuccessSnackBar('번역이 완료되었습니다!');
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _translatedText = '번역 중 오류가 발생했습니다.';
      });
      _showErrorSnackBar('텍스트 인식 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _saveTranslationRecord(String imagePath) async {
    try {
      final record = TranslationRecord(
        id: _uuid.v4(),
        originalText: _extractedText,
        translatedText: _translatedText,
        imagePath: imagePath,
        createdAt: DateTime.now(),
      );
      
      await TranslationService.saveTranslationRecord(record);
    } catch (e) {
      print('Error saving translation record: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.screenPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppSizes.xl),
                        _buildImageSection(),
                        const SizedBox(height: AppSizes.xl),
                        _buildActionButtons(),
                        const SizedBox(height: AppSizes.xl),
                        _buildResultsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Snap2Korean',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
          ),
          child: Stack(
            children: [
              // 배경 장식 요소들
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // 중앙 아이콘
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.translate,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사진에서 텍스트를\n한글로 번역하세요',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          '영어 텍스트가 포함된 사진을 촬영하거나 갤러리에서 선택하여 즉시 한글로 번역할 수 있습니다.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Container(
        width: double.infinity,
        height: AppSizes.imageHeightLarge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          color: AppColors.cardBackground,
        ),
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                child: Stack(
                  children: [
                    Image.file(
                      _image!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    if (_isProcessing)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                              SizedBox(height: AppSizes.md),
                              Text(
                                '텍스트 인식 중...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(
                    color: AppColors.border,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: AppSizes.iconSizeLarge,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      '사진을 선택하거나 촬영하세요',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          label: '카메라로 촬영',
          onPressed: _isLoading ? null : () => _pickImage(source: ImageSource.camera),
          type: ButtonType.primary,
          isLoading: _isLoading,
          isFullWidth: true,
          icon: Icons.camera_alt,
        ),
        const SizedBox(height: AppSizes.md),
        CustomButton(
          label: '갤러리에서 선택',
          onPressed: _isLoading ? null : () => _pickImage(source: ImageSource.gallery),
          type: ButtonType.primary,
          isLoading: _isLoading,
          isFullWidth: true,
          icon: Icons.photo_library,
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    if (_extractedText.isEmpty && _translatedText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '인식 결과',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: AppSizes.iconSize,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        InfoCard(
          title: '인식된 영어 텍스트',
          content: _extractedText,
          icon: Icons.text_fields,
          iconColor: AppColors.info,
        ),
        const SizedBox(height: AppSizes.md),
        InfoCard(
          title: '번역 결과 (한글)',
          content: _translatedText,
          icon: Icons.translate,
          iconColor: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return InfoCard(
      title: title,
      content: content,
      icon: icon,
      iconColor: color,
    );
  }
}
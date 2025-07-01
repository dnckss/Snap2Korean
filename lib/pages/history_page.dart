import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/translation_record.dart';
import '../services/translation_service.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart';
import '../constants/sizes.dart';
import '../components/custom_button.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin {
  List<TranslationRecord> _records = [];
  bool _isLoading = true;
  bool _showFavoritesOnly = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });

    final records = await TranslationService.loadTranslationRecords();
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  List<TranslationRecord> get _filteredRecords {
    if (_showFavoritesOnly) {
      return _records.where((record) => record.isFavorite).toList();
    }
    return _records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '번역 기록',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showFavoritesOnly ? null : _showClearAllDialog,
            icon: const Icon(Icons.delete_sweep, color: AppColors.error),
            tooltip: '모든 기록 삭제',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: '전체 기록'),
            Tab(text: '즐겨찾기'),
          ],
          onTap: (index) {
            setState(() {
              _showFavoritesOnly = index == 1;
            });
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _filteredRecords.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadRecords,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.screenPadding),
                    itemCount: _filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = _filteredRecords[index];
                      return _buildRecordCard(record);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showFavoritesOnly ? Icons.favorite_border : Icons.history,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            _showFavoritesOnly ? '즐겨찾기한 번역이 없습니다' : '번역 기록이 없습니다',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            _showFavoritesOnly 
                ? '번역 후 하트를 눌러 즐겨찾기에 추가하세요'
                : '첫 번째 번역을 시작해보세요!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(TranslationRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: InkWell(
        onTap: () => _showRecordDetail(record),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.originalText,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          record.translatedText,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => _toggleFavorite(record),
                        icon: Icon(
                          record.isFavorite 
                              ? Icons.favorite 
                              : Icons.favorite_border,
                          color: record.isFavorite 
                              ? AppColors.error 
                              : AppColors.textLight,
                          size: AppSizes.iconSize,
                        ),
                      ),
                      if (record.imagePath != null)
                        Icon(
                          Icons.image,
                          color: AppColors.info,
                          size: AppSizes.iconSizeSmall,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: AppSizes.iconSizeSmall,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: AppSizes.xs),
                  Text(
                    DateFormat('yyyy.MM.dd HH:mm').format(record.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _deleteRecord(record),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: AppSizes.iconSizeSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordDetail(TranslationRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailSheet(record),
    );
  }

  Widget _buildDetailSheet(TranslationRecord record) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '번역 상세',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _toggleFavorite(record),
                        icon: Icon(
                          record.isFavorite 
                              ? Icons.favorite 
                              : Icons.favorite_border,
                          color: record.isFavorite 
                              ? AppColors.error 
                              : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                  if (record.imagePath != null) ...[
                    _buildImageSection(record.imagePath!),
                    const SizedBox(height: AppSizes.lg),
                  ],
                  _buildTextSection('원본 텍스트', record.originalText, AppColors.info),
                  const SizedBox(height: AppSizes.lg),
                  _buildTextSection('번역 결과', record.translatedText, AppColors.success),
                  const SizedBox(height: AppSizes.lg),
                  _buildInfoSection(record),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '원본 이미지',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextSection(String title, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.text_fields, color: color, size: AppSizes.iconSize),
            const SizedBox(width: AppSizes.sm),
            Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(TranslationRecord record) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildInfoRow('생성일', DateFormat('yyyy년 MM월 dd일 HH:mm').format(record.createdAt)),
          const SizedBox(height: AppSizes.sm),
          _buildInfoRow('즐겨찾기', record.isFavorite ? '추가됨' : '추가되지 않음'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _toggleFavorite(TranslationRecord record) async {
    await TranslationService.toggleFavorite(record.id);
    await _loadRecords();
  }

  Future<void> _deleteRecord(TranslationRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 번역 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await TranslationService.deleteRecord(record.id);
      await _loadRecords();
      setState(() {});
    }
  }

  Future<void> _showClearAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 기록 삭제'),
        content: const Text('모든 번역 기록을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await TranslationService.clearAllRecords();
      await _loadRecords();
    }
  }
} 
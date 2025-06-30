# Snap2Korean 📸🇰🇷

영어 텍스트가 포함된 사진을 촬영하거나 갤러리에서 선택하여 즉시 한글로 번역할 수 있는 Flutter 앱입니다.

## ✨ 주요 기능

- 📷 **카메라 촬영**: 실시간으로 영어 텍스트가 포함된 사진을 촬영
- 🖼️ **갤러리 선택**: 기존 사진에서 영어 텍스트 인식
- 🔍 **OCR 텍스트 인식**: Google ML Kit을 사용한 정확한 텍스트 추출
- 🌐 **한글 번역**: 인식된 영어 텍스트를 한글로 번역
- 🎨 **현대적인 UI**: Material Design 3 기반의 아름다운 인터페이스
- 📱 **반응형 디자인**: 다양한 화면 크기에 최적화
- 🌙 **다크 모드 지원**: 시스템 설정에 따른 자동 테마 전환

## 🛠️ 기술 스택

- **Framework**: Flutter 3.7+
- **언어**: Dart
- **OCR**: Google ML Kit Text Recognition
- **이미지 선택**: image_picker
- **진동 피드백**: vibration
- **HTTP 통신**: http
- **파일 관리**: path_provider

## 📦 설치 및 실행

### 필수 요구사항

- Flutter SDK 3.7.0 이상
- Dart SDK
- Android Studio / VS Code
- iOS 개발을 위한 Xcode (macOS)
- Android 개발을 위한 Android Studio

### 설치 단계

1. **저장소 클론**
   ```bash
   git clone https://github.com/yourusername/snap2korean.git
   cd snap2korean
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **앱 실행**
   ```bash
   flutter run
   ```

### 플랫폼별 설정

#### Android
- `android/app/build.gradle.kts`에서 최소 SDK 버전 확인
- 카메라 및 저장소 권한이 자동으로 요청됩니다

#### iOS
- `ios/Runner/Info.plist`에서 카메라 및 사진 라이브러리 권한 설정
- iOS 12.0 이상 필요

## 🎨 UI/UX 특징

### 디자인 시스템
- **색상 팔레트**: 인디고 기반의 현대적인 색상 체계
- **타이포그래피**: 가독성 높은 폰트 스타일
- **간격 시스템**: 일관된 여백과 패딩
- **애니메이션**: 부드러운 전환 효과

### 컴포넌트
- **CustomButton**: 다양한 스타일의 버튼 컴포넌트
- **InfoCard**: 정보 표시용 카드 컴포넌트
- **LoadingWidget**: 로딩 상태 표시 컴포넌트

## 📁 프로젝트 구조

```
lib/
├── components/          # 재사용 가능한 UI 컴포넌트
│   ├── custom_button.dart
│   ├── info_card.dart
│   └── loading_widget.dart
├── constants/           # 앱 상수
│   └── sizes.dart
├── data/               # 데이터 및 샘플 텍스트
│   └── sample_text.dart
├── pages/              # 앱 페이지
│   └── home_page.dart
├── styles/             # 스타일 정의
│   ├── colors.dart
│   └── text_styles.dart
└── main.dart           # 앱 진입점
```

## 🔧 개발 가이드

### 코드 스타일
- Dart 공식 스타일 가이드 준수
- 의미있는 변수명과 함수명 사용
- 주석을 통한 코드 문서화

### 상태 관리
- 현재는 StatefulWidget을 사용한 로컬 상태 관리
- 향후 Provider 또는 Riverpod 도입 예정

### 에러 처리
- try-catch를 통한 예외 처리
- 사용자 친화적인 에러 메시지
- SnackBar를 통한 피드백

## 🚀 향후 계획

- [ ] 실제 번역 API 연동 (Google Translate, Papago 등)
- [ ] 번역 기록 저장 및 관리
- [ ] 오프라인 모드 지원
- [ ] 다국어 지원
- [ ] 텍스트 편집 기능
- [ ] 공유 기능
- [ ] 설정 페이지
- [ ] 테마 커스터마이징

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 연락처

프로젝트 링크: [https://github.com/yourusername/snap2korean](https://github.com/yourusername/snap2korean)

## 🙏 감사의 말

- [Flutter](https://flutter.dev/) - 멋진 크로스 플랫폼 프레임워크
- [Google ML Kit](https://developers.google.com/ml-kit) - 텍스트 인식 기능
- [Material Design](https://material.io/) - 디자인 가이드라인

---

⭐ 이 프로젝트가 도움이 되었다면 스타를 눌러주세요!

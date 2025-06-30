// 샘플 번역 텍스트
const dummyTranslation = "번역 결과: ";

// 샘플 영어 텍스트 예시들
const List<String> sampleEnglishTexts = [
  "Hello, how are you today?",
  "Welcome to our restaurant. Please have a seat.",
  "The weather is beautiful today.",
  "Thank you for your help.",
  "Please wait for your turn.",
  "This is a sample text for testing.",
  "Have a great day!",
  "The meeting starts at 2 PM.",
  "Please check your email for updates.",
  "The train will arrive in 5 minutes.",
];

// 샘플 한글 번역 예시들
const List<String> sampleKoreanTranslations = [
  "안녕하세요, 오늘 어떠세요?",
  "저희 레스토랑에 오신 것을 환영합니다. 자리에 앉아주세요.",
  "오늘 날씨가 정말 좋네요.",
  "도움을 주셔서 감사합니다.",
  "차례를 기다려주세요.",
  "이것은 테스트용 샘플 텍스트입니다.",
  "좋은 하루 되세요!",
  "회의는 오후 2시에 시작됩니다.",
  "업데이트 내용을 확인하려면 이메일을 확인해주세요.",
  "열차는 5분 후에 도착합니다.",
];

// 랜덤 샘플 텍스트 가져오기
String getRandomSampleText() {
  final random = DateTime.now().millisecondsSinceEpoch % sampleEnglishTexts.length;
  return sampleEnglishTexts[random];
}

// 랜덤 샘플 번역 가져오기
String getRandomSampleTranslation() {
  final random = DateTime.now().millisecondsSinceEpoch % sampleKoreanTranslations.length;
  return sampleKoreanTranslations[random];
}
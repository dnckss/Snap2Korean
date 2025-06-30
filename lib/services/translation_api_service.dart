import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationApiService {
  // Google Translate API 키
  static const String _apiKey = 'AIzaSyA2kEKpdicVpe5PM5j3ZnchtWwje9kCHKE';
  static const String _baseUrl = 'https://translation.googleapis.com/language/translate/v2';
  
  // 번역 함수
  static Future<String> translateText(String text, {String from = 'en', String to = 'ko'}) async {
    try {
      if (text.trim().isEmpty) {
        return '번역할 텍스트가 없습니다.';
      }

      // Google Translate API 호출
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'q': text,
          'source': from,
          'target': to,
          'format': 'text'
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null && 
            data['data']['translations'] != null && 
            data['data']['translations'].isNotEmpty) {
          return data['data']['translations'][0]['translatedText'];
        }
      }
      
      // API 호출 실패 시 기본 번역 시도
      return _getBasicTranslation(text);
      
    } catch (e) {
      print('번역 API 에러: $e');
      // 에러 발생 시 기본 번역 사용
      return _getBasicTranslation(text);
    }
  }

  // 기본 번역 (API 실패 시 사용)
  static String _getBasicTranslation(String text) {
    final basicTranslations = {
      'hello': '안녕하세요',
      'hi': '안녕하세요',
      'goodbye': '안녕히 가세요',
      'thank you': '감사합니다',
      'thanks': '고마워요',
      'please': '부탁합니다',
      'sorry': '죄송합니다',
      'excuse me': '실례합니다',
      'welcome': '환영합니다',
      'good morning': '좋은 아침입니다',
      'good afternoon': '좋은 오후입니다',
      'good evening': '좋은 저녁입니다',
      'good night': '좋은 밤 되세요',
      'how are you': '어떠세요?',
      'i am fine': '좋습니다',
      'yes': '네',
      'no': '아니요',
      'okay': '알겠습니다',
      'help': '도움',
      'help me': '도와주세요',
      'water': '물',
      'food': '음식',
      'restaurant': '레스토랑',
      'hotel': '호텔',
      'airport': '공항',
      'station': '역',
      'bus': '버스',
      'train': '기차',
      'car': '자동차',
      'money': '돈',
      'time': '시간',
      'today': '오늘',
      'tomorrow': '내일',
      'yesterday': '어제',
      'now': '지금',
      'later': '나중에',
      'soon': '곧',
      'here': '여기',
      'there': '저기',
      'this': '이것',
      'that': '저것',
      'big': '큰',
      'small': '작은',
      'good': '좋은',
      'bad': '나쁜',
      'hot': '뜨거운',
      'cold': '차가운',
      'new': '새로운',
      'old': '오래된',
      'beautiful': '아름다운',
      'ugly': '못생긴',
      'happy': '행복한',
      'sad': '슬픈',
      'angry': '화난',
      'tired': '피곤한',
      'hungry': '배고픈',
      'thirsty': '목마른',
      'open': '열다',
      'close': '닫다',
      'start': '시작하다',
      'stop': '멈추다',
      'go': '가다',
      'come': '오다',
      'see': '보다',
      'hear': '듣다',
      'speak': '말하다',
      'read': '읽다',
      'write': '쓰다',
      'eat': '먹다',
      'drink': '마시다',
      'sleep': '자다',
      'work': '일하다',
      'play': '놀다',
      'study': '공부하다',
      'learn': '배우다',
      'teach': '가르치다',
      'buy': '사다',
      'sell': '팔다',
      'give': '주다',
      'take': '가져가다',
      'find': '찾다',
      'lose': '잃다',
      'know': '알다',
      'think': '생각하다',
      'feel': '느끼다',
      'want': '원하다',
      'need': '필요하다',
      'like': '좋아하다',
      'love': '사랑하다',
      'hate': '싫어하다',
      'understand': '이해하다',
      'remember': '기억하다',
      'forget': '잊다',
      'try': '시도하다',
      'can': '할 수 있다',
      'will': '할 것이다',
      'should': '해야 한다',
      'must': '해야 한다',
      'may': '할 수 있다',
      'might': '할 수도 있다',
      'would': '할 것이다',
      'could': '할 수 있다',
      'have': '가지다',
      'has': '가지다',
      'had': '가졌다',
      'do': '하다',
      'does': '한다',
      'did': '했다',
      'am': '이다',
      'is': '이다',
      'are': '이다',
      'was': '였다',
      'were': '였다',
      'be': '되다',
      'been': '되었다',
      'being': '되고 있다',
      'the': '그',
      'a': '하나의',
      'an': '하나의',
      'and': '그리고',
      'or': '또는',
      'but': '하지만',
      'if': '만약',
      'when': '언제',
      'where': '어디',
      'why': '왜',
      'how': '어떻게',
      'what': '무엇',
      'who': '누구',
      'which': '어떤',
      'that': '그것',
      'this': '이것',
      'these': '이것들',
      'those': '그것들',
      'my': '내',
      'your': '당신의',
      'his': '그의',
      'her': '그녀의',
      'its': '그것의',
      'our': '우리의',
      'their': '그들의',
      'me': '나를',
      'you': '당신',
      'him': '그를',
      'her': '그녀를',
      'it': '그것',
      'us': '우리를',
      'them': '그들을',
      'i': '나는',
      'he': '그는',
      'she': '그녀는',
      'we': '우리는',
      'they': '그들은',
      'one': '하나',
      'two': '둘',
      'three': '셋',
      'four': '넷',
      'five': '다섯',
      'six': '여섯',
      'seven': '일곱',
      'eight': '여덟',
      'nine': '아홉',
      'ten': '열',
    };

    // 소문자로 변환하여 매칭
    final lowerText = text.toLowerCase();
    
    // 정확한 매칭 시도
    if (basicTranslations.containsKey(lowerText)) {
      return basicTranslations[lowerText]!;
    }
    
    // 부분 매칭 시도
    for (String key in basicTranslations.keys) {
      if (lowerText.contains(key)) {
        return basicTranslations[key]!;
      }
    }
    
    // 매칭되는 번역이 없으면 원본 텍스트 반환
    return '번역할 수 없는 텍스트입니다: $text';
  }
} 
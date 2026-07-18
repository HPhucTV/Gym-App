import 'dart:convert';

class MotivationRepository {
  final Future<String> Function(String) assetReader;
  List<String>? _quotes;

  MotivationRepository({required this.assetReader});

  Future<void> init() async {
    if (_quotes != null) return;
    try {
      final jsonStr = await assetReader("assets/motivational_quotes.json");
      final list = json.decode(jsonStr) as List<dynamic>;
      _quotes = list.map((e) => e.toString()).toList();
    } catch (_) {
      _quotes = const [
        "Hãy tiếp tục cố gắng vì mục tiêu của bạn!",
        "Mỗi ngày một chút nỗ lực sẽ tạo nên sự khác biệt lớn.",
        "Kỷ luật là cầu nối giữa mục tiêu và thành tựu.",
        "Đừng so sánh bản thân với người khác, hãy so sánh với ngày hôm qua.",
        "Thành công không phải là ngẫu nhiên, đó là sự lựa chọn."
      ];
    }
  }

  String getDailyQuote({int? epochDay}) {
    final day = epochDay ?? (DateTime.now().millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000));
    final currentQuotes = _quotes;
    if (currentQuotes == null || currentQuotes.isEmpty) {
      return "Hãy tiếp tục cố gắng!";
    }
    var index = day % currentQuotes.length;
    if (index < 0) {
      index += currentQuotes.length;
    }
    return currentQuotes[index];
  }
}

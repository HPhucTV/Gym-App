import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/motivation/motivation_repository.dart';

void main() {
  test('loads quotes successfully when asset exists and is valid', () async {
    final repository = MotivationRepository(
      assetReader: (path) async {
        expect(path.contains('motivational_quotes.json'), isTrue);
        return '["Quote A", "Quote B", "Quote C"]';
      },
    );

    await repository.init();

    expect(repository.getDailyQuote(epochDay: 0), 'Quote A');
    expect(repository.getDailyQuote(epochDay: 1), 'Quote B');
    expect(repository.getDailyQuote(epochDay: 2), 'Quote C');
    expect(repository.getDailyQuote(epochDay: 3), 'Quote A');
  });

  test('falls back to default quotes when asset reader fails', () async {
    final repository = MotivationRepository(
      assetReader: (path) async {
        throw Exception('File not found');
      },
    );

    await repository.init();

    final quote = repository.getDailyQuote(epochDay: 0);
    expect(quote.isNotEmpty, isTrue);
    expect(
      quote == "Hãy tiếp tục cố gắng vì mục tiêu của bạn!" ||
      quote == "Mỗi ngày một chút nỗ lực sẽ tạo nên sự khác biệt lớn." ||
      quote == "Kỷ luật là cầu nối giữa mục tiêu và thành tựu." ||
      quote == "Đừng so sánh bản thân với người khác, hãy so sánh với ngày hôm qua." ||
      quote == "Thành công không phải là ngẫu nhiên, đó là sự lựa chọn.",
      isTrue,
    );
  });

  test('falls back to default quotes when json serialization fails', () async {
    final repository = MotivationRepository(
      assetReader: (path) async {
        return 'invalid json content';
      },
    );

    await repository.init();

    final quote = repository.getDailyQuote(epochDay: 5);
    expect(quote.isNotEmpty, isTrue);
    expect(
      quote == "Hãy tiếp tục cố gắng vì mục tiêu của bạn!" ||
      quote == "Mỗi ngày một chút nỗ lực sẽ tạo nên sự khác biệt lớn." ||
      quote == "Kỷ luật là cầu nối giữa mục tiêu và thành tựu." ||
      quote == "Đừng so sánh bản thân với người khác, hãy so sánh với ngày hôm qua." ||
      quote == "Thành công không phải là ngẫu nhiên, đó là sự lựa chọn.",
      isTrue,
    );
  });
}

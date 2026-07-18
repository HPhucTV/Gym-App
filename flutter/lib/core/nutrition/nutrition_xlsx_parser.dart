import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'nutrition_csv_parser.dart';

class NutritionXlsxParser {
  static CsvParseResult parse(Uint8List xlsxBytes, {String batchId = ""}) {
    try {
      final rows = _extractRowsFromXlsx(xlsxBytes);
      return NutritionCsvParser.parseTable(rows, batchId: batchId);
    } catch (e) {
      return CsvParseResult(items: [], warnings: ["Lỗi đọc tệp Excel: $e"]);
    }
  }

  static List<List<String>> _extractRowsFromXlsx(Uint8List xlsxBytes) {
    final archive = ZipDecoder().decodeBytes(xlsxBytes);
    List<String> sharedStrings = [];
    List<List<String>> sheetRows = [];

    ArchiveFile? sharedStringsFile;
    ArchiveFile? sheetFile;

    for (final file in archive) {
      if (file.name == 'xl/sharedStrings.xml') {
        sharedStringsFile = file;
      } else if (file.name == 'xl/worksheets/sheet1.xml') {
        sheetFile = file;
      }
    }

    if (sharedStringsFile != null) {
      final content = sharedStringsFile.content as List<int>;
      final xmlContent = utf8.decode(content);
      sharedStrings = _parseSharedStrings(xmlContent);
    }

    if (sheetFile != null) {
      final content = sheetFile.content as List<int>;
      final xmlContent = utf8.decode(content);
      sheetRows = _parseSheetRows(xmlContent, sharedStrings);
    }

    return sheetRows;
  }

  static List<String> _parseSharedStrings(String xmlContent) {
    final document = XmlDocument.parse(xmlContent);
    final strings = <String>[];
    final siElements = document.findAllElements('si');
    for (final si in siElements) {
      final tElements = si.findAllElements('t');
      final sb = StringBuffer();
      for (final t in tElements) {
        sb.write(t.innerText);
      }
      strings.add(_decodeXmlEntities(sb.toString()));
    }
    return strings;
  }

  static List<List<String>> _parseSheetRows(String xmlContent, List<String> sharedStrings) {
    final document = XmlDocument.parse(xmlContent);
    final rows = <List<String>>[];
    final rowElements = document.findAllElements('row');

    for (final row in rowElements) {
      final cellMap = <int, String>{};
      var maxColIndex = -1;

      final cellElements = row.findAllElements('c');
      for (final cell in cellElements) {
        final rAttr = cell.getAttribute('r');
        final currentColumnIndex = rAttr != null ? _getColumnIndex(rAttr) : -1;
        if (currentColumnIndex > maxColIndex) {
          maxColIndex = currentColumnIndex;
        }

        final tAttr = cell.getAttribute('t');
        final isShared = tAttr == 's';

        final vElement = cell.findElements('v').firstOrNull;
        var cellValue = vElement?.innerText ?? "";

        if (isShared && cellValue.isNotEmpty) {
          final idx = int.tryParse(cellValue);
          if (idx != null && idx >= 0 && idx < sharedStrings.length) {
            cellValue = sharedStrings[idx];
          } else {
            cellValue = "";
          }
        }

        if (currentColumnIndex != -1) {
          cellMap[currentColumnIndex] = _decodeXmlEntities(cellValue);
        }
      }

      final rowCells = List.filled(maxColIndex + 1, "");
      cellMap.forEach((col, val) {
        rowCells[col] = val;
      });
      rows.add(rowCells);
    }
    return rows;
  }

  static int _getColumnIndex(String ref) {
    final letters = ref.split(RegExp(r'[0-9]')).first.toUpperCase();
    var col = 0;
    for (var i = 0; i < letters.length; i++) {
      final charCode = letters.codeUnitAt(i);
      col = col * 26 + (charCode - 65 + 1);
    }
    return col - 1;
  }

  static String _decodeXmlEntities(String str) {
    if (!str.contains('&')) return str;
    return str
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
  }
}

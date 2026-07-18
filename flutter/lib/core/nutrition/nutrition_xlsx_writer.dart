import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../model/nutrition_models.dart';

class NutritionXlsxWriter {
  static Uint8List write(List<FoodCatalogItem> items) {
    final archive = Archive();

    // 1. [Content_Types].xml
    final contentTypesXml = _getContentTypesXml();
    archive.addFile(ArchiveFile('[Content_Types].xml', contentTypesXml.length,
        utf8.encode(contentTypesXml)));

    // 2. _rels/.rels
    final relsXml = _getRelsXml();
    archive.addFile(
        ArchiveFile('_rels/.rels', relsXml.length, utf8.encode(relsXml)));

    // 3. xl/workbook.xml
    final workbookXml = _getWorkbookXml();
    archive.addFile(ArchiveFile(
        'xl/workbook.xml', workbookXml.length, utf8.encode(workbookXml)));

    // 4. xl/_rels/workbook.xml.rels
    final workbookRelsXml = _getWorkbookRelsXml();
    archive.addFile(ArchiveFile('xl/_rels/workbook.xml.rels',
        workbookRelsXml.length, utf8.encode(workbookRelsXml)));

    // 5. xl/worksheets/sheet1.xml
    final sheetXml = _getSheetXml(items);
    archive.addFile(ArchiveFile(
        'xl/worksheets/sheet1.xml', sheetXml.length, utf8.encode(sheetXml)));

    final zipBytes = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipBytes);
  }

  static String _getContentTypesXml() {
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">\n'
        '  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>\n'
        '  <Default Extension="xml" ContentType="application/xml"/>\n'
        '  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>\n'
        '  <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>\n'
        '</Types>';
  }

  static String _getRelsXml() {
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n'
        '  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>\n'
        '</Relationships>';
  }

  static String _getWorkbookXml() {
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">\n'
        '  <sheets>\n'
        '    <sheet name="Sheet1" sheetId="1" r:id="rId1"/>\n'
        '  </sheets>\n'
        '</workbook>';
  }

  static String _getWorkbookRelsXml() {
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n'
        '  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>\n'
        '</Relationships>';
  }

  static String _getSheetXml(List<FoodCatalogItem> items) {
    final sb = StringBuffer();
    sb.write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">\n'
        '  <sheetData>\n');

    // Row 1: Headers
    sb.write('    <row r="1">\n'
        '      <c r="A1" t="inlineStr"><is><t>Tên thực phẩm</t></is></c>\n'
        '      <c r="B1" t="inlineStr"><is><t>Khối lượng (g)</t></is></c>\n'
        '      <c r="C1" t="inlineStr"><is><t>Calo (kcal)</t></is></c>\n'
        '      <c r="D1" t="inlineStr"><is><t>Chất đạm (g)</t></is></c>\n'
        '      <c r="E1" t="inlineStr"><is><t>Tinh bột (g)</t></is></c>\n'
        '      <c r="F1" t="inlineStr"><is><t>Chất béo (g)</t></is></c>\n'
        '      <c r="G1" t="inlineStr"><is><t>Chất xơ (g)</t></is></c>\n'
        '    </row>\n');

    // Data Rows
    for (var i = 0; i < items.length; i++) {
      final food = items[i];
      final rowNum = i + 2;
      final nameEscaped = _escapeXml(food.name);
      sb.write('    <row r="$rowNum">\n'
          '      <c r="A$rowNum" t="inlineStr"><is><t>$nameEscaped</t></is></c>\n'
          '      <c r="B$rowNum"><v>${food.gramsPerServing}</v></c>\n'
          '      <c r="C$rowNum"><v>${food.caloriesPerServing}</v></c>\n'
          '      <c r="D$rowNum"><v>${food.proteinPerServing}</v></c>\n'
          '      <c r="E$rowNum"><v>${food.carbsPerServing}</v></c>\n'
          '      <c r="F$rowNum"><v>${food.fatPerServing}</v></c>\n'
          '      <c r="G$rowNum"><v>${food.fiberPerServing}</v></c>\n'
          '    </row>\n');
    }

    sb.write('  </sheetData>\n'
        '</worksheet>');
    return sb.toString();
  }

  static String _escapeXml(String str) {
    return str
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

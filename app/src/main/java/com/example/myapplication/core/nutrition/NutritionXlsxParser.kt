package com.example.myapplication.core.nutrition

import org.xmlpull.v1.XmlPullParser
import org.xmlpull.v1.XmlPullParserFactory
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.util.zip.ZipInputStream

object NutritionXlsxParser {
    fun parse(xlsxBytes: ByteArray, batchId: String = ""): CsvParseResult {
        return try {
            val rows = extractRowsFromXlsx(xlsxBytes)
            NutritionCsvParser.parseTable(rows, batchId)
        } catch (e: Exception) {
            CsvParseResult(emptyList(), listOf("Lỗi đọc tệp Excel: ${e.message}"))
        }
    }

    private fun extractRowsFromXlsx(xlsxBytes: ByteArray): List<List<String>> {
        var sharedStrings = listOf<String>()
        var sheetRows = listOf<List<String>>()

        ZipInputStream(ByteArrayInputStream(xlsxBytes)).use { zip ->
            var entry = zip.nextEntry
            while (entry != null) {
                if (entry.name == "xl/sharedStrings.xml") {
                    val entryBytes = zip.readBytes()
                    sharedStrings = parseSharedStrings(ByteArrayInputStream(entryBytes))
                } else if (entry.name == "xl/worksheets/sheet1.xml") {
                    val entryBytes = zip.readBytes()
                    sheetRows = parseSheetRows(ByteArrayInputStream(entryBytes), sharedStrings)
                }
                entry = zip.nextEntry
            }
        }
        return sheetRows
    }

    private fun parseSharedStrings(inputStream: InputStream): List<String> {
        val strings = mutableListOf<String>()
        val factory = XmlPullParserFactory.newInstance()
        val parser = factory.newPullParser()
        parser.setInput(inputStream, "UTF-8")

        var eventType = parser.eventType
        var inT = false
        val sb = java.lang.StringBuilder()

        while (eventType != XmlPullParser.END_DOCUMENT) {
            when (eventType) {
                XmlPullParser.START_TAG -> {
                    if (parser.name == "t") {
                        inT = true
                        sb.setLength(0)
                    }
                }
                XmlPullParser.TEXT -> {
                    if (inT) {
                        sb.append(parser.text)
                    }
                }
                XmlPullParser.END_TAG -> {
                    if (parser.name == "t") {
                        inT = false
                    } else if (parser.name == "si") {
                        strings.add(decodeXmlEntities(sb.toString()))
                    }
                }
            }
            eventType = parser.next()
        }
        return strings
    }

    private fun parseSheetRows(inputStream: InputStream, sharedStrings: List<String>): List<List<String>> {
        val rows = mutableListOf<List<String>>()
        val factory = XmlPullParserFactory.newInstance()
        val parser = factory.newPullParser()
        parser.setInput(inputStream, "UTF-8")

        var eventType = parser.eventType
        var currentColumnIndex = -1
        var isShared = false
        var cellValue: String? = null
        val currentCells = mutableMapOf<Int, String>()
        var maxColIndex = -1

        while (eventType != XmlPullParser.END_DOCUMENT) {
            when (eventType) {
                XmlPullParser.START_TAG -> {
                    val tagName = parser.name
                    if (tagName == "row") {
                        currentCells.clear()
                        maxColIndex = -1
                    } else if (tagName == "c") {
                        val rAttr = parser.getAttributeValue(null, "r")
                        currentColumnIndex = if (rAttr != null) getColumnIndex(rAttr) else -1
                        if (currentColumnIndex > maxColIndex) {
                            maxColIndex = currentColumnIndex
                        }
                        val tAttr = parser.getAttributeValue(null, "t")
                        isShared = tAttr == "s"
                        cellValue = null
                    } else if (tagName == "v" || tagName == "t") {
                        cellValue = ""
                    }
                }
                XmlPullParser.TEXT -> {
                    if (cellValue != null) {
                        cellValue += parser.text
                    }
                }
                XmlPullParser.END_TAG -> {
                    val tagName = parser.name
                    if (tagName == "c") {
                        if (currentColumnIndex != -1) {
                            val finalVal = if (isShared && cellValue != null) {
                                val idx = cellValue!!.toIntOrNull()
                                if (idx != null && idx >= 0 && idx < sharedStrings.size) {
                                    sharedStrings[idx]
                                } else {
                                    ""
                                }
                            } else {
                                cellValue ?: ""
                            }
                            currentCells[currentColumnIndex] = decodeXmlEntities(finalVal)
                        }
                    } else if (tagName == "row") {
                        val result = MutableList(maxColIndex + 1) { "" }
                        for ((col, valStr) in currentCells) {
                            result[col] = valStr
                        }
                        rows.add(result)
                    }
                }
            }
            eventType = parser.next()
        }
        return rows
    }

    private fun getColumnIndex(ref: String): Int {
        val letters = ref.takeWhile { it.isLetter() }.uppercase()
        var col = 0
        for (char in letters) {
            col = col * 26 + (char - 'A' + 1)
        }
        return col - 1
    }

    private fun decodeXmlEntities(str: String): String {
        if (!str.contains('&')) return str
        return str
            .replace("&amp;", "&")
            .replace("&lt;", "<")
            .replace("&gt;", ">")
            .replace("&quot;", "\"")
            .replace("&apos;", "'")
    }
}

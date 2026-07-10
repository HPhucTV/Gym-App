package com.example.myapplication.core.nutrition

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
                    val content = zip.readBytes().toString(Charsets.UTF_8)
                    sharedStrings = parseSharedStrings(content)
                } else if (entry.name == "xl/worksheets/sheet1.xml") {
                    val content = zip.readBytes().toString(Charsets.UTF_8)
                    sheetRows = parseSheetRows(content, sharedStrings)
                }
                entry = zip.nextEntry
            }
        }
        return sheetRows
    }

    private fun parseSharedStrings(xml: String): List<String> {
        val strings = mutableListOf<String>()
        var pos = 0
        while (true) {
            val startIdx = xml.indexOf("<si>", pos)
            if (startIdx == -1) break
            val endIdx = xml.indexOf("</si>", startIdx)
            if (endIdx == -1) break
            
            val siContent = xml.substring(startIdx + 4, endIdx)
            strings.add(decodeXmlEntities(extractTextFromSi(siContent)))
            pos = endIdx + 5
        }
        return strings
    }

    private fun extractTextFromSi(siContent: String): String {
        val sb = StringBuilder()
        var pos = 0
        while (true) {
            val startIdx = siContent.indexOf("<t", pos)
            if (startIdx == -1) break
            val tagCloseIdx = siContent.indexOf(">", startIdx)
            if (tagCloseIdx == -1) break
            val endIdx = siContent.indexOf("</t>", tagCloseIdx)
            if (endIdx == -1) break
            
            sb.append(siContent.substring(tagCloseIdx + 1, endIdx))
            pos = endIdx + 4
        }
        return sb.toString()
    }

    private fun parseSheetRows(xml: String, sharedStrings: List<String>): List<List<String>> {
        val rows = mutableListOf<List<String>>()
        var pos = 0
        while (true) {
            val startIdx = xml.indexOf("<row", pos)
            if (startIdx == -1) break
            val openTagClose = xml.indexOf(">", startIdx)
            if (openTagClose == -1) break
            val endIdx = xml.indexOf("</row>", openTagClose)
            if (endIdx == -1) break
            
            val rowContent = xml.substring(openTagClose + 1, endIdx)
            rows.add(parseCellsInRow(rowContent, sharedStrings))
            pos = endIdx + 6
        }
        return rows
    }

    private val rRegex = Regex("""\br=["']([A-Za-z]+)\d+["']""")
    private val tRegex = Regex("""\bt=["']([^"']+)["']""")

    private fun parseCellsInRow(rowContent: String, sharedStrings: List<String>): List<String> {
        val cellMap = mutableMapOf<Int, String>()
        var pos = 0
        var maxColIndex = -1

        while (true) {
            val startIdx = rowContent.indexOf("<c", pos)
            if (startIdx == -1) break
            val tagCloseIdx = rowContent.indexOf(">", startIdx)
            if (tagCloseIdx == -1) break
            
            val cellAttr = rowContent.substring(startIdx, tagCloseIdx)
            val rMatch = rRegex.find(cellAttr)
            val colIdx = if (rMatch != null) getColumnIndex(rMatch.groupValues[1]) else -1

            if (colIdx != -1) {
                if (colIdx > maxColIndex) {
                    maxColIndex = colIdx
                }

                val tMatch = tRegex.find(cellAttr)
                val isShared = tMatch != null && tMatch.groupValues[1] == "s"

                // Check for value tag <v>...</v>
                val vStart = rowContent.indexOf("<v>", tagCloseIdx)
                val cellEndIdx = rowContent.indexOf("</c>", tagCloseIdx)
                val limit = if (cellEndIdx != -1) cellEndIdx else rowContent.length
                
                if (vStart != -1 && vStart < limit) {
                    val vEnd = rowContent.indexOf("</v>", vStart)
                    if (vEnd != -1) {
                        val rawVal = rowContent.substring(vStart + 3, vEnd)
                        val decodedVal = if (isShared) {
                            val idx = rawVal.toIntOrNull()
                            if (idx != null && idx >= 0 && idx < sharedStrings.size) {
                                sharedStrings[idx]
                            } else {
                                ""
                            }
                        } else {
                            rawVal
                        }
                        cellMap[colIdx] = decodeXmlEntities(decodedVal)
                    }
                } else {
                    // Check for inline string <is><t>...</t></is>
                    val isStart = rowContent.indexOf("<is>", tagCloseIdx)
                    if (isStart != -1 && isStart < limit) {
                        val tStart = rowContent.indexOf("<t", isStart)
                        if (tStart != -1) {
                            val tOpenClose = rowContent.indexOf(">", tStart)
                            val tEnd = rowContent.indexOf("</t>", tOpenClose)
                            if (tOpenClose != -1 && tEnd != -1) {
                                cellMap[colIdx] = decodeXmlEntities(rowContent.substring(tOpenClose + 1, tEnd))
                            }
                        }
                    }
                }
            }

            val cCloseIdx = rowContent.indexOf("</c>", tagCloseIdx)
            if (cCloseIdx == -1) {
                pos = tagCloseIdx + 1
            } else {
                pos = cCloseIdx + 4
            }
        }

        val result = MutableList(maxColIndex + 1) { "" }
        for ((col, valStr) in cellMap) {
            result[col] = valStr
        }
        return result
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

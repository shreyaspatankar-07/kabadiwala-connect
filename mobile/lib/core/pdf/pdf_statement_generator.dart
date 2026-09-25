import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../data/repositories/ledger_repository.dart';

/// Pure-Dart lightweight PDF 1.4 Statement Generator.
/// Generates an official EPR income proof and earnings statement without external C/heavy dependencies.
class PdfStatementGenerator {
  /// Generates a valid PDF 1.4 file and returns its absolute file path.
  static Future<File> generateEarningsStatementPdf({
    required String collectorId,
    required String statementRefNo,
    required DateTime fromDate,
    required DateTime toDate,
    required double totalEarned,
    required double cashReceived,
    required double pendingAmount,
    required List<LedgerItemDetail> items,
    String locale = 'mr',
    Directory? targetDirectory,
  }) async {
    final pdfBytes = _buildPdfBytes(
      collectorId: collectorId,
      statementRefNo: statementRefNo,
      fromDate: fromDate,
      toDate: toDate,
      totalEarned: totalEarned,
      cashReceived: cashReceived,
      pendingAmount: pendingAmount,
      items: items,
      locale: locale,
    );

    final outputDir = targetDirectory ?? await getApplicationDocumentsDirectory();
    final file = File('${outputDir.path}/earnings_statement_$statementRefNo.pdf');
    await file.writeAsBytes(pdfBytes, flush: true);
    return file;
  }

  static List<int> _buildPdfBytes({
    required String collectorId,
    required String statementRefNo,
    required DateTime fromDate,
    required DateTime toDate,
    required double totalEarned,
    required double cashReceived,
    required double pendingAmount,
    required List<LedgerItemDetail> items,
    required String locale,
  }) {
    // Escape parenthesis and backslashes for PDF string literals
    String esc(String s) => s.replaceAll(r'\', r'\\').replaceAll('(', r'\(').replaceAll(')', r'\)');

    // Header stream commands
    final streamBuf = StringBuffer();

    // Background header bar (Dark Emerald green #047857)
    streamBuf.writeln('0.016 0.471 0.341 rg'); // RGB for #047857
    streamBuf.writeln('30 760 535 60 re f');

    // Header Text (White)
    streamBuf.writeln('1 1 1 rg');
    streamBuf.writeln('BT');
    streamBuf.writeln('/F2 16 Tf');
    streamBuf.writeln('45 795 Td');
    streamBuf.writeln('(${esc("KABADIWALA CONNECT - JNARDDC EPR EARNINGS STATEMENT")}) Tj');
    streamBuf.writeln('/F1 10 Tf');
    streamBuf.writeln('0 -18 Td');
    streamBuf.writeln('(${esc("Official Informal E-Waste Collector Income Proof under E-Waste Rules 2022")}) Tj');
    streamBuf.writeln('ET');

    // Collector Meta Card
    streamBuf.writeln('0 0 0 rg');
    streamBuf.writeln('0.95 0.96 0.98 rg');
    streamBuf.writeln('30 670 535 75 re f');
    streamBuf.writeln('0.8 0.85 0.9 rg');
    streamBuf.writeln('30 670 535 75 re S');

    streamBuf.writeln('0 0 0 rg');
    streamBuf.writeln('BT');
    streamBuf.writeln('/F2 11 Tf');
    streamBuf.writeln('45 725 Td');
    streamBuf.writeln('(${esc("Collector Reference ID: $collectorId")}) Tj');
    streamBuf.writeln('260 0 Td');
    streamBuf.writeln('(${esc("Statement Ref: $statementRefNo")}) Tj');
    streamBuf.writeln('/F1 10 Tf');
    streamBuf.writeln('-260 -20 Td');
    streamBuf.writeln('(${esc("Period: ${_fmtDate(fromDate)} to ${_fmtDate(toDate)}")}) Tj');
    streamBuf.writeln('260 0 Td');
    streamBuf.writeln('(${esc("Issued: ${_fmtDate(DateTime.now())}")}) Tj');
    streamBuf.writeln('/F1 9 Tf');
    streamBuf.writeln('-260 -18 Td');
    streamBuf.writeln('(${esc("Total E-Waste Transactions: ${items.length}")}) Tj');
    streamBuf.writeln('ET');

    // Financial Summary Cards
    // 1. Total Earned
    streamBuf.writeln('0.86 0.99 0.91 rg'); // Light green
    streamBuf.writeln('30 600 170 55 re f');
    streamBuf.writeln('0.13 0.64 0.29 rg');
    streamBuf.writeln('BT');
    streamBuf.writeln('/F1 9 Tf');
    streamBuf.writeln('40 638 Td');
    streamBuf.writeln('(${esc("TOTAL EARNED (INR)")}) Tj');
    streamBuf.writeln('/F2 15 Tf');
    streamBuf.writeln('0 -18 Td');
    streamBuf.writeln('(${esc("Rs. ${totalEarned.toStringAsFixed(2)}")}) Tj');
    streamBuf.writeln('ET');

    // 2. Cash Received
    streamBuf.writeln('0.91 0.96 1.0 rg'); // Light blue
    streamBuf.writeln('212 600 170 55 re f');
    streamBuf.writeln('0.1 0.3 0.6 rg');
    streamBuf.writeln('BT');
    streamBuf.writeln('/F1 9 Tf');
    streamBuf.writeln('222 638 Td');
    streamBuf.writeln('(${esc("CASH RECEIVED (INR)")}) Tj');
    streamBuf.writeln('/F2 15 Tf');
    streamBuf.writeln('0 -18 Td');
    streamBuf.writeln('(${esc("Rs. ${cashReceived.toStringAsFixed(2)}")}) Tj');
    streamBuf.writeln('ET');

    // 3. Pending Dues
    streamBuf.writeln('1.0 0.95 0.88 rg'); // Light amber
    streamBuf.writeln('395 600 170 55 re f');
    streamBuf.writeln('0.7 0.3 0.0 rg');
    streamBuf.writeln('BT');
    streamBuf.writeln('/F1 9 Tf');
    streamBuf.writeln('405 638 Td');
    streamBuf.writeln('(${esc("PENDING DUES (INR)")}) Tj');
    streamBuf.writeln('/F2 15 Tf');
    streamBuf.writeln('0 -18 Td');
    streamBuf.writeln('(${esc("Rs. ${pendingAmount.toStringAsFixed(2)}")}) Tj');
    streamBuf.writeln('ET');

    // Table Header
    streamBuf.writeln('0.15 0.23 0.36 rg');
    streamBuf.writeln('30 560 535 24 re f');
    streamBuf.writeln('1 1 1 rg');
    streamBuf.writeln('BT');
    streamBuf.writeln('/F2 9 Tf');
    streamBuf.writeln('40 568 Td');
    streamBuf.writeln('(${esc("Date")}) Tj');
    streamBuf.writeln('70 0 Td');
    streamBuf.writeln('(${esc("Category")}) Tj');
    streamBuf.writeln('90 0 Td');
    streamBuf.writeln('(${esc("Weight")}) Tj');
    streamBuf.writeln('80 0 Td');
    streamBuf.writeln('(${esc("Recycler")}) Tj');
    streamBuf.writeln('170 0 Td');
    streamBuf.writeln('(${esc("Amount")}) Tj');
    streamBuf.writeln('70 0 Td');
    streamBuf.writeln('(${esc("Status")}) Tj');
    streamBuf.writeln('ET');

    // Table Rows
    double y = 540;
    int index = 0;
    for (final item in items.take(15)) {
      index++;
      final isEven = index % 2 == 0;
      if (isEven) {
        streamBuf.writeln('0.97 0.98 0.99 rg');
        streamBuf.writeln('30 ${y - 4} 535 20 re f');
      }

      streamBuf.writeln('0 0 0 rg');
      streamBuf.writeln('BT');
      streamBuf.writeln('/F1 8 Tf');
      streamBuf.writeln('40 $y Td');
      streamBuf.writeln('(${esc(_fmtDate(item.recordedAt))}) Tj');
      streamBuf.writeln('70 0 Td');
      streamBuf.writeln('(${esc(item.category)}) Tj');
      streamBuf.writeln('90 0 Td');
      streamBuf.writeln('(${esc("${item.weightKg.toStringAsFixed(1)} kg")}) Tj');
      streamBuf.writeln('80 0 Td');
      final recName = item.recyclerName.length > 25
          ? '${item.recyclerName.substring(0, 22)}...'
          : item.recyclerName;
      streamBuf.writeln('(${esc(recName)}) Tj');
      streamBuf.writeln('170 0 Td');
      streamBuf.writeln('(${esc("Rs. ${item.amount.toStringAsFixed(0)}")}) Tj');
      streamBuf.writeln('70 0 Td');
      streamBuf.writeln('(${esc(item.paymentStatus)}) Tj');
      streamBuf.writeln('ET');

      y -= 20;
    }

    // Footer signature notice
    streamBuf.writeln('0.4 0.45 0.5 rg');
    streamBuf.writeln('BT');
    streamBuf.writeln('/F1 8 Tf');
    streamBuf.writeln('30 40 Td');
    streamBuf.writeln('(${esc("Digitally generated via Kabadiwala Connect offline ledger. Tamper-evident hash chained under Ministry of Mines / JNARDDC.")}) Tj');
    streamBuf.writeln('ET');

    final streamString = streamBuf.toString();
    final streamBytes = utf8.encode(streamString);

    // Build PDF objects with byte offsets
    final List<int> pdfOutput = [];

    void append(String s) {
      pdfOutput.addAll(utf8.encode(s));
    }

    append('%PDF-1.4\n');

    final offsets = <int>[];

    // Object 1: Catalog
    offsets.add(pdfOutput.length);
    append('1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n');

    // Object 2: Pages
    offsets.add(pdfOutput.length);
    append('2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n');

    // Object 3: Page (A4: 595.28 x 841.89 pt)
    offsets.add(pdfOutput.length);
    append('3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595.28 841.89] /Contents 4 0 R /Resources << /Font << /F1 5 0 R /F2 6 0 R >> >> >>\nendobj\n');

    // Object 4: Content Stream
    offsets.add(pdfOutput.length);
    append('4 0 obj\n<< /Length ${streamBytes.length} >>\nstream\n');
    pdfOutput.addAll(streamBytes);
    append('\nendstream\nendobj\n');

    // Object 5: Helvetica Font
    offsets.add(pdfOutput.length);
    append('5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n');

    // Object 6: Helvetica-Bold Font
    offsets.add(pdfOutput.length);
    append('6 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>\nendobj\n');

    // XREF Table
    final startXref = pdfOutput.length;
    append('xref\n0 7\n0000000000 65535 f \n');
    for (final offset in offsets) {
      append('${offset.toString().padLeft(10, '0')} 00000 n \n');
    }

    // Trailer
    append('trailer\n<< /Size 7 /Root 1 0 R >>\nstartxref\n$startXref\n%%EOF\n');

    return pdfOutput;
  }

  static String _fmtDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

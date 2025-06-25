import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:twh/data/services/storageService.dart';
import 'package:twh/data/services/twilio_whatsapp_service.dart';
import 'package:twh/data/services/vonage_whatsapp_service.dart';

import '../../data/services/ai_summary_service.dart';
import '../../data/services/email_service.dart';
import '../../data/services/pdf_service.dart';
import '../../core/models/summary_report.dart';
import 'home_screen.dart';

class SummaryScreen extends StatefulWidget {
  final Map<String, dynamic> formData;

  const SummaryScreen({super.key, required this.formData});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  String? aiSummary;
  bool isLoading = true;
  String? error;
  bool isSendingEmail = false;
  String? emailStatus;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    try {
      final summary = await AISummaryService().generateSummary(widget.formData);
      setState(() {
        aiSummary = summary;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _sendEmail() async {
    setState(() {
      isSendingEmail = true;
      emailStatus = null;
    });

    try {
      await EmailService.sendSummaryEmail(
        name: widget.formData['name'] ?? 'Customer',
        email: widget.formData['email'] ?? 'noemail@example.com',
        message: aiSummary ?? '',
      );

      setState(() {
        emailStatus = "Email sent successfully!";
        isSendingEmail = false;
      });
    } catch (e) {
      setState(() {
        emailStatus = "Failed to send email.";
        isSendingEmail = false;
      });
    }
  }

  Future<void> _generatePdf() async {
    try {
      // ✅ Generate the PDF with the summary report
      final report = SummaryReport(
        name: widget.formData['name'] ?? 'Customer',
        email: widget.formData['email'] ?? 'noemail@example.com',
        aiSummary: aiSummary ?? '',
        date: DateTime.now(),
      );
      final pdfData = await PdfService.generateSummaryPdf(report);

      // ✅ Optional: Preview the PDF locally before sending (for testing purposes)
      await Printing.layoutPdf(onLayout: (format) => pdfData);

      // ✅ Upload the PDF to Firebase Storage
      final storageService = StorageService();
      final fileName =
          'wellness-report-${DateTime.now().millisecondsSinceEpoch}.pdf';
      final pdfUrl = await storageService.uploadPdf(pdfData, fileName);

      print('✅ PDF uploaded to: $pdfUrl');

      // ✅ Send the generated PDF link via WhatsApp using Twilio
      // Replace '201015063716' with the dynamic receiver phone number
      await TwilioWhatsAppService.sendWhatsAppMessage(
        'whatsapp:+201015063716', // Dynamic recipient number in proper format
        pdfUrl,
      );

      // Show success message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF link sent via WhatsApp successfully!')),
      );
    } catch (e) {
      // If an error occurs during any of the steps
      print('❌ ERROR generating or sending PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send WhatsApp message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Wellness Summary"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9F6FB), Color(0xFFE8DAEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Text("Error: $error",
                        style: const TextStyle(color: Colors.red)),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Personalized Wellness Insights:",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A2E76),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 6),
                              )
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              aiSummary ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: isSendingEmail
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.email),
                          label: Text(
                            isSendingEmail
                                ? "Sending..."
                                : "Send to Customer Email",
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: const Color(0xFF6A2E76),
                          ),
                          onPressed: isSendingEmail ? null : _sendEmail,
                        ),
                      ),

                      if (emailStatus != null) ...[
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            emailStatus!,
                            style: TextStyle(
                              color: emailStatus!.contains("success")
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // PDF button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("Generate PDF"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: const Color(0xFF4A148C),
                          ),
                          onPressed: _generatePdf,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Home button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.home),
                          label: const Text("Return to Home"),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                              (route) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../../data/services/ai_summary_service.dart';
import '../../data/services/email_service.dart';

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

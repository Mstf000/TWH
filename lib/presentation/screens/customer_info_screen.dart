import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/translations.dart';
import '../providers/locale_provider.dart';
import '../providers/form_data_provider.dart';
import 'lifestyle_info_screen.dart';

class CustomerInfoScreen extends StatelessWidget {
  const CustomerInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final formData = context.read<FormDataProvider>();
    final isArabic = locale == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF9F6FB), Color(0xFFE8DAEF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // Header Icon & Title
              Column(
                children: [
                  const Icon(Icons.assignment_ind_rounded,
                      size: 60, color: Color(0xFF6A2E76)),
                  const SizedBox(height: 16),
                  Text(
                    translations['personalInfo']![locale]!,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A2E76),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Card Form Container
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
                    child: Column(
                      children: [
                        _buildField(
                          context,
                          label: translations['name']![locale]!,
                          icon: Icons.person,
                          onChanged: (val) => formData.update('name', val),
                        ),
                        _buildField(
                          context,
                          label: translations['phone']![locale]!,
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone,
                          onChanged: (val) => formData.update('phone', val),
                        ),
                        _buildField(
                          context,
                          label: translations['email']![locale]!,
                          keyboardType: TextInputType.emailAddress,
                          icon: Icons.email_outlined,
                          onChanged: (val) => formData.update('email', val),
                        ),
                        _buildDateField(
                          context,
                          label: translations['dob']![locale]!,
                          icon: Icons.calendar_today_outlined,
                          onDatePicked: (val) => formData.update('dob', val),
                        ),
                        _buildField(
                          context,
                          label: translations['height']![locale]!,
                          keyboardType: TextInputType.number,
                          icon: Icons.height,
                          onChanged: (val) => formData.update('height', val),
                        ),
                        _buildField(
                          context,
                          label: translations['weight']![locale]!,
                          keyboardType: TextInputType.number,
                          icon: Icons.monitor_weight_outlined,
                          onChanged: (val) => formData.update('weight', val),
                        ),
                        const SizedBox(height: 16),
                        _buildGenderSelector(context, locale, formData),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(translations['next']![locale]!),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LifestyleInfoScreen(),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context,
      {required String label,
      TextInputType? keyboardType,
      required Function(String) onChanged,
      IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context,
      {required String label,
      required Function(String) onDatePicked,
      IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(1995),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            onDatePicked(picked.toIso8601String().split('T').first);
          }
        },
        child: AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: icon != null ? Icon(icon) : null,
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector(
      BuildContext context, String locale, FormDataProvider formData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translations['gender']![locale]!),
        Row(
          children: [
            Expanded(
              child: RadioListTile(
                title: Text(translations['male']![locale]!),
                value: 'male',
                groupValue: formData.getValue('gender'),
                onChanged: (val) => formData.update('gender', val),
              ),
            ),
            Expanded(
              child: RadioListTile(
                title: Text(translations['female']![locale]!),
                value: 'female',
                groupValue: formData.getValue('gender'),
                onChanged: (val) => formData.update('gender', val),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

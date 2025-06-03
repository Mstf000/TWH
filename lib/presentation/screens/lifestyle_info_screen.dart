import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twh/presentation/screens/home_screen.dart';
import 'package:twh/presentation/screens/summary_screen.dart';

import '../../core/utils/translations.dart';
import '../providers/locale_provider.dart';
import '../providers/form_data_provider.dart';
import '../../data/services/firestore_service.dart';

class LifestyleInfoScreen extends StatefulWidget {
  const LifestyleInfoScreen({super.key});

  @override
  State<LifestyleInfoScreen> createState() => _LifestyleInfoScreenState();
}

class _LifestyleInfoScreenState extends State<LifestyleInfoScreen> {
  late TextEditingController notesController;
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    final formData = context.read<FormDataProvider>();
    notesController =
        TextEditingController(text: formData.getValue('notes') ?? '');
    notesController.addListener(() {
      formData.update('notes', notesController.text);
    });
  }

  @override
  void dispose() {
    notesController.dispose();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String keyName) {
    if (!_textControllers.containsKey(keyName)) {
      final formData = context.read<FormDataProvider>();
      _textControllers[keyName] =
          TextEditingController(text: formData.getValue(keyName) ?? '');
      _textControllers[keyName]!.addListener(() {
        formData.update(keyName, _textControllers[keyName]!.text);
      });
    }
    return _textControllers[keyName]!;
  }

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
              const Icon(Icons.self_improvement_rounded,
                  size: 60, color: Color(0xFF6A2E76)),
              const SizedBox(height: 16),
              Text(
                translations['lifeStyle']![locale]!,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A2E76),
                ),
              ),
              const SizedBox(height: 24),
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
                        _buildRadioQuestion(
                          context,
                          label: isArabic
                              ? 'ما هي طبيعة عملك الأساسية؟'
                              : 'What is your main type of work?',
                          options: [
                            {
                              'en': 'Desk job (sitting)',
                              'ar': 'عمل مكتبي (جلوس لفترات طويلة)'
                            },
                            {
                              'en': 'Standing job',
                              'ar': 'عمل يتطلب الوقوف لفترات طويلة'
                            },
                            {
                              'en': 'Physically demanding',
                              'ar': 'عمل يتطلب مجهود بدني عالي'
                            },
                            {
                              'en': 'Mental work',
                              'ar': 'عمل ذهني (تفكير وتحليل مستمر)'
                            },
                            {'en': 'Other', 'ar': 'أخرى'},
                          ],
                          keyName: 'work_type',
                        ),
                        _buildYesNoQuestion(
                          context,
                          label: isArabic
                              ? 'هل تسوق لمسافات طويلة بشكل يومي؟'
                              : 'Do you drive long distances daily?',
                          keyName: 'drives_long',
                        ),
                        _buildRadioQuestion(
                          context,
                          label: isArabic
                              ? 'كم يوم تعمل في الأسبوع؟'
                              : 'How many days do you work per week?',
                          options: [
                            {'en': 'Less than 5 days', 'ar': 'أقل من 5 أيام'},
                            {'en': '5 days', 'ar': '5 أيام'},
                            {'en': 'More than 5 days', 'ar': 'أكثر من 5 أيام'},
                          ],
                          keyName: 'work_days',
                        ),
                        _buildYesNoQuestion(
                          context,
                          label: isArabic
                              ? 'هل تستخدم الهاتف أو الكمبيوتر لفترات طويلة يوميًا؟'
                              : 'Do you use phone or computer a lot daily?',
                          keyName: 'screen_time',
                        ),
                        _buildCheckboxQuestion(
                          context,
                          label: isArabic
                              ? 'هل تعاني من أمراض مزمنة؟'
                              : 'Do you suffer from chronic diseases?',
                          options: [
                            {'en': 'Diabetes', 'ar': 'السكر'},
                            {'en': 'Hypertension', 'ar': 'الضغط'},
                            {'en': 'Heart Disease', 'ar': 'أمراض القلب'},
                            {'en': 'Rheumatism', 'ar': 'الروماتيزم'},
                            {'en': 'Other', 'ar': 'أخرى'},
                            {'en': 'None', 'ar': 'لا يوجد'},
                          ],
                          keyName: 'chronic_diseases',
                        ),
                        _buildShortAnswerQuestion(
                          context,
                          label: isArabic
                              ? 'هل يوجد من إصابات؟'
                              : 'Do you have any injuries?',
                          keyName: 'injuries',
                        ),
                        _buildCheckboxQuestion(
                          context,
                          label: isArabic
                              ? 'هل يوجد مشاكل في القوام؟'
                              : 'Do you have any posture-related issues?',
                          options: [
                            {'en': 'Neck Issue', 'ar': 'مشكلة في الرقبة'},
                            {'en': 'Back Issue', 'ar': 'مشكلة في الظهر'},
                            {'en': 'Knee Issue', 'ar': 'مشكلة في الركبة'},
                            {'en': 'Pelvis Issue', 'ar': 'مشكلة في الحوض'},
                            {'en': 'Balance Issue', 'ar': 'مشكلة في التوازن'},
                            {'en': 'None', 'ar': 'لا توجد'},
                          ],
                          keyName: 'posture_issues',
                        ),
                        _buildRadioQuestion(
                          context,
                          label: isArabic
                              ? 'هل خضعت لعملية جراحية من قبل (خصوصًا في العمود الفقري أو الرقبة)؟'
                              : 'Have you had surgery before (especially in the spine or neck)?',
                          options: [
                            {'en': 'Yes', 'ar': 'نعم'},
                            {'en': 'No', 'ar': 'لا'},
                          ],
                          keyName: 'surgery_history',
                        ),
                        _buildRadioQuestion(
                          context,
                          label: isArabic
                              ? 'هل تعاني من صعوبات في النوم (أرق/تقطع النوم)؟'
                              : 'Do you have difficulties sleeping (insomnia / interrupted sleep)?',
                          options: [
                            {'en': 'Yes', 'ar': 'نعم'},
                            {'en': 'No', 'ar': 'لا'},
                          ],
                          keyName: 'sleep_difficulty',
                        ),
                        _buildRadioQuestion(
                          context,
                          label: isArabic
                              ? 'هل تمارس الرياضة بانتظام؟'
                              : 'Do you exercise regularly?',
                          options: [
                            {'en': 'Yes', 'ar': 'نعم'},
                            {'en': 'No', 'ar': 'لا'},
                          ],
                          keyName: 'exercise_regular',
                        ),
                        _buildParagraphQuestion(
                          context,
                          label: isArabic
                              ? 'إذا نعم، ما نوع الرياضة التي تمارسها؟'
                              : 'If yes, what type of sport do you practice?',
                          keyName: 'exercise_type',
                        ),
                        _buildYesNoQuestion(
                          context,
                          label: isArabic
                              ? 'هل سبق لك تجربة أجهزة المساج من قبل؟'
                              : 'Have you used massage devices before?',
                          keyName: 'used_massage_device',
                        ),
                        _buildYesNoQuestion(
                          context,
                          label: isArabic
                              ? 'هل سبق لك الحصول على جلسات مساج يدوية؟'
                              : 'Have you had manual massage sessions before?',
                          keyName: 'manual_massage_experience',
                        ),
                        _buildRadioQuestion(
                          context,
                          label: isArabic
                              ? 'أي نوع من المساج تفضله؟'
                              : 'Which type of massage do you prefer?',
                          options: [
                            {'en': 'Soft Massage', 'ar': 'مساج ناعم (Soft)'},
                            {'en': 'Hard Massage', 'ar': 'مساج قوي (Hard)'},
                            {
                              'en': 'Not sure, need to try',
                              'ar': 'لست متأكداً، أحتاج للتجربة'
                            },
                          ],
                          keyName: 'massage_preference',
                        ),
                        _buildYesNoQuestion(
                          context,
                          label: isArabic
                              ? 'هل تعرف فوائد المساج وتأثيره الإيجابي على الصحة؟'
                              : 'Do you know the health benefits of massage?',
                          keyName: 'massage_benefits_awareness',
                        ),
                        _buildRadioQuestion(
                          context,
                          label: isArabic
                              ? 'ما هي حالة الصفقة؟'
                              : 'What is the deal status?',
                          options: [
                            {'en': 'Done', 'ar': 'تمت', 'value': 'done'},
                            {
                              'en': 'Pending',
                              'ar': 'قيد الانتظار',
                              'value': 'pending'
                            },
                            {
                              'en': 'No Deal',
                              'ar': 'لم تتم',
                              'value': 'no_deal'
                            },
                          ],
                          keyName: 'deal_status',
                          customValueKey: 'value',
                        ),
                        if (formData.getValue('deal_status') == 'done')
                          DealProductSelector(
                            onSelected: (category, product) {
                              formData.update('deal_category', category);
                              formData.update('deal_product', product);
                            },
                          ),
                        const SizedBox(height: 24),
                        Text(
                          isArabic
                              ? 'ملاحظات إضافية (اختياري)'
                              : 'Additional Notes (Optional)',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: notesController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: isArabic
                                ? 'أكتب أي ملاحظات هنا...'
                                : 'Write any notes here...',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(translations['back']![locale]!),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check),
                                label: Text(translations['submit']![locale]!),
                                onPressed: () async {
                                  try {
                                    await FirestoreService()
                                        .saveFormData(formData.allData);
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text(isArabic
                                            ? 'تم الإرسال'
                                            : 'Submitted'),
                                        content: Text(isArabic
                                            ? 'تم حفظ بياناتك في السحابة بنجاح'
                                            : 'Your data has been saved to Firebase.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => SummaryScreen(
                                                      formData:
                                                          formData.allData),
                                                ),
                                              );
                                            },
                                            child: const Text('OK'),
                                          )
                                        ],
                                      ),
                                    );
                                  } catch (e) {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Error'),
                                        content: Text(
                                            'Failed to save: ${e.toString()}'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioQuestion(BuildContext context,
      {required String label,
      required List<Map<String, String>> options,
      required String keyName,
      String? customValueKey}) {
    final locale = context.watch<LocaleProvider>().locale;
    final formData = context.watch<FormDataProvider>();
    final groupValue = formData.getValue(keyName);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          ...options.map((option) {
            final text = option[locale]!;
            final value =
                customValueKey != null ? option[customValueKey]! : text;
            return RadioListTile(
              title: Text(text, style: const TextStyle(fontSize: 14)),
              value: value,
              groupValue: groupValue,
              onChanged: (val) => formData.update(keyName, val),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildYesNoQuestion(BuildContext context,
      {required String label, required String keyName}) {
    final locale = context.watch<LocaleProvider>().locale;
    final formData = context.watch<FormDataProvider>();
    final groupValue = formData.getValue(keyName);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          RadioListTile(
            title: Text(locale == 'ar' ? 'نعم' : 'Yes',
                style: const TextStyle(fontSize: 14)),
            value: 'yes',
            groupValue: groupValue,
            onChanged: (val) => formData.update(keyName, val),
          ),
          RadioListTile(
            title: Text(locale == 'ar' ? 'لا' : 'No',
                style: const TextStyle(fontSize: 14)),
            value: 'no',
            groupValue: groupValue,
            onChanged: (val) => formData.update(keyName, val),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxQuestion(BuildContext context,
      {required String label,
      required List<Map<String, String>> options,
      required String keyName}) {
    final locale = context.watch<LocaleProvider>().locale;
    final formData = context.watch<FormDataProvider>();
    final selectedValues = List<String>.from(formData.getValue(keyName) ?? []);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          ...options.map((option) {
            final value = option[locale]!;
            return CheckboxListTile(
              title: Text(value),
              value: selectedValues.contains(value),
              onChanged: (checked) {
                final updated = [...selectedValues];
                if (checked == true) {
                  updated.add(value);
                } else {
                  updated.remove(value);
                }
                formData.update(keyName, updated);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildShortAnswerQuestion(BuildContext context,
      {required String label, required String keyName}) {
    final locale = context.watch<LocaleProvider>().locale;
    final controller = _getController(keyName);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: locale == 'ar' ? 'اكتب هنا' : 'Write here',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraphQuestion(BuildContext context,
      {required String label, required String keyName}) {
    final locale = context.watch<LocaleProvider>().locale;
    final controller = _getController(keyName);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  locale == 'ar' ? 'اكتب بالتفصيل هنا' : 'Write in detail...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}

class DealProductSelector extends StatefulWidget {
  final void Function(String category, String product)? onSelected;

  const DealProductSelector({super.key, this.onSelected});

  @override
  State<DealProductSelector> createState() => _DealProductSelectorState();
}

class _DealProductSelectorState extends State<DealProductSelector> {
  String? selectedCategory;
  String? selectedProduct;

  List<String> get availableProducts {
    final categoryMap = productData.firstWhere(
      (element) => element['category'] == selectedCategory,
      orElse: () => {"products": []},
    );
    return List<String>.from(categoryMap['products']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Product Category',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          hint: const Text("Select category"),
          value: selectedCategory,
          items: productData
              .map((e) => DropdownMenuItem<String>(
                    value: e['category'] as String, // 👈 cast explicitly
                    child: Text(e['category'] as String),
                  ))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedCategory = val;
              selectedProduct = null;
            });
            if (widget.onSelected != null && val != null) {
              widget.onSelected!(val, '');
            }
          },
        ),
        const SizedBox(height: 20),
        if (selectedCategory != null) ...[
          const Text(
            'Product Name',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            hint: const Text("Select product"),
            value: selectedProduct,
            items: availableProducts
                .map((product) => DropdownMenuItem<String>(
                      value: product,
                      child: Text(product),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                selectedProduct = val;
              });
              if (widget.onSelected != null &&
                  selectedCategory != null &&
                  val != null) {
                widget.onSelected!(selectedCategory!, val);
              }
            },
          ),
        ],
      ],
    );
  }
}

final List<Map<String, dynamic>> productData = [
  {
    "category": "Massage Chairs",
    "products": [
      "Model A1 Massage Chair",
      "Model B2 Luxury Chair",
      "TheraRelax Pro 9000"
    ]
  },
  {
    "category": "Back Massage",
    "products": [
      "Back Bliss Roller",
      "Posture Pro Cushion",
      "FlexiHeat Back Massager"
    ]
  },
  {
    "category": "Foot Massage",
    "products": [
      "Sole Soothe Machine",
      "FootEase Pro",
      "Revive Circulation Booster"
    ]
  },
  {
    "category": "Tools",
    "products": [
      "Trigger Point Gun",
      "Deep Tissue Wand",
      "Massage Roller Stick"
    ]
  },
  {
    "category": "Fitness Products",
    "products": [
      "Yoga Mat Deluxe",
      "Resistance Band Set",
      "Compact Rowing Machine"
    ]
  }
];

import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'TaleemOS use karke aap in terms se agree karte hain:\n\n'
                '1. Account Responsibility\nAapki login credentials ki security aapki apni zimmedari hai. Kisi bhi unauthorized access ki soorat mein foran admin ko inform karein.\n\n'
                '2. Acceptable Use\nPlatform sirf education-related activities ke liye use hoga. Koi bhi ghalat, harmful ya misleading content post karna mana hai.\n\n'
                '3. Data Accuracy\nSchool admin aur teachers ki zimmedari hai ke student records accurate aur up-to-date rakhein.\n\n'
                '4. Service Availability\nHum best-effort basis par service uptime ensure karte hain, lekin scheduled maintenance ke doran service temporarily unavailable ho sakti hai.\n\n'
                '5. Changes to Terms\nYe terms waqtan faqtan update ho sakti hain. Continued use is baat ki tasdeeq hai ke aap updated terms se agree hain.',
            style: TextStyle(height: 1.6, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Aapki madad ke liye hum hazir hain', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _FaqTile(question: 'Password bhool gaya, kya karein?', answer: 'Login screen par "Password bhool gaye?" par click karein aur registered email darj karein.'),
          _FaqTile(question: 'Attendance edit kyun nahi ho rahi?', answer: 'Attendance mark hone ke 24 ghante baad edit lock ho jati hai. Admin se rabta karein.'),
          _FaqTile(question: 'Fee payment kaise track karein?', answer: 'Fees section mein jaayein, wahan har invoice ki status aur payment history mil jayegi.'),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Support Ticket Banayein'),
              subtitle: const Text('Kisi bhi masle ke liye direct ticket raise karein'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/support/create'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: Align(alignment: Alignment.centerLeft, child: Text(answer, style: TextStyle(color: Colors.grey.shade700))),
        ),
      ],
    );
  }
}
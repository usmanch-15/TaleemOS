import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'TaleemOS aapki privacy ko seriously leta hai. Ye policy batati hai ke hum aapka data kaise collect, use, aur protect karte hain.\n\n'
                '1. Data Collection\nHum sirf wahi information collect karte hain jo school management ke liye zaroori hai — student records, attendance, marks, fees, aur communication data.\n\n'
                '2. Data Usage\nAapka data sirf school ke andar hi accessible hai, role-based permissions ke through. Kisi third party ko bagair aapki razamandi ke data share nahi kiya jata.\n\n'
                '3. Data Security\nSab data encrypted aur secure servers par store hota hai, row-level security policies ke sath jo ensure karti hain ke har user sirf apna authorized data hi dekh sake.\n\n'
                '4. Data Retention\nStudent records school ki policy ke mutabiq retain kiye jate hain. Deactivated records permanently delete karne ke bajaye inactive status mein rakhe jate hain.\n\n'
                '5. Aapke Rights\nAap apna data kabhi bhi dekh, update, ya deletion request kar sakte hain — apne school admin se rabta karke.',
            style: TextStyle(height: 1.6, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
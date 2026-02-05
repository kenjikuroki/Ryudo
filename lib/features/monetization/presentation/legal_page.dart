import 'package:flutter/material.dart';
import '../../../app/responsive_layout.dart';


class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Legal Information'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: ResponsiveLayout(
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              'Privacy Policy & Terms of Use',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Effective Date: January 26, 2026',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 24),
            _buildSection(
              null,
              'This document governs the privacy policy and terms of use for all mobile applications (collectively referred to as the "Services") developed and published by kenji kuroki.\n\nBy downloading or using the Services, you agree to the terms outlined below.',
              isIntroduction: true,
            ),
            Divider(height: 48),
            _buildSection(
              'Part 1: Privacy Policy',
              '''
1. Information Collection
We do not require you to create an account to use the Services. However, we may collect certain information automatically:
• Device Information: We may collect information about your mobile device, including device model, operating system version, and unique device identifiers (e.g., IDFA/AAID) for advertising and analytics purposes.
• Usage Data: Information about how you interact with the Services, such as quiz progress, correct/incorrect answers, and features accessed.

2. Advertising and Analytics
The Services include third-party advertising. These partners may use cookies or mobile advertising identifiers to collect data for personalized ads.
• Third-Party Ad Networks: We work with partners such as Google AdMob and Unity Ads. These companies may use data about your use of the Services to provide relevant advertisements.
• Analytics: We may use tools like Google Analytics for Firebase to understand performance and improve user experience across our applications.

3. In-App Purchases (IAP)
If you choose to purchase additional content or features within the Services:
Transactions are processed directly by the Apple App Store or Google Play Store. We do not collect or store your credit card numbers or financial information. We only receive confirmation from the app store that a purchase was successful.

4. Data Retention and Security
We take reasonable measures to protect your information. Since we do not collect personal identifiers like names or emails (unless you contact us for support), your data is largely anonymous. We retain usage data as long as necessary to provide functionality and improve our Services.

5. Children’s Privacy
The Services are not specifically directed to children under 13. We do not knowingly collect personal information from children. If you believe we have inadvertently collected such data, please contact us so we can delete it.

6. Your Rights and Choices
• Ad Tracking: You can opt-out of interest-based advertising by adjusting the privacy settings on your mobile device (e.g., "Limit Ad Tracking" on iOS or "Opt out of Ads Personalization" on Android).
• In-App Purchases: You can manage IAP preferences via your device's system settings.

7. Changes to This Policy
We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page.
''',
            ),
            SizedBox(height: 32),
            _buildSection(
              'Part 2: Terms of Use & Disclaimer',
              '''
1. General Disclaimer
The Services are provided on an "AS IS" and "AS AVAILABLE" basis. The developer makes no representations or warranties of any kind, express or implied, regarding the operation of the Services. To the full extent permissible by applicable law, the developer disclaims all warranties, express or implied, including implied warranties of merchantability and fitness for a particular purpose.

2. Educational Content & Exam Results
The Services are intended to assist with learning and exam preparation, but the developer does not guarantee specific results (e.g., passing an exam, obtaining a certification, or improving grades).
• Accuracy of Information: While the developer strives to keep the content (quizzes, explanations, laws, and regulations) accurate and up-to-date, exam formats and legal standards may change over time. The developer is not responsible for any errors, omissions, or outdated information contained in the Services.
• Not Professional Advice: The content provided in the Services is for educational purposes only and should not be considered as professional legal, financial, or medical advice.

3. No Official Affiliation
Unless explicitly stated otherwise, the Services are not affiliated with, endorsed by, or associated with any official testing organization, government agency, or certification body. Any trademarks or service marks used in the Services are the property of their respective owners.

4. Limitation of Liability
The developer shall not be liable for any damages of any kind arising from the use of the Services, including, but not limited to, direct, indirect, incidental, punitive, and consequential damages. This includes, without limitation, damages for loss of data, loss of profits, or device malfunction.

5. Third-Party Links and Ads
The Services may contain links to third-party websites or services (including advertisements) that are not owned or controlled by the developer. The developer has no control over and assumes no responsibility for the content, privacy policies, or practices of any third-party websites or services.
''',
            ),
            Divider(height: 64),
            _buildSection(
              'Contact Us',
              'If you have any questions about this Privacy Policy or Terms of Use, please contact us at:\nsanataro2025@protonmail.com',
            ),
            SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSection(String? title, String content, {bool isIntroduction = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          content,
          style: TextStyle(
            fontSize: isIntroduction ? 16 : 14,
            height: 1.6,
            color: isIntroduction ? Colors.black87 : Colors.black54,
            fontWeight: isIntroduction ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

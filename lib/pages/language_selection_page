import 'package:flutter/material.dart';
import '../main.dart'; // Import main.dart for dynamic locale change
import '../generated/l10n.dart'; // Import localization delegate

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).language, // Localized "Language" string
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF680C5D), // Match your app's theme
      ),
      body: ListView(
        children: [
          _buildLanguageTile(context, 'English', const Locale('en')),
          _buildLanguageTile(context, 'Malay', const Locale('ms')),
          // Add more languages as needed
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, String language, Locale locale) {
    return ListTile(
      title: Text(language, style: const TextStyle(fontSize: 18)),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        MyApp.setLocale(context, locale); // Dynamically update the locale
        Navigator.pop(context); // Return to the previous page
      },
    );
  }
}

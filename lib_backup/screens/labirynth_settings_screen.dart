import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LabirynthSettingsScreen extends StatefulWidget {
  const LabirynthSettingsScreen({super.key});

  @override
  State<LabirynthSettingsScreen> createState() => _LabirynthSettingsScreenState();
}

class _LabirynthSettingsScreenState extends State<LabirynthSettingsScreen> {
  int selectedLevel = 1;
  bool soundOn = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLevel = prefs.getInt('labirynth_level') ?? 1;
      soundOn = prefs.getBool('labirynth_sound') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('labirynth_level', selectedLevel);
    await prefs.setBool('labirynth_sound', soundOn);
  }

  Future<void> _resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      selectedLevel = 1;
      soundOn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EB),
      appBar: AppBar(
        title: const Text('⚙️ Labirynth Settings'),
        backgroundColor: const Color(0xFF154314),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFFCF6DB)),
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFFFCF6DB),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎮 Choose Starting Level:', style: TextStyle(fontFamily: 'Poppins')),
            Slider(
              value: selectedLevel.toDouble(),
              min: 1,
              max: 50,
              divisions: 49,
              label: '$selectedLevel',
              onChanged: (val) {
                setState(() => selectedLevel = val.round());
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🔊 Sound:', style: TextStyle(fontFamily: 'Poppins')),
                Switch(
                  value: soundOn,
                  onChanged: (val) => setState(() => soundOn = val),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _resetProgress();
                },
                icon: const Icon(Icons.delete_forever),
                label: const Text('Reset All Progress'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _saveSettings();
                  Navigator.pop(context);
                },
                child: const Text('Save & Back', style: TextStyle(fontFamily: 'Poppins')),
              ),
            )
          ],
        ),
      ),
    );
  }
} 

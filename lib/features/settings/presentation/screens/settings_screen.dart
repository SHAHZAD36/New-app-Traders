import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../../data/models/settings_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _bizCtrl;
  late TextEditingController _ownerCtrl;
  bool _init = false;

  @override Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    if (settings != null && !_init) {
      _bizCtrl = TextEditingController(text: settings.businessName);
      _ownerCtrl = TextEditingController(text: settings.ownerName ?? '');
      _init = true;
    } else if (!_init) {
      _bizCtrl = TextEditingController();
      _ownerCtrl = TextEditingController();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('سیٹنگز (Settings)')),
      body: settings == null ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                  const Text('کاروباری معلومات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  TextField(controller: _bizCtrl, decoration: const InputDecoration(labelText: 'کاروبار کا نام', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: _ownerCtrl, decoration: const InputDecoration(labelText: 'مالک کا نام', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                    onPressed: () {
                      ref.read(settingsProvider.notifier).update(SettingsModel(
                        id: settings.id, businessName: _bizCtrl.text, ownerName: _ownerCtrl.text,
                        currencySymbol: settings.currencySymbol, themeMode: settings.themeMode, language: settings.language));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سیٹنگز محفوظ ہو گئیں')));
                    },
                    child: const Text('محفوظ کریں'),
                  ),
                ]))),
              const SizedBox(height: 16),
              Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  ListTile(leading: const Icon(Icons.info), title: const Text('ورژن'), trailing: const Text('1.0.0')),
                  const Divider(height: 1),
                  ListTile(leading: const Icon(Icons.business), title: const Text('چوہدری ٹریڈرز'), subtitle: const Text('Snack Distribution App')),
                ])),
            ])),
    );
  }
}

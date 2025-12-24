import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Uygulama Hakkında'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Versiyon'),
            subtitle: const Text('1.0.0 (MVP)'),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Yasal'),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Kullanım Koşulları'),
            subtitle: const Text('Bu uygulama sadece eğitim amaçlıdır.'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Yasal Uyarı'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Bu uygulama ("Trader AI Tutor") sadece eğitim ve bilgilendirme amaçlıdır. '
                      'Burada sunulan hiçbir içerik, analiz veya veri yatırım tavsiyesi değildir. '
                      'Finansal piyasalar yüksek risk içerir ve paranızın tamamını kaybedebilirsiniz. '
                      'Herhangi bir yatırım kararı almadan önce lisanslı bir finansal danışmana başvurmalısınız. '
                      'Uygulama geliştiricileri, bu uygulamanın kullanımından doğabilecek zararlardan sorumlu tutulamaz.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Anladım'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Hesap'),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                // Router redirect will handle navigation to /auth
                // But we can also force it if needed, though GoRouter redirect is better
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

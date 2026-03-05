import 'package:flutter/material.dart';
import '../app/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Regulamin')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Regulamin korzystania z aplikacji SoberSteps',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text('Ostatnia aktualizacja: 1 marca 2026', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            SizedBox(height: 24),

            _Section(title: '1. Postanowienia ogólne', content:
                'Niniejszy Regulamin określa zasady korzystania z aplikacji mobilnej SoberSteps (dalej: „Aplikacja"), '
                'której operatorem jest SoberSteps (dalej: „Operator"). Kontakt: sobersteps@pm.me.\n\n'
                'Korzystanie z Aplikacji oznacza akceptację niniejszego Regulaminu. Jeśli nie zgadzasz się z jego treścią, '
                'prosimy o zaprzestanie korzystania z Aplikacji.'),

            _Section(title: '2. Opis usługi', content:
                'SoberSteps jest aplikacją wspierającą osoby w procesie zdrowienia z uzależnień. Aplikacja oferuje:\n'
                '• Śledzenie dni trzeźwości\n'
                '• Codzienne check-iny z oceną nastroju i poziomu głodu\n'
                '• Kamienie milowe i celebracje postępów\n'
                '• 3 AM Wall of Strength — wsparcie kryzysowe\n'
                '• Craving Surf — techniki radzenia sobie z głodem\n'
                '• Listy do siebie z przyszłości\n'
                '• Społeczność użytkowników\n'
                '• Plan Premium (Recovery+) z dodatkowymi funkcjami'),

            _Section(title: '3. Rejestracja i konto', content:
                'Rejestracja jest możliwa poprzez:\n'
                '• Link magiczny (e-mail OTP)\n'
                '• Konto Google\n'
                '• Konto Apple\n\n'
                'Użytkownik zobowiązuje się podać prawdziwy adres e-mail. Jedno konto odpowiada jednemu użytkownikowi. '
                'Operator zastrzega sobie prawo do usunięcia konta naruszającego Regulamin.'),

            _Section(title: '4. Zasady korzystania ze społeczności', content:
                'Użytkownik zobowiązuje się do:\n'
                '• Traktowania innych użytkowników z szacunkiem\n'
                '• Niepublikowania treści obraźliwych, nielegalnych lub promujących użyczanie substancji\n'
                '• Niepublikowania linków zewnętrznych, reklam ani spamu\n'
                '• Niepodejmowania prób obejścia systemów moderacji\n\n'
                'Posty naruszające zasady mogą być automatycznie ukrywane po zgłoszeniu przez 3 lub więcej użytkowników. '
                'Operator zastrzega sobie prawo do moderacji treści.'),

            _Section(title: '5. Subskrypcje i płatności', content:
                'Aplikacja oferuje plan darmowy oraz płatny plan Recovery+:\n'
                '• Monthly: \$6.99/miesiąc\n'
                '• Annual: \$59.99/rok\n'
                '• Family: \$9.99/miesiąc\n'
                '• Lifetime: \$89.99 (dostępny po 90 dniach użytkowania)\n\n'
                'Płatności są obsługiwane przez Google Play / Apple App Store. Subskrypcje odnawiają się automatycznie, '
                'chyba że zostaną anulowane co najmniej 24 godziny przed końcem bieżącego okresu. '
                'Przywracanie zakupów jest dostępne w ustawieniach profilu.\n\n'
                '7-dniowy darmowy okres próbny jest dostępny dla nowych użytkowników. Po jego zakończeniu automatycznie '
                'rozpoczyna się płatna subskrypcja, chyba że zostanie anulowana.'),

            _Section(title: '6. Zastrzeżenie medyczne', content:
                'WAŻNE: SoberSteps NIE jest usługą medyczną, terapeutyczną ani kryzysową. Aplikacja nie zastępuje '
                'profesjonalnej pomocy medycznej, psychologicznej ani psychiatrycznej.\n\n'
                'Jeśli jesteś w kryzysie, skontaktuj się z:\n'
                '• SAMHSA National Helpline: 1-800-662-4357 (USA)\n'
                '• Telefon Zaufania: 116 123 (Polska)\n'
                '• Pogotowie ratunkowe: 112\n\n'
                'Operator nie ponosi odpowiedzialności za decyzje zdrowotne podejmowane na podstawie korzystania z Aplikacji.'),

            _Section(title: '7. Własność intelektualna', content:
                'Wszelkie treści zawarte w Aplikacji, w tym teksty, grafiki, ikony, animacje, dźwięki i kod źródłowy, '
                'stanowią własność Operatora i są chronione prawem autorskim. Kopiowanie, modyfikowanie lub rozpowszechnianie '
                'treści bez zgody Operatora jest zabronione.'),

            _Section(title: '8. Ograniczenie odpowiedzialności', content:
                'Aplikacja jest dostarczana „tak jak jest" (as is). Operator dokłada starań, aby Aplikacja działała '
                'prawidłowo, ale nie gwarantuje nieprzerwanego i bezbłędnego działania.\n\n'
                'Operator nie ponosi odpowiedzialności za:\n'
                '• Przerwy w działaniu wynikające z przyczyn technicznych\n'
                '• Utratę danych spowodowaną awarią urządzenia użytkownika\n'
                '• Treści publikowane przez użytkowników w społeczności\n'
                '• Skutki decyzji podejmowanych na podstawie treści z Aplikacji'),

            _Section(title: '9. Rozwiązanie umowy', content:
                'Użytkownik może w dowolnym momencie zaprzestać korzystania z Aplikacji i usunąć swoje konto '
                'kontaktując się pod adresem sobersteps@pm.me.\n\n'
                'Operator może zawiesić lub usunąć konto użytkownika naruszającego Regulamin.'),

            _Section(title: '10. Zmiany Regulaminu', content:
                'Operator zastrzega sobie prawo do zmiany Regulaminu. O istotnych zmianach użytkownicy zostaną '
                'powiadomieni za pośrednictwem Aplikacji lub e-mail. Dalsze korzystanie z Aplikacji po zmianie '
                'Regulaminu oznacza jego akceptację.'),

            _Section(title: '11. Kontakt', content:
                'W sprawach związanych z Regulaminem prosimy o kontakt:\n'
                'E-mail: sobersteps@pm.me'),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

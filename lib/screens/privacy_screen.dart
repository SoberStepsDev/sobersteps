import 'package:flutter/material.dart';
import '../app/theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Polityka Prywatności')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Polityka Prywatności SoberSteps',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text('Ostatnia aktualizacja: 1 marca 2026', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            SizedBox(height: 16),
            Text('Twoja prywatność jest dla nas niezwykle ważna. Rozumiemy, że dane dotyczące zdrowienia są '
                'wrażliwe i traktujemy ich ochronę priorytetowo.',
                style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary)),
            SizedBox(height: 24),

            _Section(title: '1. Administrator danych', content:
                'Administratorem danych osobowych jest SoberSteps.\n'
                'Kontakt: sobersteps@pm.me\n\n'
                'Dane są przetwarzane zgodnie z Rozporządzeniem Parlamentu Europejskiego i Rady (UE) 2016/679 (RODO) '
                'oraz obowiązującymi przepisami o ochronie danych osobowych.'),

            _Section(title: '2. Jakie dane zbieramy', content:
                'Zbieramy następujące kategorie danych:\n\n'
                'a) Dane konta:\n'
                '• Adres e-mail (rejestracja)\n'
                '• Identyfikator konta Google lub Apple (logowanie społecznościowe)\n\n'
                'b) Dane dotyczące zdrowienia:\n'
                '• Data rozpoczęcia trzeźwości\n'
                '• Typ substancji\n'
                '• Dzienne check-iny (nastrój, poziom głodu, triggery, notatki)\n'
                '• Osiągnięte kamienie milowe\n'
                '• Sesje Craving Surf\n'
                '• Wpisy 3 AM Wall\n'
                '• Listy do siebie z przyszłości\n\n'
                'c) Dane społecznościowe:\n'
                '• Posty w społeczności\n'
                '• Polubienia\n\n'
                'd) Dane techniczne:\n'
                '• Wariant A/B (optymalizacja doświadczenia)\n'
                '• Data instalacji\n'
                '• Preferencje powiadomień'),

            _Section(title: '3. Cel przetwarzania danych', content:
                'Przetwarzamy dane w celu:\n'
                '• Świadczenia usług Aplikacji (śledzenie postępów, check-iny, milestones)\n'
                '• Zapewnienia funkcji społecznościowych\n'
                '• Obsługi płatności i subskrypcji\n'
                '• Wysyłania powiadomień (za zgodą użytkownika)\n'
                '• Moderacji treści i bezpieczeństwa społeczności\n'
                '• Ulepszania Aplikacji na podstawie anonimowych statystyk'),

            _Section(title: '4. Bezpieczeństwo danych', content:
                'Stosujemy następujące środki ochrony:\n'
                '• Baza danych Supabase z szyfrowaniem w spoczynku i w transporcie (TLS/SSL)\n'
                '• Row Level Security (RLS) — każdy użytkownik ma dostęp wyłącznie do swoich danych\n'
                '• Hasła nie są przechowywane — używamy logowania bezhasłowego (magic link) lub OAuth\n'
                '• Wpisy 3 AM Wall są anonimowe — inni użytkownicy nie widzą autora\n'
                '• Dane check-inów nie są widoczne dla innych użytkowników\n'
                '• Moderacja treści chroni społeczność przed nieodpowiednimi treściami'),

            _Section(title: '5. Udostępnianie danych', content:
                'Nie sprzedajemy danych osobowych. Dane mogą być udostępniane:\n\n'
                '• Supabase Inc. — hosting bazy danych (przetwarzanie danych)\n'
                '• Google / Apple — logowanie OAuth i płatności\n'
                '• RevenueCat — obsługa subskrypcji\n'
                '• OneSignal — powiadomienia push (za zgodą)\n\n'
                'Wszyscy partnerzy przetwarzają dane zgodnie z własnymi politykami prywatności i stosują odpowiednie '
                'zabezpieczenia.'),

            _Section(title: '6. Przechowywanie danych', content:
                'Dane są przechowywane tak długo, jak posiadasz aktywne konto. Po usunięciu konta:\n'
                '• Dane osobowe są usuwane w ciągu 30 dni\n'
                '• Anonimowe wpisy w społeczności mogą pozostać (bez powiązania z kontem)\n'
                '• Logi techniczne są usuwane po 90 dniach\n\n'
                'Część danych (check-iny, kamienie milowe) jest cachowana lokalnie na urządzeniu '
                'w celu działania offline. Te dane nie opuszczają urządzenia.'),

            _Section(title: '7. Twoje prawa', content:
                'Masz prawo do:\n'
                '• Dostępu do swoich danych — napisz na sobersteps@pm.me\n'
                '• Sprostowania danych — edycja w ustawieniach profilu\n'
                '• Usunięcia danych — napisz na sobersteps@pm.me, usunięcie w ciągu 30 dni\n'
                '• Przenoszenia danych — eksport na żądanie\n'
                '• Cofnięcia zgody na powiadomienia — w ustawieniach telefonu\n'
                '• Wniesienia skargi do organu nadzorczego (UODO w Polsce)'),

            _Section(title: '8. Pliki cookie i dane lokalne', content:
                'Aplikacja korzysta z SharedPreferences (lokalna pamięć urządzenia) do przechowywania:\n'
                '• Sesji logowania\n'
                '• Cachowanych danych (dni trzeźwości, preferencje)\n'
                '• Kolejki offline (check-iny do synchronizacji)\n'
                '• Wariantu A/B i daty instalacji\n\n'
                'Te dane nie są wysyłane do podmiotów trzecich i służą wyłącznie funkcjonowaniu Aplikacji.'),

            _Section(title: '9. Dzieci', content:
                'Aplikacja nie jest przeznaczona dla osób poniżej 18 roku życia. Nie zbieramy świadomie '
                'danych od niepełnoletnich. Jeśli dowiesz się, że dziecko przekazało nam dane, '
                'skontaktuj się z nami pod sobersteps@pm.me.'),

            _Section(title: '10. Zmiany polityki', content:
                'O istotnych zmianach Polityki Prywatności poinformujemy poprzez Aplikację lub e-mail '
                'co najmniej 14 dni przed wejściem zmian w życie.'),

            _Section(title: '11. Kontakt', content:
                'Pytania dotyczące prywatności:\n'
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

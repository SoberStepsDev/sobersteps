import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/theme.dart';
import '../providers/purchase_provider.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final Set<int> _completed = {};

  @override
  void initState() {
    super.initState();
    _loadCompleted();
  }

  Future<void> _loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('completed_lessons') ?? [];
    setState(() => _completed.addAll(list.map(int.parse)));
  }

  Future<void> _markCompleted(int idx) async {
    final prefs = await SharedPreferences.getInstance();
    _completed.add(idx);
    await prefs.setStringList('completed_lessons', _completed.map((e) => e.toString()).toList());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PurchaseProvider>().isPremium;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mini-lekcje')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _lessons.length,
        itemBuilder: (context, i) {
          final lesson = _lessons[i];
          final isFree = i < 7;
          final locked = !isFree && !isPremium;
          final done = _completed.contains(i);
          return _LessonCard(
            index: i + 1,
            lesson: lesson,
            locked: locked,
            done: done,
            onTap: () {
              if (locked) {
                Navigator.pushNamed(context, '/paywall');
                return;
              }
              _showLesson(context, lesson, i);
            },
          );
        },
      ),
    );
  }

  void _showLesson(BuildContext context, _Lesson lesson, int idx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              Text(lesson.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(lesson.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('~${lesson.readMinutes} min', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              Text(lesson.content, style: const TextStyle(fontSize: 15, height: 1.7, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              if (lesson.keyTakeaway.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kluczowy wniosek:', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(lesson.keyTakeaway, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _markCompleted(idx);
                    Navigator.pop(context);
                  },
                  child: const Text('Przeczytane ✓'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final int index;
  final _Lesson lesson;
  final bool locked;
  final bool done;
  final VoidCallback onTap;

  const _LessonCard({required this.index, required this.lesson, required this.locked, required this.done, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: done ? AppColors.success.withValues(alpha: 0.4) : (locked ? AppColors.surfaceLight : AppColors.surfaceLight)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: done ? AppColors.success.withValues(alpha: 0.2) : (locked ? AppColors.surfaceLight : AppColors.primary.withValues(alpha: 0.15)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, size: 18, color: AppColors.success)
                    : locked
                        ? const Icon(Icons.lock, size: 16, color: AppColors.textSecondary)
                        : Text('$index', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title, style: TextStyle(color: locked ? AppColors.textSecondary : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                  Text('${lesson.emoji}  ~${lesson.readMinutes} min', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (locked) Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: const Text('PRO', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Lesson {
  final String title;
  final String emoji;
  final int readMinutes;
  final String content;
  final String keyTakeaway;
  const _Lesson(this.title, this.emoji, this.readMinutes, this.content, this.keyTakeaway);
}

const _lessons = [
  // FREE (0-6)
  _Lesson('Jak działa uzależnienie na mózg', '🧠', 2,
      'Uzależnienie to choroba mózgu, nie brak silnej woli. Substancje psychoaktywne zalewają układ nagrody dopaminą — neuroprzekaźnikiem odpowiedzialnym za przyjemność. Przy regularnym używaniu mózg adaptuje się: zmniejsza liczbę receptorów dopaminy, co oznacza, że potrzebujesz coraz więcej substancji, by poczuć to samo (tolerancja).\n\nJednocześnie kora przedczołowa — odpowiedzialna za podejmowanie decyzji, kontrolę impulsów i planowanie — traci swoją skuteczność. To dlatego wiesz, że powinieneś przestać, ale ciało robi swoje.\n\nDobra wiadomość: mózg jest plastyczny. Abstynencja pozwala na odbudowę receptorów i wzmocnienie kory przedczołowej. Po 90 dniach zmiany są mierzalne na skanach mózgu.',
      'Uzależnienie zmienia mózg fizycznie, ale abstynencja pozwala mu się odbudować.'),
  _Lesson('Co to jest PAWS?', '🌊', 2,
      'PAWS (Post-Acute Withdrawal Syndrome) to zespół objawów poabstynencyjnych, który pojawia się po ostrej fazie odstawienia. Może trwać tygodnie, miesiące, a nawet do 2 lat.\n\nObjawy PAWS:\n• Wahania nastroju bez wyraźnej przyczyny\n• Problemy ze snem\n• Trudności z koncentracją\n• Lęk i drażliwość\n• Niska energia\n• Nagłe fale craving\n\nPAWS przychodzi falami — możesz mieć świetny tydzień, a potem nagle 3 ciężkie dni. To normalne i NIE oznacza, że coś jest nie tak. To mózg się kalibruje.\n\nCo pomaga: regularny sen, ćwiczenia, nawodnienie, unikanie stresu, akceptacja że to przejściowe.',
      'PAWS to normalna część procesu. Przychodzi falami i każda fala jest krótsza od poprzedniej.'),
  _Lesson('Pierwszych 72 godzin', '⏰', 2,
      'Pierwsze 3 dni to najtrudniejszy fizycznie okres abstynencji. Ciało dosłownie protestuje przeciwko brakowi substancji.\n\nCo się dzieje:\n• 6-12h: Lęk, drżenie rąk, pocenie się, bezsenność\n• 12-24h: Szczyt objawów fizycznych\n• 24-48h: Zmęczenie, wahania nastroju, bóle głowy\n• 48-72h: Objawy zaczynają słabnąć\n\nWAŻNE: Odstawienie alkoholu może być niebezpieczne medycznie. Jeśli piłeś dużo i regularnie, skonsultuj się z lekarzem przed odstawieniem.\n\nCo robić:\n• Pij dużo wody\n• Jedz regularnie (nawet jeśli nie chcesz)\n• Nie bądź sam\n• Jeśli objawy są silne — szukaj pomocy medycznej\n\nPo 72h najtrudniejsze za Tobą. Fizycznie robi się łatwiej z każdym dniem.',
      'Po 72 godzinach fizyczne objawy słabną. Jeśli odstawiasz alkohol po ciężkim piciu — skonsultuj się z lekarzem.'),
  _Lesson('Czym jest craving i jak go surfować', '🏄', 2,
      'Craving (głód substancji) to intensywna potrzeba użycia. Przychodzi jak fala — narasta, osiąga szczyt i opada. Przeciętny craving trwa 15-30 minut.\n\n„Surfing" polega na obserwowaniu cravingu bez reagowania na niego. Wyobraź sobie, że siedzisz na desce surfingowej i pozwalasz fali przejść pod Tobą.\n\nTechnika STOP:\n• S — Stop. Zatrzymaj się.\n• T — Take a breath. Weź 3 głębokie oddechy.\n• O — Observe. Obserwuj co czujesz w ciele.\n• P — Proceed. Podejmij świadomą decyzję.\n\nKażdy przesurfowany craving wzmacnia ścieżki neuronowe samokontroli. Z czasem cravings stają się słabsze i rzadsze.',
      'Craving jest jak fala — trwa 15-30 minut i zawsze mija. Nie musisz walczyć, wystarczy przeczekać.'),
  _Lesson('Trigger — rozpoznaj wroga', '🎯', 2,
      'Trigger to bodziec, który uruchamia chęć użycia. Mogą być wewnętrzne (emocje) i zewnętrzne (sytuacje).\n\nNajczęstsze triggery:\n• Stres i lęk\n• Samotność i nuda\n• Miejsca gdzie używałeś\n• Ludzie z którymi używałeś\n• Piątkowy wieczór / weekend\n• Pory roku (święta, lato)\n• Sukcesy (! — \"zasłużyłem\")\n• Złość i frustracja\n\nPlan działania:\n1. Identyfikuj — zapisuj każdy trigger w check-inie\n2. Unikaj — na początku unikaj sytuacji high-risk\n3. Radzij sobie — miej plan B na każdy trigger\n4. Analizuj — po miesiącu zobacz wzorce\n\nŚwiadomość triggera to połowa sukcesu.',
      'Zapisuj triggery konsekwentnie. Wzorce ujawnią się po 2-3 tygodniach.'),
  _Lesson('Sen w trzeźwości', '😴', 2,
      'Uzależnienie niszczy architekturę snu. Alkohol np. pomaga zasnąć, ale eliminuje fazę REM — tę odpowiedzialną za przetwarzanie emocji i pamięć.\n\nPo odstawieniu sen jest często okropny przez pierwsze 1-4 tygodnie. To normalne.\n\nJak poprawić sen w trzeźwości:\n• Stała pora wstawania (nawet w weekend)\n• Żadnych ekranów 30 min przed snem\n• Chłodna sypialnia (18-20°C)\n• Magnez przed snem\n• 4-7-8 oddychanie: wdech 4s, wstrzymaj 7s, wydech 8s\n• Ruch w ciągu dnia (nie przed snem)\n\nPo 2-4 tygodniach abstynencji sen staje się głębszy i bardziej regenerujący niż kiedykolwiek podczas używania.',
      'Zły sen na początku to norma. Po 2-4 tygodniach będziesz spać lepiej niż kiedykolwiek.'),
  _Lesson('Budowanie nowych nawyków', '🔄', 2,
      'Uzależnienie to nawyk — potężny, ale wciąż nawyk. Nie wystarczy usunąć stary; trzeba zbudować nowy.\n\nPętla nawyku: Sygnał → Rutyna → Nagroda\n\nPrzykład starego: Piątek 18:00 (sygnał) → Piwo (rutyna) → Relaks (nagroda)\nNowy: Piątek 18:00 (sygnał) → Bieganie (rutyna) → Endorfiny (nagroda)\n\nKlucz: zachowaj ten sam sygnał i nagrodę, zmień tylko rutynę.\n\nZasada 2 minut: Nowy nawyk powinien zaczynać się od czegoś tak łatwego, że trwa max 2 minuty. „Będę biegać 30 min" → „Założę buty do biegania". Reszta przyjdzie.\n\nStack nawyków: Połącz nowy nawyk z istniejącym. „Po porannej kawie zrobię 5 pompek." „Po check-inie w SoberSteps przeczytam 1 stronę."',
      'Nie usuwaj starego nawyku — zastąp go nowym z tą samą nagrodą.'),
  // PREMIUM (7+)
  _Lesson('Relacje w trzeźwości', '❤️', 3,
      'Trzeźwość zmienia każdą relację. Niektóre rozkwitają, inne się kończą — i obie opcje są OK.\n\nFazy zmian relacyjnych:\n\n1. Szok i opór (0-30 dni): Bliscy mogą nie wierzyć, testować Cię, a nawet sabotować. Ludzie z którymi piłeś mogą poczuć się zagrożeni Twoją zmianą.\n\n2. Reorganizacja (1-6 miesięcy): Uczysz się od nowa: jak się bawić, jak rozmawiać, jak radzić sobie z konfliktem bez substancji. To niezręczne. To normalne.\n\n3. Głębia (6+ miesięcy): Relacje stają się prawdziwsze. Uczysz się granic, komunikacji, wrażliwości.\n\nTrudne prawdy:\n• Nie wszyscy będą Cię wspierać\n• Niektóre przyjaźnie przetrwają tylko w barze\n• Partner/ka może nie rozpoznać nowej wersji Ciebie\n\nPomoc:\n• Terapia par, jeśli jesteś w związku\n• Spotkania AA/NA/SMART dla budowania nowej sieci\n• Sponsor lub accountability partner',
      'Trzeźwość ujawnia prawdę o relacjach. To bolesne, ale prowadzi do głębszych połączeń.'),
  _Lesson('Samotność vs bycie samemu', '🏔️', 2,
      'Samotność to najsilniejszy trigger nawrotów. Ale jest różnica między byciem samemu a samotnością.\n\nBycie samemu = wybór. Czas z sobą, refleksja, regeneracja.\nSamotność = poczucie odcięcia nawet wśród ludzi.\n\nW uzależnieniu często otaczamy się ludźmi, ale jesteśmy samotni. W trzeźwości możemy być sami, ale czuć się połączeni.\n\nPlan na samotność:\n• Miej listę 3 osób, do których możesz zadzwonić o każdej porze\n• Pisz na 3 AM Wall — nie jesteś sam\n• Chodź na spotkania (nawet online)\n• Wolontariat — pomaganie innym leczy samotność\n• Przyjmij, że samotność to emocja, nie fakt. Przejdzie jak craving.',
      'Samotność to emocja, nie rzeczywistość. Masz 3 AM Wall i całą społeczność.'),
  _Lesson('Nawrót nie jest porażką', '🔁', 2,
      'Nawrót (relapse) jest częścią procesu zdrowienia dla wielu osób. To NIE jest powód do wstydu ani porażka.\n\nModel nawrotu Marlatta:\n1. Nawrót emocjonalny (tygodnie wcześniej): izolacja, tłumienie emocji, zaniedbywanie siebie\n2. Nawrót mentalny (dni wcześniej): fantazjowanie o używaniu, myślenie \"jeden raz\", planowanie\n3. Nawrót fizyczny: użycie substancji\n\nJeśli doszło do nawrotu:\n• Natychmiast zatrzymaj się — jeden raz nie musi stać się ciągiem\n• Zadzwoń do kogoś: sponsor, przyjaciel, linia kryzysowa\n• Nie usuwaj aplikacji. Zresetuj licznik. Zacznij od zera — z doświadczeniem\n• Zapytaj się: co było triggerem? Czego mogę się nauczyć?\n\nKażdy dzień trzeźwości się liczy — nawet jeśli nie są po kolei.',
      'Nawrót to informacja, nie wyrok. Najważniejsze co robisz następnego dnia.'),
  _Lesson('Gniew i frustracja bez substancji', '😤', 2,
      'Wiele osób pije/używa, żeby stłumić gniew. Bez substancji emocje wracają ze zdwojoną siłą.\n\nDlaczego gniew jest taki silny w trzeźwości:\n• Lata tłumionych emocji wracają\n• Mózg uczy się od nowa regulacji emocji\n• Frustracja z powodu trudności trzeźwości\n\nZdrowe sposoby na gniew:\n• Ruch fizyczny: bieg, boks, pompki\n• Lodowa technika: trzymaj kostkę lodu w dłoni — ból odwraca uwagę od gniewu\n• Journaling: napisz list do osoby, na którą się gniewasz (nie wysyłaj)\n• 5-4-3-2-1: Znajdź 5 rzeczy, które widzisz, 4 słyszysz, 3 czujesz, 2 wąchasz, 1 smakujesz\n• Box breathing: 4s wdech, 4s pauza, 4s wydech, 4s pauza',
      'Gniew to normalna emocja. Problem nie jest w czuciu go, a w tym co z nim robisz.'),
  _Lesson('Finanse po uzależnieniu', '💰', 2,
      'Uzależnienie to nie tylko problem zdrowotny — to finansowa katastrofa. Średni alkoholik wydaje \$10,000-\$15,000 rocznie na alkohol. Narkotyki — znacznie więcej.\n\nPo odstawieniu:\n\n1. Natychmiast: Przestań wydawać na substancję. Zacznij śledzić ile oszczędzasz (zakładka Oszczędności w SoberSteps).\n\n2. Miesiąc 1: Oceń szkody — długi, nieopłacone rachunki, stracone możliwości.\n\n3. Miesiąc 2-6: Budżet. Każda zaoszczędzona złotówka/dolar idzie na: spłatę długów (50%), fundusz awaryjny (30%), nagrody za trzeźwość (20%).\n\n4. Rok 1+: Inwestuj w siebie: kurs, terapia, hobby, podróże — to nagrody, które nie kradną jutrzejszego dnia.',
      'Licząc oszczędności widzisz namacalny dowód, że trzeźwość się opłaca — dosłownie.'),
  _Lesson('Nudza — ukryty trigger #1', '🥱', 2,
      'Nuda jest jednym z najczęstszych, a zarazem najczęściej ignorowanych triggerów. Dlaczego?\n\nSubstancje sztucznie stymulują układ nagrody. Bez nich „normalne" aktywności wydają się nijakie. To anhedonia — tymczasowa niezdolność do odczuwania przyjemności z codziennych rzeczy.\n\nCo robić:\n• Zrób listę 20 rzeczy, które możesz zrobić zamiast (miej ją w telefonie)\n• Flow state: znajdź aktywność tak angażującą, że tracisz poczucie czasu\n• Zaakceptuj nudę: nie każda minuta musi być wypełniona\n• Naucz się czegoś nowego: instrument, język, gotowanie\n• Pomagaj innym: wolontariat zabija nudę i buduje sens\n\nAnhedonia mija. Po 3-6 miesiącach trzeźwości mózg przywraca naturalne receptory dopaminy i „normalne" czynności znów dają radość.',
      'Nuda to tymczasowa anhedonia. Mija z czasem. Miej listę 20 alternatyw w telefonie.'),
  _Lesson('Wdzięczność jako narzędzie', '🙏', 2,
      'Wdzięczność to nie banalny slogan z Instagrama. To neurologicznie udowodnione narzędzie regulacji emocji.\n\nCo mówi nauka:\n• Wdzięczność aktywuje prefrontal cortex i nucleus accumbens — te same obszary, które osłabło uzależnienie\n• Regularna praktyka wdzięczności zwiększa produkcję serotoniny i dopaminy — naturalnie\n• Zmniejsza kortyzol (hormon stresu) o 23%\n\nPraktyka:\n• Codzienne 3 rzeczy w check-inie (pole \"Za co jesteś dziś wdzięczny?\")\n• List do kogoś, kto Ci pomógł (nie musisz go wysyłać)\n• \"Cicha wdzięczność\": zauważ jedną dobrą rzecz w tej chwili\n\nTo nie jest ignorowanie problemów. To poszerzanie perspektywy — widzisz trudne I dobre jednocześnie.',
      'Wdzięczność zmienia mózg na poziomie neurochemicznym. 3 rzeczy dziennie wystarczą.'),
];

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/theme.dart';
import '../l10n/strings.dart';
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
      appBar: AppBar(title: Text(S.t(context, 'miniLessons'))),
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
    final lang = Localizations.localeOf(context).languageCode;
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
              Text(lesson.localTitle(lang), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('~${lesson.readMinutes} ${S.t(context, 'min')}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              Text(lesson.localContent(lang), style: const TextStyle(fontSize: 15, height: 1.7, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              if (lesson.keyTakeaway.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.t(context, 'keyTakeaway'), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(lesson.localTakeaway(lang), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
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
                  child: Text(S.t(context, 'readCheck')),
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
                  Text(Localizations.localeOf(context).languageCode == 'pl' ? lesson.title : lesson.titleEn, style: TextStyle(color: locked ? AppColors.textSecondary : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                  Text('${lesson.emoji}  ~${lesson.readMinutes} ${S.t(context, 'min')}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (locked) Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(S.t(context, 'pro'), style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Lesson {
  final String title;
  final String titleEn;
  final String emoji;
  final int readMinutes;
  final String content;
  final String contentEn;
  final String keyTakeaway;
  final String keyTakeawayEn;
  const _Lesson(this.title, this.titleEn, this.emoji, this.readMinutes, this.content, this.contentEn, this.keyTakeaway, this.keyTakeawayEn);
  String localTitle(String lang) => lang == 'pl' ? title : titleEn;
  String localContent(String lang) => lang == 'pl' ? content : contentEn;
  String localTakeaway(String lang) => lang == 'pl' ? keyTakeaway : keyTakeawayEn;
}

const _lessons = [
  // FREE (0-6)
  _Lesson('Jak działa uzależnienie na mózg', 'How Addiction Works in the Brain', '🧠', 2,
      'Uzależnienie to choroba mózgu, nie brak silnej woli. Substancje psychoaktywne zalewają układ nagrody dopaminą — neuroprzekaźnikiem odpowiedzialnym za przyjemność. Przy regularnym używaniu mózg adaptuje się: zmniejsza liczbę receptorów dopaminy, co oznacza, że potrzebujesz coraz więcej substancji, by poczuć to samo (tolerancja).\n\nJednocześnie kora przedczołowa — odpowiedzialna za podejmowanie decyzji, kontrolę impulsów i planowanie — traci swoją skuteczność. To dlatego wiesz, że powinieneś przestać, ale ciało robi swoje.\n\nDobra wiadomość: mózg jest plastyczny. Abstynencja pozwala na odbudowę receptorów i wzmocnienie kory przedczołowej. Po 90 dniach zmiany są mierzalne na skanach mózgu.',
      'Addiction is a brain disease, not a lack of willpower. Psychoactive substances flood the reward system with dopamine — the neurotransmitter responsible for pleasure. With regular use, the brain adapts: it reduces dopamine receptors, meaning you need more and more to feel the same effect (tolerance).

At the same time, the prefrontal cortex — responsible for decision-making, impulse control, and planning — loses its effectiveness. That’s why you know you should stop, but your body does its own thing.

Good news: the brain is plastic. Abstinence allows receptors to rebuild and the prefrontal cortex to strengthen. After 90 days, changes are measurable on brain scans.',
      'Uzależnienie zmienia mózg fizycznie, ale abstynencja pozwala mu się odbudować.',
      'Addiction physically changes the brain, but abstinence allows it to rebuild.'),
  _Lesson('Co to jest PAWS?', 'What Is PAWS?', '🌊', 2,
      'PAWS (Post-Acute Withdrawal Syndrome) to zespół objawów poabstynencyjnych, który pojawia się po ostrej fazie odstawienia. Może trwać tygodnie, miesiące, a nawet do 2 lat.\n\nObjawy PAWS:\n• Wahania nastroju bez wyraźnej przyczyny\n• Problemy ze snem\n• Trudności z koncentracją\n• Lęk i drażliwość\n• Niska energia\n• Nagłe fale craving\n\nPAWS przychodzi falami — możesz mieć świetny tydzień, a potem nagle 3 ciężkie dni. To normalne i NIE oznacza, że coś jest nie tak. To mózg się kalibruje.\n\nCo pomaga: regularny sen, ćwiczenia, nawodnienie, unikanie stresu, akceptacja że to przejściowe.',
      'PAWS (Post-Acute Withdrawal Syndrome) is a set of post-abstinence symptoms that appear after the acute withdrawal phase. It can last weeks, months, or even up to 2 years.

PAWS symptoms:
• Mood swings without obvious cause
• Sleep problems
• Difficulty concentrating
• Anxiety and irritability
• Low energy
• Sudden craving waves

PAWS comes in waves — you can have a great week, then suddenly 3 hard days. This is normal and does NOT mean something is wrong. The brain is calibrating.',
      'PAWS to normalna część procesu. Przychodzi falami i każda fala jest krótsza od poprzedniej.',
      'PAWS is a normal part of the process. It comes in waves and each wave is shorter than the last.'),
  _Lesson('Pierwszych 72 godzin', 'The First 72 Hours', '⏰', 2,
      'Pierwsze 3 dni to najtrudniejszy fizycznie okres abstynencji. Ciało dosłownie protestuje przeciwko brakowi substancji.\n\nCo się dzieje:\n• 6-12h: Lęk, drżenie rąk, pocenie się, bezsenność\n• 12-24h: Szczyt objawów fizycznych\n• 24-48h: Zmęczenie, wahania nastroju, bóle głowy\n• 48-72h: Objawy zaczynają słabnąć\n\nWAŻNE: Odstawienie alkoholu może być niebezpieczne medycznie. Jeśli piłeś dużo i regularnie, skonsultuj się z lekarzem przed odstawieniem.\n\nCo robić:\n• Pij dużo wody\n• Jedz regularnie (nawet jeśli nie chcesz)\n• Nie bądź sam\n• Jeśli objawy są silne — szukaj pomocy medycznej\n\nPo 72h najtrudniejsze za Tobą. Fizycznie robi się łatwiej z każdym dniem.',
      'The first 3 days are the most physically difficult period of abstinence. The body literally recalibrates.

What to expect:
• Hours 6–12: Anxiety, tremors, sweating, insomnia
• Hours 12–24: Symptoms peak. This is the hardest moment.
• Hours 24–48: Gradual improvement. The body begins to stabilize.
• Hours 48–72: Most physical symptoms subside.

After 72 hours, physical symptoms weaken. If you’re stopping alcohol after heavy drinking — consult a doctor. Alcohol withdrawal can be dangerous.',
      'Po 72 godzinach fizyczne objawy słabną. Jeśli odstawiasz alkohol po ciężkim piciu — skonsultuj się z lekarzem.',
      'The first 72 hours are the hardest. After that, the body begins to heal.'),
  _Lesson('Czym jest craving i jak go surfować', 'What Is Craving and How to Surf It', '🏄', 2,
      'Craving (głód substancji) to intensywna potrzeba użycia. Przychodzi jak fala — narasta, osiąga szczyt i opada. Przeciętny craving trwa 15-30 minut.\n\n„Surfing" polega na obserwowaniu cravingu bez reagowania na niego. Wyobraź sobie, że siedzisz na desce surfingowej i pozwalasz fali przejść pod Tobą.\n\nTechnika STOP:\n• S — Stop. Zatrzymaj się.\n• T — Take a breath. Weź 3 głębokie oddechy.\n• O — Observe. Obserwuj co czujesz w ciele.\n• P — Proceed. Podejmij świadomą decyzję.\n\nKażdy przesurfowany craving wzmacnia ścieżki neuronowe samokontroli. Z czasem cravings stają się słabsze i rzadsze.',
      'Craving (substance hunger) is an intense urge to use. It comes like a wave — it builds, peaks, and subsides. The average craving lasts 15–30 minutes.

“Surfing” means observing the craving without reacting to it. Imagine sitting on a surfboard and letting the wave pass beneath you.

The STOP technique:
• S — Stop. Pause.
• T — Take a breath. Take 3 deep breaths.
• O — Observe. Notice what you feel in your body.
• P — Proceed. Make a conscious decision.

Every surfed craving strengthens the neural pathways of self-control. Over time, cravings become weaker and less frequent.',
      'Craving jest jak fala — trwa 15-30 minut i zawsze mija. Nie musisz walczyć, wystarczy przeczekać.',
      'Craving is like a wave — it lasts 15–30 minutes and always passes. You don’t have to fight it, just ride it.'),
  _Lesson('Trigger — rozpoznaj wroga', 'Trigger — Know Your Enemy', '🎯', 2,
      'Trigger to bodziec, który uruchamia chęć użycia. Mogą być wewnętrzne (emocje) i zewnętrzne (sytuacje).\n\nNajczęstsze triggery:\n• Stres i lęk\n• Samotność i nuda\n• Miejsca gdzie używałeś\n• Ludzie z którymi używałeś\n• Piątkowy wieczór / weekend\n• Pory roku (święta, lato)\n• Sukcesy (! — "zasłużyłem")\n• Złość i frustracja\n\nPlan działania:\n1. Identyfikuj — zapisuj każdy trigger w check-inie\n2. Unikaj — na początku unikaj sytuacji high-risk\n3. Radzij sobie — miej plan B na każdy trigger\n4. Analizuj — po miesiącu zobacz wzorce\n\nŚwiadomość triggera to połowa sukcesu.',
      'A trigger is a stimulus that activates the urge to use. They can be internal (emotions) and external (places, people, situations).

Common triggers:
• Stress and anxiety
• Boredom
• Loneliness
• Specific places (bar, old friends)
• Anger and frustration

Action plan:
1. Identify — write down every trigger you notice
2. Analyze — what emotion precedes it?
3. Plan — what will you do instead when this trigger appears?

Track triggers consistently. Patterns will emerge after 2–3 weeks.',
      'Zapisuj triggery konsekwentnie. Wzorce ujawnią się po 2-3 tygodniach.',
      'Track triggers consistently. Patterns will emerge after 2–3 weeks.'),
  _Lesson('Sen w trzeźwości', 'Sleep in Sobriety', '😴', 2,
      'Uzależnienie niszczy architekturę snu. Alkohol np. pomaga zasnąć, ale eliminuje fazę REM — tę odpowiedzialną za przetwarzanie emocji i pamięć.\n\nPo odstawieniu sen jest często okropny przez pierwsze 1-4 tygodnie. To normalne.\n\nJak poprawić sen w trzeźwości:\n• Stała pora wstawania (nawet w weekend)\n• Żadnych ekranów 30 min przed snem\n• Chłodna sypialnia (18-20°C)\n• Magnez przed snem\n• 4-7-8 oddychanie: wdech 4s, wstrzymaj 7s, wydech 8s\n• Ruch w ciągu dnia (nie przed snem)\n\nPo 2-4 tygodniach abstynencji sen staje się głębszy i bardziej regenerujący niż kiedykolwiek podczas używania.',
      'Addiction destroys sleep architecture. Alcohol, for example, helps you fall asleep but eliminates deep REM sleep — the phase responsible for emotional processing and memory consolidation.

In early sobriety:
• Insomnia is common (weeks 1–4)
• Vivid, intense dreams (the brain processes suppressed emotions)
• Fatigue despite sleeping

What helps:
• Consistent sleep schedule (same time every day)
• No screens 1 hour before bed
• Cool, dark room
• Magnesium glycinate (consult a doctor)
• Light exercise during the day',
      'Zły sen na początku to norma. Po 2-4 tygodniach będziesz spać lepiej niż kiedykolwiek.',
      'Poor sleep at the start is normal. After 2–4 weeks you’ll sleep better than ever.'),
  _Lesson('Budowanie nowych nawyków', 'Building New Habits', '🔄', 2,
      'Uzależnienie to nawyk — potężny, ale wciąż nawyk. Nie wystarczy usunąć stary; trzeba zbudować nowy.\n\nPętla nawyku: Sygnał → Rutyna → Nagroda\n\nPrzykład starego: Piątek 18:00 (sygnał) → Piwo (rutyna) → Relaks (nagroda)\nNowy: Piątek 18:00 (sygnał) → Bieganie (rutyna) → Endorfiny (nagroda)\n\nKlucz: zachowaj ten sam sygnał i nagrodę, zmień tylko rutynę.\n\nZasada 2 minut: Nowy nawyk powinien zaczynać się od czegoś tak łatwego, że trwa max 2 minuty. „Będę biegać 30 min" → „Założę buty do biegania". Reszta przyjdzie.\n\nStack nawyków: Połącz nowy nawyk z istniejącym. „Po porannej kawie zrobię 5 pompek." „Po check-inie w SoberSteps przeczytam 1 stronę."',
      'Addiction is a habit — powerful, but still a habit. It’s not enough to remove the old one; you need to replace it with something that gives a similar reward.

The habit loop: Trigger → Routine → Reward

Your task: keep the trigger and reward, change the routine.

Examples:
• Stress (trigger) → run instead of drink (routine) → relief (reward)
• Evening boredom (trigger) → read/journal (routine) → relaxation (reward)

Habit stacking: Link a new habit to an existing one. "After my morning coffee, I meditate for 5 minutes." Start with one. The rest will follow.',
      'Nie usuwaj starego nawyku — zastąp go nowym z tą samą nagrodą.',
      'Don\'t remove the old habit — replace it with a new one that gives the same reward.'),
  // PRO (7+)
  _Lesson('Relacje w trzeźwości', 'Relationships in Sobriety', '❤️', 3,
      'Trzeźwość zmienia każdą relację. Niektóre rozkwitają, inne się kończą — i obie opcje są OK.\n\nFazy zmian relacyjnych:\n\n1. Szok i opór (0-30 dni): Bliscy mogą nie wierzyć, testować Cię, a nawet sabotować. Ludzie z którymi piłeś mogą poczuć się zagrożeni Twoją zmianą.\n\n2. Reorganizacja (1-6 miesięcy): Uczysz się od nowa: jak się bawić, jak rozmawiać, jak radzić sobie z konfliktem bez substancji. To niezręczne. To normalne.\n\n3. Głębia (6+ miesięcy): Relacje stają się prawdziwsze. Uczysz się granic, komunikacji, wrażliwości.\n\nTrudne prawdy:\n• Nie wszyscy będą Cię wspierać\n• Niektóre przyjaźnie przetrwają tylko w barze\n• Partner/ka może nie rozpoznać nowej wersji Ciebie\n\nPomoc:\n• Terapia par, jeśli jesteś w związku\n• Spotkania AA/NA/SMART dla budowania nowej sieci\n• Sponsor lub accountability partner',
      'Sobriety changes every relationship. Some flourish, others end — and both outcomes are okay.

What changes:
• Relationships built around drinking/using often fall apart
• Family relationships can heal — but it takes time
• New, deeper connections form

Difficult truths:
• Some people won’t understand your sobriety
• You may need to distance yourself from certain people
• Loneliness is normal in early recovery

What helps:
• Sober community (meetings, apps, groups)
• Honest communication about your needs
• Patience — trust rebuilds slowly',
      'Trzeźwość ujawnia prawdę o relacjach. To bolesne, ale prowadzi do głębszych połączeń.',
      'Sobriety reveals the truth about relationships. It’s painful, but leads to deeper connections.'),
  _Lesson('Samotność vs bycie samemu', 'Loneliness vs Being Alone', '🏔️', 2,
      'Samotność to najsilniejszy trigger nawrotów. Ale jest różnica między byciem samemu a samotnością.\n\nBycie samemu = wybór. Czas z sobą, refleksja, regeneracja.\nSamotność = poczucie odcięcia nawet wśród ludzi.\n\nW uzależnieniu często otaczamy się ludźmi, ale jesteśmy samotni. W trzeźwości możemy być sami, ale czuć się połączeni.\n\nPlan na samotność:\n• Miej listę 3 osób, do których możesz zadzwonić o każdej porze\n• Pisz na 3 AM Wall — nie jesteś sam\n• Chodź na spotkania (nawet online)\n• Wolontariat — pomaganie innym leczy samotność\n• Przyjmij, że samotność to emocja, nie fakt. Przejdzie jak craving.',
      'Loneliness is the strongest trigger for relapse. But there’s a difference between being alone and loneliness.

Being alone = choice. Time with yourself, reflection, regeneration.
Loneliness = feeling cut off even among people.

In addiction we often surround ourselves with people but feel lonely. In sobriety we can be alone but feel connected.

Plan for loneliness:
• Have a list of 3 people you can call at any time
• Write on the 3 AM Wall — you’re not alone
• Go to meetings (even online)
• Volunteer — helping others heals loneliness
• Accept that loneliness is an emotion, not a fact. It will pass like a craving.',
      'Samotność to emocja, nie rzeczywistość. Masz 3 AM Wall i całą społeczność.',
      'Loneliness is an emotion, not reality. You have the 3 AM Wall and the whole community.'),
  _Lesson('Nawrót nie jest porażką', 'Relapse Is Not Failure', '🔁', 2,
      'Nawrót (relapse) jest częścią procesu zdrowienia dla wielu osób. To NIE jest powód do wstydu ani porażka.\n\nModel nawrotu Marlatta:\n1. Nawrót emocjonalny (tygodnie wcześniej): izolacja, tłumienie emocji, zaniedbywanie siebie\n2. Nawrót mentalny (dni wcześniej): fantazjowanie o używaniu, myślenie "jeden raz", planowanie\n3. Nawrót fizyczny: użycie substancji\n\nJeśli doszło do nawrotu:\n• Natychmiast zatrzymaj się — jeden raz nie musi stać się ciągiem\n• Zadzwoń do kogoś: sponsor, przyjaciel, linia kryzysowa\n• Nie usuwaj aplikacji. Zresetuj licznik. Zacznij od zera — z doświadczeniem\n• Zapytaj się: co było triggerem? Czego mogę się nauczyć?\n\nKażdy dzień trzeźwości się liczy — nawet jeśli nie są po kolei.',
      'Relapse is part of the recovery process for many people. It is NOT a reason for shame or failure.

Marlatt’s relapse model:
1. Emotional relapse (weeks before): isolation, suppressing emotions, neglecting yourself
2. Mental relapse (days before): fantasizing about using, thinking "just once", planning
3. Physical relapse: substance use

If relapse happened:
• Stop immediately — once doesn’t have to become a binge
• Call someone: sponsor, friend, crisis line
• Don’t delete the app. Reset the counter. Start from zero — with experience
• Ask yourself: what was the trigger? What can I learn?',
      'Nawrót to informacja, nie wyrok. Najważniejsze co robisz następnego dnia.',
      'Relapse is information, not a verdict. What matters most is what you do the next day.'),
  _Lesson('Gniew i frustracja bez substancji', 'Anger and Frustration Without Substances', '😤', 2,
      'Wiele osób pije/używa, żeby stłumić gniew. Bez substancji emocje wracają ze zdwojoną siłą.\n\nDlaczego gniew jest taki silny w trzeźwości:\n• Lata tłumionych emocji wracają\n• Mózg uczy się od nowa regulacji emocji\n• Frustracja z powodu trudności trzeźwości\n\nZdrowe sposoby na gniew:\n• Ruch fizyczny: bieg, boks, pompki\n• Lodowa technika: trzymaj kostkę lodu w dłoni — ból odwraca uwagę od gniewu\n• Journaling: napisz list do osoby, na którą się gniewasz (nie wysyłaj)\n• 5-4-3-2-1: Znajdź 5 rzeczy, które widzisz, 4 słyszysz, 3 czujesz, 2 wąchasz, 1 smakujesz\n• Box breathing: 4s wdech, 4s pauza, 4s wydech, 4s pauza',
      'Many people drink/use to suppress anger. Without substances, emotions return with double force.

Why anger is so strong in sobriety:
• Years of suppressed emotions return
• The brain relearns emotional regulation
• Frustration from the difficulties of sobriety

Healthy ways to handle anger:
• Physical movement: running, boxing, push-ups
• Ice technique: hold an ice cube in your hand — the pain redirects attention from anger
• Journaling: write a letter to the person you’re angry at (don’t send it)
• 5-4-3-2-1: Find 5 things you see, 4 you hear, 3 you feel, 2 you smell, 1 you taste
• Box breathing: 4s inhale, 4s pause, 4s exhale, 4s pause',
      'Gniew to normalna emocja. Problem nie jest w czuciu go, a w tym co z nim robisz.',
      'Anger is a normal emotion. The problem isn’t feeling it, but what you do with it.'),
  _Lesson('Finanse po uzależnieniu', 'Finances After Addiction', '💰', 2,
      'Uzależnienie to nie tylko problem zdrowotny — to finansowa katastrofa. Średni alkoholik wydaje \$10,000-\$15,000 rocznie na alkohol. Narkotyki — znacznie więcej.\n\nPo odstawieniu:\n\n1. Natychmiast: Przestań wydawać na substancję. Zacznij śledzić ile oszczędzasz (zakładka Oszczędności w SoberSteps).\n\n2. Miesiąc 1: Oceń szkody — długi, nieopłacone rachunki, stracone możliwości.\n\n3. Miesiąc 2-6: Budżet. Każda zaoszczędzona złotówka/dolar idzie na: spłatę długów (50%), fundusz awaryjny (30%), nagrody za trzeźwość (20%).\n\n4. Rok 1+: Inwestuj w siebie: kurs, terapia, hobby, podróże — to nagrody, które nie kradną jutrzejszego dnia.',
      'Addiction is not just a health problem — it’s a financial disaster. The average alcoholic spends $10,000–$15,000 a year on alcohol. Drugs — much more.

After quitting:

1. Immediately: Stop spending on the substance. Start tracking how much you’re saving (Savings tab in SoberSteps).

2. Month 1: Assess the damage — debts, unpaid bills, lost opportunities.

3. Months 2–6: Budget. Every saved dollar goes to: debt repayment (50%), emergency fund (30%), sobriety rewards (20%).

4. Year 1+: Invest in yourself: course, therapy, hobby, travel — rewards that don’t steal tomorrow.',
      'Licząc oszczędności widzisz namacalny dowód, że trzeźwość się opłaca — dosłownie.',
      'Counting your savings gives you tangible proof that sobriety pays off — literally.'),
  _Lesson('Nudza — ukryty trigger #1', 'Boredom — The Hidden Trigger #1', '🥱', 2,
      'Nuda jest jednym z najczęstszych, a zarazem najczęściej ignorowanych triggerów. Dlaczego?\n\nSubstancje sztucznie stymulują układ nagrody. Bez nich „normalne" aktywności wydają się nijakie. To anhedonia — tymczasowa niezdolność do odczuwania przyjemności z codziennych rzeczy.\n\nCo robić:\n• Zrób listę 20 rzeczy, które możesz zrobić zamiast (miej ją w telefonie)\n• Flow state: znajdź aktywność tak angażującą, że tracisz poczucie czasu\n• Zaakceptuj nudę: nie każda minuta musi być wypełniona\n• Naucz się czegoś nowego: instrument, język, gotowanie\n• Pomagaj innym: wolontariat zabija nudę i buduje sens\n\nAnhedonia mija. Po 3-6 miesiącach trzeźwości mózg przywraca naturalne receptory dopaminy i „normalne" czynności znów dają radość.',
      'Boredom is one of the most common yet most ignored triggers. Why?

Substances artificially stimulate the reward system. Without them, "normal" activities seem dull. This is anhedonia — a temporary inability to feel pleasure from everyday things.

What to do:
• Make a list of 20 things you can do instead (keep it in your phone)
• Flow state: find an activity so engaging you lose track of time
• Accept boredom: not every minute needs to be filled
• Learn something new: instrument, language, cooking
• Help others: volunteering kills boredom and builds meaning

Anhedonia passes. After 3–6 months of sobriety the brain restores natural dopamine receptors and "normal" activities bring joy again.',
      'Nuda to tymczasowa anhedonia. Mija z czasem. Miej listę 20 alternatyw w telefonie.',
      'Boredom is temporary anhedonia. It passes with time. Keep a list of 20 alternatives in your phone.'),
  _Lesson('Wdzięczność jako narzędzie', 'Gratitude as a Tool', '🙏', 2,
      'Wdzięczność to nie banalny slogan z Instagrama. To neurologicznie udowodnione narzędzie regulacji emocji.\n\nCo mówi nauka:\n• Wdzięczność aktywuje prefrontal cortex i nucleus accumbens — te same obszary, które osłabło uzależnienie\n• Regularna praktyka wdzięczności zwiększa produkcję serotoniny i dopaminy — naturalnie\n• Zmniejsza kortyzol (hormon stresu) o 23%\n\nPraktyka:\n• Codzienne 3 rzeczy w check-inie (pole "Za co jesteś dziś wdzięczny?")\n• List do kogoś, kto Ci pomógł (nie musisz go wysyłać)\n• "Cicha wdzięczność": zauważ jedną dobrą rzecz w tej chwili\n\nTo nie jest ignorowanie problemów. To poszerzanie perspektywy — widzisz trudne I dobre jednocześnie.',
      'Gratitude is not a cliché Instagram slogan. It’s a neurologically proven tool for emotional regulation.

What science says:
• Gratitude activates the prefrontal cortex and nucleus accumbens — the same areas weakened by addiction
• Regular gratitude practice increases serotonin and dopamine production — naturally
• Reduces cortisol (stress hormone) by 23%

Practice:
• Daily 3 things in check-in (the "What are you grateful for today?" field)
• Letter to someone who helped you (you don’t have to send it)
• "Silent gratitude": notice one good thing right now

This isn’t ignoring problems. It’s broadening perspective — seeing the difficult AND the good simultaneously.',
      'Wdzięczność zmienia mózg na poziomie neurochemicznym. 3 rzeczy dziennie wystarczą.',
      'Gratitude changes the brain at the neurochemical level. 3 things a day is enough.'),
];


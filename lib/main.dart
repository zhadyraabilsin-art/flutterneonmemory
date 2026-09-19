import 'package:flutter/material.dart';

void main() {
  runApp(const NeonMemoryApp());
}

class NeonMemoryApp extends StatelessWidget {
  const NeonMemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neon Memory Match',
      theme: ThemeData.dark(useMaterial3: true),
      home: const MemoryGameScreen(),
    );
  }
}

class MemoryCardItem {
  final IconData icon;
  final Color color;
  bool isFlipped;
  bool isMatched;

  MemoryCardItem({
    required this.icon,
    required this.color,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late List<MemoryCardItem> _cards;
  int? _firstSelectedIndex;
  bool _isChecking = false;
  int _moves = 0;
  int _matches = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final basePairs = [
      (Icons.rocket_launch, Colors.cyanAccent),
      (Icons.bolt, Colors.amberAccent),
      (Icons.favorite, Colors.pinkAccent),
      (Icons.diamond, Colors.purpleAccent),
      (Icons.local_fire_department, Colors.deepOrangeAccent),
      (Icons.eco, Colors.greenAccent),
      (Icons.star, Colors.yellowAccent),
      (Icons.music_note, Colors.lightBlueAccent),
    ];

    final deck = <MemoryCardItem>[];
    for (final pair in basePairs) {
      deck.add(MemoryCardItem(icon: pair.$1, color: pair.$2));
      deck.add(MemoryCardItem(icon: pair.$1, color: pair.$2));
    }
    deck.shuffle();

    setState(() {
      _cards = deck;
      _firstSelectedIndex = null;
      _isChecking = false;
      _moves = 0;
      _matches = 0;
    });
  }

  void _onCardTap(int index) {
    if (_isChecking || _cards[index].isFlipped || _cards[index].isMatched)
      return;

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _moves++;
      final firstIndex = _firstSelectedIndex!;
      _firstSelectedIndex = null;

      if (_cards[firstIndex].icon == _cards[index].icon) {
        setState(() {
          _cards[firstIndex].isMatched = true;
          _cards[index].isMatched = true;
          _matches++;
        });
      } else {
        _isChecking = true;
        Future.delayed(const Duration(milliseconds: 650), () {
          if (!mounted) return;
          setState(() {
            _cards[firstIndex].isFlipped = false;
            _cards[index].isFlipped = false;
            _isChecking = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWon = _matches == 8;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'NEON MEMORY',
          style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statBox('MOVES', '$_moves', Colors.cyanAccent),
                _statBox('MATCHES', '$_matches / 8', Colors.greenAccent),
              ],
            ),
            const SizedBox(height: 24),
            if (isWon)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.greenAccent),
                ),
                child: Text(
                  'Completed in $_moves moves! 🎉',
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cards.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemBuilder: (ctx, index) {
                      final card = _cards[index];
                      final showFace = card.isFlipped || card.isMatched;

                      return GestureDetector(
                        onTap: () => _onCardTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          decoration: BoxDecoration(
                            color: showFace
                                ? const Color(0xFF1A2033)
                                : const Color(0xFF131726),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: card.isMatched
                                  ? Colors.greenAccent
                                  : (showFace ? card.color : Colors.white12),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: showFace
                                ? Icon(card.icon, color: card.color, size: 34)
                                : const Icon(
                                    Icons.question_mark,
                                    color: Colors.white24,
                                    size: 26,
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _initGame,
              icon: const Icon(Icons.shuffle),
              label: const Text('Restart & Shuffle'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.purpleAccent.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

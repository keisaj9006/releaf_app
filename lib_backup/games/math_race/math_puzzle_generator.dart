import 'dart:math';

enum Difficulty { easy, medium, hard }
enum MissingSlot { a, b, res }

class MathPuzzle {
  final int a;
  final int b;
  final String op; // "+", "-", "×", "÷", "^", "%"
  final int res;
  final MissingSlot missing;
  final int correctAnswer;
  final List<int> options;

  MathPuzzle({
    required this.a,
    required this.b,
    required this.op,
    required this.res,
    required this.missing,
    required this.correctAnswer,
    required this.options,
  });
}

class MathPuzzleGenerator {
  final Random _rng = Random();

  /// Generuje zadanie na podstawie poziomu gry.
  /// Poziomy:
  ///  1–10: +,-
  /// 11–20: +,-,×,÷
  /// 21–30: +,-,×,÷,^   (potęgi – tylko brakujące 'res')
  /// 31–40+: +,-,×,÷,%  (procenty – tylko brakujące 'res')
  MathPuzzle generateForLevel({required int level}) {
    // progi operatorów
    List<String> ops;
    if (level <= 10) {
      ops = ['+', '-'];
    } else if (level <= 20) {
      ops = ['+', '-', '×', '÷'];
    } else if (level <= 30) {
      ops = ['+', '-', '×', '÷', '^'];
    } else {
      ops = ['+', '-', '×', '÷', '%'];
    }

    // zakresy liczb rosną z poziomem
    final baseMax = level <= 10 ? 10 : level <= 20 ? 20 : 50;
    final op = ops[_rng.nextInt(ops.length)];

    int a, b, res;

    // budowa równania
    if (op == '+') {
      a = _rng.nextInt(baseMax) + 1;
      b = _rng.nextInt(baseMax) + 1;
      res = a + b;
    } else if (op == '-') {
      a = _rng.nextInt(baseMax) + 1;
      b = _rng.nextInt(baseMax) + 1;
      if (b > a) {
        final t = a; a = b; b = t;
      }
      res = a - b;
    } else if (op == '×') {
      a = _rng.nextInt(max(2, baseMax ~/ 2)) + 1;
      b = _rng.nextInt(max(2, baseMax ~/ 2)) + 1;
      res = a * b;
    } else if (op == '÷') {
      // a = q * b, res = q (iloraz całkowity)
      final q = _rng.nextInt(max(2, baseMax ~/ 2) - 1) + 2;
      b = _rng.nextInt(max(2, baseMax ~/ 2) - 1) + 2;
      a = q * b;
      res = q;
    } else if (op == '^') {
      // małe potęgi, by wynik był sensowny
      a = _rng.nextInt(5) + 2;  // podstawa 2..6
      b = _rng.nextInt(3) + 2;  // wykładnik 2..4
      res = _intPow(a, b);
    } else { // '%'
      // "a% of b = res" – b wielokrotność 100, a wielokrotność 5
      a = (_rng.nextInt(19) + 1) * 5;           // 5..100
      b = (_rng.nextInt(15) + 1) * 100;         // 100..1600
      res = (a * b) ~/ 100;                     // całkowite
    }

    // jakie pole może być brakujące
    final allowedMissing = (op == '^' || op == '%')
        ? [MissingSlot.res] // dla uproszczenia tylko wynik
        : [MissingSlot.a, MissingSlot.b, MissingSlot.res];

    final missing = allowedMissing[_rng.nextInt(allowedMissing.length)];
    final correct = switch (missing) {
      MissingSlot.a => _solveForA(b, res, op),
      MissingSlot.b => _solveForB(a, res, op),
      MissingSlot.res => res,
    };

    if (correct <= 0) {
      // jeżeli wyszło niepoprawnie, spróbuj jeszcze raz
      return generateForLevel(level: level);
    }

    // 4 opcje – 1 poprawna + 3 mylące
    final options = <int>{correct};
    while (options.length < 4) {
      final delta = _rng.nextInt(8) + 1;
      final cand = _rng.nextBool()
          ? correct + delta
          : max(1, correct - delta);
      options.add(cand);
    }
    final shuffled = options.toList()..shuffle(_rng);

    return MathPuzzle(
      a: a,
      b: b,
      op: op,
      res: res,
      missing: missing,
      correctAnswer: correct,
      options: shuffled,
    );
  }

  int _intPow(int a, int b) {
    var r = 1;
    for (var i = 0; i < b; i++) r *= a;
    return r;
  }

  int _solveForA(int b, int res, String op) {
    switch (op) {
      case '+': return res - b;        // ? + b = res
      case '-': return res + b;        // ? - b = res
      case '×': return res * b;        // ? × b = res
      case '÷': return res * b;        // ? ÷ b = res
      case '^': return 0;              // nie używamy (tylko res)
      case '%': return 0;              // nie używamy (tylko res)
      default:  return 0;
    }
  }

  int _solveForB(int a, int res, String op) {
    switch (op) {
      case '+': return res - a;        // a + ? = res
      case '-': return a - res;        // a - ? = res
      case '×':
        if (a == 0) return 0;
        return res ~/ a;               // a × ? = res
      case '÷':
        if (res == 0) return a;
        return a ~/ res;               // a ÷ ? = res
      case '^': return 0;              // nie używamy (tylko res)
      case '%': return 0;              // nie używamy (tylko res)
      default:  return 0;
    }
  }
}

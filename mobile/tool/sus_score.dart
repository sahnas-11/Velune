// ignore_for_file: avoid_print
import 'dart:io';

/// SUS Score Calculator for HCI Milestone 03 Usability Evaluation.
/// 
/// Evaluates System Usability Scale (SUS) survey data (10 items, 1-5 Likert scale)
/// based on the standard scoring methodology (Brooke, 1996):
///   - Odd-numbered items (1, 3, 5, 7, 9): score - 1
///   - Even-numbered items (2, 4, 6, 8, 10): 5 - score
///   - Total score = sum of converted item scores * 2.5 (0 to 100 range)
void main(List<String> args) {
  final csvPath = args.isNotEmpty 
      ? args[0] 
      : '../docs/testing/hr/sus-responses.csv';

  final file = File(csvPath);
  if (!file.existsSync()) {
    print('SUS Response file not found at: $csvPath');
    print('Usage: dart run tool/sus_score.dart [path_to_csv]');
    exit(1);
  }

  final lines = file.readAsLinesSync().where((line) => line.trim().isNotEmpty).toList();
  if (lines.length <= 1) {
    print('No participant response rows found in $csvPath');
    exit(0);
  }

  print('================================================================');
  print('           VELUNE HR MODULE - SYSTEM USABILITY SCALE            ');
  print('================================================================');
  print('CSV Source: $csvPath');
  print('Loaded ${lines.length - 1} response records.\n');

  final participantScores = <String, double>{};
  double totalAll = 0.0;

  for (int i = 1; i < lines.length; i++) {
    final parts = lines[i].split(',').map((s) => s.trim()).toList();
    if (parts.length < 11) continue;

    final participantId = parts[0];
    final scores = <int>[];
    for (int q = 1; q <= 10; q++) {
      scores.add(int.tryParse(parts[q]) ?? 3);
    }

    double convertedSum = 0;
    for (int q = 0; q < 10; q++) {
      if (q % 2 == 0) {
        // Odd questions (Q1, Q3, Q5, Q7, Q9) -> index 0, 2, 4, 6, 8
        convertedSum += (scores[q] - 1);
      } else {
        // Even questions (Q2, Q4, Q6, Q8, Q10) -> index 1, 3, 5, 7, 9
        convertedSum += (5 - scores[q]);
      }
    }

    final susScore = convertedSum * 2.5;
    participantScores[participantId] = susScore;
    totalAll += susScore;

    print('Participant: ${participantId.padRight(12)} | Raw Items: ${scores.join(", ")} | SUS: ${susScore.toStringAsFixed(1)} / 100');
  }

  if (participantScores.isEmpty) {
    print('No valid participant score records processed.');
    return;
  }

  final meanScore = totalAll / participantScores.length;
  final grade = _getSusGrade(meanScore);
  final adjective = _getSusAdjective(meanScore);

  print('----------------------------------------------------------------');
  print('Total Participants : ${participantScores.length}');
  print('Mean SUS Score     : ${meanScore.toStringAsFixed(2)} / 100');
  print('Letter Grade       : $grade');
  print('Adjective Rating   : $adjective');
  print('Benchmark Standard : 68.0 (Industry Average SUS)');
  if (meanScore >= 80.3) {
    print('Result Assessment  : EXCELLENT (Top 10th percentile usability)');
  } else if (meanScore >= 68.0) {
    print('Result Assessment  : ABOVE AVERAGE (Meets university project criteria)');
  } else {
    print('Result Assessment  : BELOW BENCHMARK (Needs UX improvements)');
  }
  print('================================================================\n');
}

String _getSusGrade(double score) {
  if (score >= 84.1) return 'A+';
  if (score >= 80.8) return 'A';
  if (score >= 78.9) return 'A-';
  if (score >= 77.2) return 'B+';
  if (score >= 74.1) return 'B';
  if (score >= 72.6) return 'B-';
  if (score >= 71.1) return 'C+';
  if (score >= 65.0) return 'C';
  if (score >= 62.7) return 'C-';
  if (score >= 51.7) return 'D';
  return 'F';
}

String _getSusAdjective(double score) {
  if (score >= 85.0) return 'Best Imaginable';
  if (score >= 71.4) return 'Good';
  if (score >= 50.9) return 'OK';
  if (score >= 35.7) return 'Poor';
  return 'Worst Imaginable';
}

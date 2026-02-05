import 'package:flutter/material.dart';
import '../presentation/target_board_widget.dart';
import '../domain/score_display_strategy.dart';

class ScoreSheetWidget extends StatelessWidget {
  final List<List<ShotPoint>> pastEnds;
  final List<ShotPoint> currentEndShots;
  final ScoreDisplayStrategy displayStrategy;

  const ScoreSheetWidget({
    super.key,
    required this.pastEnds,
    required this.currentEndShots,
    required this.displayStrategy,
  });

  @override
  Widget build(BuildContext context) {
    final allEnds = [...pastEnds];
    if (currentEndShots.isNotEmpty) {
      allEnds.add(currentEndShots);
    }

    if (allEnds.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No shots recorded yet'),
        ),
      );
    }

    int cumulativeScore = 0;

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FixedColumnWidth(50), // End #
        1: FlexColumnWidth(),    // Shots
        2: FixedColumnWidth(60), // Subtotal
        3: FixedColumnWidth(70), // Total
      },
      children: [
        _buildHeader(),
        ...allEnds.asMap().entries.map((entry) {
          final index = entry.key;
          final shots = entry.value;
          final subtotal = shots.fold(0, (sum, s) => sum + s.score);
          cumulativeScore += subtotal;

          return _buildRow(index + 1, shots, subtotal, cumulativeScore);
        }),
      ],
    );
  }


  TableRow _buildHeader() {
    return const TableRow(
      decoration: BoxDecoration(color: Colors.grey),
      children: [
        Padding(padding: EdgeInsets.all(8), child: Text('End', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
        Padding(padding: EdgeInsets.all(8), child: Text('Shots', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
        Padding(padding: EdgeInsets.all(8), child: Text('End', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
        Padding(padding: EdgeInsets.all(8), child: Text('Acc', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      ],
    );
  }

  TableRow _buildRow(int endNumber, List<ShotPoint> shots, int subtotal, int acc) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Center(child: Text(endNumber.toString()))),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            children: shots.map((s) => displayStrategy.buildScoreWidget(s.score)).toList(),
          ),
        ),
        Padding(padding: const EdgeInsets.all(8), child: Center(child: Text(subtotal.toString(), style: const TextStyle(fontWeight: FontWeight.bold)))),
        Padding(padding: const EdgeInsets.all(8), child: Center(child: Text(acc.toString(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)))),
      ],
    );
  }
}

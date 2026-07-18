import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:mynextmeal/features/user/user_profile_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/helpers/helper_functions.dart';

class WeightHistoryChart extends StatefulWidget {
  final bool showUpdateButton;

  const WeightHistoryChart({
    super.key,
    this.showUpdateButton = true,
  });

  @override
  State<WeightHistoryChart> createState() => _WeightHistoryChartState();
}

class _WeightHistoryChartState extends State<WeightHistoryChart> {
  //Map is a collection of key-value pairs
  List<Map<String,dynamic>> entries = []; //store weight records

  @override
  void initState() {
    super.initState();
    // Fetch weight history on load
    UserProfileController.instance.fetchWeightHistory();
  }

  @override
  Widget build(BuildContext context) {
    final controller = UserProfileController.instance;
    final dark = AppHelperFunctions.isDarkMode(context);

    return Obx((){
      final entries = controller.weightHistory;

      if(entries.length <= 1){
        return Container(
            height: 160,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF221E19) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
                'No weight history yet',
                style: TextStyle(color: dark ? AppColors.apricotCream200 : AppColors.textSecondary)
            )
        );
      }

      //only displays latest 5 data
      final displayedEntries = entries.length > 5
          ? entries.sublist(entries.length - 5)
          : entries;

      //build chart
      //converts entries list into a map, gives each item an index
      //keys -> indices
      final spots = displayedEntries.asMap().entries.map((e){
        // x-value -> index (sorted from oldest to newest date)
        // y-value -> weight
        return FlSpot(e.key.toDouble(), (e.value['weight'] as double)); //each entry (index + data) converted into FlSpot
      }).toList();

      final weightSpots = spots.map((s) => s.y); //only takes y-value (weight) from FlSpot

      final lowestWeight = weightSpots.reduce(min); //find lowest weight in history
      final highestWeight = weightSpots.reduce(max); //find highest weight in history

      return Container(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF221E19) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dark ? Colors.white.withOpacity(0.08) : AppColors.apricotCream100,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkerGrey.withOpacity(0.01),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: lowestWeight,
                  maxY: highestWeight,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: (dark ? Colors.white : Colors.black).withOpacity(0.06),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (value, meta){
                            return Text(
                              value.toStringAsFixed(1), //one decimal place for y-axis values
                              style: TextStyle(fontSize: 11, color: dark ? AppColors.apricotCream200 : AppColors.textSecondary),
                            );
                          }
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta){
                          final index = value.toInt();
                          if(index < 0 || index >= displayedEntries.length){
                            return const SizedBox();
                          }
                          final date = displayedEntries[index]['date'] as DateTime;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat('d MMM').format(date),
                              style: TextStyle(fontSize: 10, color: dark ? AppColors.apricotCream200 : AppColors.textSecondary),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: AppColors.primary,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true, //show dots on points
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.primary,
                              strokeWidth: 2,
                              strokeColor: dark ? const Color(0xFF221E19) : Colors.white,
                            ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) =>
                      dark ? const Color(0xFF3A3530) : Colors.white,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.toInt(); //index of touched spot (matches index in displayedEntries)
                          final date = displayedEntries[idx]['date'] as DateTime;
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(1)} kg\n${DateFormat('d MMM yyyy').format(date)}',
                            TextStyle(
                              color: dark ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
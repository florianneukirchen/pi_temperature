/*
MIT License

Copyright (c) 2024 Florian Neukirchen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 */

import 'dart:async';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class LiveLineChart extends StatefulWidget {
  const LiveLineChart({super.key});



  @override
  State<LiveLineChart> createState() => _LiveLineChartState();
}

class _LiveLineChartState extends State<LiveLineChart> {
  static const sampleRate = 40; // Milliseconds
  final limitCount = 100;
  final geoPoints = <FlSpot>[];

  double xValue = 0;
  double step = sampleRate / 1000 ; // per Second
  double tickInterval = 5;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: sampleRate), (timer) {
      while (geoPoints.length > limitCount) {
        geoPoints.removeAt(0);
      }
      addPoint(xValue);
      xValue += step;
    });
  }

  void addPoint (x) {
    final appState = Provider.of<MyAppState>(context, listen: false);
    setState(() {
      geoPoints.add(FlSpot(x, appState.getValue()));
    });

  }



  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        '$value',
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    var primaryColor = Theme.of(context).colorScheme.primary;
    return geoPoints.isNotEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Text(
                '${xValue.toStringAsFixed(1)} s',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${geoPoints.last.y.toStringAsFixed(1)} ${appState.getUnit()}',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: LineChart(
                    duration: Duration.zero,
                    LineChartData(
                      minY: 20,
                      maxY: appState.maxValue,
                      minX: geoPoints.first.x,
                      maxX: geoPoints.last.x,
                      lineTouchData: const LineTouchData(enabled: false),
                      clipData: const FlClipData.all(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: tickInterval,
                        getDrawingHorizontalLine: (value) {
                          return const FlLine(
                            color: Colors.black26,
                            strokeWidth: 1,
                          );
                        }
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        geoLine(geoPoints),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: leftTitleWidgets,
                            interval: tickInterval,
                            reservedSize: 32,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        : Container();
  }

  LineChartBarData geoLine(List<FlSpot> points) {
    var primaryColor = Theme.of(context).colorScheme.primary;
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      gradient: LinearGradient(
        colors: [primaryColor.withOpacity(0.5), primaryColor],
        stops: const [0.1, 1.0],
      ),
      barWidth: 3,
      isCurved: true,
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

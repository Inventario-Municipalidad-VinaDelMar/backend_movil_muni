import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TimeSinceWidget extends StatefulWidget {
  final String hora;

  const TimeSinceWidget({Key? key, required this.hora}) : super(key: key);

  @override
  _TimeSinceWidgetState createState() => _TimeSinceWidgetState();
}

class _TimeSinceWidgetState extends State<TimeSinceWidget> {
  late DateTime targetTime;
  late Duration difference;

  @override
  void initState() {
    super.initState();
    targetTime = _parseTime(widget.hora);
    _updateDifference();
    _scheduleFirstUpdate();
  }

  DateTime _parseTime(String timeString) {
    final now = DateTime.now();
    final time = DateFormat('HH:mm').parse(timeString);
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  void _updateDifference() {
    setState(() {
      difference = DateTime.now().difference(targetTime);
    });
  }

  void _scheduleFirstUpdate() {
    final now = DateTime.now();
    final secondsToNextMinute = 60 - now.second;
    final initialDelay = Duration(seconds: secondsToNextMinute);

    Future.delayed(initialDelay, () {
      _updateDifference();
      _scheduleRegularUpdates();
    });
  }

  void _scheduleRegularUpdates() {
    final refreshInterval = difference.inSeconds < 60
        ? const Duration(seconds: 1)
        : const Duration(minutes: 1);

    Future.delayed(refreshInterval, () {
      if (mounted) {
        _updateDifference();
        _scheduleRegularUpdates();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;

    // Descomponemos la duración en horas, minutos y segundos
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Componente de horas
        if (hours > 0) ...[
          AnimatedDigitWidget(
            duration: Duration(milliseconds: 800),
            value: hours,
            textStyle: textStyles.small.copyWith(color: Colors.white),
          ),
          Text(
            hours == 1 ? " hora " : " horas ",
            style: textStyles.small.copyWith(color: Colors.white),
          ),
        ],

        // Componente de minutos
        if (hours > 0 || minutes > 0) ...[
          AnimatedDigitWidget(
            duration: Duration(milliseconds: 800),
            value: minutes,
            textStyle: textStyles.small.copyWith(color: Colors.white),
          ),
          Text(
            minutes == 1 ? " minuto " : " minutos ",
            style: textStyles.small.copyWith(color: Colors.white),
          ),
        ],

        // Componente de segundos (solo si no hay horas ni minutos)
        if (hours == 0 && minutes == 0) ...[
          AnimatedDigitWidget(
            duration: Duration(milliseconds: 800),
            value: seconds,
            textStyle: textStyles.small.copyWith(color: Colors.white),
          ),
          Text(
            seconds == 1 ? " segundo" : " segundos",
            style: textStyles.small.copyWith(color: Colors.white),
          ),
        ],
      ],
    );
  }
}

import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TimeSinceWidget extends StatefulWidget {
  final String horaInicioEnvio;
  final String? horaFinalizacion;

  const TimeSinceWidget({
    super.key,
    required this.horaInicioEnvio,
    this.horaFinalizacion,
  });

  @override
  State<TimeSinceWidget> createState() => _TimeSinceWidgetState();
}

class _TimeSinceWidgetState extends State<TimeSinceWidget> {
  late DateTime targetTime;
  late Duration difference;
  bool disposed = false;

  @override
  void initState() {
    super.initState();
    targetTime = DateTime.parse(widget.horaInicioEnvio);

    if (widget.horaFinalizacion != null) {
      // Si `horaFinalizacion` no es null, calcula la diferencia entre `horaInicioEnvio` y `horaFinalizacion`
      final endTime = DateTime.parse(widget.horaFinalizacion!);
      difference = endTime.difference(targetTime);
    } else {
      // Si `horaFinalizacion` es null, calcula la diferencia con el tiempo actual
      _updateDifference();
      _scheduleFirstUpdate();
    }
  }

  void _updateDifference() {
    if (mounted && !disposed) {
      setState(() {
        difference = DateTime.now().difference(targetTime);
      });
    }
  }

  void _scheduleFirstUpdate() {
    final now = DateTime.now();
    final secondsToNextMinute = 60 - now.second;
    final initialDelay = Duration(seconds: secondsToNextMinute);

    Future.delayed(initialDelay, () {
      if (!disposed) {
        _updateDifference();
        _scheduleRegularUpdates();
      }
    });
  }

  void _scheduleRegularUpdates() {
    final refreshInterval = difference.inSeconds < 60
        ? const Duration(seconds: 1)
        : const Duration(minutes: 1);

    Future.delayed(refreshInterval, () {
      if (mounted && !disposed) {
        _updateDifference();
        _scheduleRegularUpdates();
      }
    });
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;
    Size size = MediaQuery.of(context).size;

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
            textStyle: textStyles.small.copyWith(
              color: Colors.white,
              fontSize: size.height * 0.018,
            ),
          ),
          Text(
            hours == 1 ? " hora " : " horas ",
            style: textStyles.small.copyWith(
              color: Colors.white,
              fontSize: size.height * 0.018,
            ),
          ),
        ],

        // Componente de minutos
        if (hours > 0 || minutes > 0) ...[
          AnimatedDigitWidget(
            duration: Duration(milliseconds: 800),
            value: minutes,
            textStyle: textStyles.small.copyWith(
              color: Colors.white,
              fontSize: size.height * 0.018,
            ),
          ),
          Text(
            minutes == 1 ? " minuto " : " minutos ",
            style: textStyles.small.copyWith(
              color: Colors.white,
              fontSize: size.height * 0.018,
            ),
          ),
        ],

        // Componente de segundos (solo si no hay horas ni minutos)
        if (hours == 0 && minutes == 0) ...[
          AnimatedDigitWidget(
            duration: Duration(milliseconds: 800),
            value: seconds,
            textStyle: textStyles.small.copyWith(
              color: Colors.white,
              fontSize: size.height * 0.018,
            ),
          ),
          Text(
            seconds == 1 ? " segundo" : " segundos",
            style: textStyles.small.copyWith(
              color: Colors.white,
              fontSize: size.height * 0.018,
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TimeSinceWidget extends StatefulWidget {
  final String horaInicioEnvio;
  final String? horaFinalizacion;
  final TextStyle? style;

  const TimeSinceWidget({
    super.key,
    required this.horaInicioEnvio,
    this.horaFinalizacion,
    this.style,
  });

  @override
  State<TimeSinceWidget> createState() => _TimeSinceWidgetState();
}

class _TimeSinceWidgetState extends State<TimeSinceWidget> {
  late DateTime targetTime;
  late Duration difference;
  bool disposed = false;
  bool isStatic = false;

  @override
  void initState() {
    super.initState();
    targetTime = DateTime.parse(widget.horaInicioEnvio);

    if (widget.horaFinalizacion != null) {
      // Si `horaFinalizacion` no es null, calcula la diferencia entre `horaInicioEnvio` y `horaFinalizacion`
      _setStaticDifference();
    } else {
      // Si `horaFinalizacion` es null, calcula la diferencia con el tiempo actual
      _updateDifference();
      _scheduleFirstUpdate();
    }
  }

  @override
  void didUpdateWidget(covariant TimeSinceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.horaFinalizacion != oldWidget.horaFinalizacion) {
      if (widget.horaFinalizacion != null) {
        // Si `horaFinalizacion` se establece, detenemos el temporizador y calculamos la diferencia estática
        _setStaticDifference();
      } else {
        // Si se elimina `horaFinalizacion`, reiniciamos el temporizador
        isStatic = false;
        _updateDifference();
        _scheduleFirstUpdate();
      }
    }
  }

  void _setStaticDifference() {
    final endTime = DateTime.parse(widget.horaFinalizacion!);
    setState(() {
      difference = endTime.difference(targetTime);
      isStatic = true; // Detiene las actualizaciones
    });
  }

  void _updateDifference() {
    if (mounted && !disposed && !isStatic) {
      setState(() {
        difference = DateTime.now().difference(targetTime);
      });
    }
  }

  void _scheduleFirstUpdate() {
    if (isStatic) return;
    _updateDifference();

    if (_shouldUpdateEverySecond()) {
      // Actualiza cada segundo si los segundos son visibles
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && !disposed) {
          _scheduleRegularUpdates();
        }
      });
    } else {
      // Sincroniza con el próximo minuto
      final now = DateTime.now();
      final secondsToNextMinute = 60 - now.second;

      Future.delayed(Duration(seconds: secondsToNextMinute), () {
        if (mounted && !disposed) {
          _scheduleRegularUpdates();
        }
      });
    }
  }

  void _scheduleRegularUpdates() {
    if (isStatic) return;
    _updateDifference();

    if (_shouldUpdateEverySecond()) {
      Future.delayed(const Duration(seconds: 1), () {
        if (!isStatic && mounted && !disposed) {
          _scheduleRegularUpdates();
        }
      });
    } else {
      // Sincroniza con el próximo minuto
      final now = DateTime.now();
      final secondsToNextMinute = 60 - now.second;

      Future.delayed(Duration(seconds: secondsToNextMinute), () {
        if (!isStatic && mounted && !disposed) {
          _scheduleRegularUpdates();
        }
      });
    }
  }

  /// Detecta si debemos actualizar cada segundo
  bool _shouldUpdateEverySecond() {
    if (isStatic) return false;
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    // Actualizar cada segundo si:
    // - Hay segundos visibles.
    // - Estamos en una transición crítica (minutos y segundos en cero pero menos de 1 hora).
    return hours == 0 || (minutes == 0 && seconds >= 0);
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
      mainAxisAlignment: widget.style == null
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        // Componente de horas
        if (hours > 0) ...[
          AnimatedDigitWidget(
            duration: const Duration(milliseconds: 800),
            value: hours,
            textStyle: widget.style ??
                textStyles.small.copyWith(
                  color: Colors.white,
                  fontSize: size.height * 0.0165,
                ),
          ),
          Text(
            hours == 1 ? " hora " : " horas ",
            style: widget.style ??
                textStyles.small.copyWith(
                  color: Colors.white,
                  fontSize: size.height * 0.0165,
                ),
          ),
        ],

        // Componente de minutos y segundos (cuando hay horas o minutos)
        if (hours > 0 || minutes > 0) ...[
          if (minutes > 0) ...[
            AnimatedDigitWidget(
              duration: const Duration(milliseconds: 800),
              value: minutes,
              textStyle: widget.style ??
                  textStyles.small.copyWith(
                    color: Colors.white,
                    fontSize: size.height * 0.0165,
                  ),
            ),
            Text(
              minutes == 1 ? " minuto " : " minutos ",
              style: widget.style ??
                  textStyles.small.copyWith(
                    color: Colors.white,
                    fontSize: size.height * 0.0165,
                  ),
            ),
          ],
          if (hours == 0 || (minutes == 0 && seconds >= 0)) ...[
            AnimatedDigitWidget(
              duration: const Duration(milliseconds: 200),
              value: seconds,
              textStyle: widget.style ??
                  textStyles.small.copyWith(
                    color: Colors.white,
                    fontSize: size.height * 0.0165,
                  ),
            ),
            Text(
              seconds == 1 ? " seg" : " segs",
              style: widget.style ??
                  textStyles.small.copyWith(
                    color: Colors.white,
                    fontSize: size.height * 0.0165,
                  ),
            ),
          ],
        ],

        // Componente de segundos (cuando no hay horas ni minutos)
        if (hours == 0 && minutes == 0) ...[
          AnimatedDigitWidget(
            duration: const Duration(milliseconds: 200),
            value: seconds,
            textStyle: widget.style ??
                textStyles.small.copyWith(
                  color: Colors.white,
                  fontSize: size.height * 0.0165,
                ),
          ),
          Text(
            seconds == 1 ? " segundo" : " segundos",
            style: widget.style ??
                textStyles.small.copyWith(
                  color: Colors.white,
                  fontSize: size.height * 0.0165,
                ),
          ),
        ],
      ],
    );
  }
}

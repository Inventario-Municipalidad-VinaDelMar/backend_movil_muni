import 'package:frontend_movil_muni/infraestructure/models/detalle_planificacion.dart';
import 'package:frontend_movil_muni/infraestructure/models/envio_model.dart';

class PlanificacionModel {
  EnvioModel? envioIniciado;
  String id;
  String fecha;
  List<DetallePlanificacion> detalles;

  PlanificacionModel({
    this.envioIniciado,
    required this.id,
    required this.fecha,
    required this.detalles,
  });

  factory PlanificacionModel.fromApi(Map<String, dynamic> planificacion) {
    return PlanificacionModel(
      envioIniciado: EnvioModel.fromApi(planificacion['envioIniciado']),
      id: planificacion['id'],
      fecha: planificacion['fecha'],
      detalles: (planificacion['detalles'] as List<dynamic>)
          .map((d) => DetallePlanificacion.fromApi(d))
          .toList(),
    );
  }

  // Método para verificar si todos los detalles están completos
  bool areAllDetailsComplete() {
    return detalles.every((detalle) => detalle.isComplete);
  }
}

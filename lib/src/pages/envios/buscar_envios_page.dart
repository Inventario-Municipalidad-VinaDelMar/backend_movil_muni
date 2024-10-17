import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/src/pages/envios/sheet_buscar_envios_page.dart';
import 'package:frontend_movil_muni/src/providers/inventario/inventario_provider.dart';
import 'package:frontend_movil_muni/src/providers/inventario/mixin/socket/socket_inventario_provider.dart';
import 'package:frontend_movil_muni/src/providers/planificacion/planificacion_provider.dart';
import 'package:frontend_movil_muni/src/utils/dates_utils.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BuscarEnviosPage extends StatefulWidget {
  final String productoId;
  const BuscarEnviosPage({super.key, required this.productoId});

  @override
  State<BuscarEnviosPage> createState() => _BuscarEnviosPageState();
}

class _BuscarEnviosPageState extends State<BuscarEnviosPage> {
  late InventarioProvider _inventarioProvider;
  @override
  void initState() {
    _inventarioProvider = context.read<InventarioProvider>();
    _inventarioProvider.connect([
      InventarioEvent.getTandasByProducto,
    ], productoId: widget.productoId);
    super.initState();
  }

  @override
  void dispose() {
    _inventarioProvider.disconnect([
      InventarioEvent.getTandasByProducto,
    ], productoId: widget.productoId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    final inventarioProvider = context.watch<InventarioProvider>();
    final planificacionProvider = context.watch<PlanificacionProvider>();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[500],
        title: Text(
          'Tandas de productos',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: inventarioProvider.loadingTandas
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimateIcon(
                    width: 80,
                    height: 80,
                    onTap: () {},
                    color: Colors.blue,
                    iconType: IconType.continueAnimation,
                    animateIcon: AnimateIcons.loading4,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cargando...',
                    style: textStyles.p.copyWith(color: Colors.blue),
                  )
                ],
              ),
            )
          : Column(
              children: [
                const _InputBodega(),
                SizedBox(
                  width: size.width,
                  height: size.height * 0.75,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: inventarioProvider.tandaByProducto.length,
                    itemBuilder: (context, i) {
                      final tanda = inventarioProvider.tandaByProducto[i];

                      return FadeInUp(
                        duration: const Duration(milliseconds: 300),
                        delay: Duration(milliseconds: i * (200)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(
                                  bottom: 30,
                                ),
                                height: size.height * 0.16,
                                width: size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue[700]!,
                                      Colors.teal[300]!
                                    ], // Azul y verde
                                    stops: const [
                                      0.4,
                                      1.0,
                                    ], // Gradiente entre dos tonos de azul
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: const Offset(
                                          2, 4), // Desplazamiento de la sombra
                                      blurRadius: 6, // Difusión de la sombra
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Disponible ',
                                          style: textStyles.p.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ShadBadge(
                                          child: Text(
                                            '${tanda.cantidadActual}',
                                            style: textStyles.small
                                                .copyWith(color: Colors.white),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          tanda.bodega,
                                          style: textStyles.small
                                              .copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                AnimateIcon(
                                                  width: 20,
                                                  height: 20,
                                                  color: Colors.white,
                                                  onTap: () {},
                                                  iconType: IconType
                                                      .continueAnimation,
                                                  animateIcon:
                                                      AnimateIcons.mapPointer,
                                                ),
                                                const SizedBox(width: 10),
                                                SizedBox(
                                                    width: size.width * 0.5,
                                                    child: FittedBox(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          tanda.ubicacion,
                                                          style: textStyles
                                                              .small
                                                              .copyWith(
                                                            color: Colors.white,
                                                          ),
                                                        )))
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                AnimateIcon(
                                                  width: 18,
                                                  height: 18,
                                                  color: Colors.white,
                                                  onTap: () {},
                                                  iconType: IconType
                                                      .continueAnimation,
                                                  animateIcon:
                                                      AnimateIcons.calendar,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'Vence en:',
                                                  style: textStyles.small
                                                      .copyWith(
                                                          color: Colors.white),
                                                ),
                                                Text(
                                                  ' ${calcularDiasRestantes(tanda.fechaVencimiento)}',
                                                  style:
                                                      textStyles.small.copyWith(
                                                    color: Colors.orange[300],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Column(
                                          children: [
                                            const SizedBox(height: 10),
                                            ShadButton(
                                              onPressed: () {
                                                showShadSheet(
                                                  side: ShadSheetSide.bottom,
                                                  context: context,
                                                  builder: (context) =>
                                                      SheetBuscarEnviosPage(
                                                    productoImgUrl:
                                                        planificacionProvider
                                                            .getOneDetallePlanificacion(
                                                                widget
                                                                    .productoId)!
                                                            .urlImagen,
                                                    cantidadDisponible:
                                                        tanda.cantidadActual,
                                                    tandaId: tanda.id,
                                                    producto: tanda.producto,
                                                    productoId:
                                                        tanda.productoId,
                                                    side: ShadSheetSide.bottom,
                                                  ),
                                                );
                                              },
                                              backgroundColor: Colors.blue[900],
                                              size: ShadButtonSize.sm,
                                              icon: const Icon(
                                                Icons.system_update_alt_rounded,
                                                color: Colors.white,
                                              ),
                                              child: const Text('Retirar'),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Positioned(
                                top: -10,
                                right: 0,
                                // right: size.width * 0.2,
                                child: ShadBadge(
                                  child: Text(
                                    tanda.producto,
                                    style: textStyles.small
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _InputBodega extends StatefulWidget {
  const _InputBodega();

  @override
  State<_InputBodega> createState() => _InputBodegaState();
}

class _InputBodegaState extends State<_InputBodega> {
  var searchValue = '';
  final frameworks = {
    'bodega A': 'Bodega A - Miraflores Centro',
  };
  Map<String, String> get filteredFrameworks => {
        for (final framework in frameworks.entries)
          if (framework.value.toLowerCase().contains(searchValue.toLowerCase()))
            framework.key: framework.value
      };

  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;

    return FadeInLeft(
      duration: const Duration(milliseconds: 200),
      delay: const Duration(milliseconds: 500),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 20, bottom: 0, right: 10, left: 15),
            child: SizedBox(
                width: double.infinity,
                child: Text('Bodega', style: textStyles.small)),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
            child: SizedBox(
              width: double.infinity,
              child: ShadSelect<String>.withSearch(
                minWidth: 180,
                //Valor por defecto
                // initialValue: frameworks['bodega A'] ?? '',
                placeholder:
                    Text('Seleccione una bodega', style: textStyles.small),
                onSearchChanged: (value) => setState(() => searchValue = value),
                searchPlaceholder: const Text('Buscar bodega'),
                options: [
                  if (filteredFrameworks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('Bodega no encontrada'),
                    ),
                  ...frameworks.entries.map(
                    (framework) {
                      return Offstage(
                        offstage:
                            !filteredFrameworks.containsKey(framework.key),
                        child: ShadOption(
                          value: framework.key,
                          child: Text(framework.value),
                        ),
                      );
                    },
                  )
                ],
                selectedOptionBuilder: (context, value) =>
                    Text(frameworks[value]!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

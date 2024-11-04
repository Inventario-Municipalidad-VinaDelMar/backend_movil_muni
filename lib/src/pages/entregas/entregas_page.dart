import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EntregaOption {
  String title;
  String description;
  String asset;
  double width;
  double height;
  String textButton;
  IconData iconButton;
  String route;
  bool extraPadding;

  EntregaOption({
    required this.title,
    required this.description,
    required this.asset,
    required this.textButton,
    required this.route,
    required this.width,
    required this.height,
    required this.extraPadding,
    required this.iconButton,
  });
}

class EntregasPage extends StatefulWidget {
  const EntregasPage({super.key});

  @override
  State<EntregasPage> createState() => _EntregasPageState();
}

class _EntregasPageState extends State<EntregasPage> {
  late PageController _pageController;
  late int _pageSelected;

  List<EntregaOption> options = [];

  @override
  void initState() {
    super.initState();
    _pageSelected = 0;
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onOptionChange(int page) {
    setState(() {
      _pageSelected = page - 1;
    });
    _pageController.animateToPage(
      page - 1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;
    Size size = MediaQuery.of(context).size;
    double topPadd = MediaQuery.of(context).padding.top;

    // Configuramos la lista `options` dentro del build usando el size
    options = [
      EntregaOption(
        title: 'Nueva entrega',
        description: 'Registra una entrega perteneciente a un envío en curso.',
        asset: 'assets/logos/entrega_realizada.gif',
        textButton: 'Crear una nueva entrega',
        route: '/entregas/registro/list-envios',
        width: size.width,
        height: size.height * 0.5,
        extraPadding: true,
        iconButton: MdiIcons.truckCargoContainer,
      ),
      EntregaOption(
        title: 'Actualización de entrega',
        description: 'Adjunta el acta legal que valida la entrega realizada.',
        asset: 'assets/logos/entrega_update.gif',
        textButton: 'Seleccionar entrega',
        route: '/entregas/actualizacion/list-envios',
        width: size.width,
        height: size.height * 0.5,
        extraPadding: true,
        iconButton: MdiIcons.chevronTripleRight,
      ),
      EntregaOption(
        title: 'Incidente durante envío',
        description:
            'Informa acerca de un accidente durante el transporte de productos.',
        asset: 'assets/logos/entrega_accidente.gif',
        textButton: 'Registrar incidente',
        route: '/entregas/incidente/list-envios',
        width: size.width,
        height: size.height * 0.3,
        extraPadding: false,
        iconButton: MdiIcons.carEmergency,
      ),
    ];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[600]!,
        title: Text(
          'Entregas',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            _HeaderOptions(
              topPadd: topPadd,
              pageSelected: _pageSelected,
              onOptionClicked: _onOptionChange,
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: size.width,
                height: size.height * 0.52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  itemCount: options.length,
                  itemBuilder: (context, i) {
                    final option = options[i];
                    return _PageCardAtion(
                      option: option,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageCardAtion extends StatelessWidget {
  final EntregaOption option;
  const _PageCardAtion({
    required this.option,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(20),
      width: size.width,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: Container(
              padding: option.extraPadding
                  ? EdgeInsets.only(bottom: size.height * 0.05)
                  : null,
              width: option.width,
              height: option.height,
              child: Image.asset(
                option.asset,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                option.title,
                style: textStyles.h3,
              ),
              Text(
                option.description,
                style: textStyles.p.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Spacer(),
              ShadButton(
                onPressed: () => context.push(option.route),
                size: ShadButtonSize.lg,
                width: double.infinity,
                icon: Text(
                  option.textButton,
                  style: textStyles.p.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Icon(
                  option.iconButton,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderOptions extends StatelessWidget {
  final double topPadd;
  final int pageSelected;
  final void Function(int page) onOptionClicked;
  const _HeaderOptions({
    required this.topPadd,
    required this.pageSelected,
    required this.onOptionClicked,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double appBarHeight = kToolbarHeight;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      margin: EdgeInsets.only(
        top: (topPadd + appBarHeight) - 1, // use the topPadd here
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue[600]!,
          Colors.blue[700]!,
          Colors.blue[800]!,
          Colors.blue[900]!,
        ],
      )),
      width: double.infinity,
      height: size.height * 0.4,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            width: double.infinity,
            height: (size.height * 0.36 - 30) / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => onOptionClicked(1),
                  child: _CardAction(
                    selected: 0 == pageSelected,
                    title: 'Registrar una entrega',
                    description: 'Asigna una entrega a un envío.',
                    color: Colors.green[600]!,
                    icon: MdiIcons.packageCheck,
                  ),
                ),
                InkWell(
                  onTap: () => onOptionClicked(2),
                  child: _CardAction(
                    selected: 1 == pageSelected,
                    delay: 150,
                    title: 'Actualiza una entrega',
                    description: 'Adjunta documento acta legal.',
                    color: Colors.purple[400]!,
                    icon: MdiIcons.folderArrowUp,
                  ),
                ),
              ],
            ),
          ),
          // SizedBox()
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            width: double.infinity,
            height: (size.height * 0.36 - 30) / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => onOptionClicked(3),
                  child: _CardAction(
                    selected: 2 == pageSelected,
                    delay: 300,
                    title: 'Registrar un incidente ',
                    description: 'Registra incidente durante envio.',
                    color: Colors.orange[600]!,
                    icon: MdiIcons.truckAlertOutline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final int delay;
  final IconData icon;
  final bool selected;
  const _CardAction({
    required this.color,
    required this.title,
    required this.description,
    this.delay = 0,
    required this.icon,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -13,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 10,
            width: (size.width - 30) * 0.48,
            child: Align(
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: 3,
                width: selected
                    ? (size.width - 70) * 0.48
                    : 10, // Cambiado de 0 a 1
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.white.withOpacity(.3),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ),
        ZoomIn(
          duration: Duration(milliseconds: 200),
          delay: Duration(milliseconds: delay),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.03,
              vertical: size.height * 0.02,
            ),
            height: double.infinity,
            width: (size.width - 30) * 0.48,
            decoration: BoxDecoration(
              boxShadow: !selected
                  ? []
                  : [
                      BoxShadow(
                        color: color.withOpacity(
                            0.25), // Reduce la opacidad para un efecto más suave
                        offset: Offset(2,
                            4), // La sombra caerá más directamente debajo del widget
                        blurRadius:
                            15, // Aumenta el desenfoque para una sombra más difusa
                        spreadRadius:
                            -3, // Disminuye la extensión para concentrar la sombra
                      ),
                    ],
              color: selected ? color : color.withOpacity(.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                    top: -size.height * 0.01,
                    right: 0,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: selected
                            ? Colors.white.withOpacity(.3)
                            : Colors.grey[400]!.withOpacity(.3),
                      ),
                      child: Icon(
                        icon,
                        color: selected ? Colors.white : Colors.grey[400],
                      ),
                    )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textStyles.small.copyWith(
                        color: selected ? Colors.white : Colors.grey[400],
                        fontWeight: FontWeight.bold,
                        fontSize: size.height * 0.018,
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),
                    Text(
                      description,
                      style: textStyles.small.copyWith(
                        color: selected ? Colors.white : Colors.grey[400],
                        fontSize: size.height * 0.0175,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

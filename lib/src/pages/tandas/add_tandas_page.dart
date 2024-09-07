import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/src/providers/inventario/inventario_provider.dart';
import 'package:frontend_movil_muni/src/providers/inventario/mixin/socket/socket_inventario_provider.dart';
import 'package:frontend_movil_muni/src/utils/dateText.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddTandasPage extends StatefulWidget {
  const AddTandasPage({super.key});

  @override
  State<AddTandasPage> createState() => _AddTandasPageState();
}

class _AddTandasPageState extends State<AddTandasPage> {
  TextEditingController fechaController = TextEditingController();
  bool isInvalidDate = false;
  late InventarioProvider _inventarioProvider;

  @override
  void initState() {
    super.initState();
    _inventarioProvider = context.read<InventarioProvider>();
    _inventarioProvider.connect([InventarioEvent.getProductos]);
  }

  @override
  void dispose() {
    _inventarioProvider.disconnect([InventarioEvent.getProductos]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Tanda'),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              HeadRowTextForm(
                texto: 'Producto:',
                funcionOnPressed: () {},
              ),
              SelectSearch(),
              HeadTextForm(
                texto: 'Cantidad: ',
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: const ShadInput(
                  placeholder: Text('200...'),
                  keyboardType: TextInputType.number,
                ),
              ),
              HeadTextForm(
                texto: 'Fecha de vencimiento: ',
              ),
              CustomDateInput(
                label: 'Fecha de vencimiento...',
                validator: (String? errorsDate) {
                  setState(() {
                    isInvalidDate = errorsDate != null;
                  });
                },
                controller: fechaController,
              ),
              HeadTextForm(
                texto: 'Bodega: ',
              ),
              SelectSearch(),
              HeadRowTextForm(
                texto: 'Ubicación: ',
                funcionOnPressed: () {},
              ),
              SelectSearch(),
            ],
          ),
          BotonAgregar()
        ],
      ),
    );
  }
}

class HeadRowTextForm extends StatelessWidget {
  const HeadRowTextForm({
    super.key,
    required this.texto,
    required this.funcionOnPressed,
  });

  final String texto;
  final Function() funcionOnPressed;
  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            texto,
            style: textStyles.small,
          ),
          const Spacer(),
          ShadButton(
            size: ShadButtonSize.sm,
            icon: const Icon(
              Icons.add,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class HeadTextForm extends StatelessWidget {
  const HeadTextForm({super.key, required this.texto});
  final String texto;
  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        texto,
        style: textStyles.small,
      ),
    );
  }
}

class SelectSearch extends StatefulWidget {
  const SelectSearch({
    super.key,
  });

  @override
  State<SelectSearch> createState() => _SelectSearchState();
}

class _SelectSearchState extends State<SelectSearch> {
  var searchValue = '';

  final frameworks = {
    'nextjs': 'Next.js',
    'svelte': 'SvelteKit',
    'nuxtjs': 'Nuxt.js',
    'remix': 'Remix',
    'astro': 'Astro',
  };

  Map<String, String> get filteredFrameworks => {
        for (final framework in frameworks.entries)
          if (framework.value.toLowerCase().contains(searchValue.toLowerCase()))
            framework.key: framework.value
      };

  @override
  Widget build(BuildContext context) {
    return ShadSelect<String>.withSearch(
      minWidth: 180,
      placeholder: const Text('Seleccionar producto...'),
      onSearchChanged: (value) => setState(() => searchValue = value),
      searchPlaceholder: const Text('Buscar producto'),
      options: [
        if (filteredFrameworks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('No se encuentran productos...'),
          ),
        ...frameworks.entries.map(
          (framework) {
            // this offstage is used to avoid the focus loss when the search results appear again
            // because it keeps the widget in the tree.
            return Offstage(
              offstage: !filteredFrameworks.containsKey(framework.key),
              child: ShadOption(
                value: framework.key,
                child: Text(framework.value),
              ),
            );
          },
        )
      ],
      selectedOptionBuilder: (context, value) => Text(frameworks[value]!),
    );
  }
}

class BotonAgregar extends StatelessWidget {
  const BotonAgregar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final inventarioProvider = context.watch<InventarioProvider>();

    return Positioned(
      bottom: 10.0,
      left: 10.0,
      right: 10.0,
      child: ShadButton(
        child: Text('Añadir'),
        onPressed: () {
          print('Productos: ');
          print(inventarioProvider.productos);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:giuseppe/presentation/tabs/inventory/object_form/object_form.dart';
import 'package:giuseppe/presentation/tabs/search_object/search_object_tab.dart';
import 'package:giuseppe/router/app_routes.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';

class InventoryTab extends StatefulWidget {
  const InventoryTab({super.key});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  String? _selectedCategory;
  List<String> _categories = [
    'Plasticos',
    'Metales',
    'Vidrio',
    'Papel',
    'Otros'
  ];
  bool isAdmin = true;

  final List<Map<String, String>> inventoryItems = [
    {'name': 'Jarron', 'quantity': '10', 'image': 'assets/images/jarron.png'},
    {'name': 'Jarron 2', 'quantity': '10', 'image': 'assets/images/jarron2.png'},
    {'name': 'Lampara', 'quantity': '4', 'image': 'assets/images/lampara.png'},
    {'name': 'Mesa', 'quantity': '4', 'image': 'assets/images/mesa.png'},
    {'name': 'Silla', 'quantity': '16', 'image': 'assets/images/silla.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Parte estática
          Container(
            padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
            child: const Image(
              image: AssetImage('assets/images/logo.png'),
              height: 70.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Buscar",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: AppColors.primaryVariantColor,
                          width: 1.0,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primaryVariantColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: DropdownMenu(
                    initialSelection: _selectedCategory,
                    inputDecorationTheme: InputDecorationTheme(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: AppColors.primaryVariantColor,
                          width: 1.0,
                        ),
                      ),
                    ),
                    hintText: 'Filtrar',
                    onSelected: (String? value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    dropdownMenuEntries: _categories.map((String category) {
                      return DropdownMenuEntry<String>(
                        value: category,
                        label: category,
                      );
                    }).toList(),
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(AppColors.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                if (isAdmin)
                  SizedBox(
                    width: 50,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SearchObjectTab()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: AppColors.primaryColor),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(
            color: AppColors.primaryVariantColor,
            thickness: 1.0,
            indent: 20.0,
            endIndent: 20.0,
          ),
          // Parte desplazable
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: inventoryItems.length,
                itemBuilder: (context, index) {
                  return InventoryCard(
                      item: inventoryItems[index], context: context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class InventoryCard extends StatelessWidget {
  final Map<String, String> item;
  final BuildContext context;
  const InventoryCard({super.key, required this.item, required this.context});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        modalObject();
      },
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: AppColors.primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Image.asset(
                item['image']!,
                height: 60.0,
                width: double.infinity,
              ),
              const SizedBox(height: 10.0),
              Text(
                item['name']!,
                style: Theme.of(context).textTheme.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: Text(
                  "Disponibles: ${item['quantity']!}",
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // * Ventana modal
  void modalObject() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop())),
                  Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back), onPressed: () {}),
                      Expanded(
                        child: Column(children: [
                          Image.asset(
                            item['image']!,
                            height: 130.0,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            item['name']!,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            "Disponibles: ${item['quantity']!}",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            "Detalle quemado",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]),
                      ),
                      IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {}),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

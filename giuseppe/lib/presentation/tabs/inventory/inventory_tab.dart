import 'package:flutter/material.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';

class InventoryTab extends StatefulWidget {
  const InventoryTab({super.key});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  String? _selectedCategory;
  List<String> _categories = ['Plasticos', 'Metales', 'Vidrio', 'Papel', 'Otros'];

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
      body: CustomScrollView(
        slivers: [
          SliverList(delegate: SliverChildListDelegate([
            Container(
              padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
              child: const Image(
                image: AssetImage('assets/images/logo.png'),
                height: 75.0,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Buscar...",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                            color: AppColors.primaryVariantColor,
                            width: 1.0,
                          ),
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
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                            color: AppColors.primaryVariantColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                      hintText: 'Categoría',
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
                    ),
                  )
                ],
              ),
            ),
          ])
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(left: 20.0 ,right: 20.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: inventoryItems.length,
                itemBuilder: (context, index) {
                  return InventoryCard(item: inventoryItems[index]);
                },
              ),
            ),
          ),
        ],
      )
    );
  }
}

class InventoryCard extends StatelessWidget {
  final Map<String, String> item;
  const InventoryCard({super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}

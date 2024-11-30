import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:giuseppe/presentation/tabs/search_object/search_object_tab.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../services/firebase_services/firestore_database/object_service.dart';

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

  List<Map<String, dynamic>> inventoryItems = [];

  final ObjectService _objectService = ObjectService();

  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
  }

  // Cargar los objetos desde la base de datos
  Future<void> _loadInventoryItems() async {
    List<Map<String, dynamic>> items = await _objectService.getAllItems();
    setState(() {
      inventoryItems = items.map((item) {
        return {
          'image': item['images'] ?? [],
          'name': item['name'] ?? 'Unnamed',
          'quantity': item['quantity']?.toString() ?? '0',
          'detail': item['detail'] ?? 'Sin detalle',
        };
      }).toList();
    });
  }

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
                      backgroundColor:
                          WidgetStateProperty.all(AppColors.primaryColor),
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
  final Map<String, dynamic> item;
  final BuildContext context;
  const InventoryCard({super.key, required this.item, required this.context});

  @override
  Widget build(BuildContext context) {
    String imageUrl = item['image']?.isNotEmpty == true ? item['image'][0] : '';
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Image.network(
                    imageUrl,
                    height: 70.0,
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
            // Icono de mas opciones
            Positioned(
              top: 4,
              right: 4,
              child: Theme(
                data: Theme.of(context).copyWith(
                  popupMenuTheme: const PopupMenuThemeData(
                    color: AppColors.primaryColor, // Fondo del menú
                  ),
                ),
                child: PopupMenuButton<String>(
                  offset: const Offset(0, 40), // Ajustar la posición del menú
                  onSelected: (String value) {
                    handleMenuOption(value);
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.primaryVariantColor,
                    size: 20.0,
                  ),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'añadir_orden',
                      child: Text('Añadir a Orden'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'editar',
                      child: Text('Editar'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'eliminar',
                      child: Text('Eliminar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Opciones del menú
  void handleMenuOption(String value) {
    switch (value) {
      case 'añadir_orden':
        addItem(item);
        break;
      case 'editar':
        editItem(item); // Cambiado para abrir el modal de edición
        break;
      case 'eliminar':
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar Eliminación'),
              content:
                  Text('¿Está seguro que desea eliminar "${item['name']}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Eliminar'),
                ),
              ],
            );
          },
        );
        break;
    }
  }

  //ventana modal de añadir item a la orden de despacho
  void addItem(Map<String, dynamic> item) {
    final TextEditingController quantityController =
        TextEditingController(text: item['quantity']);
    final TextEditingController additionalInfoController =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
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
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Image.asset(
                      item['image']!,
                      height: 130.0,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Añadir a Orden',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 10),
                    Text('Producto: ${item['name']}'),
                    const SizedBox(height: 10),
                    Text('Stock: ${item['quantity']}'),
                    const SizedBox(height: 10),
                    const TextField(
                      decoration: InputDecoration(labelText: 'Cantidad'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: additionalInfoController,
                      decoration:
                          const InputDecoration(labelText: 'Observaciones:'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Añadir'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //ventana modal de editar item
  void editItem(Map<String, dynamic> item) {
    final TextEditingController nameController =
        TextEditingController(text: item['name']);
    final TextEditingController quantityController =
        TextEditingController(text: item['quantity']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Image.asset(
                      item['image']!,
                      height: 130.0,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Editar ${item['name']}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: 'Cantidad'),
                      keyboardType: TextInputType.number,
                    ),
                    const TextField(
                      decoration: InputDecoration(labelText: 'Detalle'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // * Ventana modal info
  void modalObject() {
    List<dynamic> images = item['image'] ?? []; // Lista de imágenes
    final CarouselSliderController _carouselController =
        CarouselSliderController();
    int currentIndex = 0; // Índice de la imagen actual

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
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  if (images.isNotEmpty)
                    Stack(
                      children: [
                        // Carrusel de imágenes
                        CarouselSlider(
                          carouselController:
                              _carouselController, // Usa CarouselSliderController aquí
                          options: CarouselOptions(
                            height: 200.0,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            onPageChanged: (index, reason) {
                              setModalState(() {
                                currentIndex = index;
                              });
                            },
                          ),
                          items: images.map((imgUrl) {
                            return GestureDetector(
                              onTap: () {
                                _showImagePreview(
                                    context, images, images.indexOf(imgUrl));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Container(
                                  height: 150.0,
                                  width: double.infinity,
                                  child: Image.network(
                                    imgUrl,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                            value: progress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? progress
                                                        .cumulativeBytesLoaded /
                                                    progress.expectedTotalBytes!
                                                : null),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.broken_image,
                                            size: 50, color: Colors.red),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        // Flecha izquierda
                        if (currentIndex > 0)
                          Positioned(
                            left: 10,
                            top: 80,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                _carouselController.previousPage();
                              },
                            ),
                          ),

                        // Flecha derecha
                        if (currentIndex < images.length - 1)
                          Positioned(
                            right: 10,
                            top: 80,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: () {
                                _carouselController.nextPage();
                              },
                            ),
                          ),
                      ],
                    )
                  else
                    const Text("No hay imágenes disponibles."),
                  const SizedBox(height: 15),
                  Text(
                    item['name']!,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    "Disponibles: ${item['quantity']!}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Detalle: ${item['detail']!}",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showImagePreview(
      BuildContext context, List<dynamic> images, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: PhotoViewGallery.builder(
            itemCount: images.length,
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(images[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            pageController: PageController(initialPage: initialIndex),
            onPageChanged: (index) {},
          ),
        );
      },
    );
  }
}

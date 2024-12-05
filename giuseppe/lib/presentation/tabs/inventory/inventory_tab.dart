import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:giuseppe/presentation/tabs/inventory/object_form/edit_object_form.dart';
import 'package:giuseppe/presentation/tabs/search_object/search_object_tab.dart';
import 'package:giuseppe/services/firebase_services/firestore_database/object_service.dart';
import 'package:giuseppe/services/local_storage/session_in_local_storage_service.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class InventoryTab extends StatefulWidget {
  const InventoryTab({super.key});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  String? _selectedCategory;
  final List<String> _categories = [
    'Accesorios', //ia
    'Auxiliares',
    'Bases', //ia
    'Candelabros', //ia
    'Electrodomésticos',
    'Herramientas',
    'Lamparas', //ia
    'Mobiliario', //ia
    'Vajilla', //ia
    'Otros',
  ];
  bool isAdmin = false;

  List<Map<String, dynamic>> inventoryItems = [];

  final ObjectService _objectService = ObjectService();
  final SessionInLocalStorageService _localStorage = SessionInLocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
  }

  // Funcion para cargar los objetos desde la bdd
  Future<void> _loadInventoryItems() async {
    List<Map<String, dynamic>> items = await _objectService.getAllItems();
    setState(() {
      inventoryItems = items.map((item) {
        return {
          'id': item['id'],
          'image': item['images'] ?? [],
          'name': item['name'] ?? 'Unnamed',
          'quantity': item['quantity']?.toString() ?? '0',
          'detail': item['detail'] ?? 'Sin detalle',
          'category': item['category'] ?? '',
        };
      }).toList();
    });
  }

  // Función para eliminar un objeto
  Future<void> _deleteItem(Map<String, dynamic> item, int index) async {
    List<String> images = List<String>.from(item['image'] ?? []);

    bool success = await _objectService.deleteObject(item['id'], images);

    if (mounted) {
      if (success) {
        setState(() {
          inventoryItems.removeAt(index); //refresh
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Objeto eliminado exitosamente'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el objeto'),
          ),
        );
      }
    }
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
                        inventoryItems = inventoryItems.where((item) {
                          if (_selectedCategory == null || _selectedCategory!.isEmpty) return true;
                          return item['category'] == _selectedCategory;
                        }).toList();
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
                      maximumSize: WidgetStateProperty.all(Size.fromHeight(350.0)),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),


                // Verificacion si es admin o no
                FutureBuilder<bool>(
                  future: _localStorage.fetchSession().then((sessionData) => sessionData?['isAdmin'] ?? false),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return SizedBox(
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
                      );
                    }
                    return const SizedBox.shrink();
                  },
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
                    item: inventoryItems[index],
                    objectService: _objectService,
                    context: context,
                    onDelete: () {
                      _deleteItem(inventoryItems[index], index);
                    },
                  );
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
  final ObjectService objectService;
  final Function onDelete;

  const InventoryCard({
    super.key,
    required this.item,
    required this.objectService,
    required this.onDelete,
    required this.context,
  });

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
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: Text(
                      "Disponibles: ${item['quantity']!}",
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall,
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
                    color: AppColors.primaryColor,
                  ),
                ),
                child: PopupMenuButton<String>(
                  offset: const Offset(0, 40),
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
        _navigateAndReloadItems(item);
        break;
      case 'eliminar':
        _DeleteDialog(item);
        break;
    }
  }

  //Funcion editar items
  void _navigateAndReloadItems(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditObjectForm(
          item: item,
          objectService: objectService,
        ),
      ),
    ).then((shouldReload) {
      if (shouldReload == true) {
        if (context.mounted) {
          final state = context.findAncestorStateOfType<_InventoryTabState>();
          if (state != null) {
            state._loadInventoryItems();
          }
        }
      }
    });
  }

  // Modal de eliminacion
  void _DeleteDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          backgroundColor: AppColors.primaryColor,
          title: Center(
            child: const Text('Eliminar Item'),
          ),
          content: Text(
            '¿Está seguro que desea eliminar el item "${item['name']}"?, Esta acción es irreversible.',
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onPrimaryColor, // Color del texto (letra)
              ),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                onDelete(); // Llama a la función de eliminar
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.errorColor,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }


  //Modal de añadir item a la orden de despacho
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
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleSmall,
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


  // * Ventana modal info
  void modalObject() {
    List<dynamic> images = item['image'] ?? [];
    final CarouselSliderController _carouselController =
    CarouselSliderController();
    int currentIndex = 0;

    showModalBottomSheet(
      backgroundColor: AppColors.primaryColor,
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
                          _carouselController,
                          // Usa CarouselSliderController aquí
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
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,

                    ),
                  ),
                  Text(
                    "Disponibles: ${item['quantity']!}",
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    "Detalle: ${item['detail']!}",
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  //visualizacion de la imagen en grande
  void _showImagePreview(BuildContext context, List<dynamic> images, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: Stack(
                children: [
                  PhotoViewGallery.builder(
                    itemCount: images.length,
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(images[index]),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 4,
                      );
                    },
                    scrollPhysics: const BouncingScrollPhysics(),
                    backgroundDecoration: BoxDecoration(
                      color: AppColors.primaryColor,
                    ),
                    pageController: PageController(initialPage: initialIndex),
                    onPageChanged: (index) {},
                  ),
                  Positioned(
                    right: 0.0,
                    child: IconButton(
                      icon: Icon(Icons.close, color: AppColors.primaryVariantColor, size: 30),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}

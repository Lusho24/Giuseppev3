import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:giuseppe/presentation/tabs/inventory/inventory_view_model.dart';
import 'package:giuseppe/presentation/tabs/inventory/object_form/edit_object_form.dart';
import 'package:giuseppe/presentation/tabs/search_object/search_object_tab.dart';
import 'package:giuseppe/services/firebase_services/firestore_database/object_service.dart';
import 'package:giuseppe/services/firebase_services/firestore_database/cart_service.dart';
import 'package:giuseppe/services/local_storage/session_in_local_storage_service.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class InventoryTab extends StatefulWidget {
  const InventoryTab({super.key});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  String? _selectedCategory;
  bool isAdmin = false;
  List<Map<String, dynamic>> inventoryItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  final ObjectService _objectService = ObjectService();
  final SessionInLocalStorageService _localStorage = SessionInLocalStorageService();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Accesorios',
    'Bases', //ia
    'Candelabros', //ia
    'Lamparas',
    'Mobiliario', //ia
    'Otros',
  ];


  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
    _searchController.addListener(_onSearchChanged);
  }

  //Funcion para ordenar items alfabeticamente
  void _sortItems() {
    filteredItems.sort((a, b) => a['name'].compareTo(b['name']));
  }

  // Funcion para cargar los objetos desde la bdd
  Future<void>  _loadInventoryItems() async {
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
      filteredItems = List.from(inventoryItems);
      _sortItems();
    });
  }
  // Filtrar ítems
  void _onSearchChanged() {
    setState(() {
      _applyFilters();
    });
  }

  // Aplicar filtros
  void _applyFilters() {
    filteredItems = inventoryItems.where((item) {
      final matchesSearch = item['name'].toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = _selectedCategory == null || _selectedCategory!.isEmpty || item['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
    _sortItems();
  }

  // Quitar el filtro de categoría
  void _clearCategoryFilter() {
    setState(() {
      _selectedCategory = null;
      _applyFilters();
    });
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InventoryViewModel(),
      child: Scaffold(
        body: Column(
          children: [
            // Parte estática
            Stack(
              alignment: Alignment.center,
              children: [
                Consumer<InventoryViewModel>(
                    builder: (context, viewmodel, child){
                      return Container(
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child: MenuAnchor(
                            menuChildren: [
                              MenuItemButton(
                                onPressed: () async {
                                  await viewmodel.removeSessionInLocalStorage(
                                      context: context
                                  );
                                },
                                child: const Text("Salir"),
                              ),
                            ],
                            builder: (BuildContext context, MenuController controller, Widget? child) {
                              return IconButton(
                                icon: const Icon(Icons.exit_to_app),
                                onPressed: () {
                                  if (controller.isOpen) {
                                    controller.close();
                                  } else {
                                    controller.open();
                                  }
                                },
                              );
                            },
                            style: MenuStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  AppColors.primaryColor),
                            ),
                          )
                      );
                    }
                ),
                Container(
                  padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
                  child: const Image(
                    image: AssetImage('assets/images/logo.png'),
                    height: 70.0,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Buscar",
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
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
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: const BorderSide(
                            color: AppColors.primaryVariantColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                      hintText: _selectedCategory == null ? 'Filtrar' : _selectedCategory!,
                      onSelected: (String? value) {
                        setState(() {
                          _selectedCategory = value;
                          _applyFilters();
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
                        maximumSize: WidgetStateProperty.all(const Size.fromHeight(350.0)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),

                  // Verificacion si es admin o no
                  FutureBuilder<bool>(
                    future: _localStorage.fetchSession().then((sessionData) =>
                    sessionData?['isAdmin'] ?? false),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              )
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

            // Mensaje de filtro y restablecer
            if (_selectedCategory != null && _selectedCategory!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filtro: $_selectedCategory',),
                    TextButton(
                      onPressed: _clearCategoryFilter,
                      child: const Text('Restablecer',
                      style: TextStyle(
                        color: AppColors.onPrimaryColor,
                        fontWeight: FontWeight.w400,
                      ),),
                    ),
                  ],
                ),
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
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return InventoryCard(
                      item: filteredItems[index],
                      objectService: _objectService,
                      context: context,
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

class InventoryCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final BuildContext context;
  final ObjectService objectService;

  const InventoryCard({
    super.key,
    required this.item,
    required this.objectService,
    required this.context,
  });

  @override
  State<InventoryCard> createState() => _InventoryCardState();
}

class _InventoryCardState extends State<InventoryCard> {

  final CartService _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.item['image']?.isNotEmpty == true ? widget.item['image'][0] : '';

    return GestureDetector(
      onTap: () {
        modalObject();
      },
      child: Card(
        elevation: 4.0,
        color: AppColors.primaryColor,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 75.0,
                      width: 75.0,
                      child: imageUrl.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 50.0,
                          ),
                        ),
                      )
                          : const Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 50.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      widget.item['name']!,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      "Disponibles: ${widget.item['quantity']!}",
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

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
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
        addItem(widget.item);
        break;
      case 'editar':
        _navigateAndReloadItems(widget.item);
        break;
      case 'eliminar':
        _deleteDialog(widget.item);
        break;
    }
  }

  //Funcion editar items
  void _navigateAndReloadItems(Map<String, dynamic> item) {
    final state = context.findAncestorStateOfType<_InventoryTabState>();
    if (state == null) {
      debugPrint("No se pudo encontrar el estado de _InventoryTabState");
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditObjectForm(
          item: item,
          objectService: widget.objectService,
        ),
      ),
    ).then((shouldReload) {
      if (shouldReload == true) {
        if (mounted) {
          state._loadInventoryItems();
        }
      }
    });
  }

// Función para eliminar un objeto
  Future<void> _deleteItem(Map<String, dynamic> item) async {
    bool isInCart = await _cartService.itemInCart(item['id']);

    if (isInCart) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No puedes eliminar el ítem porque se encuentra en una orden de despacho en proceso"),
          ),
        );
      }
    } else {
      List<String> images = List<String>.from(item['image'] ?? []);
      bool success = await widget.objectService.deleteObject(item['id'], images);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Objeto eliminado exitosamente'),
            ),
          );
          final state = context.findAncestorStateOfType<_InventoryTabState>();
          if (state != null) {
            state._clearCategoryFilter();
            state._loadInventoryItems();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar el objeto'),
            ),
          );
        }
      }
    }
  }


  // Modal de eliminación
  void _deleteDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          backgroundColor: AppColors.primaryColor,
          title: const Center(
            child: Text('Eliminar Item'),
          ),
          content: Text(
            '¿Está seguro que desea eliminar el item "${item['name']}"? Esta acción es irreversible.',
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
                foregroundColor: AppColors.onPrimaryColor,
              ),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteItem(item);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                backgroundColor: AppColors.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }


  //Modal de añadir item a la orden de despacho
  void addItem(Map<String, dynamic> item) async {
    int orderQuantity = 1;
    final int maxQuantity = int.tryParse(item['quantity'].toString()) ?? 0;

    final cartItems = await CartService().fetchCartItems();
    int currentQuantityInCart = 0;

    final existingItem = cartItems.firstWhere(
          (cartItem) => cartItem['itemId'] == item['id'],
      orElse: () => {'itemId': '', 'quantityOrder': 0},
    );

    currentQuantityInCart = existingItem['quantityOrder'] ?? 0;
    final int availableToAdd = maxQuantity - currentQuantityInCart;

    final TextEditingController quantityController = TextEditingController(
      text: orderQuantity.toString(),
    );
    if (mounted){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 30, color: Colors.black),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              'Seleccione la cantidad a añadir',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Item: ${item['name'] ?? 'Nombre del ítem'}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'Disponibilidad: $maxQuantity',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'Cantidad actual en el carrito: $currentQuantityInCart',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: orderQuantity > 1
                            ? () {
                          setDialogState(() {
                            orderQuantity--;
                            quantityController.text =
                                orderQuantity.toString();
                          });
                        }
                            : null,
                      ),
                      SizedBox(
                        width: 55,
                        height: 45,
                        child: TextField(
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setDialogState(() {
                              orderQuantity = int.tryParse(value) ?? 1;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: orderQuantity < availableToAdd
                            ? () {
                          setDialogState(() {
                            orderQuantity++;
                            quantityController.text =
                                orderQuantity.toString();
                          });
                        }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(
                        AppColors.onPrimaryColor),
                    overlayColor: WidgetStateProperty.all(
                        AppColors.onSecondaryColor),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                    minimumSize: WidgetStateProperty.all(const Size(110, 43)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(
                      orderQuantity > availableToAdd
                          ? AppColors.primaryVariantColor
                          : AppColors.secondaryColor,
                    ),
                  ),
                  onPressed: orderQuantity > availableToAdd
                      ? null
                      : () async {
                    if (orderQuantity > availableToAdd) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Solo puedes agregar $availableToAdd unidad(es) de ${item['name']} al carrito.',
                            ),
                          ),
                        );
                      }
                    } else {
                      String itemId = item['id'];
                      try {
                        await CartService().addItemToCart(
                            itemId, orderQuantity);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Añadiste $orderQuantity unidad(es) de ${item['name']} al carrito.',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al agregar al carrito: $e'),
                            ),
                          );
                        }
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  }


  void modalObject() {
    List<dynamic> images = widget.item['image'] ?? [];
    final CarouselSliderController carouselController = CarouselSliderController();
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
                          carouselController: carouselController,
                          options: CarouselOptions(
                            height: 150.0,
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
                                child: SizedBox(
                                  width: 170.0,
                                  child: Image.network(
                                    imgUrl,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: progress.expectedTotalBytes != null
                                              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.broken_image, size: 50, color: Colors.red),
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
                            top: 60,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                carouselController.previousPage();
                              },
                            ),
                          ),

                        // Flecha derecha
                        if (currentIndex < images.length - 1)
                          Positioned(
                            right: 10,
                            top: 60,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: () {
                                carouselController.nextPage();
                              },
                            ),
                          ),
                      ],
                    )
                  else
                    const Text("No hay imágenes disponibles."),
                  const SizedBox(height: 15),
                  // Nombre del producto centrado
                  Center(
                    child: Text(
                      widget.item['name']!,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Información adicional
                  Text(
                    "Disponibles: ${widget.item['quantity']!}",
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Detalle: ${widget.item['detail']!}",
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
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
  void _showImagePreview(BuildContext context, List<dynamic> images,
      int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery
                    .of(context)
                    .size
                    .height * 0.6,
                maxWidth: MediaQuery
                    .of(context)
                    .size
                    .width * 0.9,
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
                    backgroundDecoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                    ),
                    pageController: PageController(initialPage: initialIndex),
                    onPageChanged: (index) {},
                  ),
                  Positioned(
                    right: 0.0,
                    child: IconButton(
                      icon: const Icon(
                          Icons.close, color: AppColors.primaryVariantColor,
                          size: 30),
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

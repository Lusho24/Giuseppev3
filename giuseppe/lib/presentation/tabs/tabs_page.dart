import 'package:flutter/material.dart';
import 'package:giuseppe/presentation/tabs/dispatch_order/dispatch_order_tab.dart';
import 'package:giuseppe/presentation/tabs/inventory/object_form/object_form.dart';
import 'package:giuseppe/presentation/tabs/orders/orders_tab.dart';
import 'package:giuseppe/presentation/tabs/inventory/inventory_tab.dart';
import 'package:giuseppe/presentation/tabs/search_object/search_object_tab.dart';
import 'package:giuseppe/presentation/tabs/users/users_tab.dart';

class TabsPage extends StatefulWidget {
  final bool isAdmin;
  const TabsPage({super.key, required this.isAdmin});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int _selectedItemIndex = 0;


  // * Opciones de tabs para admin
  late final List<Widget> _adminTabsOptions = [
    const InventoryTab(),
    const ObjectForm(),
    const DispatchOrderTab(),
    OrdersTab(isAdmin: widget.isAdmin)
  ];

  // Navegación para admin
  late final List<NavigationDestination> _adminDestinations = const [
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view_sharp),
      label: 'Inventario',
    ),
    NavigationDestination(
      icon: Icon(Icons.add),
      selectedIcon: Icon(Icons.add_box),
      label: 'Añadir',
    ),
    NavigationDestination(
      icon: Icon(Icons.email_outlined),
      selectedIcon: Icon(Icons.email_rounded),
      label: 'Orden',
    ),
    NavigationDestination(
      icon: Icon(Icons.folder_open_outlined),
      selectedIcon: Icon(Icons.folder_rounded),
      label: 'Historial',
    )
  ];

  // * Opciones de tabs para usuario normal
  late final List<Widget> _userTabsOptions = [
    const InventoryTab(),
    const SearchObjectTab(),
    OrdersTab(isAdmin: widget.isAdmin)
  ];

  late final List<NavigationDestination> _userDestinations = const [
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view_sharp),
      label: 'Inventario',
    ),
    NavigationDestination(
      icon: Icon(Icons.camera_alt_outlined),
      selectedIcon: Icon(Icons.camera_alt),
      label: 'Buscar Objetos',
    ),
    NavigationDestination(
      icon: Icon(Icons.folder_open_outlined),
      selectedIcon: Icon(Icons.folder_rounded),
      label: 'Ordenes',
    )
  ];

  void _onItemTapped(int index){
    setState(() {
      _selectedItemIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabsOptions = widget.isAdmin ? _adminTabsOptions : _userTabsOptions;
    final destinations = widget.isAdmin ? _adminDestinations : _userDestinations;

    return Scaffold(
      body: tabsOptions.elementAt(_selectedItemIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedItemIndex,
        onDestinationSelected: _onItemTapped,
        destinations: destinations
      ),

    );
  }

}

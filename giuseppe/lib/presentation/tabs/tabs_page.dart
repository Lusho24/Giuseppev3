import 'package:flutter/material.dart';
import 'package:giuseppe/presentation/tabs/dispatch_order/dispatch_order_tab.dart';
import 'package:giuseppe/presentation/tabs/inventory/object_form/add_object_form.dart';
import 'package:giuseppe/presentation/tabs/order_history_user/order_history_user_tab.dart';
import 'package:giuseppe/presentation/tabs/inventory/inventory_tab.dart';
import 'package:giuseppe/presentation/tabs/orders_history_admin/order_history_admin_tab.dart';
import 'package:giuseppe/presentation/tabs/search_object/search_object_tab.dart';
import 'package:giuseppe/presentation/tabs/tabs_view_model.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  bool _isLoading = true;
  final TabsViewModel _viewModel = TabsViewModel();
  late final bool _isAdmin;

  int _selectedItemIndex = 0;

  // * Opciones de tabs para admin
  late final List<Widget> _adminTabsOptions = [
    const InventoryTab(),
    const AddObjectForm(),
    const DispatchOrderTab(),
    const OrderHistoryAdminTab()
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
    const OrderHistoryUserTab()
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

  Future<void> _initSessionData() async {
    Map<String, dynamic>? sessionData =  await _viewModel.fetchSessionInLocalStorage();
    setState(() {
      _isAdmin = sessionData!['isAdmin'];
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _initSessionData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tabsOptions = _isAdmin ? _adminTabsOptions : _userTabsOptions;
    final destinations = _isAdmin ? _adminDestinations : _userDestinations;

    return Scaffold(
      body: tabsOptions.elementAt(_selectedItemIndex),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.onSecondaryColor,
        indicatorColor: AppColors.primaryColor,
        selectedIndex: _selectedItemIndex,
        onDestinationSelected: _onItemTapped,
        destinations: destinations
      ),

    );
  }

}

import 'package:flutter/material.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  // Simulamos una lista de usuarios
  final List<Map<String, String>> _users = [
    {"name": "Nombre usuario", "cargo": "Cargo", "informacion": "Información  Usuario", "image": "assets/images/users/foto1.PNG"},
    {"name": "Laura Pausini", "cargo": "Patrona", "informacion": "Información  Laura", "image": "assets/images/users/foto2.jpg"},
    {"name": "Hermano Lucho", "cargo": "Cargo 1", "informacion": "Información  Usuario", "image": "assets/images/users/foto1.PNG"},
    {"name": "Yo", "cargo": "cargo 2", "informacion": "Información  Usuario", "image": "assets/images/users/foto1.PNG"},
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
                    child: ElevatedButton(
                        onPressed: (){},
                        child: const Text("Añadir Usuario")
                    )
                  )
                ],
              ),
            ),
          ])
          ),
          // Grid de usuarios
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 10.0,
              childAspectRatio: 2.1,
            ),
            delegate: SliverChildBuilderDelegate( (context, index) {
                return Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 1.5), // Línea gris
                    ),
                  ),
                  child: UserCard(user: _users[index])
                );
              },
              childCount: _users.length,
            ),
          ),
        ],
      )
    );
  }
}

class UserCard extends StatelessWidget {
  final Map<String, String> user;
  const UserCard({
    required this.user,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              user['image']!,
              height: 140.0,
              width: 120.0,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 15.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( user['name']!,
                    style: const TextStyle(
                      color: AppColors.primaryTextColor,
                      fontSize: 22.5
                    ),
                    overflow: TextOverflow.ellipsis, // Evitar desbordamiento
                  ),
                  Text( user['cargo']!,
                    style: const TextStyle(
                        color: AppColors.variantTextColor,
                        fontSize: 15
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5.0),
                  Text(user['informacion']!,
                    style: const TextStyle(
                        color: AppColors.primaryTextColor,
                        fontSize: 15
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: (){},
                        child: const Text("Editar")
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                          onPressed: (){},
                          child: const Text("Eliminar")
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}



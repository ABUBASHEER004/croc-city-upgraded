import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlayersScreen extends StatelessWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Players"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/players/add');
        },
        icon: const Icon(Icons.person_add),
        label: const Text("Add Player"),
      ),

      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.groups),
                ),
                title: const Text(
                  "Total Players",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "0",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                hintText: "Search player...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 120,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No Players Found",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Tap the Add Player button\nto register your first player.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
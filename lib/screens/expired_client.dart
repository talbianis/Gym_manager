import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/client_viewmodel.dart';
import 'package:intl/intl.dart';

class ExpiredClientsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expired Clients")),
      body: Consumer<ClientViewModel>(
        builder: (context, vm, child) {
          final expired = vm.expiredClients;

          if (expired.isEmpty) {
            return Center(child: Text("No expired clients."));
          }

          return ListView.builder(
            itemCount: expired.length,
            itemBuilder: (context, index) {
              final c = expired[index];
              return Card(
                color: Colors.red[300],
                child: ListTile(
                  leading: Icon(Icons.warning, color: Colors.red),

                  title: Text(c.name),
                  subtitle: Text(
                    "Expired: ${DateFormat('yyyy-MM-dd').format(c.endDate)}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

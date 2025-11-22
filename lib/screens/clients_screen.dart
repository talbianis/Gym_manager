import 'package:flutter/material.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/view_models/client_viewmodel.dart';
import 'package:gym_manager/widgets/add_client_dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ClientsScreen extends StatefulWidget {
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  @override
  void initState() {
    super.initState();
    // Load clients when screen opens
    Provider.of<ClientViewModel>(context, listen: false).loadClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clients")),
      body: Consumer<ClientViewModel>(
        builder: (context, clientVM, child) {
          final clients = clientVM.clients;

          if (clients.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColor.mainColor,
                strokeWidth: 6,
              ),
            );
          }

          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              final daysLeft = client.endDate.difference(DateTime.now()).inDays;

              return Card(
                color: daysLeft <= 5
                    ? Colors.red[100]
                    : Colors.greenAccent, // Expiry warning
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(client.name),
                  subtitle: Text(
                    "days left: ${daysLeft}\nPhone: ${client.phone}\nEnds: ${DateFormat('yyyy-MM-dd').format(client.endDate)}",
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      clientVM.deleteClient(client.id!);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.greenAccent,

        onPressed: () {
          showDialog(context: context, builder: (_) => AddClientDialog());
        },
      ),
    );
  }
}

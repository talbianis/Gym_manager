import 'package:flutter/material.dart';
import 'package:gym_manager/models/client.dart';
import 'package:gym_manager/view_models/client_viewmodel.dart';
import 'package:gym_manager/widgets/recharge_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ClientListItem extends StatelessWidget {
  final Client client;

  const ClientListItem({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysLeft = client.endDate.difference(DateTime.now()).inDays;

    return Card(
      color: daysLeft <= 0
          ? Colors.red[500]
          : (daysLeft < 5 ? Colors.red[100] : Colors.greenAccent),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(client.name),
        subtitle: Text(
          "Days left: ${daysLeft}\nPhone: ${client.phone}\nEnds: ${DateFormat('yyyy-MM-dd').format(client.endDate)}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: Text("Recharge"),
              onPressed: () {
                showRechargeDialog(client, context);
              },
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(client, context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Client client, BuildContext context) {
    final clientVM = Provider.of<ClientViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete ${client.name}?"),
        content: Text("Are you sure you want to delete this client?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete"),
            onPressed: () async {
              await clientVM.deleteClient(client.id!);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

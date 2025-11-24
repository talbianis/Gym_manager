import 'package:flutter/material.dart';
import 'package:gym_manager/models/client.dart';

import 'package:gym_manager/widgets/client_list_item.dart';

class ClientsList extends StatelessWidget {
  final List<Client> clients;
  final Future<void> Function() onRefresh;

  const ClientsList({Key? key, required this.clients, required this.onRefresh})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return ClientListItem(client: client);
        },
      ),
    );
  }
}

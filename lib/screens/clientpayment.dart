import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/database/db_helper.dart';
import 'package:gym_manager/models/client.dart';
import 'package:gym_manager/models/client_payment.dart';

import 'package:intl/intl.dart';

class ClientPaymentsScreen extends StatelessWidget {
  final Client client;

  const ClientPaymentsScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColor.whitecolor),
        ),
        title: Text(
          "${client.name} • Payments",
          style: TextStyle(color: AppColor.whitecolor),
        ),
        backgroundColor: AppColor.mainColor,
      ),
      body: FutureBuilder(
        future: DBHelper.getPaymentsByClient(client.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return Center(
              child: Text(
                "No payments yet until recharge.",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
              ),
            );
          }

          final payments = snapshot.data as List<ClientPayment>;

          return ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: payments.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, i) {
              final p = payments[i];

              return ListTile(
                leading: Icon(Icons.payments, color: AppColor.successcolor),
                title: Text("${p.amount} DA"),
                subtitle: Text(
                  "${p.subscriptionType ?? 'Payment'} • "
                  "${DateFormat('yyyy-MM-dd').format(p.date)}",
                ),
              );
            },
          );
        },
      ),
    );
  }
}

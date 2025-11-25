import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/models/client.dart';
import 'package:gym_manager/view_models/client_viewmodel.dart';
import 'package:gym_manager/widgets/recharge_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ClientListItem extends StatelessWidget {
  final Client client;

  const ClientListItem({Key? key, required this.client}) : super(key: key);

  Color getStatusColor(int daysLeft) {
    if (daysLeft <= 0) return Colors.red;
    if (daysLeft < 5) return Colors.orange;
    return Colors.green;
  }

  String getStatusText(int daysLeft) {
    if (daysLeft <= 0) return "Expired";
    if (daysLeft < 5) return "Expiring Soon";
    return "Active";
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = client.endDate.difference(DateTime.now()).inDays;
    final statusColor = getStatusColor(daysLeft);

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar (optional)
            CircleAvatar(
              radius: 26,
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(Icons.person, color: statusColor, size: 30.sp),
            ),

            SizedBox(width: 12.w),

            // Text section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    client.name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Status Pill
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      getStatusText(daysLeft),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Days & Phone
                  Text("Days left: $daysLeft"),
                  Text("Phone: ${client.phone}"),
                  Text(
                    "Ends: ${DateFormat('yyyy-MM-dd').format(client.endDate)}",
                  ),
                ],
              ),
            ),

            // Right side buttons
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => showRechargeDialog(client, context),
                  child: Text(
                    "Recharge",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.mainColor,
                  ),
                ),

                SizedBox(height: 8),

                IconButton(
                  icon: Icon(Icons.delete, color: Color(0xFFE53935)),
                  onPressed: () => _showDeleteDialog(client, context),
                ),
              ],
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

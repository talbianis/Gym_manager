import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/models/client.dart';
import 'package:gym_manager/widgets/normal_appbar.dart';
import 'package:gym_manager/widgets/search_appbar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../view_models/client_viewmodel.dart';

class ExpiredClientsScreen extends StatefulWidget {
  final Client? client;
  const ExpiredClientsScreen({super.key, this.client});

  @override
  State<ExpiredClientsScreen> createState() => _ExpiredClientsScreenState();
}

class _ExpiredClientsScreenState extends State<ExpiredClientsScreen> {
  final TextEditingController searchControllerexp = TextEditingController();
  bool isSearchingexp = false;
  @override
  void dispose() {
    searchControllerexp.dispose();
    super.dispose();
  }

  void onSearchChangedexp(String query) {
    Provider.of<ClientViewModel>(context, listen: false).searchClients(query);
  }

  void clearSearchexp() {
    searchControllerexp.clear();
    Provider.of<ClientViewModel>(context, listen: false).clearExpiredSearch();
    setState(() {
      isSearchingexp = false;
    });
  }

  void onSearchChangedForExpired(String query) {
    Provider.of<ClientViewModel>(
      context,
      listen: false,
    ).searchExpiredClients(query);
  }

  void startSearch() {
    setState(() {
      isSearchingexp = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isSearchingexp
          ? SearchAppBar(
              searchController: searchControllerexp,
              onClearSearch: clearSearchexp,
              onSearchChanged: onSearchChangedForExpired,
            )
          : NormalAppBar(onSearchPressed: startSearch, text: "Expired Clients"),

      //     : AppBar(

      //         leading: IconButton(
      //           icon: Icon(Icons.arrow_back, color: AppColor.whitecolor),
      //           onPressed: () {
      //             Navigator.pop(context);
      //           },
      //         ),
      //         title: Text(
      //           "Expired Clients",
      //           style: TextStyle(color: AppColor.whitecolor),
      //         ),
      //           actions: [
      //   Container(
      //     margin: EdgeInsets.only(right: 12),
      //     decoration: BoxDecoration(
      //       color: Colors.grey.shade200,
      //       shape: BoxShape.circle,
      //     ),
      //     child: IconButton(
      //       icon: Icon(Icons.search, color: Colors.black87),
      //       onPressed: onSearchPressed,
      //     ),
      //   ),
      // ],
      //   backgroundColor: AppColor.mainColor,
      // ),
      body: Consumer<ClientViewModel>(
        builder: (context, vm, child) {
          final expired = vm.expiredClients;

          if (expired.isEmpty) {
            return Center(
              child: Text(
                "No expired clients.",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12.w),
            itemCount: expired.length,
            itemBuilder: (context, index) {
              final c = expired[index];

              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 28.r,
                        backgroundColor: AppColor.warningcolor.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: AppColor.warningcolor,
                          size: 30.sp,
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Text Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 6.h),

                            // Status Tag
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.warningcolor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                "Expired",
                                style: TextStyle(
                                  color: AppColor.warningcolor[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            SizedBox(height: 6.h),

                            Text("Phone: ${c.phone}"),
                            Text(
                              "Expired on: ${DateFormat('yyyy-MM-dd').format(c.endDate)}",
                            ),
                          ],
                        ),
                      ),

                      // Warning Icon
                      Column(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColor.warningcolor,
                            size: 30.sp,
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Color(0xFFE53935)),
                            onPressed: () => _showDeleteDialog(c, context),
                          ),
                        ],
                      ),
                    ],
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

void _showDeleteDialog(Client client, BuildContext context) {
  final clientVM = Provider.of<ClientViewModel>(context, listen: false);

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text("Delete ${client.name}?"),
      content: Text("Are you sure you want to delete this client?"),
      actions: [
        TextButton(child: Text("Cancel"), onPressed: () => Navigator.pop(ctx)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text("Delete"),
          onPressed: () async {
            await clientVM.deleteClient(client.id!);
            if (!ctx.mounted) return;
            Navigator.pop(ctx);
          },
        ),
      ],
    ),
  );
}

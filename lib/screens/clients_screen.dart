import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/view_models/client_viewmodel.dart';
import 'package:gym_manager/widgets/add_client_dialog.dart';
import 'package:gym_manager/widgets/client_list.dart';
import 'package:gym_manager/widgets/empty_searchstate.dart';
import 'package:gym_manager/widgets/loading_state.dart';
import 'package:gym_manager/widgets/no_clientstate.dart';
import 'package:gym_manager/widgets/normal_appbar.dart';
import 'package:gym_manager/widgets/search_appbar.dart';
import 'package:provider/provider.dart';

class ClientsScreen extends StatefulWidget {
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _initialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    await Provider.of<ClientViewModel>(context, listen: false).loadClients();
    setState(() {
      _initialLoad = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    Provider.of<ClientViewModel>(context, listen: false).searchClients(query);
  }

  void _clearSearch() {
    _searchController.clear();
    Provider.of<ClientViewModel>(context, listen: false).clearSearch();
    setState(() {
      _isSearching = false;
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _addNewClient() {
    showDialog(context: context, builder: (_) => AddClientDialog()).then((_) {
      _loadClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSearching
          ? SearchAppBar(
              searchController: _searchController,
              onClearSearch: _clearSearch,
              onSearchChanged: _onSearchChanged,
            )
          : NormalAppBar(onSearchPressed: _startSearch),

      body: Consumer<ClientViewModel>(
        builder: (context, clientVM, child) {
          final displayClients = clientVM.filteredClients;
          final todayExpiredClients = clientVM.getTodayExpiredClients();

          if (_initialLoad) return LoadingState();

          return Column(
            children: [
              if (todayExpiredClients.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColor.warningcolor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: AppColor.warningcolor,
                        size: 26,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          todayExpiredClients.length == 1
                              ? "${todayExpiredClients[0].name} انتهى اشتراكه اليوم."
                              : "${todayExpiredClients.length} من العملاء انتهت اشتراكاتهم اليوم.",
                          style: TextStyle(
                            color: AppColor.warningcolor.shade700,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: Builder(
                  builder: (_) {
                    if (clientVM.clients.isEmpty) {
                      return NoClientsState(onAddClient: _addNewClient);
                    }

                    if (displayClients.isEmpty &&
                        clientVM.searchQuery.isNotEmpty) {
                      return EmptySearchState(
                        query: clientVM.searchQuery,
                        onClearSearch: _clearSearch,
                      );
                    }

                    return ClientsList(
                      clients: displayClients,
                      onRefresh: _loadClients,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: _isSearching
          ? null
          : FloatingActionButton(
              backgroundColor: AppColor.mainColor,
              child: Icon(Icons.add, color: AppColor.whitecolor),
              onPressed: _addNewClient,
            ),
    );
  }
}

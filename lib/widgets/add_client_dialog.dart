import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/view_models/client_viewmodel.dart';
import 'package:provider/provider.dart';
import '../models/client.dart';
import 'package:intl/intl.dart';

class AddClientDialog extends StatefulWidget {
  const AddClientDialog({Key? key}) : super(key: key);

  @override
  State<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _subscriptionType = "1 Month";

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add New Client"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Text("Start Date: "),
                TextButton(
                  child: Text(DateFormat('yyyy-MM-dd').format(_startDate!)),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate!,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                        _endDate = picked.add(Duration(days: 30)); // optional
                      });
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text("End Date: "),
                TextButton(
                  child: Text(DateFormat('yyyy-MM-dd').format(_endDate!)),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate!,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _endDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
            DropdownButton<String>(
              value: _subscriptionType,
              items: [
                "1 Month",
                "3 Months",
                "1 Session",
              ].map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
              onChanged: (val) {
                setState(() {
                  _subscriptionType = val!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text("Add"),
          onPressed: () {
            if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.greenAccent,
                  content: Text("Please fill all fields"),
                ),
              );
              return;
            }

            final newClient = Client(
              name: _nameController.text,
              phone: _phoneController.text,
              startDate: _startDate!,
              endDate: _endDate!,
              subscriptionType: _subscriptionType,
            );

            Provider.of<ClientViewModel>(
              context,
              listen: false,
            ).addClient(newClient);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

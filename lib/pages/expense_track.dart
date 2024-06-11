import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budgetplannertracker/services/firestore_expense.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:budgetplannertracker/firebase_options.dart';

class ExpenseTrack extends StatefulWidget {
  final String trip;
  ExpenseTrack({Key? key, required this.trip}) : super(key: key);
  State<ExpenseTrack> createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrack> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Food';
  final FirestoreService _firestoreService = FirestoreService();

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_formatAmount);
  }

  void _formatAmount() {
    final text = _amountController.text;
    if (text.isEmpty) return;
    _amountController.removeListener(_formatAmount);

    final value = double.tryParse(text.replaceAll(RegExp(r'[^\d]'), ''));
    if (value != null) {
      _amountController.text = _currencyFormatter.format(value);
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    }

    _amountController.addListener(_formatAmount);
  }

  void _addExpense() async {
    if (_formKey.currentState!.validate()) {
      final amount = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
      await _firestoreService.addExpense(
        widget.trip,
        amount,
        _descriptionController.text,
        _selectedCategory,
      );
      _amountController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCategory = 'Food';
      });
    }
  }

  void _editExpense(String id, String amount, String description, String category) {
    _amountController.text = _currencyFormatter.format(double.parse(amount));
    _descriptionController.text = description;
    _selectedCategory = category;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Expense'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(labelText: 'Category'),
                  items: ['Food', 'Transport', 'Shopping', 'Other'].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final amount = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
                  await _firestoreService.updateExpense(
                    widget.trip,
                    id,
                    amount,
                    _descriptionController.text,
                    _selectedCategory,
                  );
                  _amountController.clear();
                  _descriptionController.clear();
                  setState(() {
                    _selectedCategory = 'Food';
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  double _calculateTotal(List<Map<String, dynamic>> expenses) {
    return expenses.fold(0, (sum, item) {
      return sum + double.parse(item['amount']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(labelText: 'Category'),
                      items: ['Food', 'Transport', 'Shopping', 'Other'].map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addExpense,
                      child: Text('Add Expense'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firestoreService.getExpenses(widget.trip),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading expenses'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No expenses found'));
                  }
                  final expenses = snapshot.data!;
                  final totalExpense = _calculateTotal(expenses);

                  return Column(
                    children: [
                      Text(
                        'Total Expense: ${_currencyFormatter.format(totalExpense)}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return ListTile(
                            title: Text(expense['description']!),
                            subtitle: Text('${expense['category']} - ${_currencyFormatter.format(double.parse(expense['amount']))}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _editExpense(
                                      expense['id'],
                                      expense['amount'],
                                      expense['description'],
                                      expense['category'],
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _firestoreService.deleteExpense(widget.trip, expense['id']);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

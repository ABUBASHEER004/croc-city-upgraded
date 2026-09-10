import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/finance_repository.dart';
import '../../models/fee_category.dart';

class FeeCategoriesScreen extends StatelessWidget {
  const FeeCategoriesScreen({super.key});

  Future<void> _add(BuildContext context) async {
    final title = TextEditingController();
    final amount = TextEditingController();
    final description = TextEditingController();

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('New fee category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: title, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 10),
                TextField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Default amount (₦)'),
                ),
                const SizedBox(height: 10),
                TextField(controller: description, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Save')),
          ],
        ),
      );

      if (result != true) return;
      final name = title.text.trim();
      final parsedAmount = double.tryParse(amount.text.trim().replaceAll(',', '')) ?? 0;
      if (name.isEmpty) {
        _message(context, 'Enter a fee category name.');
        return;
      }
      if (parsedAmount < 0) {
        _message(context, 'Amount cannot be negative.');
        return;
      }

      await FinanceRepository().saveFeeCategory(
        FeeCategory(id: '', title: name, amount: parsedAmount, description: description.text.trim(), active: true),
      );
      if (context.mounted) _message(context, 'Fee category saved.');
    } catch (e) {
      if (context.mounted) _message(context, 'Could not save fee category: $e');
    } finally {
      title.dispose();
      amount.dispose();
      description.dispose();
    }
  }

  Future<void> _delete(BuildContext context, FeeCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete fee category?'),
        content: Text('Remove “${category.title}” from the reusable fee list? Existing invoices are not changed.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await FinanceRepository().deleteFeeCategory(category.id);
      if (context.mounted) _message(context, 'Fee category deleted.');
    } catch (e) {
      if (context.mounted) _message(context, 'Could not delete fee category: $e');
    }
  }

  void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final repo = FinanceRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Fee Categories')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        icon: const Icon(Icons.add),
        label: const Text('Add fee'),
      ),
      body: StreamBuilder<List<FeeCategory>>(
        stream: repo.watchFeeCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('Unable to load fee categories right now.')));
          }
          final items = snapshot.data ?? <FeeCategory>[];
          if (items.isEmpty) {
            return const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No fee categories yet. Add your first academy fee.')));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = items[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.category_outlined)),
                  title: Text(category.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(category.description.isEmpty ? (category.active ? 'Active fee category' : 'Inactive') : category.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_money(category.amount), style: const TextStyle(fontWeight: FontWeight.w900)),
                      IconButton(tooltip: 'Delete', onPressed: () => _delete(context, category), icon: const Icon(Icons.delete_outline)),
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

String _money(double value) => NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2).format(value);

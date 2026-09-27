import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/app_user.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../data/finance_repository.dart';
import '../../models/invoice.dart';
import '../../models/payment.dart';
import '../../models/scholarship.dart';
import 'create_invoice_screen.dart';
import 'fee_categories_screen.dart';
import 'payment_history_screen.dart';
import 'scholarship_screen.dart';
import 'pay_invoice_screen.dart';

class FinanceDashboardScreen extends StatelessWidget {
  const FinanceDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return user.isAdmin ? const _AdminFinanceView() : _ParentFinanceView(user: user);
  }
}

class _AdminFinanceView extends StatelessWidget {
  const _AdminFinanceView();
  @override
  Widget build(BuildContext context) {
    final repo = FinanceRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Finance Command Centre')),
      body: StreamBuilder<List<Invoice>>(
        stream: repo.watchInvoices(),
        builder: (context, invoiceSnapshot) {
          final invoices = invoiceSnapshot.data ?? const <Invoice>[];
          return StreamBuilder<List<Payment>>(
            stream: repo.watchPayments(),
            builder: (context, paymentSnapshot) {
              final payments = paymentSnapshot.data ?? const <Payment>[];
              final billed = invoices.fold<double>(0, (sum, i) => sum + i.amount);
              final collected = payments.fold<double>(0, (sum, p) => sum + p.amount);
              final outstanding = invoices.fold<double>(0, (sum, i) => sum + i.balance);
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  const _HeroCard(title: 'Academy finance', subtitle: 'Live billing, collections and parent visibility in one place.', icon: Icons.account_balance_wallet_outlined),
                  const SizedBox(height: 16),
                  LayoutBuilder(builder: (context, c) {
                    final cards = [
                      _MoneyCard(label: 'Billed', value: _money(billed), icon: Icons.receipt_long_outlined),
                      _MoneyCard(label: 'Collected', value: _money(collected), icon: Icons.payments_outlined),
                      _MoneyCard(label: 'Outstanding', value: _money(outstanding), icon: Icons.pending_actions_outlined),
                    ];
                    if (c.maxWidth < 720) return Column(children: cards.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: e)).toList());
                    return Row(children: [for (var i = 0; i < cards.length; i++) Expanded(child: Padding(padding: EdgeInsets.only(right: i == cards.length - 1 ? 0 : 10), child: cards[i]))]);
                  }),
                  const SizedBox(height: 14),
                  _SectionCard(title: 'Finance actions', children: [
                    _ActionTile(icon: Icons.add_card_outlined, title: 'Create invoice', subtitle: 'Bill a player and link the invoice to their parent.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()))),
                    _ActionTile(icon: Icons.payments_outlined, title: 'Record payment', subtitle: 'Post a payment and update the invoice balance instantly.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()))),
                    _ActionTile(icon: Icons.category_outlined, title: 'Fee categories', subtitle: 'Maintain reusable academy fee types.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeCategoriesScreen()))),
                    _ActionTile(icon: Icons.school_outlined, title: 'Scholarships', subtitle: 'Record financial assistance for players.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScholarshipScreen()))),
                  ]),
                  const SizedBox(height: 14),
                  _SectionCard(title: 'Latest invoices', children: invoices.take(6).map((i) => _InvoiceRow(invoice: i, admin: true)).toList()),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ParentFinanceView extends StatelessWidget {
  const _ParentFinanceView({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final repo = FinanceRepository();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees & Payments'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: StreamBuilder<List<Invoice>>(
        stream: repo.watchInvoices(parentId: user.uid),
        builder: (context, invoiceSnapshot) {
          final invoices = invoiceSnapshot.data ?? const <Invoice>[];
          return StreamBuilder<List<Payment>>(
            stream: repo.watchPayments(parentId: user.uid),
            builder: (context, paymentSnapshot) {
              final payments = paymentSnapshot.data ?? const <Payment>[];
              return StreamBuilder<List<Scholarship>>(
                stream: repo.watchScholarships(parentId: user.uid),
                builder: (context, scholarshipSnapshot) {
                  final scholarships = scholarshipSnapshot.data ?? const [];
                  final due = invoices.fold<double>(0, (sum, i) => sum + i.balance);
                  final paid = payments.fold<double>(0, (sum, p) => sum + p.amount);
                  final assistance = scholarships.fold<double>(0, (sum, item) => sum + item.amount);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    children: [
                      _HeroCard(
                        title: 'Welcome, ${user.firstName.isEmpty ? 'Parent' : user.firstName}',
                        subtitle: 'Your child’s financial records update automatically when the academy posts a change.',
                        icon: Icons.family_restroom_outlined,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _MoneyCard(label: 'Outstanding', value: _money(due), icon: Icons.pending_actions_outlined)),
                          const SizedBox(width: 10),
                          Expanded(child: _MoneyCard(label: 'Paid', value: _money(paid), icon: Icons.verified_outlined)),
                        ],
                      ),
                      if (assistance > 0) ...[
                        const SizedBox(height: 10),
                        _MoneyCard(label: 'Scholarship assistance', value: _money(assistance), icon: Icons.school_outlined),
                      ],
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Invoices',
                        children: invoices.isEmpty
                            ? [const _EmptyFinance(message: 'No invoices are linked to your parent account yet. The academy will publish them here automatically.')]
                            : invoices.map((i) => _InvoiceRow(invoice: i, admin: false)).toList(),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Recent payments',
                        children: payments.isEmpty
                            ? [const _EmptyFinance(message: 'No payments have been recorded yet.')]
                            : payments.take(10).map((p) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
                                  title: Text(_money(p.amount), style: const TextStyle(fontWeight: FontWeight.w800)),
                                  subtitle: Text('${p.playerName} · ${p.method}\n${DateFormat('d MMM yyyy · h:mm a').format(p.paidAt)}'),
                                  isThreeLine: true,
                                )).toList(),
                      ),
                      if (scholarships.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: 'Scholarship assistance',
                          children: scholarships.map<Widget>((s) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(child: Icon(Icons.school_outlined)),
                                title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                                subtitle: Text('${s.playerName} · ${_money(s.amount)}${s.reason.isEmpty ? '' : '\n${s.reason}'}'),
                                isThreeLine: true,
                              )).toList(),
                        ),
                      ],
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.title, required this.subtitle, required this.icon});
  final String title, subtitle; final IconData icon;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [CircleAvatar(radius: 28, child: Icon(icon, size: 28)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text(subtitle)]))])));
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({required this.label, required this.value, required this.icon});
  final String label, value; final IconData icon;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [CircleAvatar(child: Icon(icon, size: 20)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))]))])));
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title; final List<Widget> children;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 8), ...children])));
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right), onTap: onTap);
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({required this.invoice, required this.admin});
  final Invoice invoice; final bool admin;
  @override
  Widget build(BuildContext context) {
    final canPay = !admin && !invoice.isPaid && invoice.balance > 0.009;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: invoice.isPaid
                ? Colors.green.withValues(alpha: .10)
                : Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              invoice.isPaid ? Icons.check_rounded : Icons.receipt_long_outlined,
              color: invoice.isPaid ? Colors.green : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${invoice.invoiceNumber} · ${invoice.title}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${invoice.playerName.isEmpty ? 'Player' : invoice.playerName}${admin && invoice.parentName.isNotEmpty ? ' · ${invoice.parentName}' : ''}\nDue ${DateFormat('d MMM yyyy').format(invoice.dueDate)} · ${invoice.displayStatus}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(invoice.balance),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              if (canPay) ...[
                const SizedBox(height: 7),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PayInvoiceScreen(invoice: invoice),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  child: const Text('Pay now'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyFinance extends StatelessWidget {
  const _EmptyFinance({required this.message}); final String message;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text(message, textAlign: TextAlign.center));
}

String _money(double value) => NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2).format(value);

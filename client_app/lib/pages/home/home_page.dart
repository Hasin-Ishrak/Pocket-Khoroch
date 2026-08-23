import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import '../../providers/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid;
    if (userId != null) {
      await context.read<TransactionProvider>().loadTransactions(
        userId,
        syncFirst: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hi, ${user?.displayName.split(' ').first ?? 'Student'} 👋',
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                onPressed: () =>
                    themeProvider.toggleTheme(!themeProvider.isDarkMode),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-transaction'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child:
            transactionProvider.isLoading &&
                transactionProvider.transactions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverToBoxAdapter(
                      child: BalanceCard(
                        balance: transactionProvider.balance,
                        income: transactionProvider.totalIncome,
                        expense: transactionProvider.totalExpense,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (transactionProvider.transactions.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.receipt_long_rounded,
                        title: 'No transactions yet',
                        subtitle:
                            'Tap the + button to add your first income or expense',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final transaction =
                              transactionProvider.transactions[index];
                          return TransactionTile(
                            transaction: transaction,
                            onTap: () => context.push(
                              '/edit-transaction',
                              extra: transaction,
                            ),
                            onDelete: () {
                              final userId = authProvider.currentUser!.uid;
                              context
                                  .read<TransactionProvider>()
                                  .deleteTransaction(userId, transaction.id);
                            },
                          );
                        }, childCount: transactionProvider.transactions.length),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

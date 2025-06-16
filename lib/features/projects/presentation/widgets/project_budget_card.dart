import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectBudgetCard extends StatelessWidget {
  const ProjectBudgetCard({
    super.key,
    required this.budget,
    required this.actualCost,
  });

  final double budget;
  final double actualCost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    final remainingBudget = budget - actualCost;
    final isOverBudget = remainingBudget < 0;
    final spentPercentage = (actualCost / budget * 100).clamp(0.0, 100.0);

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isOverBudget
                        ? colorScheme.errorContainer
                        : colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isOverBudget ? Icons.warning : Icons.account_balance_wallet,
                    color: isOverBudget
                        ? colorScheme.onErrorContainer
                        : colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Budget',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Budget visualization
            _buildBudgetVisualization(context, spentPercentage, isOverBudget),

            const SizedBox(height: 24),

            // Budget breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildBudgetRow(
                    context,
                    label: 'Total Budget',
                    amount: currencyFormat.format(budget),
                    color: colorScheme.onSurface,
                    icon: Icons.account_balance,
                  ),
                  const SizedBox(height: 12),
                  _buildBudgetRow(
                    context,
                    label: 'Spent',
                    amount: currencyFormat.format(actualCost),
                    color: colorScheme.primary,
                    icon: Icons.payments,
                  ),
                  const Divider(height: 24),
                  _buildBudgetRow(
                    context,
                    label: isOverBudget ? 'Over Budget' : 'Remaining',
                    amount: currencyFormat.format(remainingBudget.abs()),
                    color: isOverBudget
                        ? colorScheme.error
                        : colorScheme.tertiary,
                    icon: isOverBudget ? Icons.trending_up : Icons.savings,
                    isHighlight: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetVisualization(
    BuildContext context,
    double spentPercentage,
    bool isOverBudget,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${spentPercentage.toStringAsFixed(1)}%',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isOverBudget ? colorScheme.error : colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Spent',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: spentPercentage / 100,
          backgroundColor: colorScheme.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            isOverBudget ? colorScheme.error : colorScheme.primary,
          ),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildBudgetRow(
    BuildContext context, {
    required String label,
    required String amount,
    required Color color,
    required IconData icon,
    bool isHighlight = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style:
                (isHighlight
                        ? theme.textTheme.titleSmall
                        : theme.textTheme.bodyMedium)
                    ?.copyWith(
                      fontWeight: isHighlight
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isHighlight
                          ? color
                          : theme.colorScheme.onSurfaceVariant,
                    ),
          ),
        ),
        Text(
          amount,
          style:
              (isHighlight
                      ? theme.textTheme.titleSmall
                      : theme.textTheme.bodyMedium)
                  ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

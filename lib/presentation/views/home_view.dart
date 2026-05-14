import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../viewmodels/churn_viewmodel.dart';
import '../viewmodels/market_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/glass_card.dart';
import 'prediction_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildSystemStatus(),
                  const SizedBox(height: 24),
                  _buildMarketTicker(),
                  const SizedBox(height: 32),
                  _buildStatGrid(),
                  const SizedBox(height: 32),
                  _buildMarketTrends(),
                  const SizedBox(height: 32),
                  _buildRecentActivity(),
                  const SizedBox(height: 32),
                  _buildModelLibrary(),
                  const SizedBox(height: 32),
                  _buildChartSection(),
                  const SizedBox(height: 32),
                  _buildActionCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'AI Model: Ready',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const Text(
            'TFLite v2.15',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Financial Intelligence',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                ),
              ),
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 22),
                tooltip: 'Logout',
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showProfileDialog(context),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.surface,
                  child: Icon(FontAwesomeIcons.user, size: 18, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              // Close dialog
              Navigator.pop(context);
              
              // Clear data
              context.read<ChurnViewModel>().clearHistory();
              
              // Perform logout
              await context.read<AuthViewModel>().logout();
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final user = context.read<AuthViewModel>().currentUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('User Profile', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Icon(FontAwesomeIcons.user, size: 30, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(user?.email ?? 'Unknown User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Financial Intelligence Account', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard('Total Customers', '10,245', FontAwesomeIcons.users, AppColors.primary),
        _buildStatCard('Churn Rate', '14.2%', FontAwesomeIcons.arrowTrendUp, AppColors.error),
        _buildStatCard('Avg Balance', '\$76.5k', FontAwesomeIcons.wallet, AppColors.success),
        _buildStatCard('Active Users', '7,892', FontAwesomeIcons.bolt, AppColors.warning),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Market Performance Index',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        GlassCard(
          height: 250,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: RepaintBoundary(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(2.6, 2),
                      FlSpot(4.9, 5),
                      FlSpot(6.8, 3.1),
                      FlSpot(8, 4),
                      FlSpot(9.5, 3),
                      FlSpot(11, 4),
                    ],
                    isCurved: true,
                    gradient: AppColors.primaryGradient,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.primary.withValues(alpha: 0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketTicker() {
    return Consumer<MarketViewModel>(
      builder: (context, marketVM, child) {
        if (marketVM.stocks.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: marketVM.stocks.length,
            itemBuilder: (context, index) {
              final stock = marketVM.stocks[index];
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  borderRadius: 16,
                  child: Row(
                    children: [
                      Text(
                        stock.symbol,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${stock.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        stock.isUp ? FontAwesomeIcons.caretUp : FontAwesomeIcons.caretDown,
                        size: 12,
                        color: stock.isUp ? AppColors.success : AppColors.error,
                      ),
                      Text(
                        '${stock.changePercentage.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: stock.isUp ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMarketTrends() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Market Trends',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        Consumer<MarketViewModel>(
          builder: (context, marketVM, child) {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: marketVM.stocks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final stock = marketVM.stocks[index];
                return GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (stock.isUp ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          stock.isUp ? FontAwesomeIcons.arrowTrendUp : FontAwesomeIcons.arrowTrendDown,
                          size: 16,
                          color: stock.isUp ? AppColors.success : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(stock.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(stock.symbol, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${stock.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${stock.isUp ? '+' : ''}${stock.changePercentage.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: stock.isUp ? AppColors.success : AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        Consumer<ChurnViewModel>(
          builder: (context, churnVM, child) {
            if (churnVM.history.isEmpty) {
              return GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No recent predictions',
                      style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: churnVM.history.take(3).length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = churnVM.history[index];
                return GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (item.isHighRisk ? AppColors.error : AppColors.success).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.isHighRisk ? Icons.warning_rounded : Icons.check_circle_rounded,
                          size: 20,
                          color: item.isHighRisk ? AppColors.error : AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.customer.surname, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${(item.probability * 100).toStringAsFixed(1)}% Churn Risk',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${DateTime.now().difference(item.timestamp).inMinutes}m ago',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildModelLibrary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Model Library',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildModelCard('Neural Network', 'Active', AppColors.primary),
              const SizedBox(width: 16),
              _buildModelCard('Random Forest', 'Backup', AppColors.textSecondary),
              const SizedBox(width: 16),
              _buildModelCard('Logistic Reg', 'Legacy', AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModelCard(String name, String status, Color color) {
    return GlassCard(
      width: 150,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.hub_rounded, color: color, size: 24),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(status, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PredictionView()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Predict New Churn',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Analyze customer behavior and predict churn probability in seconds.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(FontAwesomeIcons.chevronRight, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

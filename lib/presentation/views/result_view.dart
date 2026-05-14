import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme.dart';
import '../viewmodels/churn_viewmodel.dart';
import '../widgets/glass_card.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChurnViewModel>();
    final probability = provider.lastPrediction ?? 0.0;
    final isHighRisk = probability > 0.5;

    return Scaffold(
      body: Stack(
        children: [
          // Risk-based background gradient
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isHighRisk 
                      ? AppColors.error.withOpacity(0.2) 
                      : AppColors.success.withOpacity(0.2),
                  AppColors.background,
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildResultHeader(isHighRisk),
                  const SizedBox(height: 60),
                  _buildGauge(probability, isHighRisk),
                  const SizedBox(height: 60),
                  _buildDetailsCard(provider),
                  const Spacer(),
                  _buildActionButtons(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeader(bool isHighRisk) {
    return Column(
      children: [
        Icon(
          isHighRisk ? FontAwesomeIcons.triangleExclamation : FontAwesomeIcons.circleCheck,
          color: isHighRisk ? AppColors.error : AppColors.success,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          isHighRisk ? 'High Churn Risk' : 'Low Churn Risk',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isHighRisk ? AppColors.error : AppColors.success,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Based on our AI analysis of customer behavior',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildGauge(double probability, bool isHighRisk) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: probability,
            strokeWidth: 12,
            backgroundColor: Colors.white.withOpacity(0.1),
            color: isHighRisk ? AppColors.error : AppColors.success,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(probability * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'Probability',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsCard(ChurnViewModel provider) {
    final customer = provider.currentCustomer;
    return GlassCard(
      child: Column(
        children: [
          _buildDetailRow('Customer', customer.surname),
          const Divider(color: Colors.white10),
          _buildDetailRow('Age', '${customer.age} years'),
          const Divider(color: Colors.white10),
          _buildDetailRow('Balance', '\$${customer.balance.toStringAsFixed(2)}'),
          const Divider(color: Colors.white10),
          _buildDetailRow('Status', customer.isActiveMember ? 'Active Member' : 'Inactive'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Dashboard', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('New Analysis', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

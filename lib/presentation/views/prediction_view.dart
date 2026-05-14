import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme.dart';
import '../viewmodels/churn_viewmodel.dart';
import '../widgets/glass_card.dart';
import 'result_view.dart';

class PredictionView extends StatefulWidget {
  const PredictionView({super.key});

  @override
  State<PredictionView> createState() => _PredictionViewState();
}

class _PredictionViewState extends State<PredictionView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _surnameController;
  late TextEditingController _creditScoreController;
  late TextEditingController _ageController;
  late TextEditingController _balanceController;
  late TextEditingController _salaryController;
  late TextEditingController _tenureController;
  late TextEditingController _productsController;

  String _selectedGeography = 'France';
  String _selectedGender = 'Female';
  bool _hasCrCard = true;
  bool _isActiveMember = true;
  String _selectedModelType = 'Local';
  final List<String> _modelOptions = ['Local', 'Random Forest', 'SVM', 'KNN'];

  @override
  void initState() {
    super.initState();
    final customer = context.read<ChurnViewModel>().currentCustomer;
    _surnameController = TextEditingController(text: customer.surname);
    _creditScoreController = TextEditingController(text: customer.creditScore.toString());
    _ageController = TextEditingController(text: customer.age.toString());
    _balanceController = TextEditingController(text: customer.balance.toString());
    _salaryController = TextEditingController(text: customer.estimatedSalary.toString());
    _tenureController = TextEditingController(text: customer.tenure.toString());
    _productsController = TextEditingController(text: customer.numOfProducts.toString());
    _selectedGeography = customer.geography;
    _selectedGender = customer.gender;
    _hasCrCard = customer.hasCrCard;
    _isActiveMember = customer.isActiveMember;
  }

  @override
  void dispose() {
    _surnameController.dispose();
    _creditScoreController.dispose();
    _ageController.dispose();
    _balanceController.dispose();
    _salaryController.dispose();
    _tenureController.dispose();
    _productsController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<ChurnViewModel>();
      
      // Configure model type in data source (Simplified for MVVM)
      // Note: In a full architecture, this would be passed through the UseCase
      // For this demo, we'll assume the provider handles it or we use a global toggle
      
      provider.updateCustomer(
        provider.currentCustomer.copyWith(
          surname: _surnameController.text,
          creditScore: int.parse(_creditScoreController.text),
          age: int.parse(_ageController.text),
          balance: double.parse(_balanceController.text),
          estimatedSalary: double.parse(_salaryController.text),
          tenure: int.parse(_tenureController.text),
          numOfProducts: int.parse(_productsController.text),
          geography: _selectedGeography,
          gender: _selectedGender,
          hasCrCard: _hasCrCard,
          isActiveMember: _isActiveMember,
        ),
      );

      await provider.predictChurn();
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResultView()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Prediction'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<ChurnViewModel>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Model Configuration'),
                      const SizedBox(height: 16),
                      _buildDropdown('Select Prediction Model', _modelOptions, _selectedModelType, (val) => setState(() => _selectedModelType = val!)),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Customer Identity'),
                      const SizedBox(height: 16),
                      _buildTextField(_surnameController, 'Surname', FontAwesomeIcons.userTag),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildDropdown('Geography', ['France', 'Spain', 'Germany'], _selectedGeography, (val) => setState(() => _selectedGeography = val!))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDropdown('Gender', ['Female', 'Male'], _selectedGender, (val) => setState(() => _selectedGender = val!))),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      _buildSectionTitle('Financial Profile'),
                      const SizedBox(height: 16),
                      _buildTextField(_creditScoreController, 'Credit Score', FontAwesomeIcons.gaugeHigh, isNumber: true),
                      const SizedBox(height: 16),
                      _buildTextField(_balanceController, 'Balance', FontAwesomeIcons.wallet, isNumber: true),
                      const SizedBox(height: 16),
                      _buildTextField(_salaryController, 'Estimated Salary', FontAwesomeIcons.moneyBillWave, isNumber: true),
                      
                      const SizedBox(height: 32),
                      _buildSectionTitle('Engagement'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_ageController, 'Age', FontAwesomeIcons.calendar, isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(_tenureController, 'Tenure (Years)', FontAwesomeIcons.clock, isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_productsController, 'Num of Products', FontAwesomeIcons.box, isNumber: true),
                      const SizedBox(height: 16),
                      _buildSwitch('Has Credit Card', _hasCrCard, (val) => setState(() => _hasCrCard = val)),
                      _buildSwitch('Is Active Member', _isActiveMember, (val) => setState(() => _isActiveMember = val)),
                      
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: provider.isPredicting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: provider.isPredicting 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Analyze Churn Risk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.2),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (isNumber && double.tryParse(value) == null) return 'Invalid number';
        return null;
      },
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textPrimary)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

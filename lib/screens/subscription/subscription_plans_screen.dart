// lib/screens/subscription/subscription_plans_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/subscription_plan.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<SubscriptionPlan> plans = [
      SubscriptionPlan(
        id: 'basic',
        name: 'Basique',
        description: 'Parfait pour les petites entreprises',
        price: 30000,
        storageLimit: 50,
        documentLimit: 1000,
        features: [
          'Stockage 50 GB',
          'Jusqu\'à 1000 documents',
          'Support email',
          'Accès basique aux statistiques',
        ],
        billingPeriod: 'monthly',
      ),
      SubscriptionPlan(
        id: 'pro',
        name: 'Professionnel',
        description: 'Pour les entreprises en croissance',
        price: 100000,
        storageLimit: 200,
        documentLimit: 5000,
        features: [
          'Stockage 200 GB',
          'Jusqu\'à 5000 documents',
          'Support prioritaire',
          'Statistiques avancées',
          'API accès',
        ],
        billingPeriod: 'monthly',
      ),
      SubscriptionPlan(
        id: 'enterprise',
        name: 'Entreprise',
        description: 'Solution complète pour grandes entreprises',
        price: 150000,
        storageLimit: 1000,
        documentLimit: 50000,
        features: [
          'Stockage 1 TB',
          'Documents illimités',
          'Support 24/7',
          'Statistiques personnalisées',
          'API complète',
          'Formation personnalisée',
        ],
        billingPeriod: 'monthly',
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Choisissez votre plan',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Des solutions adaptées à vos besoins',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildPlansGrid(plans),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Plans d\'abonnement',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: const Text('Comparer les plans'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansGrid(List<SubscriptionPlan> plans) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.7,
      ),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        return _buildPlanCard(plans[index]);
      },
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final bool isPopular = plan.id == 'pro';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPopular ? AppTheme.primaryBlue : Colors.grey[200]!,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: const Text(
                'Plus populaire',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plan.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${plan.price.toStringAsFixed(2)} GNF',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/mois',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ...plan.features.map((feature) => _buildFeatureItem(feature)),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isPopular ? AppTheme.primaryBlue : Colors.grey[200],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Modifier le tarif',
                        style: TextStyle(
                          color: isPopular ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

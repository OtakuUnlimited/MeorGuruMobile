import 'package:flutter/material.dart';
import '../../../constants.dart';

class CheckoutSummaryCard extends StatelessWidget {
  final String subtotal;
  final String discount;
  final String deliveryFee;
  final String tax;
  final String total;

  const CheckoutSummaryCard({
    Key? key,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.tax,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSummaryRow('Subtotal', subtotal),
        _buildSummaryRow('Discount (10%)', discount),
        _buildSummaryRow('Delivery Fee', deliveryFee),
        _buildSummaryRow('Tax (13%)', tax),
        const Divider(height: 24, thickness: 1),
        _buildSummaryRow('Total', total, isGrandTotal: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGrandTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isGrandTotal ? 16 : 14,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
              color: isGrandTotal ? AppColors.textDark : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isGrandTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isGrandTotal ? AppColors.textDark : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
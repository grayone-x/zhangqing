import 'package:flutter/material.dart';
import '../../theme.dart';

/// 底部弹出数字键盘，返回确认金额；取消返回 null
Future<double?> showAmountPad(BuildContext context, String mateName) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AmountPad(mateName: mateName),
  );
}

class _AmountPad extends StatefulWidget {
  final String mateName;
  const _AmountPad({required this.mateName});

  @override
  State<_AmountPad> createState() => _AmountPadState();
}

class _AmountPadState extends State<_AmountPad> {
  String _input = '';

  void _press(String k) {
    setState(() {
      if (k == 'del') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
        return;
      }
      if (k == '.') {
        if (_input.contains('.') || _input.isEmpty) return;
        _input += '.';
        return;
      }
      if (_input.contains('.')) {
        final dec = _input.split('.')[1];
        if (dec.length >= 2) return;
      } else {
        if (_input.length >= 5) return;
        if (_input == '0') return;
      }
      _input += k;
    });
  }

  double? get _amount {
    if (_input.isEmpty || _input == '.' || _input.endsWith('.')) return null;
    return double.tryParse(_input);
  }

  @override
  Widget build(BuildContext context) {
    final amount = _amount;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text('${widget.mateName} · 记账',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSub)),
            const SizedBox(height: 4),
            Text(
              _input.isEmpty ? '¥ 0' : '¥ $_input',
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                  fontFeatures: [FontFeature.tabularFigures()]),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.2,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final k in [
                    '1', '2', '3', '4', '5', '6',
                    '7', '8', '9', '.', '0', 'del'
                  ])
                    _Key(k: k, onTap: () => _press(k)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GestureDetector(
                onTap: amount == null
                    ? null
                    : () => Navigator.pop(context, amount),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color:
                        amount == null ? AppColors.border : AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    amount == null
                        ? '确认'
                        : '确认 ¥${amount.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: amount == null
                          ? AppColors.textWeak
                          : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  final String k;
  final VoidCallback onTap;
  const _Key({required this.k, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDel = k == 'del';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: isDel
              ? const Icon(Icons.backspace_outlined,
                  size: 18, color: AppColors.textWeak)
              : Text(k,
                  style: const TextStyle(
                      fontSize: 17, color: AppColors.textMain)),
        ),
      ),
    );
  }
}

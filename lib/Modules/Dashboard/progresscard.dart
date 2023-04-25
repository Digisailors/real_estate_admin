import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.numerator,
    required this.denominator,
    required this.neumeratorTitle,
    required this.denominatorTitle,
    required this.cardTitle,
    required this.valueColor,
    required this.backGroundColor,
    this.isLedger = false,
  });

  final double numerator;
  final double denominator;
  final String neumeratorTitle;
  final String denominatorTitle;
  final String cardTitle;
  final Color valueColor;
  final Color backGroundColor;
  final bool isLedger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FittedBox(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          color: backGroundColor,
          child: SizedBox(
            height: 300,
            width: 400,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    cardTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Center(
                              child: SizedBox(
                                height: 100,
                                width: 100,
                                child: (numerator == 0 || denominator == 0)
                                    ? CircularProgressIndicator(
                                        value: 1,
                                        color: Colors.grey.shade400,
                                        strokeWidth: 8,
                                      )
                                    : Transform.rotate(
                                        angle: (numerator / denominator) * 100,
                                        child: CircularProgressIndicator(
                                          color: valueColor,
                                          value: isLedger
                                              ? denominator / numerator
                                              : numerator / denominator,
                                          strokeWidth: 8,
                                          backgroundColor: isLedger
                                              ? Colors.blue
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Table(
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: !isLedger
                                ? [
                                    TableRow(children: [
                                      Text(numerator.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4),
                                      Text(denominator.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4),
                                    ]),
                                    TableRow(children: [
                                      Text(neumeratorTitle,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge),
                                      Text(denominatorTitle,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge),
                                    ])
                                  ]
                                : [
                                    TableRow(children: [
                                      Text(
                                          NumberFormat.currency(
                                            locale: 'en-IN',
                                            symbol: '₹',
                                            decimalDigits: 0,
                                          ).format(numerator),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall),
                                    ]),
                                    TableRow(children: [
                                      Text(neumeratorTitle,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge),
                                    ]),
                                    const TableRow(
                                        children: [SizedBox(height: 8)]),
                                    TableRow(children: [
                                      Text(
                                          NumberFormat.currency(
                                            locale: 'en-IN',
                                            symbol: '₹',
                                            decimalDigits: 0,
                                          ).format(denominator),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall),
                                    ]),
                                    TableRow(children: [
                                      Text(denominatorTitle,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge),
                                    ]),
                                  ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

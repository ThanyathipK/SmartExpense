import 'package:flutter/material.dart';

final ValueNotifier<bool> transactionUpdated = ValueNotifier(false);

void notifyTransactionUpdate() {
  transactionUpdated.value = !transactionUpdated.value; 
}
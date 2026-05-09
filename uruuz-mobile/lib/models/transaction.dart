enum TransactionType { deposit, withdrawal, transfer }

enum TransactionStatus { pending, completed, failed }

class Transaction {
  final String id;
  final String? senderWalletId;
  final String? receiverWalletId;
  final int amount;
  final String currency;
  final String type;
  final String status;
  final String reference;
  final String description;
  final DateTime createdAt;

  Transaction({
    required this.id,
    this.senderWalletId,
    this.receiverWalletId,
    required this.amount,
    required this.currency,
    required this.type,
    required this.status,
    required this.reference,
    required this.description,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      senderWalletId: json['sender_wallet_id'],
      receiverWalletId: json['receiver_wallet_id'],
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'UGX',
      type: json['type'] ?? '',
      status: json['status'] ?? 'PENDING',
      reference: json['reference'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

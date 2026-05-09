class Wallet {
  final String id;
  final String userId;
  final String currency;
  final int balance;

  Wallet({
    required this.id,
    required this.userId,
    required this.currency,
    required this.balance,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      currency: json['currency'] ?? 'UGX',
      balance: json['balance'] ?? 0,
    );
  }
}

class WalletBalance {
  final int balance;
  final String currency;

  WalletBalance({required this.balance, required this.currency});

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balance: json['balance'] ?? 0,
      currency: json['currency'] ?? 'UGX',
    );
  }
}

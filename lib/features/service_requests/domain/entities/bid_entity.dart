import 'package:equatable/equatable.dart';

class BidEntity extends Equatable {
  final String id;
  final String requestId;
  final String providerId;
  final String providerName;
  final double amount;
  final String note;
  final DateTime createdAt;

  const BidEntity({
    required this.id,
    required this.requestId,
    required this.providerId,
    required this.providerName,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    requestId,
    providerId,
    providerName,
    amount,
    note,
    createdAt,
  ];
}

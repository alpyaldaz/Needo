import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:needo/features/service_requests/domain/entities/bid_entity.dart';

class BidModel extends BidEntity {
  const BidModel({
    required super.id,
    required super.requestId,
    required super.providerId,
    required super.providerName,
    required super.amount,
    required super.note,
    required super.createdAt,
  });

  factory BidModel.fromJson(Map<String, dynamic> json, String id) {
    return BidModel(
      id: id,
      requestId: json['requestId']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
      providerName: json['providerName']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      note: json['note']?.toString() ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'providerId': providerId,
      'providerName': providerName,
      'amount': amount,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

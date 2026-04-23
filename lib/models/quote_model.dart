import 'dart:convert';

// modelagem do objeto do tipo Quote
class Quote {
  final int? id; // id do documento (opcional, gerado pelo banco de dados)
  final String customerName; // nome do cliente
  final String customerCpf; // cpf do cliente
  final String customerAddress; // endereço do cliente
  final String customerPhone; // telefone do cliente
  final DateTime serviceDate; // data do serviço
  final String mainGoal; // principal objetivo do serviço
  final String serviceDescription; // descrição do serviço
  final double totalPrice; // preço total do serviço

  // construtor da classe Quote
  Quote({
    this.id,
    required this.customerName,
    required this.customerCpf,
    required this.customerAddress,
    required this.customerPhone,
    required this.serviceDate,
    required this.mainGoal,
    required this.serviceDescription,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerCpf': customerCpf,
      'customerAddress': customerAddress,
      'customerPhone': customerPhone,
      'serviceDate': serviceDate.toIso8601String(),
      'mainGoal': mainGoal,
      'serviceDescription': serviceDescription,
      'totalPrice': totalPrice,
    };
  }

  factory Quote.fromMap(Map<String, dynamic> map) {
    return Quote(
      id: map['id'],
      customerName: map['customerName'],
      customerCpf: map['customerCpf'],
      customerAddress: map['customerAddress'],
      customerPhone: map['customerPhone'],
      serviceDate: DateTime.parse(map['serviceDate']),
      mainGoal: map['mainGoal'],
      serviceDescription: map['serviceDescription'],
      totalPrice: map['totalPrice'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Quote.fromJson(String source) => Quote.fromMap(json.decode(source));

  Quote copyWith({
    int? id,
    String? customerName,
    String? customerCpf,
    String? customerAddress,
    String? customerPhone,
    DateTime? serviceDate,
    String? mainGoal,
    String? serviceDescription,
    double? totalPrice,
  }) {
    return Quote(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerCpf: customerCpf ?? this.customerCpf,
      customerAddress: customerAddress ?? this.customerAddress,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceDate: serviceDate ?? this.serviceDate,
      mainGoal: mainGoal ?? this.mainGoal,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

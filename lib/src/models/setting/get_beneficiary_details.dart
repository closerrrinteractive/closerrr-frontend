class BeneficiaryDetail {
  String status;
  String message;
  Data data;
  int statusCode;

  BeneficiaryDetail({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory BeneficiaryDetail.fromJson(Map<String, dynamic> json) =>
      BeneficiaryDetail(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
        statusCode: json["statusCode"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
        "statusCode": statusCode,
      };
}

class Data {
  int id;
  String beneficiaryId;
  int userId;
  String beneficiaryName;
  String bankAccountNumber;
  String bankIfsc;
  String vpa;
  String beneficiaryEmail;
  String beneficiaryPhone;
  String beneficiaryCountryCode;
  String beneficiaryAddress;
  String beneficiaryCity;
  String beneficiaryPostalCode;
  String beneficiaryState;
  DateTime createdAt;
  DateTime updatedAt;

  Data({
    required this.id,
    required this.beneficiaryId,
    required this.userId,
    required this.beneficiaryName,
    required this.bankAccountNumber,
    required this.bankIfsc,
    required this.vpa,
    required this.beneficiaryEmail,
    required this.beneficiaryPhone,
    required this.beneficiaryCountryCode,
    required this.beneficiaryAddress,
    required this.beneficiaryCity,
    required this.beneficiaryPostalCode,
    required this.beneficiaryState,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        beneficiaryId: json["beneficiary_id"],
        userId: json["user_id"],
        beneficiaryName: json["beneficiary_name"],
        bankAccountNumber: json["bank_account_number"],
        bankIfsc: json["bank_ifsc"],
        vpa: json["vpa"],
        beneficiaryEmail: json["beneficiary_email"],
        beneficiaryPhone: json["beneficiary_phone"],
        beneficiaryCountryCode: json["beneficiary_country_code"],
        beneficiaryAddress: json["beneficiary_address"],
        beneficiaryCity: json["beneficiary_city"],
        beneficiaryPostalCode: json["beneficiary_postal_code"],
        beneficiaryState: json["beneficiary_state"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "beneficiary_id": beneficiaryId,
        "user_id": userId,
        "beneficiary_name": beneficiaryName,
        "bank_account_number": bankAccountNumber,
        "bank_ifsc": bankIfsc,
        "vpa": vpa,
        "beneficiary_email": beneficiaryEmail,
        "beneficiary_phone": beneficiaryPhone,
        "beneficiary_country_code": beneficiaryCountryCode,
        "beneficiary_address": beneficiaryAddress,
        "beneficiary_city": beneficiaryCity,
        "beneficiary_postal_code": beneficiaryPostalCode,
        "beneficiary_state": beneficiaryState,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

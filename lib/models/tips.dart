class TipResponse {
  final int id;
  final String name;
  
  TipResponse({
    required this.id,
    required this.name,
  });

  factory TipResponse.fromJson(Map<String, dynamic> json) {
    return TipResponse(
      id: json['id'],
      name: json['name'],
    );
  }
}
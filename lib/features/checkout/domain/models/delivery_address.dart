class DeliveryAddress {
  const DeliveryAddress({
    required this.recipientName,
    required this.phoneNumber,
    required this.state,
    required this.lga,
    required this.streetAddress,
    required this.id,
    required this.town,
  });

  final String recipientName;
  final String phoneNumber;
  final String state;
  final String lga;
  final String town;
  final String streetAddress;
  final String id;

  DeliveryAddress copyWith({
    String? recipientName,
    String? phoneNumber,
    String? state,
    String? lga,
    String? town,
    String? streetAddress,
    String? id,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      state: state ?? this.state,
      lga: lga ?? this.lga,
      streetAddress: streetAddress ?? this.streetAddress,
      town: town ?? this.town,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryAddress &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          recipientName == other.recipientName &&
          phoneNumber == other.phoneNumber &&
          state == other.state &&
          lga == other.lga &&
          town == other.town &&
          streetAddress == other.streetAddress;

  @override
  int get hashCode => Object.hash(
    id,
    recipientName,
    phoneNumber,
    state,
    lga,
    town,
    streetAddress,
  );

  @override
  String toString() {
    return 'DeliveryAddress(id: $id, recipientName: $recipientName, phoneNumber: $phoneNumber, state: $state, lga: $lga, town: $town, streetAddress: $streetAddress)';
  }
}

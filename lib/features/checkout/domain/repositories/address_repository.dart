import 'package:cdcare_address_demo/features/checkout/domain/models/delivery_address.dart';

abstract class AddressRepository {
  Future<List<DeliveryAddress>> getDeliveryAddresses();
  Future<DeliveryAddress> getDeliveryAddressById(String id);
  Future<void> saveDeliveryAddress(DeliveryAddress address);
  Future<void> deleteDeliveryAddress(DeliveryAddress address);
  Future<void> updateDeliveryAddress(DeliveryAddress address);
}

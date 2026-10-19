import 'package:cdcare_address_demo/features/checkout/presentation/widgets/address_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Address Validation Logic', () {
    group('Recipient Name Validation', () {
      test('fails when name is null or empty', () {
        expect(AddressFormStateHelper.validateRecipientName(null), isNotNull);
        expect(AddressFormStateHelper.validateRecipientName(''), isNotNull);
        expect(AddressFormStateHelper.validateRecipientName('   '), isNotNull);
      });

      test('fails when name is less than 3 characters', () {
        expect(AddressFormStateHelper.validateRecipientName('Al'), isNotNull);
      });

      test('passes for valid recipient names', () {
        expect(
          AddressFormStateHelper.validateRecipientName('Muhammad Bashir'),
          isNull,
        );
        expect(
          AddressFormStateHelper.validateRecipientName('Chidi Okafor'),
          isNull,
        );
      });
    });

    group('Nigerian Phone Number Validation', () {
      test('fails when phone number is null or empty', () {
        expect(AddressFormStateHelper.validatePhoneNumber(null), isNotNull);
        expect(AddressFormStateHelper.validatePhoneNumber(''), isNotNull);
      });

      test('fails for invalid or incomplete numbers', () {
        expect(AddressFormStateHelper.validatePhoneNumber('080123'), isNotNull);
        expect(
          AddressFormStateHelper.validatePhoneNumber('12345678901'),
          isNotNull,
        );
        expect(
          AddressFormStateHelper.validatePhoneNumber('01234567890'),
          isNotNull,
        );
        expect(
          AddressFormStateHelper.validatePhoneNumber('080abcdefgh'),
          isNotNull,
        );
      });

      test('passes for valid 11-digit local Nigerian numbers', () {
        expect(
          AddressFormStateHelper.validatePhoneNumber('08012345678'),
          isNull,
        );
        expect(
          AddressFormStateHelper.validatePhoneNumber('07031234567'),
          isNull,
        );
        expect(
          AddressFormStateHelper.validatePhoneNumber('09091234567'),
          isNull,
        );
        expect(
          AddressFormStateHelper.validatePhoneNumber('08123456789'),
          isNull,
        );
        expect(
          AddressFormStateHelper.validatePhoneNumber('09123456789'),
          isNull,
        );
      });

      test('passes for valid international formats (+234 and 234)', () {
        expect(
          AddressFormStateHelper.validatePhoneNumber('+2348012345678'),
          isNull,
        );
        expect(
          AddressFormStateHelper.validatePhoneNumber('2348012345678'),
          isNull,
        );
      });
    });

    group('State, LGA, and Street Validation', () {
      test('state validation requires selection', () {
        expect(AddressFormStateHelper.validateState(null), isNotNull);
        expect(AddressFormStateHelper.validateState(''), isNotNull);
        expect(AddressFormStateHelper.validateState('Lagos'), isNull);
      });

      test('LGA validation requires at least 2 characters', () {
        expect(AddressFormStateHelper.validateLga(null), isNotNull);
        expect(AddressFormStateHelper.validateLga(''), isNotNull);
        expect(AddressFormStateHelper.validateLga('A'), isNotNull);
        expect(AddressFormStateHelper.validateLga('Ikeja'), isNull);
      });

      test('street address validation requires at least 5 characters', () {
        expect(AddressFormStateHelper.validateStreetAddress(null), isNotNull);
        expect(AddressFormStateHelper.validateStreetAddress(''), isNotNull);
        expect(AddressFormStateHelper.validateStreetAddress('Road'), isNotNull);
        expect(
          AddressFormStateHelper.validateStreetAddress(
            '12 Admiralty Way, Lekki',
          ),
          isNull,
        );
      });
    });
  });
}

/// Helper wrapper accessing validation static methods from AddressForm
abstract class AddressFormStateHelper {
  static String? validateRecipientName(String? val) =>
      AddressForm.validateRecipientName(val);
  static String? validatePhoneNumber(String? val) =>
      AddressForm.validatePhoneNumber(val);
  static String? validateState(String? val) => AddressForm.validateState(val);
  static String? validateLga(String? val) => AddressForm.validateLga(val);
  static String? validateStreetAddress(String? val) =>
      AddressForm.validateStreetAddress(val);
}

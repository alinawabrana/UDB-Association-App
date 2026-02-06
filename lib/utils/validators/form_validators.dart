import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

class AFormValidators {
  AFormValidators._();

  static String? validateEmptyText(
    String? value,
    String fieldName, [
    AppLocalizations? l10n,
  ]) {
    if (value == null || value.isEmpty) {
      return l10n?.translate(
            'empty_field',
            params: {'field': fieldName},
          ) ??
          '$fieldName is empty';
    }

    return null;
  }

  static String? validateEmail(String? value, [AppLocalizations? l10n]) {
    if (value == null || value.isEmpty) {
      return l10n?.translate('email_required') ?? 'Email is required';
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return l10n?.translate('invalid_email') ?? 'Invalid email address';
    }

    return null;
  }

  static String? validatePassword(String? value, [AppLocalizations? l10n]) {
    if (value == null || value.isEmpty) {
      return l10n?.translate('password_required') ?? 'Password is required';
    }

    if (value.length < 6) {
      return l10n?.translate('password_length') ??
          'Password must be 6 characters long.';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return l10n?.translate('password_number') ??
          'Password must contain at least one number.';
    }

    return null;
  }

  static String? validatePhoneNumber(
    String? value, {
    AppLocalizations? l10n,
    String? isoCode,
    String? dialCode,
  }) {
    if (value == null || value.isEmpty) {
      return l10n?.translate('phone_required') ?? 'Phone Number is Required';
    }

    final String raw = value.replaceAll(RegExp(r'[\s-]'), '');

    try {
      PhoneNumber parsed;

      if (raw.startsWith('+')) {
        parsed = PhoneNumber.parse(raw);
      } else {
        IsoCode? resolvedIso;
        if (isoCode != null && isoCode.isNotEmpty) {
          try {
            resolvedIso = IsoCode.values.firstWhere(
              (c) => c.name.toUpperCase() == isoCode.toUpperCase(),
            );
          } catch (_) {
            parsed = PhoneNumber.parse(raw);
            return parsed.isValid()
                ? null
                : l10n?.translate('invalid_phone') ?? 'Invalid phone number';
          }
        } else {
          resolvedIso = IsoCode.PK;
        }

        parsed = PhoneNumber.parse(raw, callerCountry: resolvedIso);
      }

      if (parsed.isValid()) {
        return null;
      }
    } catch (e) {
      print('Phone validation parsing failed: $e');
    }

    if (raw.startsWith('+')) {
      final internationalPattern = RegExp(r'^\+\d{7,15}$');
      if (internationalPattern.hasMatch(raw)) {
        return null;
      }
    } else {
      final localPattern = RegExp(r'^\d{7,15}$');
      if (localPattern.hasMatch(raw)) {
        return null;
      }
    }

    return l10n?.translate('invalid_phone') ?? 'Invalid phone number';
  }
}

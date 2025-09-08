/// Data format configuration model for import/export operations.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Tony Chen

library;

/// Configuration for data format specifications.

class DataFormatConfig {
  /// The title of the data format.

  final String title;

  /// List of required fields that must be present.

  final List<String> requiredFields;

  /// List of optional fields that may be present.

  final List<String> optionalFields;

  /// Whether this format is JSON (true) or CSV (false).

  final bool isJson;

  /// Optional description of the format.

  final String? description;

  const DataFormatConfig({
    required this.title,
    required this.requiredFields,
    this.optionalFields = const [],
    this.isJson = false,
    this.description,
  });

  /// Creates a copy of this config with updated properties.

  DataFormatConfig copyWith({
    String? title,
    List<String>? requiredFields,
    List<String>? optionalFields,
    bool? isJson,
    String? description,
  }) {
    return DataFormatConfig(
      title: title ?? this.title,
      requiredFields: requiredFields ?? this.requiredFields,
      optionalFields: optionalFields ?? this.optionalFields,
      isJson: isJson ?? this.isJson,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataFormatConfig &&
        other.title == title &&
        other.requiredFields.toString() == requiredFields.toString() &&
        other.optionalFields.toString() == optionalFields.toString() &&
        other.isJson == isJson &&
        other.description == description;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        requiredFields.hashCode ^
        optionalFields.hashCode ^
        isJson.hashCode ^
        description.hashCode;
  }
}

/// Pre-defined format configurations for common health data types.

class SolidFileDataFormats {
  static const bloodPressure = DataFormatConfig(
    title: 'Blood Pressure CSV Format',
    requiredFields: ['timestamp', 'systolic', 'diastolic', 'heart_rate'],
    optionalFields: ['notes'],
  );

  static const vaccination = DataFormatConfig(
    title: 'Vaccination CSV Format',
    requiredFields: ['timestamp', 'name', 'type'],
    optionalFields: ['location', 'notes', 'batch_number'],
  );

  static const medication = DataFormatConfig(
    title: 'Medication CSV Format',
    requiredFields: [
      'timestamp',
      'name',
      'dosage',
      'frequency',
      'start_date',
    ],
    optionalFields: ['notes'],
  );

  static const diary = DataFormatConfig(
    title: 'Appointment CSV Format',
    requiredFields: ['timestamp', 'content'],
    optionalFields: ['mood', 'tags', 'notes'],
  );

  static const profile = DataFormatConfig(
    title: 'Profile JSON Format',
    requiredFields: [
      'name',
      'address',
      'bestContactPhone',
      'alternativeContactNumber',
      'email',
      'dateOfBirth',
      'gender',
    ],
    isJson: true,
  );
}

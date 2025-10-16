/// Data format configuration model for import/export operations.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
    requiredFields: ['timestamp', 'name', 'dosage', 'frequency', 'start_date'],
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

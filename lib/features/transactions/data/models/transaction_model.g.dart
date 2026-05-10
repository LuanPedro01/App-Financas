// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const TransactionModelSchema = CollectionSchema(
  name: r'TransactionModel',
  id: 1234567890,
  properties: {},
  estimateSize: _transactionModelEstimateSize,
  serialize: _transactionModelSerialize,
  deserialize: _transactionModelDeserialize,
  deserializeProp: _transactionModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _transactionModelGetId,
  getLinks: _transactionModelGetLinks,
  attach: _transactionModelAttach,
  version: '3.1.0+1',
);

// Placeholder — run `flutter pub run build_runner build` to generate.
int _transactionModelEstimateSize(dynamic object, dynamic offsets, dynamic allOffsets) => 0;
dynamic _transactionModelSerialize(dynamic object, dynamic writer, dynamic offsets, dynamic allOffsets) {}
dynamic _transactionModelDeserialize(dynamic id, dynamic reader, dynamic offsets, dynamic allOffsets) => TransactionModel(id: id, title: '', amount: 0, type: TransactionType.expense, date: DateTime.now(), createdAt: DateTime.now());
dynamic _transactionModelDeserializeProp(dynamic prop, dynamic id, dynamic reader, dynamic offset, dynamic allOffsets) => null;
int _transactionModelGetId(dynamic object) => object.id;
List<dynamic> _transactionModelGetLinks(dynamic object) => [];
void _transactionModelAttach(dynamic col, dynamic id, dynamic object) { object.id = id; }

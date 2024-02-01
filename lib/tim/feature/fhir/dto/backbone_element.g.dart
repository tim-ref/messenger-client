// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backbone_element.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackboneElement _$BackboneElementFromJson(Map<String, dynamic> json) =>
    BackboneElement(
      relation: $enumDecode(_$LinkRelationEnumMap, json['relation']),
      url: Uri.parse(json['url'] as String),
    );

const _$LinkRelationEnumMap = {
  LinkRelation.previous: 'previous',
  LinkRelation.self: 'self',
  LinkRelation.next: 'next',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Donations _$DonationsFromJson(Map<String, dynamic> json) => Donations(
      json['title'] as String,
      json['creator'] as String,
      json['user'] as String,
      json['amt'] as String,
    );

Map<String, dynamic> _$DonationsToJson(Donations instance) => <String, dynamic>{
      'title': instance.title,
      'creator': instance.creator,
      'user': instance.user,
      'amt': instance.amt,
    };

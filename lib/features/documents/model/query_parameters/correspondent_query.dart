import 'package:flutter_paperless_mobile/features/documents/model/query_parameters/id_query_parameter.dart';

class CorrespondentQuery extends IdQueryParameter {
  const CorrespondentQuery.fromId(super.id) : super.fromId();
  const CorrespondentQuery.unset() : super.unset();
  const CorrespondentQuery.notAssigned() : super.notAssigned();
  const CorrespondentQuery.anyAssigned() : super.anyAssigned();

  @override
  String get queryParameterKey => 'correspondent';
}

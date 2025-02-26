import 'dart:typed_data';

import 'package:hive_flutter/adapters.dart';
import 'package:paperless_mobile/core/database/hive/hive_config.dart';

part 'client_certificate.g.dart';

@HiveType(typeId: HiveTypeIds.clientCertificate)
class ClientCertificate {
  @HiveField(0)
  Uint8List bytes;
  @HiveField(1)
  String? passphrase;


  ClientCertificate({
    required this.bytes,
    this.passphrase,
  });
}

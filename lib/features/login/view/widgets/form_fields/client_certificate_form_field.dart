import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:paperless_mobile/core/extensions/flutter_extensions.dart';
import 'package:paperless_mobile/features/login/model/client_certificate_form_model.dart';
import 'package:paperless_mobile/generated/l10n/app_localizations.dart';
import 'package:paperless_mobile/helpers/message_helpers.dart';
import 'package:path/path.dart' as p;
import 'obscured_input_text_form_field.dart';

class ClientCertificateFormField extends StatefulWidget {
  static const fkClientCertificate = 'clientCertificate';

  final String? initialPassphrase;
  final Uint8List? initialBytes;

  final ValueChanged<ClientCertificateFormModel?>? onChanged;
  const ClientCertificateFormField({
    super.key,
    this.onChanged,
    this.initialPassphrase,
    this.initialBytes,
  });

  @override
  State<ClientCertificateFormField> createState() =>
      _ClientCertificateFormFieldState();
}

class _ClientCertificateFormFieldState extends State<ClientCertificateFormField>
    with AutomaticKeepAliveClientMixin {
  File? _selectedFile;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FormBuilderField<ClientCertificateFormModel?>(
      key: const ValueKey('login-client-cert'),
      name: ClientCertificateFormField.fkClientCertificate,
      onChanged: widget.onChanged,
      initialValue: widget.initialBytes != null
          ? ClientCertificateFormModel(
              bytes: widget.initialBytes!,
              passphrase: widget.initialPassphrase,
            )
          : null,
      builder: (field) {
        final theme =
            Theme.of(context).copyWith(dividerColor: Colors.transparent); //new
        return Theme(
          data: theme,
          child: ExpansionTile(
            title: Text(S.of(context)!.clientcertificate),
            subtitle: Text(S.of(context)!.configureMutualTLSAuthentication),
            children: [
              InputDecorator(
                decoration: InputDecoration(
                  errorText: field.errorText,
                  border: InputBorder.none,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _onSelectFile(field),
                              child: Text(S.of(context)!.select),
                            ),
                            _buildSelectedFileText(field).paddedOnly(left: 8),
                          ],
                        ),
                        if (_selectedFile != null)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              _selectedFile = null;
                              field.didChange(null);
                            }),
                          )
                      ],
                    ).padded(8),
                    // ListTile(
                    //   leading: ElevatedButton(
                    //     onPressed: () => _onSelectFile(field),
                    //     child: Text(S.of(context)!.select),
                    //   ),
                    //   title: _buildSelectedFileText(field),
                    //   trailing: AbsorbPointer(
                    //     absorbing: field.value == null,
                    //     child: _selectedFile != null
                    //         ? IconButton(
                    //             icon: const Icon(Icons.close),
                    //             onPressed: () => setState(() {
                    //               _selectedFile = null;
                    //               field.didChange(null);
                    //             }),
                    //           )
                    //         : null,
                    //   ),
                    // ),
                    if (_selectedFile != null) ...[
                      ObscuredInputTextFormField(
                        key: const ValueKey('login-client-cert-passphrase'),
                        initialValue: field.value?.passphrase,
                        onChanged: (value) => field.didChange(
                          field.value?.copyWith(passphrase: value),
                        ),
                        label: S.of(context)!.passphrase,
                      ).padded(),
                    ]
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onSelectFile(
    FormFieldState<ClientCertificateFormModel?> field,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) {
      return;
    }
    final path = result.files.single.path!;
    if (p.extension(path) != '.pfx') {
      showSnackBar(context, S.of(context)!.invalidCertificateFormat);
      return;
    }
    File file = File(result.files.single.path!);
    setState(() {
      _selectedFile = file;
    });
    final bytes = await file.readAsBytes();

    final changedValue = field.value?.copyWith(bytes: bytes) ??
        ClientCertificateFormModel(bytes: bytes);
    field.didChange(changedValue);
  }

  Widget _buildSelectedFileText(
      FormFieldState<ClientCertificateFormModel?> field) {
    if (field.value == null) {
      assert(_selectedFile == null);
      return Text(
        S.of(context)!.selectFile,
        style: Theme.of(context).textTheme.labelMedium?.apply(
              color: Theme.of(context).hintColor,
            ),
      );
    } else {
      assert(_selectedFile != null);
      return Text(
        _selectedFile!.path.split("/").last,
        style: const TextStyle(
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}

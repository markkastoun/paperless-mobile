import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperless_mobile/core/logic/error_code_localization_mapper.dart';
import 'package:paperless_mobile/core/model/error_message.dart';
import 'package:paperless_mobile/features/documents/bloc/documents_cubit.dart';
import 'package:paperless_mobile/features/documents/bloc/documents_state.dart';
import 'package:paperless_mobile/features/documents/view/widgets/selection/bulk_delete_confirmation_dialog.dart';
import 'package:paperless_mobile/features/documents/view/widgets/selection/saved_view_selection_widget.dart';
import 'package:paperless_mobile/features/documents/view/widgets/sort_documents_button.dart';
import 'package:paperless_mobile/generated/l10n.dart';
import 'package:paperless_mobile/util.dart';

class DocumentsPageAppBar extends StatefulWidget with PreferredSizeWidget {
  final List<Widget> actions;

  const DocumentsPageAppBar({
    super.key,
    this.actions = const [],
  });
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  State<DocumentsPageAppBar> createState() => _DocumentsPageAppBarState();
}

class _DocumentsPageAppBarState extends State<DocumentsPageAppBar> {
  static const _flexibleAreaHeight = kToolbarHeight + 48.0;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentsCubit, DocumentsState>(
      builder: (context, documentsState) {
        final hasSelection = documentsState.selection.isNotEmpty;
        if (hasSelection) {
          return SliverAppBar(
            expandedHeight: kToolbarHeight + _flexibleAreaHeight,
            snap: true,
            floating: true,
            pinned: true,
            flexibleSpace: _buildFlexibleArea(false),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () =>
                  BlocProvider.of<DocumentsCubit>(context).resetSelection(),
            ),
            title: Text(
                '${documentsState.selection.length} ${S.of(context).documentsSelectedText}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _onDelete(context, documentsState),
              ),
            ],
          );
        } else {
          return SliverAppBar(
            expandedHeight: kToolbarHeight + _flexibleAreaHeight,
            snap: true,
            floating: true,
            pinned: true,
            flexibleSpace: _buildFlexibleArea(true),
            title: BlocBuilder<DocumentsCubit, DocumentsState>(
              builder: (context, state) {
                return Text(
                  '${S.of(context).documentsPageTitle} (${_formatDocumentCount(state.count)})',
                );
              },
            ),
            actions: [
              ...widget.actions,
            ],
          );
        }
      },
    );
  }

  Widget _buildFlexibleArea(bool enabled) {
    return FlexibleSpaceBar(
      background: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
//TODO: replace with sorting stuff...
            SavedViewSelectionWidget(height: 48, enabled: enabled),
          ],
        ),
      ),
    );
  }

  void _onDelete(BuildContext context, DocumentsState documentsState) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) =>
              BulkDeleteConfirmationDialog(state: documentsState),
        ) ??
        false;
    if (shouldDelete) {
      try {
        await BlocProvider.of<DocumentsCubit>(context)
            .bulkRemoveDocuments(documentsState.selection);
        showSnackBar(
          context,
          S.of(context).documentsPageBulkDeleteSuccessfulText,
        );
      } on ErrorMessage catch (error, stackTrace) {
        showError(context, error, stackTrace);
      }
    }
  }

  String _formatDocumentCount(int count) {
    return count > 99 ? "99+" : count.toString();
  }
}

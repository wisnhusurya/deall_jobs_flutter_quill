import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

import '../universal_ui/universal_ui.dart';
import '../widgets/demo_scaffold.dart';

class ReadOnlyPage extends StatefulWidget {
  @override
  _ReadOnlyPageState createState() => _ReadOnlyPageState();
}

const test =
    """{[ { "insert": "I've submitted an application for [Position] at your company. I was excited to learn that I've been shortlisted as one of your potential candidates." }, { "insert": "\n\nI'm reaching out to see if you have any updates on my application status. Please let me know if you're up to a discussion about my skill & expertise. I would be glad to provide additional information if necessary. " }, { "insert": "\n\nI'm looking forward to hearing from you soon. Thank you and have a good day!" }, { "insert": "\n\nRegards," }, { "insert": "\n[Talent's Name]" }, { "attributes": {}, "insert": "\n" } ]}""";

class _ReadOnlyPageState extends State<ReadOnlyPage> {
  final FocusNode _focusNode = FocusNode();

  bool _edit = false;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      documentFilename: isDesktop()
          ? 'assets/sample_data_nomedia.json'
          : 'sample_data_nomedia.json',
      // documentFilename: test,
      builder: _buildContent,
      showToolbar: _edit == true,
      floatingActionButton: FloatingActionButton.extended(
          label: Text(_edit == true ? 'Done' : 'Edit'),
          onPressed: _toggleEdit,
          icon: Icon(_edit == true ? Icons.check : Icons.edit)),
    );
  }

  Widget _buildContent(BuildContext context, QuillController? controller) {
    var quillEditor = QuillEditor(
      controller: controller!,
      scrollController: ScrollController(),
      scrollable: true,
      focusNode: _focusNode,
      autoFocus: true,
      readOnly: !_edit,
      expands: false,
      padding: EdgeInsets.zero,
      embedBuilders: FlutterQuillEmbeds.builders(),
    );
    if (kIsWeb) {
      quillEditor = QuillEditor(
          controller: controller,
          scrollController: ScrollController(),
          scrollable: true,
          focusNode: _focusNode,
          autoFocus: true,
          readOnly: !_edit,
          expands: false,
          padding: EdgeInsets.zero,
          embedBuilders: defaultEmbedBuildersWeb);
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: quillEditor,
    );
  }

  void _toggleEdit() {
    setState(() {
      _edit = !_edit;
    });
  }
}

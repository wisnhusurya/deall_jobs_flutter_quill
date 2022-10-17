import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:path_provider/path_provider.dart';

typedef DemoContentBuilder = Widget Function(
    BuildContext context, QuillController? controller);

// Common scaffold for all examples.
class DemoScaffold extends StatefulWidget {
  const DemoScaffold({
    required this.documentFilename,
    required this.builder,
    this.actions,
    this.showToolbar = true,
    this.floatingActionButton,
    Key? key,
  }) : super(key: key);

  /// Filename of the document to load into the editor.
  final String documentFilename;
  final DemoContentBuilder builder;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showToolbar;

  @override
  _DemoScaffoldState createState() => _DemoScaffoldState();
}

class _DemoScaffoldState extends State<DemoScaffold> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  QuillController? _controller;

  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null && !_loading) {
      _loading = true;
      _loadFromAssets();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadFromAssets() async {
    try {
      final result =
          await rootBundle.loadString('assets/${widget.documentFilename}');

      const test = """
      [
        {
          "insert": "I've submitted an application for [Position] at your company. I was excited to learn that I've been shortlisted as one of your potential candidates."
        },
        {
          "insert": "I'm reaching out to see if you have any updates on my application status. Please let me know if you're up to a discussion about my skill & expertise. I would be glad to provide additional information if necessary. "
        },
        {
          "insert": "\\n\\nI'm looking forward to hearing from you soon. Thank you and have a good day!"
        },
        {
          "insert": "\\n\\nRegards,"
        },
        {
          "insert": "\\n[Talent's Name]"
        },
        {
          "attributes": {},
          "insert": "\\n"
        }
      ]
""";

      final doc = Document.fromJson(jsonDecode(test));
      setState(() {
        _controller = QuillController(
            document: doc, selection: const TextSelection.collapsed(offset: 0));
        _loading = false;
      });
    } catch (error) {
      final doc = Document()..insert(0, 'Empty asset');
      setState(() {
        _controller = QuillController(
            document: doc, selection: const TextSelection.collapsed(offset: 0));
        _loading = false;
      });
    }
  }

  Future<String?> openFileSystemPickerForDesktop(BuildContext context) async {
    return await FilesystemPicker.open(
      context: context,
      rootDirectory: await getApplicationDocumentsDirectory(),
      fsType: FilesystemType.file,
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(body: Center(child: Text('Loading...')));
    }
    final actions = widget.actions ?? <Widget>[];
    var toolbar = QuillToolbar.basic(
      controller: _controller!,
      svgBoldIcon: 'assets/ic_bold.svg',
      svgItalicIcon: 'assets/ic_bold.svg',
      svgListNumberIcon: 'assets/ic_bold.svg',
      svgListBulletIcon: 'assets/ic_bold.svg',
      svgLinkIcon: 'assets/ic_bold.svg',
      embedButtons: FlutterQuillEmbeds.buttons(),
    );
    if (_isDesktop()) {
      toolbar = QuillToolbar.basic(
        controller: _controller!,
        svgBoldIcon: 'assets/ic_bold.svg',
        svgItalicIcon: 'assets/ic_bold.svg',
        svgListNumberIcon: 'assets/ic_bold.svg',
        svgListBulletIcon: 'assets/ic_bold.svg',
        svgLinkIcon: 'assets/ic_bold.svg',
        embedButtons: FlutterQuillEmbeds.buttons(
            filePickImpl: openFileSystemPickerForDesktop),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.grey.shade800,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: _loading || !widget.showToolbar ? null : toolbar,
        actions: actions,
      ),
      floatingActionButton: widget.floatingActionButton,
      body: _loading
          ? const Center(child: Text('Loading...'))
          : widget.builder(context, _controller),
    );
  }

  bool _isDesktop() => !kIsWeb && !Platform.isAndroid && !Platform.isIOS;
}

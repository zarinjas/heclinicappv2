import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'hemed_loader_model.dart';
export 'hemed_loader_model.dart';

class HemedLoaderWidget extends StatefulWidget {
  const HemedLoaderWidget({super.key});

  @override
  State<HemedLoaderWidget> createState() => _HemedLoaderWidgetState();
}

class _HemedLoaderWidgetState extends State<HemedLoaderWidget> {
  late HemedLoaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HemedLoaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(
          'assets/images/Loader.gif',
          width: 200.0,
          height: 200.0,
          fit: BoxFit.fill,
          alignment: Alignment(0.0, 0.0),
        ),
      ),
    );
  }
}

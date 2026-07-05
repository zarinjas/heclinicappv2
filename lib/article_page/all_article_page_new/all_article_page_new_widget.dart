import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import '/components/skeleton_loaders.dart';
import '/components/empty_state_widget.dart';
import '/components/error_state_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'all_article_page_new_model.dart';
export 'all_article_page_new_model.dart';

class AllArticlePageNewWidget extends StatefulWidget {
  const AllArticlePageNewWidget({super.key});

  static String routeName = 'allArticlePageNew';
  static String routePath = '/allArticlePageNew';

  @override
  State<AllArticlePageNewWidget> createState() =>
      _AllArticlePageNewWidgetState();
}

class _AllArticlePageNewWidgetState extends State<AllArticlePageNewWidget> {
  late AllArticlePageNewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AllArticlePageNewModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          title: Text(
            'He Medical Articles',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).titleMediumIsCustom,
                ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            child: StreamBuilder<List<ArticlesRecord>>(
              stream: queryArticlesRecord(
                queryBuilder: (articlesRecord) =>
                    articlesRecord.orderBy('timestamp'),
              ),
              builder: (context, snapshot) {
                // Customize what your widget looks like when it's loading.
                if (!snapshot.hasData) {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: 5,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 10.0),
                      child: SkeletonCard(height: 300.0),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return ErrorStateWidget(
                    onRetry: () => setState(() {}),
                  );
                }

                List<ArticlesRecord> listViewArticlesRecordList =
                    snapshot.data!;

                if (listViewArticlesRecordList.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.article_outlined,
                    title: 'No articles yet',
                    subtitle: 'Check back soon for health tips and updates',
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  itemCount: listViewArticlesRecordList.length,
                  itemBuilder: (context, listViewIndex) {
                    final listViewArticlesRecord =
                        listViewArticlesRecordList[listViewIndex];
                    return Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 10.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed(
                            ArticleDetailPageWidget.routeName,
                            queryParameters: {
                              'title': serializeParam(
                                listViewArticlesRecord.title,
                                ParamType.String,
                              ),
                              'content': serializeParam(
                                listViewArticlesRecord.content,
                                ParamType.String,
                              ),
                              'imageUrl': serializeParam(
                                listViewArticlesRecord.imageUrl,
                                ParamType.String,
                              ),
                              'referenceLabel': serializeParam(
                                listViewArticlesRecord.referenceLabel,
                                ParamType.String,
                              ),
                              'referenceUrl': serializeParam(
                                listViewArticlesRecord.referenceUrl,
                                ParamType.String,
                              ),
                            }.withoutNulls,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4.0,
                                color: Color(0x33000000),
                                offset: Offset(
                                  0.0,
                                  2.0,
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 10.0, 0.0, 10.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      listViewArticlesRecord.imageUrl,
                                      width: double.infinity,
                                      height: 300.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        listViewArticlesRecord.title,
                                        textAlign: TextAlign.start,
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleSmallIsCustom,
                                            ),
                                      ),
                                      RichText(
                                        textScaler:
                                            MediaQuery.of(context).textScaler,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: listViewArticlesRecord
                                                  .content,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    fontSize: 13.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w200,
                                                    lineHeight: 1.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                            )
                                          ],
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmallFamily,
                                                fontSize: 13.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w200,
                                                lineHeight: 1.0,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .titleSmallIsCustom,
                                              ),
                                        ),
                                        textAlign: TextAlign.start,
                                        maxLines: 3,
                                      ),
                                    ]
                                        .divide(SizedBox(height: 10.0))
                                        .addToStart(SizedBox(height: 10.0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

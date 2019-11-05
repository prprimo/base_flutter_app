import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grateful/src/blocs/editJournalEntry/bloc.dart';
import 'package:grateful/src/models/JournalEntry.dart';
import 'package:grateful/src/repositories/JournalEntries/JournalEntryRepository.dart';
import 'package:grateful/src/screens/JournalPageView/JournalPageView.dart';
import 'package:grateful/src/services/navigator.dart';
import 'package:grateful/src/services/routes.dart';
import 'package:grateful/src/widgets/BackgroundGradientProvider.dart';
import 'package:grateful/src/widgets/JournalEntryHero.dart';
import 'package:grateful/src/widgets/Shadower.dart';
import 'package:intl/intl.dart';

class JournalEntryDetailArguments {
  JournalEntry journalEntry;

  JournalEntryDetailArguments({@required this.journalEntry});
}

class JournalEntryDetails extends StatefulWidget {
  final JournalEntry journalEntry;
  JournalEntryDetails(this.journalEntry);

  @override
  State<StatefulWidget> createState() {
    return _JournalEntryDetails(this.journalEntry);
  }
}

class _JournalEntryDetails extends State<JournalEntryDetails>
    with TickerProviderStateMixin {
  Animation<double> _animationController;
  Animation<Offset> _animation;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animation == null) {
      // _animationController = ModalRoute.of(context).animation;
      _animationController = ModalRoute.of(context).animation;
      setState(() {
        _animation =
            Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset(0.0, 0.0))
                .animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.fastOutSlowIn,
        ));
        // _animationController.forward();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    // _animationController.dispose();
  }

  final JournalEntry journalEntry;
  _JournalEntryDetails(this.journalEntry);
  Widget _renderAppBar(context) {
    final EditJournalEntryBloc _journalEntryBloc =
        BlocProvider.of<EditJournalEntryBloc>(context);
    final theme = Theme.of(context);
    return SliverAppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: FlatButton(
          child:
              Icon(Icons.arrow_back, color: theme.appBarTheme.iconTheme.color),
          onPressed: () {
            rootNavigationService.goBack();
          }),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            showDialog(
                context: context,
                builder: (c) {
                  return AlertDialog(
                    title: Text('Delete Journal Entry'),
                    content: Text(
                        'Are you sure you want to delete this journal entry? This cannot be undone.'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('No, do not delete',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                          onPressed: () {
                            _journalEntryBloc
                                .add(DeleteJournalEntry(journalEntry));
                            Navigator.of(context).pop();
                          },
                          child: Text('Yes, delete it',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[900])))
                    ],
                  );
                });
          },
        ),
        FlatButton(
          child: Icon(
            Icons.edit,
            color: Colors.white,
          ),
          onPressed: () {
            rootNavigationService.navigateTo(FlutterAppRoutes.journalPageView,
                arguments: JournalPageArguments(entry: journalEntry));
          },
        )
      ],
    );
  }

  build(context) {
    final EditJournalEntryBloc _journalEntryBloc =
        EditJournalEntryBloc(journalEntryRepository: JournalEntryRepository());
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: BlocProvider<EditJournalEntryBloc>(
          builder: (_) => _journalEntryBloc,
          child: BlocListener<EditJournalEntryBloc, EditJournalEntryState>(
            listener: (context, state) {
              if (state is JournalEntryDeleted) {
                rootNavigationService.goBack();
              }
            },
            bloc: _journalEntryBloc,
            child: AnimatedBuilder(
                animation: _animation,
                builder: (context, snapshot) {
                  return LayoutBuilder(builder: (context, viewportConstraints) {
                    return BackgroundGradientProvider(
                      child: NestedScrollView(
                        headerSliverBuilder: (context, isScrolled) {
                          return [_renderAppBar(context)].toList();
                        },
                        body: ListView(
                          children: <Widget>[
                            Container(
                              height: journalEntry.photographs != null &&
                                      journalEntry.photographs.length > 0
                                  ? 250
                                  : 0,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Container(
                                    child: CarouselSlider(
                                  aspectRatio: 16 / 9,
                                  enlargeCenterPage: true,
                                  viewportFraction: 0.8,
                                  enableInfiniteScroll: false,
                                  items: <Widget>[
                                    ...(journalEntry.photographs ?? [])
                                        .map((p) => CachedNetworkImage(
                                              imageUrl: p.imageUrl,
                                              placeholder: (c, i) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                              imageBuilder: (c, i) {
                                                return Shadower(
                                                    child: Image(
                                                  image: i,
                                                ));
                                              },
                                            ))
                                        .toList()
                                  ],
                                )),
                              ),
                            ),
                            FractionalTranslation(
                              translation: _animation.value,
                              child: Container(
                                constraints: BoxConstraints(
                                    minHeight: viewportConstraints.maxHeight),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30)),
                                    color: Colors.white),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                                DateFormat.yMMMMd()
                                                    .format(journalEntry.date),
                                                style: theme
                                                    .accentTextTheme.headline
                                                    .copyWith(
                                                        fontStyle:
                                                            FontStyle.italic)),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Flexible(
                                              child: Column(
                                            children: <Widget>[
                                              JournalEntryHero(
                                                journalEntry: journalEntry,
                                                inverted: true,
                                              )
                                            ],
                                          )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                }),
          )),
    );
  }
}

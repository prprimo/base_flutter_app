import 'package:flutter/material.dart';
import 'package:grateful/src/blocs/itemFeed/bloc.dart';
import 'package:grateful/src/repositories/JournalEntries/JournalEntryRepository.dart';
import 'package:grateful/src/screens/JournalEntryDetails/JournalEntryDetails.dart';
import 'package:grateful/src/services/navigator.dart';
import 'package:grateful/src/services/routes.dart';
import 'package:grateful/src/widgets/AppDrawer/drawer.dart';
import 'package:grateful/src/widgets/JournalEntryCard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JournalEntryFeed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _JournalEntryFeedState();
  }
}

class _JournalEntryFeedState extends State<JournalEntryFeed> {
  // final items = List.generate(20, (_) => Item.random());
  JournalEntryBloc _journalFeedBloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void initState() {
    _journalFeedBloc =
        JournalEntryBloc(itemRepository: JournalEntryRepository());
    super.initState();
  }

  build(context) {
    final theme = Theme.of(context);
    return Scaffold(
        key: _scaffoldKey,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              FlutterAppRoutes.editJournalEntry,
            );
          },
          child: Icon(Icons.edit),
        ),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.appBarTheme.color,
          textTheme: theme.appBarTheme.textTheme,
          leading: FlatButton(
            child: Icon(Icons.menu, color: theme.appBarTheme.iconTheme.color),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            },
          ),
        ),
        drawer: AppDrawer(),
        body: BlocBuilder<JournalEntryBloc, JournalFeedState>(
          bloc: _journalFeedBloc,
          builder: (context, state) {
            if (state is JournalFeedUnloaded) {
              _journalFeedBloc.add(FetchFeed());
              return Container(
                color: theme.backgroundColor,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is JournalFeedFetched) {
              return Container(
                color: theme.backgroundColor,
                child: SafeArea(
                    child: ListView.builder(
                  itemBuilder: (context, index) {
                    return JournalEntryCard(
                      journalEntry: state.journalEntries[index],
                      onPressed: () {
                        rootNavigationService.navigateTo(
                            FlutterAppRoutes.journalEntryDetails,
                            arguments: JournalEntryDetailArguments(
                                journalEntry: state.journalEntries[index]));
                      },
                    );
                  },
                  itemCount: state.journalEntries.length,
                )),
              );
            }
            return Container();
          },
        ));
  }
}

import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/models/users_list.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

class OBPostParticipantsSearchBox extends StatefulWidget {
  final ValueChanged<User> onPostParticipantPressed;
  final Post post;
  final OBPostParticipantsSearchBoxController controller;

  const OBPostParticipantsSearchBox(
      {Key key,
      this.onPostParticipantPressed,
      @required this.post,
      this.controller})
      : super(key: key);

  @override
  OBPostParticipantsSearchBoxState createState() {
    return OBPostParticipantsSearchBoxState();
  }
}

class OBPostParticipantsSearchBoxState
    extends State<OBPostParticipantsSearchBox> {
  UserService _userService;
  LocalizationService _localizationService;
  ToastService _toastService;

  bool _needsBootstrap;

  CancelableOperation _getAllParticipantsOperation;
  CancelableOperation _searchParticipantsOperation;

  String _searchQuery;
  List<User> _all;
  bool _getAllInProgress;
  List<User> _searchResults;
  bool _searchInProgress;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    if (widget.controller != null) widget.controller.attach(this);
    _all = [];
    _searchResults = [];
    _searchQuery = '';
    _searchInProgress = false;
    _getAllInProgress = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _localizationService = openbookProvider.localizationService;
      _toastService = openbookProvider.toastService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return OBPrimaryColorContainer(
        child:
            _searchQuery.isEmpty ? _buildAllList() : _buildSearchResultsList());
  }

  Widget _buildAllList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          child: OBText(
            'Suggestions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: _buildAllItem,
            itemCount: _all.length,
            padding: const EdgeInsets.all(0),
          ),
        )
      ],
    );
  }

  Widget _buildSearchResultsList() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemBuilder: _buildResultItem,
            itemCount: _searchResults.length + 1,
          ),
        )
      ],
    );
  }

  Widget _buildResultItem(BuildContext context, int index) {
    if (index == _searchResults.length) {
      // LastItem
      if (_searchInProgress) {
        // Search in progress
        return const Padding(
          padding: EdgeInsets.all(10),
          child: Center(child: OBProgressIndicator()),
        );
      } else if (_searchResults.isEmpty) {
        return ListTile(
            leading: const OBIcon(OBIcons.sad),
            title: OBText('No results found'));
      } else {
        return const SizedBox();
      }
    }

    return OBUserTile(
      _searchResults[index],
      onUserTilePressed: widget.onPostParticipantPressed,
    );
  }

  Widget _buildAllItem(BuildContext context, int index) {
    return OBUserTile(
      _all[index],
      onUserTilePressed: widget.onPostParticipantPressed,
    );
  }

  void _bootstrap() {
    debugLog('Bootstrapping');
    refreshAll();
  }

  Future refreshAll() async {
    if (_getAllParticipantsOperation != null)
      _getAllParticipantsOperation.cancel();

    _setGetAllInProgress(true);

    debugLog('Refreshing all post participants');

    try {
      _getAllParticipantsOperation = CancelableOperation.fromFuture(
          _userService.getPostParticipants(post: widget.post));
      UsersList all = await _getAllParticipantsOperation.value;
      _setAll(all.users);
    } catch (error) {
      _onError(error);
    } finally {
      _setGetAllInProgress(false);
      _getAllParticipantsOperation = null;
    }
  }

  Future search(String searchQuery) async {
    if (_searchParticipantsOperation != null)
      _searchParticipantsOperation.cancel();
    _setSearchInProgress(true);

    debugLog('Searching post participants with query:$searchQuery');

    if (searchQuery.isEmpty) {
      clearSearch();
      return null;
    }

    _setSearchQuery(searchQuery);

    try {
      _searchParticipantsOperation = CancelableOperation.fromFuture(_userService
          .searchPostParticipants(query: searchQuery, post: widget.post));
      UsersList searchResults = await _searchParticipantsOperation.value;
      _setSearchResults(searchResults.users);
    } catch (error) {
      _onError(error);
    } finally {
      _setSearchInProgress(false);
      _searchParticipantsOperation = null;
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage, context: context);
    } else {
      _toastService.error(
          message: _localizationService.trans('error__unknown_error'),
          context: context);
      throw error;
    }
  }

  void _setSearchResults(List<User> searchResults) {
    setState(() {
      _searchResults = searchResults;
    });
  }

  void _setAll(List<User> all) {
    setState(() {
      _all = all;
    });
  }

  void _setSearchQuery(String searchQuery) {
    setState(() {
      _searchQuery = searchQuery;
    });
  }

  void _setSearchInProgress(bool searchInProgress) {
    setState(() {
      _searchInProgress = searchInProgress;
    });
  }


  void _setGetAllInProgress(bool getAllInProgress) {
    setState(() {
      _getAllInProgress = getAllInProgress;
    });
  }

  void clearSearch() {
    debugLog('Clearing search');
    setState(() {
      if (_searchParticipantsOperation != null) _searchParticipantsOperation.cancel();
      _searchInProgress = false;
      _searchQuery = '';
      _searchResults = [];
    });
  }

  void debugLog(String log) {
    debugPrint('OBPostParticipantsSearchBox:$log');
  }
}

class OBPostParticipantsSearchBoxController {
  OBPostParticipantsSearchBoxState _state;

  void attach(OBPostParticipantsSearchBoxState state) {
    _state = state;
  }

  Future search(String searchQuery) async {
    if (_state == null || !_state.mounted) {
      debugLog('Tried to search without mounted state');
      return null;
    }

    return _state.search(searchQuery);
  }

  void clearSearch() {
    _state.clearSearch();
  }

  void debugLog(String log) {
    debugPrint('OBPostParticipantsSearchBoxController:$log');
  }
}

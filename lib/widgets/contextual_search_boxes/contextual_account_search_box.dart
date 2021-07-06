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

class OBContextualAccountSearchBox extends StatefulWidget {
  final ValueChanged<User>? onPostParticipantPressed;
  final Post? post;
  final OBContextualAccountSearchBoxController? controller;
  final String? initialSearchQuery;

  const OBContextualAccountSearchBox(
      {Key? key,
      this.onPostParticipantPressed,
      // If passed, searches for post participants, if not all users using the global search API
      this.post,
      this.controller,
      this.initialSearchQuery})
      : super(key: key);

  @override
  OBContextualAccountSearchBoxState createState() {
    return OBContextualAccountSearchBoxState();
  }
}

class OBContextualAccountSearchBoxState
    extends State<OBContextualAccountSearchBox> {
  late UserService _userService;
  late LocalizationService _localizationService;
  late ToastService _toastService;

  late bool _needsBootstrap;

  CancelableOperation? _getAllOperation;
  CancelableOperation? _searchParticipantsOperation;

  late String _searchQuery;
  late List<User> _all;
  late bool _getAllInProgress;
  late List<User> _searchResults;
  late bool _searchInProgress;
  late bool _isInPostContext;

  @override
  void initState() {
    super.initState();
    _isInPostContext = widget.post != null;
    _needsBootstrap = true;
    if (widget.controller != null) widget.controller!.attach(this);
    _all = [];
    _searchResults = [];
    _searchQuery = '';
    _searchInProgress = false;
    _getAllInProgress = false;
  }

  @override
  void dispose() {
    _searchParticipantsOperation?.cancel();
    _getAllOperation?.cancel();
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
      if (widget.initialSearchQuery != null &&
          widget.initialSearchQuery!.isNotEmpty) {
        _searchQuery = widget.initialSearchQuery!;
        _searchInProgress = true;
        Future.delayed(Duration(milliseconds: 0), () {
          search(widget.initialSearchQuery!);
        });
      }
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
            _localizationService.contextual_account_search_box__suggestions,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        _all.isNotEmpty && !_getAllInProgress
            ? Expanded(
                child: ListView.builder(
                  itemBuilder: _buildAllItem,
                  itemCount: _all.length,
                  padding: const EdgeInsets.all(0),
                ),
              )
            : _buildProgressIndicator()
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
            padding: const EdgeInsets.all(0),
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
            leading: const Padding(
              padding: const EdgeInsets.only(left: 10),
              child: const OBIcon(OBIcons.sad),
            ),
            title: OBText(_localizationService.contextual_account_search_box__no_results));
      } else {
        return const SizedBox();
      }
    }

    return OBUserTile(
      _searchResults[index],
      key: Key(_searchResults[index].id.toString()),
      onUserTilePressed: widget.onPostParticipantPressed,
    );
  }

  Widget _buildAllItem(BuildContext context, int index) {
    return OBUserTile(
      _all[index],
      key: Key(_all[index].id.toString()),
      onUserTilePressed: widget.onPostParticipantPressed,
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Center(child: OBProgressIndicator()),
    );
  }

  void _bootstrap() {
    debugLog('Bootstrapping');
    refreshAll();
  }

  Future refreshAll() async {
    if (_getAllOperation != null) _getAllOperation!.cancel();

    _setGetAllInProgress(true);

    debugLog('Refreshing all accounts');

    try {
      _getAllOperation = CancelableOperation.fromFuture(_isInPostContext
          ? _userService.getPostParticipants(post: widget.post!)
          : _userService.getLinkedUsers());
      UsersList all = await _getAllOperation!.value;
      _setAll(all.users!);
    } catch (error) {
      _onError(error);
    } finally {
      _setGetAllInProgress(false);
      _getAllOperation = null;
    }
  }

  Future search(String searchQuery) async {
    if (_searchParticipantsOperation != null)
      _searchParticipantsOperation!.cancel();
    _setSearchInProgress(true);

    debugLog('Searching post participants with query:$searchQuery');

    if (searchQuery == null || searchQuery.isEmpty) {
      clearSearch();
      return null;
    }

    _setSearchQuery(searchQuery);

    try {
      _searchParticipantsOperation = CancelableOperation.fromFuture(
          _isInPostContext
              ? _userService.searchPostParticipants(
                  query: searchQuery, post: widget.post!)
              : _userService.getUsersWithQuery(searchQuery));
      UsersList searchResults = await _searchParticipantsOperation!.value;
      _setSearchResults(searchResults.users!);
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
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);
    } else {
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
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
      if (_searchParticipantsOperation != null)
        _searchParticipantsOperation!.cancel();
      _searchInProgress = false;
      _searchQuery = '';
      _searchResults = [];
    });
  }

  void debugLog(String log) {
    debugPrint('OBPostParticipantsSearchBox:$log');
  }
}

class OBContextualAccountSearchBoxController {
  OBContextualAccountSearchBoxState? _state;
  String? _lastSearchQuery;

  void attach(OBContextualAccountSearchBoxState state) {
    _state = state;
  }

  Future search(String searchQuery) async {
    _lastSearchQuery = searchQuery;

    if (_state == null || (_state != null && !_state!.mounted)) {
      debugLog('Tried to search without mounted state');
      return null;
    }

    return _state!.search(searchQuery);
  }

  void clearSearch() {
    _lastSearchQuery = null;
    _state?.clearSearch();
  }

  String? getLastSearchQuery() {
    return _lastSearchQuery;
  }

  void debugLog(String log) {
    debugPrint('OBContextualAccountSearchBox:$log');
  }
}

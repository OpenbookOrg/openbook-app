import 'dart:async';

import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/widgets/alerts/button_alert.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/load_more.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:Okuna/widgets/search_bar.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tile_group_title.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'buttons/button.dart';
import 'checkbox.dart';

class OBHttpList<T> extends StatefulWidget {
  final OBHttpListItemBuilder<T> listItemBuilder;
  final OBHttpListItemBuilder<T>? selectedListItemBuilder;
  final OBHttpListItemBuilder<T>? searchResultListItemBuilder;
  final OBHttpListSearcher<T>? listSearcher;
  final OBHttpListRefresher<T> listRefresher;
  final OBHttpListOnScrollLoader<T> listOnScrollLoader;
  final OBHttpListController? controller;
  final String resourceSingularName;
  final String resourcePluralName;
  final EdgeInsets padding;
  final IndexedWidgetBuilder? separatorBuilder;
  final ScrollPhysics physics;
  final List<Widget>? prependedItems;
  final OBHttpListSecondaryRefresher? secondaryRefresher;
  final OBHttpListSelectionChangedListener<T>? onSelectionChanged;
  final OBHttpListSelectionChangedListener<T>? onSelectionSubmitted;
  final OBHttpListSelectionSubmitter<T>? selectionSubmitter;
  final bool hasSearchBar;
  final bool isSelectable;

  const OBHttpList(
      {Key? key,
      required this.listItemBuilder,
      required this.listRefresher,
      required this.listOnScrollLoader,
      required this.resourceSingularName,
      required this.resourcePluralName,
      this.physics = const ClampingScrollPhysics(),
      this.padding = const EdgeInsets.all(0),
      this.listSearcher,
      this.searchResultListItemBuilder,
      this.controller,
      this.separatorBuilder,
      this.prependedItems,
      this.hasSearchBar = true,
      this.secondaryRefresher,
      this.isSelectable = false,
      this.onSelectionChanged,
      this.onSelectionSubmitted,
      this.selectionSubmitter,
      this.selectedListItemBuilder})
      : super(key: key);

  @override
  OBHttpListState createState() {
    return OBHttpListState<T>();
  }
}

class OBHttpListState<T> extends State<OBHttpList<T>> {
  late ToastService _toastService;
  late LocalizationService _localizationService;

  GlobalKey<RefreshIndicatorState> _listRefreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late ScrollController _listScrollController;
  List<T> _list = [];
  List<T> _listSearchResults = [];
  List<T> _listSelection = [];
  late List<Widget> _prependedItems;

  late bool _hasSearch;
  late String _searchQuery;
  late bool _needsBootstrap;
  late bool _refreshInProgress;
  late bool _searchRequestInProgress;
  late bool _selectionSubmissionInProgress;
  late bool _loadingFinished;
  late bool _wasBootstrapped;

  CancelableOperation? _searchOperation;
  CancelableOperation? _refreshOperation;
  CancelableOperation? _loadMoreOperation;
  CancelableOperation? _submitSelectionOperation;

  ScrollPhysics noItemsPhysics = const AlwaysScrollableScrollPhysics();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) widget.controller!.attach(this);
    _listScrollController = ScrollController();
    _loadingFinished = false;
    _needsBootstrap = true;
    _refreshInProgress = false;
    _wasBootstrapped = false;
    _searchRequestInProgress = false;
    _selectionSubmissionInProgress = false;
    _hasSearch = false;
    _list = [];
    _searchQuery = '';
    _prependedItems =
        widget.prependedItems != null ? widget.prependedItems!.toList() : [];
  }

  void insertListItem(T listItem,
      {bool shouldScrollToTop = true, bool shouldRefresh = false}) {
    this._list.insert(0, listItem);
    this._setList(this._list.toList());
    if (shouldScrollToTop) scrollToTop(shouldRefresh: shouldRefresh);
  }

  void removeListItem(T listItem) {
    setState(() {
      _list.remove(listItem);
      _listSearchResults.remove(listItem);
    });
  }

  void scrollToTop({bool shouldRefresh = true}) {
    if (_listScrollController.hasClients) {
      if (_listScrollController.offset == 0 && shouldRefresh) {
        _refreshWithRefreshIndicator();
      }

      _listScrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void dispose() {
    super.dispose();
    if (_searchOperation != null) _searchOperation!.cancel();
    if (_loadMoreOperation != null) _loadMoreOperation!.cancel();
    if (_refreshOperation != null) _refreshOperation!.cancel();
    _submitSelectionOperation?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OpenbookProvider.of(context);
      _localizationService = provider.localizationService;
      _toastService = provider.toastService;
      _bootstrap();
      _needsBootstrap = false;
    }

    List<Widget> columnItems = [];

    if (widget.listSearcher != null && widget.hasSearchBar) {
      columnItems.add(SizedBox(
          child: OBSearchBar(
        onSearch: _onSearch,
        hintText: _localizationService
            .user_search__list_search_text(widget.resourcePluralName.toLowerCase()),
      )));
    }

    Widget listItems = _hasSearch ? _buildSearchResultsList() : _buildList();

    if (widget.isSelectable) {
      listItems = IgnorePointer(
        ignoring: _selectionSubmissionInProgress,
        child: listItems,
      );
    }

    columnItems.add(Expanded(
      child: listItems,
    ));

    if (widget.isSelectable) {
      columnItems.add(_buildSelectionActionButtons());
    }

    return Column(
      children: columnItems,
      mainAxisSize: MainAxisSize.max,
    );
  }

  Widget _buildSelectionActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: OBButton(
                    size: OBButtonSize.large,
                    child: Text(
                        _localizationService.user_search__selection_clear_all),
                    type: OBButtonType.highlight,
                    onPressed: _onClearSelection,
                    isDisabled: _listSelection.isEmpty),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: OBButton(
                  size: OBButtonSize.large,
                  child: Text(
                      _localizationService.user_search__selection_submit +
                          _makeSelectedItemsCount()),
                  type: OBButtonType.primary,
                  isLoading: _selectionSubmissionInProgress,
                  isDisabled: _selectionSubmissionInProgress,
                  onPressed: _onSubmitSelection,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSearchResultsList() {
    int listItemCount = _listSearchResults.length + 1;

    ScrollPhysics physics = listItemCount > 0 ? widget.physics : noItemsPhysics;

    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        // Hide keyboard
        FocusScope.of(context).requestFocus(new FocusNode());
        return true;
      },
      child: widget.separatorBuilder != null
          ? ListView.separated(
              separatorBuilder: widget.separatorBuilder!,
              padding: widget.padding,
              physics: physics,
              itemCount: listItemCount,
              itemBuilder: _buildSearchResultsListItem)
          : ListView.builder(
              padding: widget.padding,
              physics: physics,
              itemCount: listItemCount,
              itemBuilder: _buildSearchResultsListItem),
    );
  }

  Widget _buildSearchResultsListItem(BuildContext context, int index) {
    if (index == _listSearchResults.length) {
      String searchQuery = _searchQuery;

      if (_searchRequestInProgress) {
        // Search in progress
        return ListTile(
            leading: const OBProgressIndicator(),
            title: OBText(
                _localizationService.user_search__searching_for(searchQuery)));
      } else if (_listSearchResults.isEmpty) {
        // Results were empty
        return ListTile(
            leading: const OBIcon(OBIcons.sad),
            title: OBText(
                _localizationService.user_search__no_results_for(searchQuery)));
      } else {
        return const SizedBox();
      }
    }

    T listItem = _listSearchResults[index];

    Widget listItemWidget =
        widget.searchResultListItemBuilder!(context, listItem);

    if (!widget.isSelectable) return listItemWidget;

    return _wrapSelectableListItemWidget(listItem, listItemWidget);
  }

  Widget _buildList() {
    return RefreshIndicator(
        key: _listRefreshIndicatorKey,
        child: _list.isEmpty && !_refreshInProgress && _wasBootstrapped
            ? _buildNoList()
            : LoadMore(
                whenEmptyLoad: false,
                isFinish: _loadingFinished,
                delegate: OBHttpListLoadMoreDelegate(_localizationService),
                child: widget.separatorBuilder != null
                    ? ListView.separated(
                        separatorBuilder: widget.separatorBuilder!,
                        controller: _listScrollController,
                        physics: widget.physics,
                        padding: widget.padding,
                        itemCount: _list.length + _prependedItems.length,
                        itemBuilder: _buildListItem)
                    : ListView.builder(
                        controller: _listScrollController,
                        physics: widget.physics,
                        padding: widget.padding,
                        itemCount: _list.length + _prependedItems.length,
                        itemBuilder: _buildListItem),
                onLoadMore: _loadMoreListItems),
        onRefresh: _refreshList);
  }

  Widget _buildNoList() {
    List<Widget> items = [];

    if (widget.prependedItems != null && widget.prependedItems!.isNotEmpty) {
      items.addAll(widget.prependedItems!);
    }

    items.add(Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OBButtonAlert(
          text: _localizationService
              .user_search__list_no_results_found(widget.resourcePluralName.toLowerCase()),
          onPressed: _refreshList,
          buttonText:
              _localizationService.trans('user_search__list_refresh_text'),
          buttonIcon: OBIcons.refresh,
          assetImage: 'assets/images/stickers/perplexed-owl.png',
        )
      ],
    ));

    return ListView(
      controller: _listScrollController,
      physics: widget.physics,
      padding: widget.padding,
      children: items,
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    int itemsIndex = index;

    if (_prependedItems.isNotEmpty && index < _prependedItems.length) {
      return _prependedItems[index];
    }

    itemsIndex = index - _prependedItems.length;

    T listItem = _list[itemsIndex];

    Widget listItemWidget = widget.listItemBuilder(context, listItem);

    if (widget.isSelectable) {
      listItemWidget = _wrapSelectableListItemWidget(listItem, listItemWidget);
    }

    return listItemWidget;
  }

  String _makeSelectedItemsCount() {
    if (_listSelection.isEmpty) return '';

    return ' (${_listSelection.length})';
  }

  Widget _wrapSelectableListItemWidget(T listItem, Widget listItemWidget) {
    return SizedBox(
        child: GestureDetector(
      onTap: () => _onWantsToToggleSelection(listItem),
      child: Row(
        children: <Widget>[
          Expanded(
            child: listItemWidget,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: OBCheckbox(
              value: _listSelection.contains(listItem),
            ),
          )
        ],
      ),
    ));
  }

  void _bootstrap() async {
    Future.delayed(Duration(milliseconds: 0), () async {
      _refreshWithRefreshIndicator();
      setState(() {
        _wasBootstrapped = true;
      });
    });
  }

  Future<void> _refreshList() async {
    if (_refreshOperation != null) _refreshOperation!.cancel();
    _setLoadingFinished(false);
    _setRefreshInProgress(true);
    try {
      List<Future<dynamic>> refreshFutures = [widget.listRefresher()];

      if (widget.secondaryRefresher != null)
        refreshFutures.add(widget.secondaryRefresher!());

      _refreshOperation =
          CancelableOperation.fromFuture(Future.wait(refreshFutures));
      List<dynamic> results = await _refreshOperation?.value;
      List<T> list = results[0];

      _setList(list);
    } catch (error) {
      _onError(error);
    } finally {
      _setRefreshInProgress(false);
      _refreshOperation = null;
    }
  }

  Future refreshList(
      {bool shouldScrollToTop = false,
      bool shouldUseRefreshIndicator = false}) async {
    if (shouldUseRefreshIndicator) {
      _refreshWithRefreshIndicator();
    } else {
      _refreshList();
    }

    if (shouldScrollToTop &&
        _listScrollController.hasClients &&
        _listScrollController.offset != 0) {
      scrollToTop();
    }
  }

  void _refreshWithRefreshIndicator(){
    // Deactivate if active
    _listRefreshIndicatorKey.currentState?.deactivate();

    // Activate
    _listRefreshIndicatorKey.currentState?.show();
  }

  Future<bool> _loadMoreListItems() async {
    if (_refreshOperation != null) return true;
    if (_loadMoreOperation != null) return true;
    if (_list.isEmpty) return true;
    debugPrint('Loading more list items');

    try {
      _loadMoreOperation =
          CancelableOperation.fromFuture(widget.listOnScrollLoader(_list));
      List<T> moreListItems = await _loadMoreOperation?.value;

      if (moreListItems.length == 0) {
        _setLoadingFinished(true);
      } else {
        _addListItems(moreListItems);
      }
      return true;
    } catch (error) {
      _onError(error);
    } finally {
      _loadMoreOperation = null;
    }

    return false;
  }

  Future _onSearch(String query) {
    _setSearchQuery(query);
    if (query.isEmpty) {
      _setHasSearch(false);
      return Future.value();
    } else {
      _setHasSearch(true);
      return _searchWithQuery(query);
    }
  }

  Future _searchWithQuery(String query) async {
    if (_searchOperation != null) _searchOperation!.cancel();

    _setSearchRequestInProgress(true);

    try {
      _searchOperation =
          CancelableOperation.fromFuture(widget.listSearcher!(_searchQuery));

      List<T> listSearchResults = await _searchOperation?.value;
      _setListSearchResults(listSearchResults);
    } catch (error) {
      _onError(error);
    } finally {
      _setSearchRequestInProgress(false);
      _searchOperation = null;
    }
  }

  void _onClearSelection() {
    _clearSelection();
  }

  void _onSubmitSelection() async {
    if (_submitSelectionOperation != null) _submitSelectionOperation!.cancel();

    _setSelectionSubmissionInProgress(true);

    try {
      _submitSelectionOperation = CancelableOperation.fromFuture(
          widget.selectionSubmitter!(_listSelection));
      widget.onSelectionSubmitted!(_listSelection);
    } catch (error) {
      _onError(error);
    } finally {
      _setSelectionSubmissionInProgress(false);
      _submitSelectionOperation = null;
    }
  }

  void _onWantsToToggleSelection(T listItem) {
    if (_listSelection.contains(listItem)) {
      _unselectItem(listItem);
    } else {
      _selectItem(listItem);
    }

    if (widget.onSelectionChanged != null)
      widget.onSelectionChanged!(_listSelection.toList());
  }

  void _resetListSearchResults() {
    _setListSearchResults(_list.toList());
  }

  void _setListSearchResults(List<T> listSearchResults) {
    setState(() {
      _listSearchResults = listSearchResults;
    });
  }

  void _setLoadingFinished(bool loadingFinished) {
    setState(() {
      _loadingFinished = loadingFinished;
    });
  }

  void _setList(List<T> list) {
    setState(() {
      this._list = list;
      _resetListSearchResults();
    });
  }

  void _addListItems(List<T> items) {
    setState(() {
      this._list.addAll(items);
    });
  }

  void _setSearchQuery(String searchQuery) {
    setState(() {
      _searchQuery = searchQuery;
    });
  }

  void _setHasSearch(bool hasSearch) {
    setState(() {
      _hasSearch = hasSearch;
    });
  }

  void _setRefreshInProgress(bool refreshInProgress) {
    setState(() {
      _refreshInProgress = refreshInProgress;
    });
  }

  void _setSearchRequestInProgress(bool searchRequestInProgress) {
    setState(() {
      _searchRequestInProgress = searchRequestInProgress;
    });
  }

  void _selectItem(T item) {
    setState(() {
      _listSelection.add(item);
    });
  }

  void _unselectItem(T item) {
    setState(() {
      _listSelection.remove(item);
    });
  }

  void _clearSelection() {
    setState(() {
      _listSelection = [];
    });
  }

  void _setSelectionSubmissionInProgress(bool selectionSubmissionInProgress) {
    setState(() {
      _selectionSubmissionInProgress = selectionSubmissionInProgress;
    });
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.trans('error__unknown_error'), context: context);
    } else {
      _toastService.error(
          message: _localizationService.trans('error__unknown_error'),
          context: context);
      throw error;
    }
  }
}

class OBHttpListController<T> {
  OBHttpListState? _state;

  void attach(OBHttpListState state) {
    _state = state;
  }

  void insertListItem(T listItem,
      {bool shouldScrollToTop = true, bool shouldRefresh = false}) {
    if (!_isAttached() || !_state!.mounted) {
      debugPrint('Tried to insertListItem in unattached OBHttpList');
      return;
    }
    _state!.insertListItem(listItem,
        shouldScrollToTop: shouldScrollToTop, shouldRefresh: shouldRefresh);
  }

  void removeListItem(T listItem) {
    if (!_isAttached() || !_state!.mounted) return;
    _state!.removeListItem(listItem);
  }

  void scrollToTop() {
    if (!_isAttached() || !_state!.mounted) return;
    _state!.scrollToTop();
  }

  Future refresh(
      {bool shouldScrollToTop = false,
      bool shouldUseRefreshIndicator = false}) async {
    if (_state == null || !_state!.mounted) return;
    _state!.refreshList(
        shouldScrollToTop: shouldScrollToTop,
        shouldUseRefreshIndicator: shouldUseRefreshIndicator);
  }

  Future search(String query) {
    return _state!._onSearch(query);
  }

  Future clearSearch() {
    return _state!._onSearch('');
  }

  bool hasItems() {
    return _state!._list.isNotEmpty;
  }

  T firstItem() {
    return _state!._list.first;
  }

  bool _isAttached() {
    return _state != null;
  }
}

typedef Widget OBHttpListItemBuilder<T>(BuildContext context, T listItem);
typedef Future<List<T>> OBHttpListSearcher<T>(String searchQuery);
typedef Future<List<T>> OBHttpListRefresher<T>();
typedef Future OBHttpListSecondaryRefresher<T>();
typedef Future<List<T>> OBHttpListOnScrollLoader<T>(List<T> currentList);
typedef void OBHttpListSelectionChangedListener<T>(List<T> selectionItems);
typedef void OBHttpListSelectionSubmittedListener<T>(List<T> selectionItems);
typedef Future OBHttpListSelectionSubmitter<T>(List<T> selectionItems);

class OBHttpListLoadMoreDelegate extends LoadMoreDelegate {
  final LocalizationService localizationService;

  const OBHttpListLoadMoreDelegate(this.localizationService);

  @override
  Widget buildChild(LoadMoreStatus status,
      {LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.chinese}) {
    if (status == LoadMoreStatus.fail) {
      return SizedBox(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OBIcon(OBIcons.refresh),
            const SizedBox(
              width: 10.0,
            ),
            OBText(localizationService.trans('user_search__list_retry'))
          ],
        ),
      );
    }
    if (status == LoadMoreStatus.loading) {
      return SizedBox(
          child: Center(
        child: OBProgressIndicator(),
      ));
    }
    return const SizedBox();
  }
}

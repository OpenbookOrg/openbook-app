import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/models/post_comment_list.dart';
import 'package:Okuna/services/user_preferences.dart';
import 'package:Okuna/services/user.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBPostCommentsPageController {
  final Post post;
  final PostCommentsPageType pageType;
  PostCommentsSortType currentSort;
  Function(List<PostComment>) setPostComments;
  Function(List<PostComment>) addPostComments;
  Function(List<PostComment>) addToStartPostComments;
  Function(PostCommentsSortType) setCurrentSortValue;
  Function(bool) setNoMoreBottomItemsToLoad;
  Function(bool) setNoMoreTopItemsToLoad;
  VoidCallback showNoMoreTopItemsToLoadToast;
  VoidCallback scrollToTop;
  VoidCallback scrollToNewComment;
  VoidCallback unfocusCommentInput;
  Function(dynamic) onError;
  UserService userService;
  UserPreferencesService userPreferencesService;

  List<PostComment> postComments = [];
  PostComment? linkedPostComment;
  PostComment? postComment;

  static const LOAD_MORE_COMMENTS_COUNT = 5;
  static const COUNT_MIN_INCLUDING_LINKED_COMMENT = 3;
  static const COUNT_MAX_AFTER_LINKED_COMMENT = 2;
  static const TOTAL_COMMENTS_IN_SLICE =
      COUNT_MIN_INCLUDING_LINKED_COMMENT + COUNT_MAX_AFTER_LINKED_COMMENT;

  CancelableOperation? _refreshCommentsOperation;
  CancelableOperation? _refreshCommentsSliceOperation;
  CancelableOperation? _refreshCommentsWithCreatedPostCommentVisibleOperation;
  CancelableOperation? _refreshPostOperation;
  CancelableOperation? _loadMoreBottomCommentsOperation;
  CancelableOperation? _loadMoreTopCommentsOperation;
  CancelableOperation? _toggleSortCommentsOperation;

  OBPostCommentsPageController({
    required this.post,
    required this.pageType,
    required this.currentSort,
    required this.userService,
    required this.userPreferencesService,
    required this.setPostComments,
    required this.setCurrentSortValue,
    required this.setNoMoreBottomItemsToLoad,
    required this.setNoMoreTopItemsToLoad,
    required this.addPostComments,
    required this.addToStartPostComments,
    required this.showNoMoreTopItemsToLoadToast,
    required this.scrollToTop,
    required this.scrollToNewComment,
    required this.unfocusCommentInput,
    required this.onError,
    this.linkedPostComment,
    this.postComment
  }) {
    this.bootstrapController();
  }

  Future bootstrapController() async {
    if (this.linkedPostComment != null) {
      await this.refreshCommentsSlice();
    } else {
      await this.refreshComments();
    }
  }

  CancelableOperation<PostCommentList> retrieveObjects({int? minId, int? maxId, int? countMax,
    int? countMin, PostCommentsSortType? sort}) {

    if (this.pageType == PostCommentsPageType.comments) {
      return CancelableOperation.fromFuture(
          this.userService.getCommentsForPost(this.post,
              sort: sort,
              minId: minId,
              maxId: maxId,
              countMax: countMax,
              countMin: countMin));

    } else {
      return CancelableOperation.fromFuture(
          this.userService.getCommentRepliesForPostComment(this.post, this.postComment!,
              sort: sort,
              minId: minId,
              maxId: maxId,
              countMax: countMax,
              countMin: countMin));
    }
  }

  void onWantsToToggleSortComments() async {
    PostCommentsSortType newSortType;
    if (currentSort == PostCommentsSortType.asc) {
      newSortType = PostCommentsSortType.dec;
    } else {
      newSortType = PostCommentsSortType.asc;
    }
    this.userPreferencesService.setPostCommentsSortType(newSortType);
    this.setNewSortValue(newSortType);
    this.onWantsToRefreshComments();
  }

  Future onWantsToRefreshComments() async {
    if (_refreshCommentsOperation != null) _refreshCommentsOperation!.cancel();
    try {
      _refreshCommentsOperation = this.retrieveObjects(sort: this.currentSort);
      this.postComments = (await _refreshCommentsOperation!.value).comments;
      this.setPostComments(this.postComments);
      this.setNoMoreBottomItemsToLoad(false);
      this.setNoMoreTopItemsToLoad(true);
    } catch (error) {
      this.onError(error);
    } finally {
      _refreshCommentsOperation = null;
    }
  }

  Future<void> refreshComments() async {
    await this.onWantsToRefreshComments();
    this.scrollToTop();
  }

  Future<bool> loadMoreTopComments() async {
    if (_loadMoreTopCommentsOperation != null)
      _loadMoreTopCommentsOperation!.cancel();
    if (this.postComments.length == 0) return true;

    List<PostComment> topComments;
    PostComment firstPost = this.postComments.first;
    int firstPostId = firstPost.id!;
    try {
      if (this.currentSort == PostCommentsSortType.dec) {
        _loadMoreTopCommentsOperation = this.retrieveObjects(
                sort: PostCommentsSortType.dec,
                countMin: LOAD_MORE_COMMENTS_COUNT,
                minId: firstPostId + 1);
      } else if (this.currentSort == PostCommentsSortType.asc) {
        _loadMoreTopCommentsOperation = this.retrieveObjects(
                sort: PostCommentsSortType.asc,
                countMax: LOAD_MORE_COMMENTS_COUNT,
                maxId: firstPostId);
      }

      topComments = (await _loadMoreTopCommentsOperation!.value).comments;

      if (topComments.length < LOAD_MORE_COMMENTS_COUNT &&
          topComments.length != 0) {
        this.setNoMoreTopItemsToLoad(true);
        this.addToStartPostComments(topComments);
      } else if (topComments.length == LOAD_MORE_COMMENTS_COUNT) {
        this.addToStartPostComments(topComments);
      } else {
        this.setNoMoreTopItemsToLoad(true);
        this.showNoMoreTopItemsToLoadToast();
      }
      return true;
    } catch (error) {
      this.onError(error);
    } finally {
      _loadMoreTopCommentsOperation = null;
    }

    return false;
  }

  Future<bool> loadMoreBottomComments() async {
    if (_loadMoreBottomCommentsOperation != null)
      _loadMoreBottomCommentsOperation!.cancel();
    if (this.postComments.length == 0 || _refreshCommentsWithCreatedPostCommentVisibleOperation != null) return true;

    PostComment lastPost = this.postComments.last;
    int lastPostId = lastPost.id!;
    List<PostComment> moreComments;
    try {
      if (this.currentSort == PostCommentsSortType.dec) {
        _loadMoreBottomCommentsOperation = this.retrieveObjects(
                countMax: LOAD_MORE_COMMENTS_COUNT,
                maxId: lastPostId,
                sort: this.currentSort);
      } else {
        _loadMoreBottomCommentsOperation = this.retrieveObjects(
                countMin: LOAD_MORE_COMMENTS_COUNT,
                minId: lastPostId + 1,
                sort: this.currentSort);
      }

      moreComments = (await _loadMoreBottomCommentsOperation!.value).comments;

      if (moreComments.length == 0) {
        this.setNoMoreBottomItemsToLoad(true);
      } else {
        this.addPostComments(moreComments);
      }
      return true;
    } catch (error) {
      this.onError(error);
    } finally {
      _loadMoreBottomCommentsOperation = null;
    }

    return false;
  }

  Future<void> refreshCommentsSlice() async {
    if (_refreshCommentsSliceOperation != null)
      _refreshCommentsSliceOperation!.cancel();
    try {
      _refreshCommentsSliceOperation = this.retrieveObjects(
              minId: this.linkedPostComment?.id,
              maxId: this.linkedPostComment?.id,
              countMax: COUNT_MAX_AFTER_LINKED_COMMENT,
              countMin: COUNT_MIN_INCLUDING_LINKED_COMMENT,
              sort: this.currentSort);

      this.postComments = (await _refreshCommentsSliceOperation!.value).comments;
      this.setPostComments(this.postComments);
      this.checkIfMoreTopItemsToLoad();
      this.setNoMoreBottomItemsToLoad(false);
    } catch (error) {
      this.onError(error);
    } finally {
      _refreshCommentsSliceOperation = null;
    }
  }

  void checkIfMoreTopItemsToLoad() {
    int linkedCommentId = this.linkedPostComment!.id!;
    Iterable<PostComment> listBeforeLinkedComment = [];
    if (this.currentSort == PostCommentsSortType.dec) {
      listBeforeLinkedComment =
          postComments.where((comment) => comment.id! > linkedCommentId);
    } else if (this.currentSort == PostCommentsSortType.asc) {
      listBeforeLinkedComment =
          postComments.where((comment) => comment.id! < linkedCommentId);
    }
    if (listBeforeLinkedComment.length < 2) {
      this.setNoMoreTopItemsToLoad(true);
    }
  }

  void refreshCommentsWithCreatedPostCommentVisible(
      PostComment createdPostComment) async {
    if (_refreshCommentsWithCreatedPostCommentVisibleOperation != null)
      _refreshCommentsWithCreatedPostCommentVisibleOperation!.cancel();
    this.unfocusCommentInput();
    List<PostComment> comments;
    int createdCommentId = createdPostComment.id!;
    try {
      if (this.currentSort == PostCommentsSortType.dec) {
        _refreshCommentsWithCreatedPostCommentVisibleOperation = this.retrieveObjects(
                sort: PostCommentsSortType.dec,
                countMax: LOAD_MORE_COMMENTS_COUNT,
                maxId: createdCommentId + 1);
        this.setNoMoreTopItemsToLoad(true);
        this.setNoMoreBottomItemsToLoad(false);
      } else if (this.currentSort == PostCommentsSortType.asc) {
        _refreshCommentsWithCreatedPostCommentVisibleOperation = this.retrieveObjects(
                sort: PostCommentsSortType.asc,
                countMax: LOAD_MORE_COMMENTS_COUNT,
                maxId: createdCommentId + 1);
        this.setNoMoreTopItemsToLoad(false);
        this.setNoMoreBottomItemsToLoad(false);
      }
      comments =
          (await _refreshCommentsWithCreatedPostCommentVisibleOperation!.value)
              .comments;
      this.postComments = comments;
      this.setPostComments(this.postComments);
      this.scrollToNewComment();
    } catch (error) {
      this.onError(error);
    } finally {
      _refreshCommentsWithCreatedPostCommentVisibleOperation = null;
    }
  }

  void setNewSortValue(PostCommentsSortType newSortType) {
    this.currentSort = newSortType;
    this.setCurrentSortValue(newSortType);
  }

  void updateControllerPostComments(List<PostComment> comments) {
    this.postComments = comments;
  }

  void dispose() {
    if (_refreshCommentsOperation != null) _refreshCommentsOperation!.cancel();
    if (_refreshCommentsSliceOperation != null)
      _refreshCommentsSliceOperation!.cancel();
    if (_loadMoreBottomCommentsOperation != null)
      _loadMoreBottomCommentsOperation!.cancel();
    if (_refreshPostOperation != null) _refreshPostOperation!.cancel();
    if (_toggleSortCommentsOperation != null)
      _toggleSortCommentsOperation!.cancel();
    if (_loadMoreTopCommentsOperation != null)
      _loadMoreTopCommentsOperation!.cancel();
    if (_refreshCommentsWithCreatedPostCommentVisibleOperation != null)
      _refreshCommentsWithCreatedPostCommentVisibleOperation!.cancel();
  }
}

enum PostCommentsPageType { replies, comments }

import 'dart:collection';

class DraftService {
  static const _maxSavedDrafts = 25;

  Map<String, String> _drafts = LinkedHashMap();

  String getCommentDraft(int postId, [int? commentId]) =>
      _drafts[_buildCommentKey(postId, commentId)] ?? '';

  String getPostDraft([int? communityId]) =>
      _drafts[_buildPostKey(communityId)] ?? '';

  void _set(String key, String text) {
    _drafts.update(key, (e) => text, ifAbsent: () => text);
    _trimDraftsIfNeeded();
  }

  void setCommentDraft(String text, int postId, [int? commentId]) {
    if (text.trim().isNotEmpty) {
      _set(_buildCommentKey(postId, commentId), text);
    } else {
      removeCommentDraft(postId, commentId);
    }
  }

  void setPostDraft(String text, [int? communityId]) {
    if (text.trim().isNotEmpty) {
      _set(_buildPostKey(communityId), text);
    } else {
      removePostDraft(communityId);
    }
  }

  void removeCommentDraft(int postId, [commentId]) =>
      _drafts.remove(_buildCommentKey(postId, commentId));

  void removePostDraft([int? communityId]) =>
      _drafts.remove(_buildPostKey(communityId));

  void _trimDraftsIfNeeded() {
    if (_drafts.length > _maxSavedDrafts) {
      _drafts.remove(_drafts.keys.first);
    }
  }

  void clear() {
    _drafts.clear();
  }

  String _buildCommentKey(int postId, int? commentId) =>
      'c|$postId|${commentId ?? "-1"}';

  String _buildPostKey(int? communityId) => 'p|${communityId ?? "-1"}';
}

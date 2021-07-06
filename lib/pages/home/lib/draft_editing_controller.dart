import 'package:Okuna/services/draft.dart';
import 'package:flutter/material.dart';

abstract class DraftTextEditingController extends TextEditingController {
  final DraftService _draftService;
  String? _previousText;

  DraftTextEditingController(this._draftService) {
    addListener(_onChanged);
  }

  factory DraftTextEditingController.comment(int postId,
      {required int? commentId, String? text, required DraftService draftService}) {
    return _CommentDraftEditingController(
        postId, commentId, text, draftService);
  }

  factory DraftTextEditingController.post(
      {int? communityId, String? text, required DraftService draftService}) {
    return _PostDraftEditingController(communityId, text, draftService);
  }

  void _onChanged() {
    if (text != _previousText) {
      _textChanged();
    }

    _previousText = text;
  }

  void _textChanged();

  void clearDraft();
}

class _CommentDraftEditingController extends DraftTextEditingController {
  final int postId;
  final int? commentId;

  _CommentDraftEditingController(
      this.postId, this.commentId, String? text, DraftService draftService)
      : super(draftService) {
    if (text == null) {
      this.text = _draftService.getCommentDraft(postId, commentId);
    } else {
      this.text = text;
    }
  }

  void _textChanged() {
    _draftService.setCommentDraft(text, postId, commentId);
  }

  void clearDraft() {
    _draftService.removeCommentDraft(postId, commentId);
  }
}

class _PostDraftEditingController extends DraftTextEditingController {
  final int? communityId;

  _PostDraftEditingController(
      this.communityId, String? text, DraftService draftService)
      : super(draftService) {
    if (text == null) {
      this.text = _draftService.getPostDraft(communityId);
    } else {
      this.text = text;
    }
  }

  void _textChanged() {
    _draftService.setPostDraft(text, communityId);
  }

  void clearDraft() {
    _draftService.removePostDraft(communityId);
  }
}

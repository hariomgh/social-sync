import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/validators.dart';
import '../../data/models/insight.dart';
import '../../data/models/media_attachment.dart';
import '../../data/models/platform_content.dart';
import '../../data/models/post.dart';
import '../../data/models/publish_result.dart';
import '../../data/models/schedule_mode.dart';
import '../../data/models/social_account.dart';
import '../../data/models/social_platform.dart';
import '../../data/services/insights_engine.dart';
import '../../data/services/publish_service.dart';
import '../providers/app_providers.dart';

/// Immutable UI state exposed by the [ComposerViewModel].
class ComposerState {
  const ComposerState({
    required this.post,
    this.previewPlatform = SocialPlatform.instagram,
    this.scheduleMode = ScheduleMode.bestTime,
    this.customScheduledAt,
    this.isPublishing = false,
    this.outcomes,
  });

  final Post post;

  /// Which platform's mock is currently centered in the preview.
  final SocialPlatform previewPlatform;

  /// Best-time vs custom scheduling.
  final ScheduleMode scheduleMode;

  /// The user's chosen time when [scheduleMode] is custom.
  final DateTime? customScheduledAt;

  final bool isPublishing;

  /// Results of the most recent publish attempt, if any.
  final List<PublishOutcome>? outcomes;

  Map<SocialPlatform, List<ValidationIssue>> get issues =>
      Validators.validate(post);

  /// Live, rule-based recommendations for the current post.
  List<Insight> get insights => InsightsEngine.analyze(post);

  bool get canPublish => Validators.canPublish(post) && !isPublishing;

  ComposerState copyWith({
    Post? post,
    SocialPlatform? previewPlatform,
    ScheduleMode? scheduleMode,
    DateTime? customScheduledAt,
    bool clearCustomScheduledAt = false,
    bool? isPublishing,
    List<PublishOutcome>? outcomes,
    bool clearOutcomes = false,
  }) {
    return ComposerState(
      post: post ?? this.post,
      previewPlatform: previewPlatform ?? this.previewPlatform,
      scheduleMode: scheduleMode ?? this.scheduleMode,
      customScheduledAt: clearCustomScheduledAt
          ? null
          : (customScheduledAt ?? this.customScheduledAt),
      isPublishing: isPublishing ?? this.isPublishing,
      outcomes: clearOutcomes ? null : (outcomes ?? this.outcomes),
    );
  }
}

/// ViewModel for the compose screen.
///
/// Owns the working [Post] and every intent the UI can fire: edit text, toggle
/// platforms, manage media, tailor per-platform copy, choose scheduling, apply
/// optimizations, save, schedule and publish.
class ComposerViewModel extends Notifier<ComposerState> {
  static const Uuid _uuid = Uuid();

  static const List<String> _recommendedHashtags = <String>[
    '#marketing',
    '#socialmedia',
    '#contentcreator',
    '#branding',
    '#community',
  ];

  @override
  ComposerState build() =>
      ComposerState(post: Post.empty(_uuid.v4(), DateTime.now()));

  Post get _post => state.post;

  void _setPost(Post post) => state = state.copyWith(post: post);

  // --- Shared content -----------------------------------------------------

  void updateBaseText(String text) => _setPost(_post.copyWith(baseText: text));

  void appendToBaseText(String snippet) {
    final String current = _post.baseText;
    final String joined =
        current.isEmpty ? snippet : '${current.trimRight()} $snippet';
    updateBaseText(joined);
  }

  // --- Platform selection -------------------------------------------------

  void togglePlatform(SocialPlatform platform) {
    final Map<SocialPlatform, PlatformContent> overrides =
        Map<SocialPlatform, PlatformContent>.of(_post.overrides);
    final PlatformContent current =
        overrides[platform] ?? PlatformContent(platform: platform);
    overrides[platform] = current.copyWith(enabled: !current.enabled);
    _setPost(_post.copyWith(overrides: overrides));
  }

  void setPreviewPlatform(SocialPlatform platform) =>
      state = state.copyWith(previewPlatform: platform);

  // --- Per-platform tailoring --------------------------------------------

  void enableCustomText(SocialPlatform platform, bool enabled) {
    final Map<SocialPlatform, PlatformContent> overrides =
        Map<SocialPlatform, PlatformContent>.of(_post.overrides);
    final PlatformContent current =
        overrides[platform] ?? PlatformContent(platform: platform);
    overrides[platform] = enabled
        ? current.copyWith(customText: _post.baseText)
        : current.copyWith(clearCustomText: true);
    _setPost(_post.copyWith(overrides: overrides));
  }

  void setCustomText(SocialPlatform platform, String text) {
    final Map<SocialPlatform, PlatformContent> overrides =
        Map<SocialPlatform, PlatformContent>.of(_post.overrides);
    final PlatformContent current =
        overrides[platform] ?? PlatformContent(platform: platform);
    overrides[platform] = current.copyWith(customText: text);
    _setPost(_post.copyWith(overrides: overrides));
  }

  // --- Media --------------------------------------------------------------

  void addMedia(List<MediaAttachment> items) {
    const int hardCap = 10;
    final List<MediaAttachment> next = <MediaAttachment>[
      ..._post.media,
      ...items,
    ].take(hardCap).toList();
    _setPost(_post.copyWith(media: next));
  }

  void replaceMedia(MediaAttachment updated) {
    final List<MediaAttachment> next = _post.media
        .map((MediaAttachment m) => m.id == updated.id ? updated : m)
        .toList();
    _setPost(_post.copyWith(media: next));
  }

  void removeMedia(String id) {
    final List<MediaAttachment> next =
        _post.media.where((MediaAttachment m) => m.id != id).toList();
    _setPost(_post.copyWith(media: next));
  }

  // --- Scheduling ---------------------------------------------------------

  void setScheduleMode(ScheduleMode mode) =>
      state = state.copyWith(scheduleMode: mode);

  void setCustomDateTime(DateTime at) => state = state.copyWith(
        scheduleMode: ScheduleMode.custom,
        customScheduledAt: at,
      );

  /// The concrete time a "schedule" action would use right now.
  DateTime resolveScheduledAt() {
    if (state.scheduleMode == ScheduleMode.custom &&
        state.customScheduledAt != null) {
      return state.customScheduledAt!;
    }
    return ref
        .read(bestTimeServiceProvider)
        .nextBestSlot(_post.selectedPlatforms);
  }

  // --- Optimizations ------------------------------------------------------

  void applyOptimization(OptimizationAction action) {
    switch (action) {
      case OptimizationAction.switchToBestTime:
        setScheduleMode(ScheduleMode.bestTime);
      case OptimizationAction.trimForX:
        final String text = _post.textFor(SocialPlatform.x);
        final int max = SocialPlatform.x.maxCharacters;
        if (text.length > max) {
          final String trimmed =
              '${text.substring(0, max - 1).trimRight()}…';
          setCustomText(SocialPlatform.x, trimmed);
        }
      case OptimizationAction.addHashtags:
        final String current = _post.baseText;
        final Iterable<String> toAdd = _recommendedHashtags
            .where((String t) => !current.toLowerCase().contains(t))
            .take(3);
        if (toAdd.isNotEmpty) appendToBaseText(toAdd.join(' '));
    }
  }

  // --- Load / reset -------------------------------------------------------

  void loadPost(Post post) =>
      state = ComposerState(post: post, previewPlatform: state.previewPlatform);

  void reset() => state = build();

  // --- Persistence & publishing ------------------------------------------

  Future<Post> saveDraft() async {
    final Post draft = _post.copyWith(
      status: PostStatus.draft,
      updatedAt: DateTime.now(),
    );
    await ref.read(postRepositoryProvider).save(draft);
    _setPost(draft);
    return draft;
  }

  /// Schedules using the resolved time (best-time slot or the user's custom
  /// date), and returns it.
  Future<Post> schedule([DateTime? at]) async {
    final DateTime when = at ?? resolveScheduledAt();
    final Post scheduled = _post.copyWith(
      status: PostStatus.scheduled,
      scheduledAt: when,
      updatedAt: DateTime.now(),
    );
    await ref.read(postRepositoryProvider).save(scheduled);
    await ref.read(schedulerServiceProvider).scheduleReminder(scheduled);
    _setPost(scheduled);
    return scheduled;
  }

  Future<List<PublishOutcome>> publish() async {
    state = state.copyWith(
      isPublishing: true,
      post: _post.copyWith(status: PostStatus.publishing),
      clearOutcomes: true,
    );

    final List<SocialAccount> accounts =
        await ref.read(accountRepositoryProvider).getAll();
    final Map<SocialPlatform, SocialAccount> accountMap =
        <SocialPlatform, SocialAccount>{
      for (final SocialAccount a in accounts) a.platform: a,
    };

    final List<PublishOutcome> outcomes = await ref
        .read(publishServiceProvider)
        .publish(_post, accounts: accountMap);

    final Post published = _post.copyWith(
      status: PublishService.statusFrom(outcomes),
      outcomes: outcomes,
      updatedAt: DateTime.now(),
    );
    await ref.read(postRepositoryProvider).save(published);

    state = state.copyWith(
      post: published,
      isPublishing: false,
      outcomes: outcomes,
    );
    return outcomes;
  }
}

final NotifierProvider<ComposerViewModel, ComposerState>
    composerViewModelProvider =
    NotifierProvider<ComposerViewModel, ComposerState>(ComposerViewModel.new);

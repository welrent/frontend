import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/icons.dart';
import '../widgets/site_footer.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _history = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _history.dispose();
    super.dispose();
  }

  void _send() {
    final id = ref.read(activeChatIdProvider);
    ref.read(chatControllerProvider.notifier).send(id, _input.text);
    _input.clear();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_history.hasClients) {
        _history.jumpTo(_history.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(chatControllerProvider);
    final activeId = ref.watch(activeChatIdProvider);
    final active = conversations.firstWhere(
      (item) => item.id == activeId,
      orElse: () => conversations.first,
    );
    final width = MediaQuery.sizeOf(context).width;
    final hideList = width < 800;
    final height = MediaQuery.sizeOf(context).height;

    return ColoredBox(
      color: AppColors.infoBg,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppBreakpoints.isMobile(width) ? 132 : 85),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width < AppBreakpoints.mobile ? 12 : 40,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppBreakpoints.content,
                  ),
                  child: SizedBox(
                    height: height < 760 ? 520 : 680,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 50,
                            offset: Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (!hideList)
                            SizedBox(
                              width: 320,
                              child: _ConversationList(
                                conversations: conversations,
                                activeId: active.id,
                                onSelect: (id) =>
                                    ref
                                            .read(activeChatIdProvider.notifier)
                                            .state =
                                        id,
                              ),
                            ),
                          Expanded(
                            child: _Thread(
                              conversation: active,
                              controller: _history,
                              input: _input,
                              onSend: _send,
                              showListButton: hideList,
                              conversations: conversations,
                              onSelect: (id) =>
                                  ref
                                          .read(activeChatIdProvider.notifier)
                                          .state =
                                      id,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SiteFooter(),
            if (AppBreakpoints.isMobile(width)) const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.conversations,
    required this.activeId,
    required this.onSelect,
  });

  final List<Conversation> conversations;
  final int activeId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.gridLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Text(
              'Messages',
              style: AppText.outfit(size: 20, weight: FontWeight.w800),
            ),
          ),
          const Divider(height: 1, color: AppColors.gridLine),
          Expanded(
            child: ListView(
              children: [
                for (final chat in conversations)
                  _ConversationTile(
                    chat: chat,
                    active: chat.id == activeId,
                    onTap: () => onSelect(chat.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.chat,
    required this.active,
    required this.onTap,
  });

  final Conversation chat;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? const Color(0xFFF0F7FF) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: active ? AppColors.accentBlue : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              _Avatar(url: chat.avatar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.name,
                            style: AppText.outfit(
                              size: 15.2,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          chat.time,
                          style: AppText.outfit(
                            size: 12.8,
                            color: AppColors.fieldText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat.lastMsg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.outfit(
                        size: 13.6,
                        color: AppColors.bodyGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thread extends StatelessWidget {
  const _Thread({
    required this.conversation,
    required this.controller,
    required this.input,
    required this.onSend,
    required this.showListButton,
    required this.conversations,
    required this.onSelect,
  });

  final Conversation conversation;
  final ScrollController controller;
  final TextEditingController input;
  final VoidCallback onSend;
  final bool showListButton;
  final List<Conversation> conversations;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.gridLine)),
          ),
          child: Row(
            children: [
              if (showListButton)
                IconButton(
                  tooltip: 'Conversations',
                  onPressed: () async {
                    final id = await showDialog<int>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: Text(
                          'Messages',
                          style: AppText.outfit(weight: FontWeight.w700),
                        ),
                        children: [
                          for (final chat in conversations)
                            SimpleDialogOption(
                              onPressed: () => Navigator.pop(context, chat.id),
                              child: Text(chat.name, style: AppText.outfit()),
                            ),
                        ],
                      ),
                    );
                    if (id != null) onSelect(id);
                  },
                  icon: const AppIcon('chat', size: 18),
                ),
              _Avatar(url: conversation.avatar, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.name,
                      style: AppText.outfit(size: 16, weight: FontWeight.w700),
                    ),
                    Text(
                      conversation.online ? 'Online' : 'Offline',
                      style: AppText.outfit(
                        size: 12.8,
                        weight: FontWeight.w600,
                        color: conversation.online
                            ? AppColors.trustGreen
                            : AppColors.fieldText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Video',
                onPressed: () => showAppMessage(
                  context,
                  message: 'Video calls are not part of the current Welrent marketplace.',
                ),
                icon: const AppIcon(
                  'video',
                  size: 20,
                  color: AppColors.bodyGrey,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              for (final message in conversation.messages)
                _Bubble(message: message),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAECF0)),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Attach',
                  onPressed: () async {
                    final file = await FilePicker.platform.pickFiles(
                      withData: false,
                    );
                    if (file == null || file.files.isEmpty) return;
                    final name = file.files.single.name;
                    input.text = input.text.isEmpty
                        ? 'Attached: $name'
                        : '${input.text} (Attached: $name)';
                  },
                  icon: const AppIcon(
                    'paperclip',
                    size: 18,
                    color: AppColors.bodyGrey,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: input,
                    onSubmitted: (_) => onSend(),
                    style: AppText.outfit(size: 15.2),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: AppText.outfit(color: AppColors.fieldText),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: input,
                  builder: (context, value, _) {
                    final enabled = value.text.trim().isNotEmpty;
                    return GestureDetector(
                      onTap: enabled ? onSend : null,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: enabled
                              ? AppColors.accentBlue
                              : const Color(0xFFEAECF0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppIcon(
                          'send',
                          size: 18,
                          color: enabled ? Colors.white : AppColors.fieldText,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.sender == 'me';
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
        decoration: BoxDecoration(
          color: mine ? AppColors.accentBlue : AppColors.searchBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: AppText.outfit(
                size: 15.2,
                height: 1.5,
                color: mine ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message.time,
              style: AppText.outfit(
                size: 11,
                color: mine
                    ? Colors.white.withValues(alpha: 0.75)
                    : AppColors.fieldText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, this.size = 50});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: RemoteOrAssetImage(source: url, fit: BoxFit.cover),
      ),
    );
  }
}

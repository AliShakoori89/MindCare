import 'package:flutter/material.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  static const Color _primaryColor = Color(0xFF4CA30D);
  static const Color _backgroundColor = Color(0xFFF8FAF7);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'سلام! 👋 من دستیار سلامت تو هستم. می‌تونی درباره '
          'ثبت علائم، مراقبت روزانه و درک بهتر اطلاعات سلامتت سؤال بپرسی.',
      isUser: false,
    ),
  ];

  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? suggestedMessage]) {
    final text = (suggestedMessage ?? _messageController.text).trim();

    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // پاسخ موقت؛ در مرحله اتصال AI جایگزین می‌شود.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      setState(() {
        _messages.add(_ChatMessage(text: _mockReply(text), isUser: false));
        _isTyping = false;
      });

      _scrollToBottom();
    });
  }

  String _mockReply(String message) {
    final normalized = message.toLowerCase();

    if (normalized.contains('دارو')) {
      return 'برای بررسی داروها، نام دقیق دارو، مقدار مصرف و '
          'دستور پزشک اهمیت دارد. این نسخه نمایشی است و '
          'تداخل دارویی را بررسی نمی‌کند. برای تغییر مصرف دارو '
          'با پزشک یا داروساز مشورت کن.';
    }

    if (normalized.contains('خواب') ||
        normalized.contains('خسته') ||
        normalized.contains('انرژی')) {
      return 'می‌تونی کیفیت خواب، سطح انرژی و حال روزانه‌ات را '
          'ثبت کنی تا الگوهای احتمالی را در طول زمان بهتر ببینی. '
          'اگر خستگی شدید یا مداوم است، با متخصص سلامت مشورت کن.';
    }

    if (normalized.contains('استرس') || normalized.contains('اضطراب')) {
      return 'یک تمرین ساده این است که چند دقیقه در محیطی آرام '
          'بنشینی و به‌آرامی نفس بکشی. اگر اضطراب ادامه دارد یا '
          'زندگی روزمره‌ات را مختل می‌کند، کمک تخصصی می‌تواند مفید باشد.';
    }

    return 'ممنون که درباره سلامتت سؤال پرسیدی. فعلاً این دستیار '
        'با پاسخ‌های نمونه کار می‌کند و هنوز به هوش مصنوعی واقعی '
        'متصل نیست. می‌تونی موضوع، علائم و مدت زمانی را که '
        'درگیر آن بوده‌ای دقیق‌تر توضیح بدهی.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: _messages.length == 1
                ? _buildWelcome()
                : _buildConversation(),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'دستیار در حال آماده‌سازی پاسخ نمونه است...',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.auto_awesome, color: _primaryColor, size: 38),
        ),
        const SizedBox(height: 20),
        Text(
          'دستیار سلامت تو',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'سؤالاتت را درباره مراقبت روزانه و پیگیری سلامت مطرح کن.',
          style: TextStyle(color: Colors.black54, height: 1.8),
        ),
        const SizedBox(height: 28),
        const Text(
          'از اینجا شروع کن',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _SuggestionTile(
          icon: Icons.medication_outlined,
          title: 'درباره داروهایم سؤال دارم',
          onTap: () => _sendMessage('درباره داروهایم سؤال دارم'),
        ),
        _SuggestionTile(
          icon: Icons.bedtime_outlined,
          title: 'چطور خوابم را بهتر پیگیری کنم؟',
          onTap: () => _sendMessage('چطور خوابم را بهتر پیگیری کنم؟'),
        ),
        _SuggestionTile(
          icon: Icons.spa_outlined,
          title: 'برای مدیریت استرس چه کار کنم؟',
          onTap: () => _sendMessage('برای مدیریت استرس چه کار کنم؟'),
        ),
        const SizedBox(height: 16),
        const Text(
          'این دستیار نسخه نمایشی است و جایگزین تشخیص یا توصیه پزشکی نیست.',
          style: TextStyle(color: Colors.black45, fontSize: 12, height: 1.7),
        ),
      ],
    );
  }

  Widget _buildConversation() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];

        return Align(
          alignment: message.isUser
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.82,
            ),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: message.isUser ? _primaryColor : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(message.isUser ? 4 : 18),
                bottomRight: Radius.circular(message.isUser ? 18 : 4),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
                height: 1.7,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE9EDE6))),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'پیامت را بنویس...',
                  filled: true,
                  fillColor: _backgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _isTyping ? null : _sendMessage,
              style: IconButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.send_rounded),
              tooltip: 'ارسال پیام',
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE9EDE6)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4CA30D)),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}

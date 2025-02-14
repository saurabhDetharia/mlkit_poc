import 'package:flutter/material.dart';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';

import '../../widgets/activity_indicator.dart';

class SmartReplyView extends StatefulWidget {
  const SmartReplyView({super.key});

  @override
  State<SmartReplyView> createState() => _SmartReplyViewState();
}

class _SmartReplyViewState extends State<SmartReplyView> {
  // To handle the message conversation.
  late TextEditingController _localUserTextController;
  late TextEditingController _remoteUserTextController;

  // To control Smart-reply
  final _smartReplier = SmartReply();

  // Suggestion reply result
  SmartReplySuggestionResult? _suggestions;

  @override
  void initState() {
    super.initState();
    _localUserTextController = TextEditingController();
    _remoteUserTextController = TextEditingController();
  }

  @override
  void dispose() {
    // Release text field controller.
    _localUserTextController.dispose();
    _remoteUserTextController.dispose();

    // Release Smart Replier.
    _smartReplier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Reply View',
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Removes focus and closes keyboard
          // on tap anywhere on the screen.
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(
            24,
          ),
          child: ListView(
            children: [
              // Space 30 px
              _getVerticalSpace30px,

              // Local user input view
              ..._getLocalUserView,

              // Space 8px
              _getVerticalSpace8px,

              // Add message to conversation
              _getAddMessageButton(
                controller: _localUserTextController,
                isLocalUser: false,
              ),

              // Space 30 px
              _getVerticalSpace30px,

              // Remote user input view
              ..._getRemoteUserView,

              // Space 8px
              _getVerticalSpace8px,

              // Add message to conversation
              _getAddMessageButton(
                controller: _remoteUserTextController,
                isLocalUser: true,
              ),

              // Space 30 px
              _getVerticalSpace30px,

              // Options
              _getOptionsView,

              // Space 30 px
              _getVerticalSpace30px,

              // Suggestions view
              ..._getSuggestionsViewWidget,
            ],
          ),
        ),
      ),
    );
  }

  /// Widgets ---->

  /// Used to give the vertical space of 30px.
  Widget get _getVerticalSpace30px {
    return const SizedBox(height: 30);
  }

  /// Used to give the vertical space of 8px.
  Widget get _getVerticalSpace8px {
    return const SizedBox(height: 8);
  }

  /// Used to show the input field section for the local user.
  List<Widget> get _getLocalUserView {
    return [
      // Title of the section
      const Text('Local User:'),

      // Space 8px
      _getVerticalSpace8px,

      // Input field
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
          ),
        ),
        child: TextField(
          controller: _localUserTextController,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          maxLines: null,
        ),
      ),
    ];
  }

  /// Used to show the input field section for the remote user.
  List<Widget> get _getRemoteUserView {
    return [
      // Title of the section
      const Text('Remote User:'),

      // Space 8px
      _getVerticalSpace8px,

      // Input field
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
          ),
        ),
        child: TextField(
          controller: _remoteUserTextController,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          maxLines: null,
        ),
      ),
    ];
  }

  /// Used to show a button to add local user's message to the
  /// conversation and get the smart reply.
  Widget _getAddMessageButton({
    required TextEditingController controller,
    required bool isLocalUser,
  }) {
    return ElevatedButton(
      onPressed: () {
        _addMessageToConversation(
          controller: controller,
          isLocalUser: isLocalUser,
        );
      },
      child: const Text(
        'Add message to conversation',
      ),
    );
  }

  /// Used to show options like clear conversation, get suggestions
  Widget get _getOptionsView {
    return Row(
      children: [
        if (_smartReplier.conversation.isNotEmpty) ...[
          // Clear conversation
          _getClearConversationWidget,

          // Horizontal Space - 8px
          const SizedBox(
            width: 8,
          ),
        ],

        // Suggest replies
        _getSuggestRepliesWidget,
      ],
    );
  }

  /// Used to clear conversations and suggestions
  Widget get _getClearConversationWidget {
    return ElevatedButton(
      onPressed: () {
        // Clears conversation.
        _smartReplier.clearConversation();

        // Remove suggestions.
        setState(() {
          _suggestions = null;
        });
      },
      child: const Text('Clear Conversation'),
    );
  }

  /// Used to get suggested replies.
  Widget get _getSuggestRepliesWidget {
    return ElevatedButton(
      onPressed: _suggestReplies,
      child: const Text(
        'Suggest Replies',
      ),
    );
  }

  /// Used to show the suggestions.
  List<Widget> get _getSuggestionsViewWidget {
    // If suggestions are not found,
    if (_suggestions == null) {
      return [];
    }

    // Get suggestions.
    final suggestions = _suggestions!.suggestions;

    // Suggestions are found.
    return [
      // Title
      Text(_suggestions!.status.name),

      // Suggestions
      for (final suggestion in suggestions) Text('\t $suggestion'),
    ];
  }

  /// <---

  /// Support methods --->

  /// This validates the message whether it is empty,
  /// and adds the message to the conversations list.
  void _addMessageToConversation({
    required TextEditingController controller,
    required bool isLocalUser,
  }) {
    // Removes focus and hides keyboard.
    FocusScope.of(context).unfocus();

    // Get the content
    final text = controller.text;

    // Checks whether the message is empty, it shows the error
    // message if so, and prevents from the further proceeding.
    if (text.isEmpty) {
      Toast().showMessage('Message can\'t be empty', context);
      return;
    }

    if (isLocalUser) {
      _smartReplier.addMessageToConversationFromLocalUser(
        text,
        DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      _smartReplier.addMessageToConversationFromRemoteUser(
        text,
        DateTime.now().millisecondsSinceEpoch,
        'UserZ',
      );
    }

    // Clears the controller.
    controller.clear();

    // Informs user about the message added successfully.
    Toast().showMessage('Message added to the conversation', context);
  }

  /// This will be used to get suggestions.
  Future<void> _suggestReplies() async {
    // Removes focus and hides keyboard.
    FocusScope.of(context).unfocus();

    // Get suggested replies.
    _suggestions = await _smartReplier.suggestReplies();
    setState(() {});
  }

  /// <---
}

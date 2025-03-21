/*
 * Modified by akquinet GmbH on 26.02.2025
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat_list/chat_list_view.dart';
import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy.dart';
import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:fluffychat/tim/tim_constants.dart';
import 'package:fluffychat/utils/account_bundles.dart';
import 'package:fluffychat/utils/famedlysdk_store.dart';
import 'package:fluffychat/utils/localized_exception_extension.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_file_extension.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/room_extension.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/utils/url_launcher.dart';
import 'package:fluffychat/utils/voip/callkeep_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:uni_links/uni_links.dart';
import 'package:vrouter/vrouter.dart';

import '../../utils/set_sync_presence.dart';
import '../../widgets/fluffy_chat_app.dart';
import '../../widgets/matrix.dart';
import '../bootstrap/bootstrap_dialog.dart';

enum SelectMode {
  normal,
  share,
  select,
}

enum PopupMenuAction {
  settings,
  invite,
  newGroup,
  newSpace,
  setStatus,
  archive,
}

enum ActiveFilter {
  allChats,
  groups,
  messages,
  spaces,
}

class ChatList extends StatefulWidget {
  static BuildContext? contextForVoip;

  const ChatList({Key? key}) : super(key: key);

  @override
  ChatListController createState() => ChatListController();
}

class ChatListController extends State<ChatList> with TickerProviderStateMixin, RouteAware {
  StreamSubscription? _intentDataStreamSubscription;

  StreamSubscription? _intentFileStreamSubscription;

  StreamSubscription? _intentUriStreamSubscription;

  bool get displayNavigationBar =>
      !FluffyThemes.isColumnMode(context) && (spaces.isNotEmpty || AppConfig.separateChatTypes);

  String? activeSpaceId;

  InviteRejectionPolicy? _inviteRejectionPolicy;

  bool _disabledBlockAllInvitesWithoutExceptionsWarning = false;

  bool get shouldShowBlockAllInvitesWithoutExceptionsWarning {
    if (_disabledBlockAllInvitesWithoutExceptionsWarning) return false;
    return rejectsEveryone(_inviteRejectionPolicy);
  }

  void dismissBlockAllInvitesWithoutExceptionsWarning() {
    setState(() {
      _disabledBlockAllInvitesWithoutExceptionsWarning = true;
    });
  }

  void resetActiveSpaceId() {
    setState(() {
      activeSpaceId = null;
    });
  }

  void setActiveSpace(String? spaceId) {
    setState(() {
      activeSpaceId = spaceId;
      activeFilter = ActiveFilter.spaces;
    });
  }

  int get selectedIndex {
    switch (activeFilter) {
      case ActiveFilter.allChats:
      case ActiveFilter.messages:
        return 0;
      case ActiveFilter.groups:
        return 1;
      case ActiveFilter.spaces:
        return AppConfig.separateChatTypes ? 2 : 1;
    }
  }

  ActiveFilter getActiveFilterByDestination(int? i) {
    switch (i) {
      case 1:
        if (AppConfig.separateChatTypes) {
          return ActiveFilter.groups;
        }
        return ActiveFilter.spaces;
      case 2:
        return ActiveFilter.spaces;
      case 0:
      default:
        if (AppConfig.separateChatTypes) {
          return ActiveFilter.messages;
        }
        return ActiveFilter.allChats;
    }
  }

  void onDestinationSelected(int? i) {
    setState(() {
      activeFilter = getActiveFilterByDestination(i);
    });
  }

  ActiveFilter activeFilter =
      AppConfig.separateChatTypes ? ActiveFilter.messages : ActiveFilter.allChats;

  bool Function(Room) getRoomFilterByActiveFilter(ActiveFilter activeFilter) {
    switch (activeFilter) {
      case ActiveFilter.allChats:
        return (room) => !room.isSpace;
      case ActiveFilter.groups:
        return (room) => !room.isSpace && !room.isDirectChatWithTwoOrLessParticipants;
      case ActiveFilter.messages:
        return (room) => !room.isSpace && room.isDirectChatWithTwoOrLessParticipants;
      case ActiveFilter.spaces:
        return (room) => room.isSpace;
    }
  }

  List<Room> get filteredRooms =>
      Matrix.of(context).client.rooms.where(getRoomFilterByActiveFilter(activeFilter)).toList();

  bool isSearchMode = false;
  Future<QueryPublicRoomsResponse>? publicRoomsResponse;
  String? searchServer;
  Timer? _coolDown;
  SearchUserDirectoryResponse? userSearchResult;
  QueryPublicRoomsResponse? roomSearchResult;

  bool isSearching = false;
  static const String _serverStoreNamespace = 'im.fluffychat.search.server';

  void setServer() async {
    final newServer = await showTextInputDialog(
      useRootNavigator: false,
      title: L10n.of(context)!.changeTheHomeserver,
      context: context,
      okLabel: L10n.of(context)!.ok,
      cancelLabel: L10n.of(context)!.cancel,
      textFields: [
        DialogTextField(
          prefixText: 'https://',
          hintText: Matrix.of(context).client.homeserver?.host,
          initialText: searchServer,
          keyboardType: TextInputType.url,
          autocorrect: false,
        ),
      ],
    );
    if (newServer == null) return;
    Store().setItem(_serverStoreNamespace, newServer.single);
    setState(() {
      searchServer = newServer.single;
    });
    onSearchEnter(searchController.text);
  }

  final TextEditingController searchController = TextEditingController();

  void _search() async {
    final client = Matrix.of(context).client;
    if (!isSearching) {
      setState(() {
        isSearching = true;
      });
    }
    SearchUserDirectoryResponse? userSearchResult;
    QueryPublicRoomsResponse? roomSearchResult;
    try {
      roomSearchResult = await client.queryPublicRooms(
        server: searchServer,
        filter: PublicRoomQueryFilter(genericSearchTerm: searchController.text),
        limit: 20,
      );
      userSearchResult = await client.searchUserDirectory(
        searchController.text,
        limit: 20,
      );
    } catch (e, s) {
      Logs().w('Searching has crashed', e, s);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toLocalizedString(context),
          ),
        ),
      );
    }
    if (!isSearchMode) return;
    setState(() {
      isSearching = false;
      this.roomSearchResult = roomSearchResult;
      this.userSearchResult = userSearchResult;
    });
  }

  void onSearchEnter(String text) {
    if (text.isEmpty) {
      cancelSearch(unfocus: false);
      return;
    }

    setState(() {
      isSearchMode = true;
    });
    _coolDown?.cancel();
    _coolDown = Timer(const Duration(milliseconds: 500), _search);
  }

  void cancelSearch({bool unfocus = true}) {
    setState(() {
      searchController.clear();
      isSearchMode = false;
      roomSearchResult = userSearchResult = null;
      isSearching = false;
    });
    if (unfocus) FocusManager.instance.primaryFocus?.unfocus();
  }

  BoxConstraints? snappingSheetContainerSize;

  final ScrollController scrollController = ScrollController();
  bool scrolledToTop = true;

  final StreamController<Client> _clientStream = StreamController.broadcast();

  Stream<Client> get clientStream => _clientStream.stream;

  void addAccountAction() => VRouter.of(context).to('/settings/account');

  void _onScroll() {
    final newScrolledToTop = scrollController.position.pixels <= 0;
    if (newScrolledToTop != scrolledToTop) {
      setState(() {
        scrolledToTop = newScrolledToTop;
      });
    }
  }

  void editSpace(BuildContext context, String spaceId) async {
    await Matrix.of(context).client.getRoomById(spaceId)!.postLoad();
    if (mounted) {
      VRouter.of(context).toSegments(['spaces', spaceId]);
    }
  }

  // Needs to match GroupsSpacesEntry for 'separate group' checking.
  List<Room> get spaces => Matrix.of(context).client.rooms.where((r) => r.isSpace).toList();

  final selectedRoomIds = <String>{};

  String? get activeChat => VRouter.of(context).pathParameters['roomid'];

  SelectMode get selectMode => Matrix.of(context).shareContent != null
      ? SelectMode.share
      : selectedRoomIds.isEmpty
          ? SelectMode.normal
          : SelectMode.select;

  void _processIncomingSharedFiles(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    final file = File(files.first.path.replaceFirst('file://', ''));

    Matrix.of(context).shareContent = {
      'msgtype': 'chat.fluffy.shared_file',
      'file': MatrixFile(
        bytes: file.readAsBytesSync(),
        name: file.path,
      ).detectFileType,
    };
    VRouter.of(context).to('/rooms');
  }

  void _processIncomingSharedText(String? text) {
    if (text == null) return;
    if (text.toLowerCase().startsWith(AppConfig.deepLinkPrefix) ||
        text.toLowerCase().startsWith(AppConfig.inviteLinkPrefix) ||
        (text.toLowerCase().startsWith(AppConfig.schemePrefix) && !RegExp(r'\s').hasMatch(text))) {
      return _processIncomingUris(text);
    }
    Matrix.of(context).shareContent = {
      'msgtype': 'm.text',
      'body': text,
    };
    VRouter.of(context).to('/rooms');
  }

  void _processIncomingUris(String? text) async {
    if (text == null) return;
    VRouter.of(context).to('/rooms');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UrlLauncher(context, text).openMatrixToUrl();
    });
  }

  void _initReceiveSharingIntent() {
    if (!PlatformInfos.isMobile) return;

    // For sharing images coming from outside the app while the app is in the memory
    _intentFileStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen(_processIncomingSharedFiles, onError: print);

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then(_processIncomingSharedFiles);

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen(_processIncomingSharedText, onError: print);

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then(_processIncomingSharedText);

    // For receiving shared Uris
    _intentUriStreamSubscription = linkStream.listen(_processIncomingUris);
    if (FluffyChatApp.gotInitialLink == false) {
      FluffyChatApp.gotInitialLink = true;
      getInitialLink().then(_processIncomingUris);
    }
  }

  @override
  void initState() {
    setSyncPresenceAccordingToConfig(Matrix.of(context).client);
    _initReceiveSharingIntent();
    scrollController.addListener(_onScroll);
    _waitForFirstSync();
    _hackyWebRTCFixForWeb();
    CallKeepManager().initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        searchServer = await Store().getItem(_serverStoreNamespace);
        Matrix.of(context).backgroundPush?.setupPush();
      }
    });

    // Workaround for chat list loading bug. Can be removed once a proper bugfix is found.
    Future.delayed(const Duration(seconds: 5), reloadChatList);

    super.initState();
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    _intentFileStreamSubscription?.cancel();
    _intentUriStreamSubscription?.cancel();
    scrollController.removeListener(_onScroll);
    super.dispose();
  }

  // Workaround for chat list loading bug. Can be removed once a proper bugfix is found.
  void reloadChatList() {
    if (kDebugMode && const bool.fromEnvironment(enableTestDriver)) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void toggleSelection(String roomId) {
    setState(
      () => selectedRoomIds.contains(roomId)
          ? selectedRoomIds.remove(roomId)
          : selectedRoomIds.add(roomId),
    );
  }

  Future<void> toggleUnread() async {
    await showFutureLoadingDialog(
      context: context,
      future: () async {
        final markUnread = anySelectedRoomNotMarkedUnread;
        final client = Matrix.of(context).client;
        for (final roomId in selectedRoomIds) {
          final room = client.getRoomById(roomId)!;
          if (room.markedUnread == markUnread) continue;
          await client.getRoomById(roomId)!.markUnread(markUnread);
        }
      },
    );
    cancelAction();
  }

  Future<void> toggleFavouriteRoom() async {
    await showFutureLoadingDialog(
      context: context,
      future: () async {
        final makeFavorite = anySelectedRoomNotFavorite;
        final client = Matrix.of(context).client;
        for (final roomId in selectedRoomIds) {
          final room = client.getRoomById(roomId)!;
          if (room.isFavourite == makeFavorite) continue;
          await client.getRoomById(roomId)!.setFavourite(makeFavorite);
        }
      },
    );
    cancelAction();
  }

  Future<void> toggleMuted() async {
    await showFutureLoadingDialog(
      context: context,
      future: () async {
        final newState =
            anySelectedRoomNotMuted ? PushRuleState.mentionsOnly : PushRuleState.notify;
        final client = Matrix.of(context).client;
        for (final roomId in selectedRoomIds) {
          final room = client.getRoomById(roomId)!;
          if (room.pushRuleState == newState) continue;
          await client.getRoomById(roomId)!.setPushRuleState(newState);
        }
      },
    );
    cancelAction();
  }

  Future<void> archiveAction() async {
    final confirmed = await showOkCancelAlertDialog(
          useRootNavigator: false,
          context: context,
          title: L10n.of(context)!.areYouSure,
          okLabel: L10n.of(context)!.yes,
          cancelLabel: L10n.of(context)!.cancel,
        ) ==
        OkCancelResult.ok;
    if (!confirmed) return;
    await showFutureLoadingDialog(
      context: context,
      future: () => _archiveSelectedRooms(),
    );
    setState(() {});
  }

  void setStatus() async {
    final input = await showTextInputDialog(
      useRootNavigator: false,
      context: context,
      title: L10n.of(context)!.setStatus,
      okLabel: L10n.of(context)!.ok,
      cancelLabel: L10n.of(context)!.cancel,
      textFields: [
        DialogTextField(
          hintText: L10n.of(context)!.statusExampleMessage,
        ),
      ],
    );
    if (input == null) return;
    await showFutureLoadingDialog(
      context: context,
      future: () => Matrix.of(context).client.setPresence(
            Matrix.of(context).client.userID!,
            AppConfig.sendPresenceUpdates ? PresenceType.online : PresenceType.offline,
            statusMsg: input.single,
          ),
    );
  }

  Future<void> _archiveSelectedRooms() async {
    final client = Matrix.of(context).client;
    while (selectedRoomIds.isNotEmpty) {
      final roomId = selectedRoomIds.first;
      try {
        await client.getRoomById(roomId)!.leave();
      } finally {
        toggleSelection(roomId);
      }
    }
    final reloadPath = VRouter.of(context).path.split("/!")[0];
    VRouter.of(context).to(reloadPath);
  }

  Future<void> addToSpace() async {
    final selectedSpace = await showConfirmationDialog<String>(
      context: context,
      title: L10n.of(context)!.addToSpace,
      message: L10n.of(context)!.addToSpaceDescription,
      fullyCapitalizedForMaterial: false,
      actions: Matrix.of(context)
          .client
          .rooms
          .where((r) => r.isSpace)
          .map(
            (space) => AlertDialogAction(
              key: space.id,
              label:
                  space.getLocalizedDisplaynameFromCustomNameEvent(MatrixLocals(L10n.of(context)!)),
            ),
          )
          .toList(),
    );
    if (selectedSpace == null) return;
    final result = await showFutureLoadingDialog(
      context: context,
      future: () async {
        final space = Matrix.of(context).client.getRoomById(selectedSpace)!;
        if (space.canSendDefaultStates) {
          for (final roomId in selectedRoomIds) {
            await space.setSpaceChild(roomId);
          }
        }
      },
    );
    if (result.error == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.chatHasBeenAddedToThisSpace),
        ),
      );
    }

    setState(() => selectedRoomIds.clear());
  }

  bool get anySelectedRoomNotMarkedUnread => selectedRoomIds.any(
        (roomId) => !Matrix.of(context).client.getRoomById(roomId)!.markedUnread,
      );

  bool get anySelectedRoomNotFavorite => selectedRoomIds.any(
        (roomId) => !Matrix.of(context).client.getRoomById(roomId)!.isFavourite,
      );

  bool get anySelectedRoomNotMuted => selectedRoomIds.any(
        (roomId) =>
            Matrix.of(context).client.getRoomById(roomId)!.pushRuleState == PushRuleState.notify,
      );

  bool waitForFirstSync = false;

  Future<void> _waitForFirstSync() async {
    final client = Matrix.of(context).client;
    await client.roomsLoading;
    await client.accountDataLoading;
    if (client.prevBatch == null) {
      await client.onSync.stream.first;

      // Only display bootstrap if not in testdriver mode
      if (!const bool.fromEnvironment(enableTestDriver)) {
        // Display first login bootstrap if enabled
        if (client.encryption?.keyManager.enabled == true) {
          if (await client.encryption?.keyManager.isCached() == false ||
              await client.encryption?.crossSigning.isCached() == false ||
              client.isUnknownSession && !mounted) {
            await BootstrapDialog(client: client).show(context);
          }
        }
      }
    }
    if (!mounted) {
      waitForFirstSync = true;
    } else {
      setState(() {
        waitForFirstSync = true;
      });
    }
  }

  void cancelAction() {
    if (selectMode == SelectMode.share) {
      setState(() => Matrix.of(context).shareContent = null);
    } else {
      setState(() => selectedRoomIds.clear());
    }
  }

  void setActiveClient(Client client) {
    VRouter.of(context).to('/rooms');
    setState(() {
      activeFilter = AppConfig.separateChatTypes ? ActiveFilter.messages : ActiveFilter.allChats;
      activeSpaceId = null;
      selectedRoomIds.clear();
      TimProvider.of(context).timAuthState().disposeHbaToken();
      Matrix.of(context).setActiveClient(client);
    });
    _clientStream.add(client);
  }

  void setActiveBundle(String bundle) {
    VRouter.of(context).to('/rooms');
    setState(() {
      selectedRoomIds.clear();
      Matrix.of(context).activeBundle = bundle;
      if (!Matrix.of(context).currentBundle!.any((client) => client == Matrix.of(context).client)) {
        Matrix.of(context).setActiveClient(Matrix.of(context).currentBundle!.first);
      }
    });
  }

  void editBundlesForAccount(String? userId, String? activeBundle) async {
    final l10n = L10n.of(context)!;
    final client =
        Matrix.of(context).widget.clients[Matrix.of(context).getClientIndexByMatrixId(userId!)];
    final action = await showConfirmationDialog<EditBundleAction>(
      context: context,
      title: L10n.of(context)!.editBundlesForAccount,
      actions: [
        AlertDialogAction(
          key: EditBundleAction.addToBundle,
          label: L10n.of(context)!.addToBundle,
        ),
        if (activeBundle != client.userID)
          AlertDialogAction(
            key: EditBundleAction.removeFromBundle,
            label: L10n.of(context)!.removeFromBundle,
          ),
      ],
    );
    if (action == null) return;
    switch (action) {
      case EditBundleAction.addToBundle:
        final bundle = await showTextInputDialog(
          context: context,
          title: l10n.bundleName,
          textFields: [DialogTextField(hintText: l10n.bundleName)],
        );
        if (bundle == null || bundle.isEmpty || bundle.single.isEmpty) return;
        await showFutureLoadingDialog(
          context: context,
          future: () => client.setAccountBundle(bundle.single),
        );
        break;
      case EditBundleAction.removeFromBundle:
        await showFutureLoadingDialog(
          context: context,
          future: () => client.removeFromAccountBundle(activeBundle!),
        );
    }
  }

  bool get displayBundles =>
      Matrix.of(context).hasComplexBundles && Matrix.of(context).accountBundles.keys.length > 1;

  String? get secureActiveBundle {
    if (Matrix.of(context).activeBundle == null ||
        !Matrix.of(context).accountBundles.keys.contains(Matrix.of(context).activeBundle)) {
      return Matrix.of(context).accountBundles.keys.first;
    }
    return Matrix.of(context).activeBundle;
  }

  void resetActiveBundle() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        Matrix.of(context).activeBundle = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadInviteRejectionPolicy();
    Matrix.of(context).navigatorContext = context;
    return ChatListView(this);
  }

  void _hackyWebRTCFixForWeb() {
    ChatList.contextForVoip = context;
  }

  Future<void> _loadInviteRejectionPolicy() async {
    _inviteRejectionPolicy =
        await TimProvider.of(context).inviteRejectionPolicyRepository().getCurrentPolicy();
    setState(() {});
  }
}

enum EditBundleAction { addToBundle, removeFromBundle }

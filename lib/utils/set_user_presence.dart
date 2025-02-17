import 'package:matrix/matrix.dart';

import '../config/app_config.dart';

void setUserPresence(Client client) {
  if (client.userID != null) {
    client.setPresence(
      client.userID!,
      AppConfig.sendPresenceUpdates ? PresenceType.online : PresenceType.offline,
    );
  }
}

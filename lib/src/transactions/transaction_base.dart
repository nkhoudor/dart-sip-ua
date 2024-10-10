import 'dart:async';

import '../event_manager/event_manager.dart';
import '../logger.dart';
import '../sip_message.dart';
import '../timers.dart';
import '../transport.dart';
import '../ua.dart';

enum TransactionState {
  // Transaction states.
  TRYING,
  PROCEEDING,
  CALLING,
  ACCEPTED,
  COMPLETED,
  TERMINATED,
  CONFIRMED
}

abstract class TransactionBase extends EventManager {
  String? id;
  late UA ua;
  Transport? transport;
  TransactionState? state;
  IncomingMessage? last_response;
  Timer? R;
  dynamic request;
  void onTransportError();

  void send();

  void receiveResponse(int status_code, IncomingMessage response,
      [void Function()? onSuccess, void Function()? onFailure]) {
    // default NO_OP implementation
  }

  void safeSend(int retryCount) {
    if (retryCount >= 5) {
      onTransportError();
      return;
    }
    if (!transport!.send(request)) {
      R = setTimeout(() {
        logger.d('Retry transaction $id, retry count: ${retryCount + 1}');
        safeSend(retryCount + 1);
      }, 1000);
    }
  }
}

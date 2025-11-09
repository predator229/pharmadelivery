import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DeliverymanSocketService extends ChangeNotifier {
  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (isConnected) return;

    final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);

    _socket = IO.io(
      // 'http://10.15.43.113:5050',
      'http://192.168.1.215:5050/deliver',
      // 'https://backend-cmpaharma-production.up.railway.app:5050',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setAuth({'token': token})
          .setQuery({'token': token}) // 2ème approche avec query params
          .build(),
    );
    _socket!.onConnect((_) {
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      notifyListeners();
    });
    _socket!.onConnectError((err) {
      notifyListeners();
    });
    _socket!.on('message', (data) {
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.clearListeners();
    _socket = null;
    notifyListeners();
  }

  void sendMessage(String event, dynamic data) {
    if (isConnected) {
      _socket!.emit(event, data);
    } else {
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

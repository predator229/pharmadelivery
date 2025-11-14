import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeliverymanSocketService extends ChangeNotifier {
  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  String get baseUrl {
    final base = dotenv.env['API_BASE_URL'];
    final namespace = dotenv.env['API_NAMESPACE'];
    final prefix = dotenv.env['WEBSOCKET_PREFIX'];

    if (base != null && base.isNotEmpty &&
        namespace != null && namespace.isNotEmpty &&
        prefix != null && prefix.isNotEmpty) {
      return "$base$namespace$prefix";
    } else {
      print('⚠️ Variables .env manquantes ou vides. Utilisation de l\'URL locale par défaut. deliveryman.controller.dart');
      return 'http://192.168.1.215:5050/deliver/websocket/';
    }
  }
  DeliverymanSocketService();

  Future<void> connect() async {
    if (isConnected) return;

    final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);

    _socket = IO.io(baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setAuth({'token': token})
          .setQuery({'token': token})
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

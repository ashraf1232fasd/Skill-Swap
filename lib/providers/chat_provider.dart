import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../data/services/dio_client.dart';
import '../core/constants.dart';

class ChatProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();
  
  // التغيير هنا: جعلناه يقبل null بدلاً من late لمنع الكراش
  IO.Socket? _socket; 
  
  List<dynamic> _myChats = [];
  List<dynamic> _messages = [];
  bool _isLoading = false;

  List<dynamic> get myChats => _myChats;
  List<dynamic> get messages => _messages;
  bool get isLoading => _isLoading;

  // تهيئة السوكت
  void initSocket(String userId) {
    // إذا كان متصلاً بالفعل لا تقم بإعادة الاتصال
    if (_socket != null && _socket!.connected) return;

    String socketUrl = AppConstants.baseUrl.replaceAll('/api', '');
    
    _socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Socket connection established ✅');
      _socket!.emit('setup', {'_id': userId});
    });

    _socket!.on('message received', (newMessageReceived) {
      _messages.add(newMessageReceived);
      notifyListeners();
    });
    
    _socket!.onDisconnect((_) => print('Socket Disconnected ❌'));
  }

  // جلب المحادثات (Inbox)
  Future<void> fetchChats() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _dioClient.dio.get('/chat');
      _myChats = res.data;
    } catch (e) {
      print("Error fetching chats: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  // دخول الشات
  Future<Map<String, dynamic>?> accessChat(String userId) async {
    try {
      final res = await _dioClient.dio.post('/chat', data: {'userId': userId});
      
      bool exists = _myChats.any((element) => element['_id'] == res.data['_id']);
      if (!exists) {
        _myChats.insert(0, res.data);
        notifyListeners();
      }
      return res.data;
    } catch (e) {
      print("Error accessing chat: $e");
      return null;
    }
  }

  // جلب الرسائل
  Future<void> fetchMessages(String chatId) async {
    _isLoading = true;
    _messages = [];
    notifyListeners();
    try {
      final res = await _dioClient.dio.get('/chat/message/$chatId');
      _messages = res.data;
      
      // نستخدم ? لمنع الخطأ إذا لم يكن السوكت جاهزاً
      _socket?.emit('join chat', chatId);
    } catch (e) {
      print("Error fetching messages: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  // إرسال رسالة
  Future<void> sendMessage(String content, String chatId) async {
    if (content.isEmpty) return;
    try {
      final res = await _dioClient.dio.post('/chat/message', data: {
        "content": content,
        "chatId": chatId,
      });
      
      _messages.add(res.data);
      // إرسال عبر السوكت فقط إذا كان متصلاً
      _socket?.emit('new message', res.data);
      notifyListeners();
    } catch (e) {
      print("Error sending message: $e");
    }
  }
  
  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }
}
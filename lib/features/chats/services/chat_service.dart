import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_models.dart';
import '../../auth/models/user_profile.dart'; // UserProfile için
import '../../../core/utils/log_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // Profile cache to avoid repetitive fetches (N+1 problem)
  static final Map<String, UserProfile> _profileCache = {};

  /// Sohbet Listesini Getir (Realtime)
  Stream<List<ChatConversation>> getConversations() {
    final user = currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('conversations')
        .where('userIds', arrayContains: user.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final chats = <ChatConversation>[];
          
          for (var doc in snapshot.docs) {
            var chat = ChatConversation.fromFirestore(doc, user.uid);
            
            if (chat.otherUserId.isNotEmpty) {
               // Check cache first
               if (_profileCache.containsKey(chat.otherUserId)) {
                 final cachedProfile = _profileCache[chat.otherUserId]!;
                 chat = chat.copyWithDetails(
                   name: cachedProfile.name,
                   avatar: cachedProfile.imageUrl,
                   isOnline: cachedProfile.isOnline,
                 );
               } else {
                 try {
                   final userDoc = await _firestore.collection('users').doc(chat.otherUserId).get();
                   if (userDoc.exists) {
                     final userProfile = UserProfile.fromMap(userDoc.data()!);
                     _profileCache[chat.otherUserId] = userProfile; // Update cache
                     chat = chat.copyWithDetails(
                       name: userProfile.name,
                       avatar: userProfile.imageUrl,
                       isOnline: userProfile.isOnline,
                     );
                   } else {
                     chat = chat.copyWithDetails(name: "Silinmiş Kullanıcı");
                   }
                 } catch (e) {
                   LogService.e("Error fetching user details for chat: $e");
                 }
               }
            }
            chats.add(chat);
          }
          return chats;
        });
  }

  /// Mesajları Getir (Realtime)
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('conversations')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
    });
  }

  /// Mesaj Gönder
  Future<void> sendMessage(String chatId, String content, String receiverId) async {
    final user = currentUser;
    if (user == null) return;

    final timestamp = Timestamp.now();

    // 1. Mesajı alt koleksiyona ekle
    await _firestore
        .collection('conversations')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'content': content,
      'timestamp': timestamp,
      'isRead': false,
    });

    // 2. Ana sohbet belgesini güncelle (son mesaj, okunmamış sayısı vb.)
    // Okunmamış sayısını artırmak için receiverId'yi kullanarak map'i güncelle
    await _firestore.collection('conversations').doc(chatId).update({
      'lastMessage': content,
      'lastMessageTime': timestamp,
      'lastMessageSenderId': user.uid,
      'unreadCounts.$receiverId': FieldValue.increment(1), // Karşı taraf için 1 artır
    });
  }

  /// Yeni Sohbet Başlat veya Mevcut Olanı Getir
  Future<String> startChat(String receiverId) async {
    final user = currentUser;
    if (user == null) throw Exception("Giriş yapılmamış");

    // Önce mevcut sohbet var mı kontrol et
    // Not: userIds dizisi sıralı değilse [user.uid, receiverId] ve [receiverId, user.uid] permütasyonlarını kontrol etmek zor olabilir.
    // İpucu: 'userIds' array-contains sorgusu ile kullanıcının sohbetlerini çekip memory'de receiverId'yi kontrol etmek,
    // çok fazla sohbet yoksa (MVP için) daha ucuzdur.
    // Büyük ölçekte userIds'i sorted saklamak ve composite key (uid1_uid2) kullanmak daha iyidir.
    
    // Yöntem 1: Basit sorgu
    final query = await _firestore
        .collection('conversations')
        .where('userIds', arrayContains: user.uid)
        .get();

    for (var doc in query.docs) {
      final List<dynamic> users = doc['userIds'];
      if (users.contains(receiverId)) {
        return doc.id; // Zaten var
      }
    }

    // Yoksa yeni oluştur
    final docRef = await _firestore.collection('conversations').add({
      'userIds': [user.uid, receiverId],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCounts': {
        user.uid: 0,
        receiverId: 0,
      }
    });

    return docRef.id;
  }
  
  /// Mesajları okundu olarak işaretle
  Future<void> markAsRead(String chatId) async {
    final user = currentUser;
    if (user == null) return;

    await _firestore.collection('conversations').doc(chatId).update({
      'unreadCounts.${user.uid}': 0,
    });
  }
}

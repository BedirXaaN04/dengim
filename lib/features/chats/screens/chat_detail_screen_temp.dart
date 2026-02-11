import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/log_service.dart';
import '../../../core/services/audio_recorder_service.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/typing_indicator_service.dart';
import '../../../core/widgets/online_status_indicator.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/feature_flag_service.dart';

import '../models/chat_models.dart';
import '../services/chat_service.dart';
import '../widgets/chat_widgets.dart';
import '../../auth/services/report_service.dart';
import '../../payment/premium_offer_screen.dart';
import 'call_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

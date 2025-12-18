import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const GoogleLoginApp());
}

class GoogleLoginApp extends StatelessWidget {
  const GoogleLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Login Test with User Info',
      home: const GoogleLoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  // iOS에서는 GoogleService-Info.plist의 CLIENT_ID를 자동으로 사용
  // serverClientId는 백엔드 검증용이므로 iOS의 경우 별도 설정 필요
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  GoogleSignInAccount? _currentUser;
  Map<String, dynamic>? _serverUserInfo;
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);

    try {
      debugPrint("🔄 Google Sign In 시작...");
      final GoogleSignInAccount? user = await _googleSignIn.signIn();

      if (user == null) {
        debugPrint("❌ 사용자가 로그인을 취소했습니다");
        setState(() => _loading = false);
        return;
      }

      debugPrint("✅ Google Sign In 성공: ${user.email}");

      final googleAuth = await user.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint("❌ ID Token을 가져올 수 없습니다");
        setState(() => _loading = false);
        return;
      }

      debugPrint("📤 백엔드로 ID Token 전송 중...");

      /// 1) FastAPI 로그인
      final loginRes = await http.post(
        Uri.parse("http://10.0.2.2:8000/auth/google"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_token": idToken}),
      );

      debugPrint("📥 백엔드 응답: ${loginRes.statusCode}");
      if (loginRes.statusCode != 200) {
        debugPrint("❌ 백엔드 로그인 실패: ${loginRes.body}");
        throw Exception("Backend login failed: ${loginRes.body}");
      }

      final loginData = jsonDecode(loginRes.body);
      final uid = loginData["uid"];
      debugPrint("✅ 백엔드 로그인 성공! UID: $uid");

      /// 2) FastAPI에서 사용자 정보 GET
      debugPrint("📤 사용자 정보 요청 중...");
      final infoRes = await http.get(
        Uri.parse("http://10.0.2.2:8000/user/info?uid=$uid"),
      );

      if (infoRes.statusCode != 200) {
        debugPrint("❌ 사용자 정보 조회 실패: ${infoRes.body}");
        throw Exception("Failed to get user info: ${infoRes.body}");
      }

      final infoData = jsonDecode(infoRes.body);
      debugPrint("✅ 사용자 정보 조회 성공!");
      debugPrint("📊 서버 사용자 정보: $infoData");

      setState(() {
        _currentUser = user;
        _serverUserInfo = infoData; // 서버에서 가져온 사용자 정보
      });

      debugPrint("🎉 구글 로그인 전체 플로우 완료!");

      // 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ 구글 로그인 성공!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint("=" * 60);
      debugPrint("❌ 에러 발생!");
      debugPrint("Error: $e");
      debugPrint("Stack trace: $stack");
      debugPrint("=" * 60);

      // 사용자에게 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("로그인 실패: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _currentUser = null;
      _serverUserInfo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Google Login Test"), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? Center(
              child: ElevatedButton(
                onPressed: _signIn,
                child: const Text("Sign in with Google"),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user.photoUrl ?? ""),
                ),
                const SizedBox(height: 10),
                Text(
                  user.displayName ?? "",
                  style: const TextStyle(fontSize: 20),
                ),
                Text(user.email),
                const SizedBox(height: 20),
                if (_serverUserInfo != null) ...[
                  const Text(
                    "📌 Server User Info",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("UID: ${_serverUserInfo!['uid']}"),
                  Text("Role: ${_serverUserInfo!['role']}"),
                  Text("Created: ${_serverUserInfo!['created_at']}"),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signOut,
                  child: const Text("Logout"),
                ),
              ],
            ),
    );
  }
}

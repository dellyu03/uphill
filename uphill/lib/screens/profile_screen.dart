import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../login_test.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<UphillColors>()!;
    final authService = AuthService();
    final userInfo = authService.userInfo;

    return Scaffold(
      backgroundColor: colors.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '마이페이지',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: userInfo?['picture'] != null
                        ? ClipOval(
                            child: Image.network(
                              userInfo!['picture'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userInfo?['name'] ?? '사용자',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userInfo?['email'] ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '오늘도 힘차게 오르고 있습니다!',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _buildSection('내 정보', [
              _buildListTile(Icons.person_outline, '프로필 수정'),
              _buildListTile(Icons.lock_outline, '비밀번호 변경'),
            ]),
            const SizedBox(height: 24),
            _buildSection('활동', [
              _buildListTile(Icons.bar_chart, '통계 보기'),
              _buildListTile(Icons.workspace_premium, '뱃지 보관함'),
            ]),
            const SizedBox(height: 24),
            _buildSection('지원', [
              _buildListTile(Icons.help_outline, '고객센터'),
              _buildListTile(Icons.info_outline, '앱 정보'),
            ]),
            const SizedBox(height: 24),
            _buildSection('계정', [
              _buildListTile(Icons.logout, '로그아웃', onTap: () async {
                final authService = AuthService();
                await authService.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const GoogleLoginScreen()),
                    (route) => false,
                  );
                }
              }),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }
}

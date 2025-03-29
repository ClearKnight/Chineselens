import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:chinese_lens/config/constants.dart';
import 'package:chinese_lens/features/auth/presentation/bloc/bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomeContent(),
    const Placeholder(color: Colors.green), // 历史记录页
    const Placeholder(color: Colors.blue), // 学习页面
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'home.tab.home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history_outlined),
            activeIcon: const Icon(Icons.history),
            label: 'home.tab.history'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.school_outlined),
            activeIcon: const Icon(Icons.school),
            label: 'home.tab.learn'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: 'home.tab.profile'.tr(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(RouteConstants.camera);
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app.title'.tr()),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UiConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 欢迎信息
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final username =
                      state.user?.name ?? 'home.greeting.user'.tr();
                  return Text(
                    'home.greeting'.tr(args: [username]),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  );
                },
              ),
              const SizedBox(height: UiConstants.paddingS),
              Text(
                'home.subgreeting'.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: UiConstants.paddingL),

              // 快速操作卡片
              Text(
                'home.quickactions'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: UiConstants.paddingM),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.camera_alt,
                      title: 'home.action.scan'.tr(),
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: UiConstants.paddingM),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.school,
                      title: 'home.action.learn'.tr(),
                      onTap: () {
                        // 切换到学习页面
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UiConstants.paddingL),

              // 进度统计
              Text(
                'home.progress'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: UiConstants.paddingM),
              const ProgressSection(),

              const Spacer(),

              // 提示信息
              Container(
                padding: const EdgeInsets.all(UiConstants.paddingM),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(UiConstants.cardRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: UiConstants.paddingM),
                    Expanded(
                      child: Text(
                        'home.tip'.tr(),
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UiConstants.cardRadius),
      child: Ink(
        padding: const EdgeInsets.all(UiConstants.paddingM),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(UiConstants.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: UiConstants.paddingS),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressSection extends StatelessWidget {
  const ProgressSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 这里应该从用户数据中获取实际的进度数据
    // 这是示例数据
    return Column(
      children: [
        _buildProgressCard(
          context,
          icon: Icons.visibility,
          title: 'home.progress.scanned'.tr(),
          value: '27',
          subtitle: 'home.progress.characters'.tr(),
        ),
        const SizedBox(height: UiConstants.paddingM),
        _buildProgressCard(
          context,
          icon: Icons.star,
          title: 'home.progress.mastered'.tr(),
          value: '12',
          subtitle: 'home.progress.characters'.tr(),
        ),
      ],
    );
  }

  Widget _buildProgressCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(UiConstants.paddingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(UiConstants.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(UiConstants.paddingM),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(UiConstants.cardRadius),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: UiConstants.paddingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
              Row(
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(width: UiConstants.paddingXs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile.title'.tr()),
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.status == AuthStatus.authenticated &&
                state.user != null) {
              final user = state.user!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(UiConstants.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 用户头像
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Text(
                              user.name?.isNotEmpty == true
                                  ? user.name!.substring(0, 1).toUpperCase()
                                  : user.email.substring(0, 1).toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            )
                          : null,
                    ),
                    const SizedBox(height: UiConstants.paddingM),

                    // 用户名
                    Text(
                      user.name ?? 'profile.unnamed'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: UiConstants.paddingXs),

                    // 邮箱
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: UiConstants.paddingXl),

                    // 账户信息卡片
                    _buildSectionCard(
                      context,
                      title: 'profile.account'.tr(),
                      items: [
                        ProfileMenuItem(
                          icon: Icons.person_outline,
                          title: 'profile.editProfile'.tr(),
                          onTap: () {
                            // 编辑个人资料
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.email_outlined,
                          title: 'profile.verifyEmail'.tr(),
                          subtitle: user.isEmailVerified
                              ? 'profile.verified'.tr()
                              : 'profile.notVerified'.tr(),
                          onTap: () {
                            if (!user.isEmailVerified) {
                              context
                                  .read<AuthBloc>()
                                  .add(const VerifyEmailRequested());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('profile.verificationSent'.tr()),
                                ),
                              );
                            }
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.password_outlined,
                          title: 'profile.changePassword'.tr(),
                          onTap: () {
                            // 修改密码
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: UiConstants.paddingM),

                    // 设置卡片
                    _buildSectionCard(
                      context,
                      title: 'profile.settings'.tr(),
                      items: [
                        ProfileMenuItem(
                          icon: Icons.language_outlined,
                          title: 'profile.language'.tr(),
                          onTap: () {
                            // 切换语言
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.brightness_6_outlined,
                          title: 'profile.theme'.tr(),
                          onTap: () {
                            // 切换主题
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.notifications_outlined,
                          title: 'profile.notifications'.tr(),
                          onTap: () {
                            // 通知设置
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: UiConstants.paddingM),

                    // 其他卡片
                    _buildSectionCard(
                      context,
                      title: 'profile.other'.tr(),
                      items: [
                        ProfileMenuItem(
                          icon: Icons.help_outline,
                          title: 'profile.help'.tr(),
                          onTap: () {
                            // 帮助页面
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.info_outline,
                          title: 'profile.about'.tr(),
                          onTap: () {
                            // 关于页面
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.logout,
                          title: 'profile.logout'.tr(),
                          textColor: Theme.of(context).colorScheme.error,
                          onTap: () {
                            context
                                .read<AuthBloc>()
                                .add(const LogoutRequested());
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.delete_outline,
                          title: 'profile.deleteAccount'.tr(),
                          textColor: Theme.of(context).colorScheme.error,
                          onTap: () {
                            // 删除账户确认对话框
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('profile.deleteAccount'.tr()),
                                content:
                                    Text('profile.deleteAccountConfirm'.tr()),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text('common.cancel'.tr()),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      context
                                          .read<AuthBloc>()
                                          .add(const DeleteAccountRequested());
                                    },
                                    child: Text(
                                      'common.delete'.tr(),
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<ProfileMenuItem> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(UiConstants.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(UiConstants.paddingM),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          ...items.map((item) => _buildMenuItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, ProfileMenuItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiConstants.paddingM,
          vertical: UiConstants.paddingM,
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: item.textColor ?? Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(width: UiConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: item.textColor,
                        ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? textColor;

  const ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.textColor,
  });
}

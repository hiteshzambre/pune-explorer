import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/admin_permissions.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/cms_models.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddAdminModal(BuildContext context) {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    AdminRole role = AdminRole.contentAdmin;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Administrator Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField('Full Name', nameCtrl),
              const SizedBox(height: 12),
              _buildField('Admin Email Address', emailCtrl),
              const SizedBox(height: 12),
              const Text('Assigned RBAC Role', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AdminRole>(
                    value: role,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: AdminRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(),
                    onChanged: (newRole) {
                      if (newRole != null) setDialogState(() => role = newRole);
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
              onPressed: () async {
                final email = emailCtrl.text.trim();
                final name = nameCtrl.text.trim();
                if (email.isEmpty || name.isEmpty) return;

                final newAccount = AdminAccount(
                  id: 'adm_${DateTime.now().millisecondsSinceEpoch}',
                  email: email,
                  name: name,
                  role: role,
                  createdAt: DateTime.now().toIso8601String(),
                );

                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();
                await ref.read(authRepositoryProvider).saveAdminAccount(newAccount);
                ref.invalidate(adminAccountsProvider);

                final admin = ref.read(adminSessionProvider);
                await ref.read(auditLogsProvider.notifier).log(
                  actorEmail: admin.email.isNotEmpty ? admin.email : 'admin@puneexplorer.in',
                  actorRole: admin.role,
                  action: 'CREATE_ADMIN_ACCOUNT',
                  resourceType: 'ADMIN_USER',
                  resourceId: newAccount.id,
                  metadata: {'email': newAccount.email, 'role': newAccount.role.label},
                );

                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Admin account ${newAccount.email} created!'), backgroundColor: AppColors.emerald),
                  );
                }
              },
              child: const Text('Create Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final adminsAsync = ref.watch(adminAccountsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: const Color(0xFF0F172A),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.emerald,
            labelColor: AppColors.emerald,
            unselectedLabelColor: const Color(0xFF94A3B8),
            tabs: const [
              Tab(icon: Icon(Icons.people_alt_rounded, size: 18), text: 'Registered Travelers & Customers'),
              Tab(icon: Icon(Icons.admin_panel_settings_rounded, size: 18), text: 'Administrators & RBAC Access'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Travelers & Customers
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('User Accounts & Customers', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('Manage registered customer profiles, account standing, and status suspensions.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                const SizedBox(height: 20),
                usersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
                  error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.error)),
                  data: (users) {
                    if (users.isEmpty) return const Center(child: Text('No registered users yet.', style: TextStyle(color: Colors.grey)));

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final u = users[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: u.isSuspended ? AppColors.error : const Color(0xFF334155)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF0F172A),
                                child: Text(u.name.isNotEmpty ? u.name[0] : 'U', style: const TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(u.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                                        if (u.isSuspended) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                            child: const Text('SUSPENDED', style: TextStyle(color: AppColors.error, fontSize: 9.5, fontWeight: FontWeight.w900)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text('${u.email} • ${u.phone}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: u.isSuspended ? AppColors.emerald : AppColors.error),
                                  foregroundColor: u.isSuspended ? AppColors.emerald : AppColors.error,
                                ),
                                onPressed: () async {
                                  await ref.read(authRepositoryProvider).toggleUserSuspension(u.id, !u.isSuspended);
                                  ref.invalidate(allUsersProvider);
                                },
                                child: Text(u.isSuspended ? 'Activate' : 'Suspend'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // 2. Administrators & RBAC
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Administrative Personnel & RBAC', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        SizedBox(height: 4),
                        Text('Granular role-based assignments: Super Admin, Content, Booking, Support, Analytics.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
                      icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 18),
                      label: const Text('Add Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      onPressed: () => _showAddAdminModal(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                adminsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
                  error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.error)),
                  data: (admins) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: admins.length,
                      itemBuilder: (context, index) {
                        final a = admins[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.emerald.withValues(alpha: 0.2),
                                child: const Icon(Icons.shield_rounded, color: AppColors.emerald, size: 18),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(a.name, style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.emerald.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            a.role.label.toUpperCase(),
                                            style: const TextStyle(color: AppColors.emerald, fontSize: 10, fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(a.email, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

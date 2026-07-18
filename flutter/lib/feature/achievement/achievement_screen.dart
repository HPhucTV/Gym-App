import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/model/achievement_models.dart';
import '../../data/providers/data_providers.dart';

final unlockedAchievementsProvider = StreamProvider<List<Achievement>>((ref) {
  final database = ref.watch(gymDatabaseProvider);
  return database.achievementDao.observeAll().map((list) {
    return list.map((item) {
      final type = AchievementType.values.firstWhere(
        (val) =>
            val.toString().split('.').last == item.type ||
            val.name == item.type,
        orElse: () => AchievementType.firstWorkout,
      );
      return Achievement(
        type: type,
        unlockedAtEpochMillis: item.unlockedAtEpochMillis,
      );
    }).toList();
  });
});

class AchievementScreen extends ConsumerWidget {
  final VoidCallback onBack;

  const AchievementScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedAsync = ref.watch(unlockedAchievementsProvider);

    return unlockedAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Lỗi: $err')),
      ),
      data: (unlockedList) {
        final unlockedMap = {for (var a in unlockedList) a.type: a};

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF14213D)),
              onPressed: onBack,
            ),
            title: const Text(
              "Thành Tựu & Huy Hiệu 🏆",
              style: TextStyle(
                color: Color(0xFF14213D),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14213D),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Danh Hiệu Chiến Binh",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              "Đã mở khóa ${unlockedList.length} / ${AchievementType.values.length} huy hiệu",
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "${((unlockedList.length * 100) / AchievementType.values.length).round()}%",
                          style: const TextStyle(
                            color: Color(0xFFF97316),
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Text(
                    "TỦ HUY HIỆU CỦA BẠN",
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                // Grid of Badges
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: AchievementType.values.length,
                    itemBuilder: (context, index) {
                      final badge = AchievementType.values[index];
                      final unlockInfo = unlockedMap[badge];
                      final isUnlocked = unlockInfo != null;

                      return _BadgeItem(
                        badge: badge,
                        isUnlocked: isUnlocked,
                        onClick: () {
                          _showBadgeDetail(context, badge, unlockInfo);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBadgeDetail(
      BuildContext context, AchievementType badge, Achievement? unlockInfo) {
    showDialog(
      context: context,
      builder: (context) => _BadgeDetailDialog(
        badge: badge,
        unlockInfo: unlockInfo,
        isUnlocked: unlockInfo != null,
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final AchievementType badge;
  final bool isUnlocked;
  final VoidCallback onClick;

  const _BadgeItem({
    required this.badge,
    required this.isUnlocked,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isUnlocked
              ? const Color(0xFFF3F4F6)
              : const Color(0xFFF3F4F6).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            width: 1.0,
            color:
                isUnlocked ? const Color(0xFFF97316) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: isUnlocked ? 1.0 : 0.25,
              child: Text(
                badge.icon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              badge.titleVi,
              style: TextStyle(
                color: isUnlocked
                    ? const Color(0xFF14213D)
                    : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeDetailDialog extends StatelessWidget {
  final AchievementType badge;
  final Achievement? unlockInfo;
  final bool isUnlocked;

  const _BadgeDetailDialog({
    required this.badge,
    required this.unlockInfo,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    String dateStr = "";
    if (isUnlocked && unlockInfo != null) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(
          unlockInfo!.unlockedAtEpochMillis);
      dateStr = DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.white,
      title: Column(
        children: [
          Text(badge.icon, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 12.0),
          Text(
            badge.titleVi,
            style: const TextStyle(
              color: Color(0xFF14213D),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            badge.descriptionVi,
            style: const TextStyle(
              color: Color(0xFF14213D),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          if (isUnlocked)
            Text(
              "🔓 Đã mở khóa vào:\n$dateStr",
              style: const TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            )
          else
            const Text(
              "🔒 Chưa mở khóa",
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnlocked) ...[
              OutlinedButton(
                onPressed: () {
                  final shareText = """
🏆 THÀNH TỰU MỚI TỪ SMARTGYM 🏆
🥇 Tôi vừa mở khóa huy hiệu: ${badge.icon} ${badge.titleVi}!
🎯 Mô tả: ${badge.descriptionVi}
🔥 Tập luyện thông minh, offline-first cùng SmartGym!
                  """
                      .trim();
                  Clipboard.setData(ClipboardData(text: shareText)).then((_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Đã sao chép nội dung chia sẻ vào bộ nhớ tạm!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  });
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  side: const BorderSide(color: Color(0xFFF97316)),
                  foregroundColor: const Color(0xFFF97316),
                ),
                child: const Text("Chia sẻ 🔗",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8.0),
            ],
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
              ),
              child: const Text("Đóng",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';

class DailyMissionPage extends StatefulWidget {
  const DailyMissionPage({super.key});

  @override
  State<DailyMissionPage> createState() => _DailyMissionPageState();
}

class _DailyMissionPageState extends State<DailyMissionPage> {
  // Sample missions data with completion status
  late List<Map<String, dynamic>> _missions;

  @override
  void initState() {
    super.initState();
    _missions = [
      {'title': 'Play 1 Game', 'reward': 100, 'completed': false},
      {'title': 'Win 1 Round', 'reward': 200, 'completed': false},
      {'title': 'Bank Co 3 times', 'reward': 300, 'completed': false},
      {'title': 'Reach 500 chips', 'reward': 500, 'completed': false},
      {'title': 'Play 3 Games', 'reward': 700, 'completed': false},
    ];
  }

  void _claimReward(int index) {
    setState(() {
      _missions[index]['completed'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Claimed ${_missions[index]['reward']} chips!',
          style: AppTheme.bodyText,
        ),
        backgroundColor: AppTheme.emeraldGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.richBlack,
      appBar: AppBar(
        title: Text('Daily Missions', style: AppTheme.headingMedium),
        centerTitle: true,
        backgroundColor: AppTheme.pureBlack,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.primaryGold,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: _missions.length,
          itemBuilder: (context, index) {
            final mission = _missions[index];
            final completed = mission['completed'] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: completed
                      ? AppTheme.emeraldGreen
                      : AppTheme.primaryGold.withOpacity(0.3),
                  width: completed ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                leading: Icon(
                  completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: completed
                      ? AppTheme.emeraldGreen
                      : AppTheme.primaryGold,
                  size: 28,
                ),
                title: Text(
                  mission['title'],
                  style: AppTheme.bodyText.copyWith(
                    decoration: completed ? TextDecoration.lineThrough : null,
                    color: completed
                        ? AppTheme.offWhite.withOpacity(0.6)
                        : null,
                  ),
                ),
                subtitle: Text(
                  'Reward: ${mission['reward']} chips',
                  style: AppTheme.captionGold,
                ),
                trailing: completed
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.emeraldGreen),
                        ),
                        child: Text(
                          'Claimed',
                          style: AppTheme.captionGold.copyWith(fontSize: 12),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () => _claimReward(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: AppTheme.pureBlack,
                          textStyle: AppTheme.buttonText.copyWith(fontSize: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Claim'),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

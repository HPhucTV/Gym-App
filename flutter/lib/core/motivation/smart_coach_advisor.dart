import '../model/goal_models.dart';
import '../../data/repositories/nutrition_repository.dart';

class SmartCoachAdvisor {
  static String getLocalAdvice({
    required FitnessGoal goal,
    required bool completedToday,
    required NutritionData nutrition,
    required String sessionTitle,
  }) {
    final calories = nutrition.caloriesEaten;
    final protein = nutrition.proteinEaten;
    final isOverCalorie = calories > 2000; // default limit or approximation

    switch (goal) {
      case FitnessGoal.muscleGain:
        if (completedToday) {
          if (protein < 60) {
            return "Bạn đã hoàn thành buổi tập [$sessionTitle] rất tốt! Tuy nhiên, đạm (Protein) nạp vào hôm nay hơi thấp (${protein}g). Hãy bổ sung thêm trứng, sữa chua hoặc thịt gà để hỗ trợ phục hồi và xây dựng cơ bắp nhé! 🥚";
          } else {
            return "Buổi tập [$sessionTitle] hoàn thành xuất sắc! Lượng đạm ${protein}g nạp vào đang rất tốt để phát triển cơ bắp. Hãy ngủ đủ giấc để cơ thể phục hồi tối đa! 💪";
          }
        } else {
          return "Hôm nay có buổi tập [$sessionTitle] đang chờ bạn kích hoạt cơ bắp. Đừng quên nạp tinh bột tốt trước tập để có nguồn năng lượng dồi dào nhé! ⚡";
        }
      case FitnessGoal.fatLossConditioning:
        if (completedToday) {
          if (nutrition.sweatActive) {
            return "Đã tập xong buổi [$sessionTitle]! Bạn nạp vượt calo định mức ($calories kcal), nhưng nhiệm vụ Sweat Payment [${nutrition.sweatExerciseName}] đã tự động cộng thêm hiệp để bù đắp. Tuyệt vời! 💦";
          } else if (isOverCalorie) {
            return "Buổi tập [$sessionTitle] đã xong! Lượng calo nạp vào hôm nay hơi cao ($calories kcal). Hãy chú ý giảm bớt đồ ăn ngọt và chất béo trong thực đơn ngày mai nhé! 🥗";
          } else {
            return "Chúc mừng bạn đã hoàn thành buổi tập [$sessionTitle] và kiểm soát calo nạp vào cực tốt ($calories kcal). Bạn đang đi đúng hướng để đốt mỡ hiệu quả! 🧘";
          }
        } else {
          return "Hãy cố gắng hoàn thành buổi tập [$sessionTitle] hôm nay để duy trì thâm hụt calo đốt mỡ. Uống đủ nước trước và trong khi tập nhé! 💧";
        }
      case FitnessGoal.endurance:
        if (completedToday) {
          return "Hoàn thành buổi tập sức bền [$sessionTitle]! Thể lực của bạn đang được nâng cấp qua từng ngày. Hãy bổ sung đầy đủ nước và chất điện giải nhé! 🏃‍♂️";
        } else {
          return "Buổi tập luyện tim mạch và sức bền [$sessionTitle] đang chờ bạn chinh phục. Tập trung vào nhịp thở đều đặn và duy trì nhịp độ nhé! 💨";
        }
      case FitnessGoal.generalFitness:
        if (completedToday) {
          return "Tuyệt vời! Bạn đã duy trì thói quen vận động tốt hôm nay với bài [$sessionTitle]. Ăn uống cân bằng và ngủ đủ giấc để cơ thể luôn tràn đầy sinh khí nhé! 🍎";
        } else {
          return "Một buổi tập nhẹ nhàng [$sessionTitle] đang chờ bạn. Hãy vận động hôm nay để duy trì lối sống năng động, khỏe mạnh và giảm stress! 🚶";
        }
    }
  }
}

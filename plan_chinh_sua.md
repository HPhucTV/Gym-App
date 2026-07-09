# Kế Hoạch Chi Tiết Chỉnh Sửa Ứng Dụng Gym App

Tài liệu này phân tích chi tiết các yêu cầu chỉnh sửa từ ghi chú của người dùng dựa trên cấu trúc codebase hiện tại của ứng dụng Android Gym App và đề xuất phương án triển khai cụ thể.

---

## 1. Phân Tích Yêu Cầu và Giải Pháp Codebase

### Yêu cầu 1: Bỏ mã vạch (Remove Barcode Scanning)
*   **Phân tích codebase**: 
    *   `NutritionScreen.kt` chứa giao diện quét mã vạch bằng camera (sử dụng ML Kit `BarcodeScanning`) và dialog nhập mã vạch thủ công (`BarcodeScannerDialog`).
    *   `NutritionViewModel.kt` có các phương thức như `scanBarcode(...)` để gửi mã vạch lên server hoặc kiểm tra offline.
*   **Giải pháp**:
    *   Gỡ bỏ nút quét mã vạch và các dialog liên quan trong `NutritionScreen.kt`.
    *   Xóa bỏ logic xử lý mã vạch, các hàm `scanBarcode` trong `NutritionViewModel.kt`.
    *   *(Tùy chọn)* Gỡ bỏ thư viện ML Kit barcode scanning (`com.google.mlkit:barcode-scanning`) trong `app/build.gradle.kts` để giảm kích thước APK.

### Yêu cầu 2: Up file Excel (Import Exercises/Programs via Excel)
*   **Phân tích codebase**:
    *   Dữ liệu bài tập (`exercises_vi.json`) và chương trình (`programs.json`) đang được đọc tĩnh từ thư mục `assets/catalog/`.
*   **Giải pháp**:
    *   Thêm một tính năng "Nhập dữ liệu tập luyện" tại tab **Cài đặt (Settings)**.
    *   Cho phép người dùng tải lên file `.xlsx` hoặc `.xls` từ bộ nhớ thông qua `GetContent` Activity Result.
    *   Tích hợp thư viện đọc Excel nhẹ (như `org.apache.poi:poi-ooxml` phiên bản rút gọn cho Android, hoặc thư viện ExcelReader đơn giản).
    *   Đọc và phân tích cấu trúc cột (Tên bài tập, Nhóm cơ, Thiết bị, Hướng dẫn...) và lưu trữ/cập nhật trực tiếp vào Room database để mở rộng danh sách bài tập hiện tại.

### Yêu cầu 3: 3D cho bài tập (3D Demonstration for Exercises)
*   **Phân tích codebase**:
    *   Màn hình chi tiết bài tập/hướng dẫn trong `ExerciseCard.kt` hiện tại chỉ hiển thị danh sách các bước dạng văn bản (`instructionsVi`).
*   **Giải pháp**:
    *   Thêm trường `image3dPath` hoặc `gif3dPath` vào cấu trúc `exercises_vi.json` và lớp `ExerciseDefinition`.
    *   Chuẩn bị các tệp ảnh động (GIF), ảnh tĩnh 3D, hoặc video ngắn (MP4) lưu trong thư mục `assets` hoặc `res/raw`.
    *   Cập nhật `ExerciseCard.kt` để hiển thị hình ảnh/ảnh động minh họa 3D này khi người dùng nhấp vào nút "Xem hướng dẫn".

### Yêu cầu 4: 1 dạng bài tập cụ thể nhóm cơ (Tập nhẹ nhóm cơ - không bỏ bài tập)
*   **Phân tích codebase**:
    *   Hệ thống thích ứng (`AdaptationEngine.kt` và `RoomWorkoutRepository.kt`) hiện tại chỉ giảm sets tổng thể (Deload) thông qua `volumeScalePercent`.
*   **Giải pháp**:
    *   Thêm một trạng thái cấu hình trong ngày tập: "Tập nhẹ cho nhóm cơ cụ thể" (ví dụ: đau khớp gối thì tập nhẹ cơ Đùi trước - Quads).
    *   Cho phép người dùng chọn nhóm cơ cần tập nhẹ trên màn hình **Hôm nay (Today)**.
    *   Khi nhóm cơ đó được đánh dấu là "tập nhẹ", tất cả các bài tập thuộc nhóm cơ đó trong buổi tập hôm nay sẽ tự động được scale số sets xuống (ví dụ: chỉ tập 1-2 sets nhẹ hoặc giảm 50% số lượng sets) và hiển thị nhãn cảnh báo `[Tập nhẹ - Hạn chế chấn thương]` thay vì loại bỏ bài tập khỏi buổi tập.

### Yêu cầu 5: Lộ trình bài tập (Workout Roadmap)
*   **Phân tích codebase**:
    *   Ứng dụng chỉ có Bottom Navigation với 3 tab chính: Trang chủ (Home), Tiến trình (Progress), Cài đặt (Settings).
*   **Giải pháp**:
    *   Tạo một màn hình mới tên là **Lộ trình tập luyện (Workout Roadmap)** hiển thị toàn bộ sơ đồ/danh sách các buổi tập của chương trình hiện tại (Tuần 1 -> Tuần N).
    *   Giao diện trực quan hóa buổi tập đã hoàn thành (tích xanh, hiển thị ngày hoàn thành), buổi tập tiếp theo (highlight) và cho phép nhấp vào xem trước các bài tập của buổi tập đó.
    *   Có thể tích hợp màn hình này thành một nút lớn trên màn hình **Trang chủ** hoặc thêm thành một tab mới.

### Yêu cầu 6: Mục tiêu ít option để chọn (Simpler Goal Selection)
*   **Phân tích codebase**:
    *   `FitnessGoal` đang định nghĩa 4 mục tiêu: Tăng cơ, Giảm mỡ & thể lực, Sức bền, Thể lực tổng quát.
*   **Giải pháp**:
    *   Rút gọn danh sách mục tiêu xuống còn 3 lựa chọn cơ bản và dễ hiểu nhất đối với người tập:
        1. Tăng cơ & Sức mạnh (Muscle Gain)
        2. Giảm mỡ & Thon gọn (Fat Loss & Tone)
        3. Cải thiện sức khỏe chung (General Health & Fitness)

### Yêu cầu 7: Cho chọn nhiều mục tiêu (tối đa 3 mục)
*   **Phân tích codebase**:
    *   `GoalConfig` chỉ cho phép lưu một mục tiêu duy nhất (`goal: FitnessGoal`).
*   **Giải pháp**:
    *   Cập nhật Room Database Entity (`GoalEntity`) và `GoalConfig` để lưu danh sách các mục tiêu đã chọn (ví dụ dưới dạng chuỗi JSON hoặc bitmask).
    *   Cho phép người dùng tick chọn tối đa 3 mục tiêu trong màn hình **Onboarding**.
    *   Điều chỉnh thuật toán chọn chương trình `ProgramSelector.kt` để tìm chương trình tối ưu nhất đáp ứng nhiều mục tiêu cùng lúc.

### Yêu cầu 8: Số lượng nước nạp vào (Water Tracking)
*   **Phân tích codebase**:
    *   `DailyNutritionEntity` hiện tại chỉ lưu trữ Kcal, Protein, Carbs, Fat.
*   **Giải pháp**:
    *   Thêm cột `waterIntakeMl` (Int) vào `DailyNutritionEntity` của Room Database để lưu số ml nước đã uống mỗi ngày.
    *   Thêm widget theo dõi nước uống trên màn hình **Dinh dưỡng (Nutrition)** hoặc màn hình **Hôm nay (Today)** (nút bấm nhanh thêm 250ml nước, hiển thị tiến trình hoàn thành mục tiêu nước hàng ngày - ví dụ 2000ml).

### Yêu cầu 9: Phân chia giới tính (Gender Selection in Onboarding)
*   **Phân tích codebase**:
    *   Giới tính sinh học (`MetabolicSex`) chỉ được hỏi trong màn hình Profile.
*   **Giải pháp**:
    *   Đưa câu hỏi lựa chọn giới tính (Nam/Nữ) thành một bước chính thức trong luồng **Onboarding** ban đầu trước khi tính toán năng lượng tiêu chuẩn.

### Yêu cầu 10: Tạng người (ốm, mập, vừa) => gợi ý mục tiêu
*   **Phân tích codebase**:
    *   Chưa có định nghĩa hay trường dữ liệu nào cho tạng người.
*   **Giải pháp**:
    *   Thêm một enum `BodyType` (OM / MAP / VUA hoặc Ectomorph / Endomorph / Mesomorph).
    *   Thêm bước hỏi về tạng người hiện tại trong luồng **Onboarding**.
    *   Dựa vào tạng người đã chọn, tự động gợi ý và tích chọn trước các mục tiêu tập luyện tối ưu (Ví dụ: Tạng ốm -> đề xuất Tăng cơ; Tạng mập -> đề xuất Giảm mỡ).

---

## 2. Kế Hoạch Thực Hiện Dự Kiến

Để triển khai các tính năng trên một cách ổn định, công việc được chia làm 3 giai đoạn:

### Giai đoạn 1: Nâng cấp Cơ sở dữ liệu và Core Logic (Database & Business Logic)
1. Cập nhật `GoalEntity` và `GoalConfig` để hỗ trợ chọn nhiều mục tiêu.
2. Thêm cột `waterIntakeMl` vào `DailyNutritionEntity` và nâng cấp Database Migration.
3. Thêm các trường giới tính và tạng người vào thực thể hồ sơ cá nhân.
4. Cập nhật `exercises_vi.json` để bổ sung trường liên kết mô hình 3D.
5. Sửa đổi logic tính toán `ProgramSelector.kt` để gợi ý lịch tập dựa trên tổ hợp mục tiêu và tạng người.

### Giai đoạn 2: Phát triển Giao diện người dùng (UI Components)
1. **Onboarding**: Thêm các màn hình chọn giới tính, tạng người và cho phép chọn nhiều mục tiêu (tối đa 3).
2. **Today Screen**:
    *   Loại bỏ hoàn toàn tính năng quét mã vạch và camera preview.
    *   Tích hợp hiển thị hình ảnh/ảnh động 3D khi mở rộng bài tập trong `ExerciseCard.kt`.
    *   Thêm tính năng tick chọn "Tập nhẹ" cho nhóm cơ bị mỏi và cập nhật giao diện bài tập tương ứng.
3. **Roadmap Screen**: Xây dựng màn hình hiển thị lộ trình buổi tập trực quan từ tuần 1 đến tuần cuối cùng.
4. **Water Widget**: Thêm nút cộng nước nhanh (+250ml) và vòng tròn tiến trình nước hàng ngày.
5. **Excel Import**: Thiết lập giao diện tải file tại mục Settings.

### Giai đoạn 3: Kiểm thử và Hoàn thiện (Testing & Verification)
1. Viết Unit Test cho thuật toán chọn chương trình dựa trên nhiều mục tiêu và tạng người.
2. Viết kiểm thử cho tính năng import file Excel để đảm bảo không bị crash khi định dạng file sai.
3. Xác nhận rằng việc bỏ mã vạch không gây ra lỗi biên dịch hay runtime trên màn hình Nutrition.
4. Đảm bảo toàn bộ tính năng hoạt động offline 100% không yêu cầu mạng.

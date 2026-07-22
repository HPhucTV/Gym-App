# Dữ liệu thực phẩm Việt Nam

## Nguồn và trạng thái giấy phép

- Nguồn trực tiếp duy nhất đã xác minh trong repository: bảng tra cứu nội bộ trong `server/server.js`.
- `server/data/vietnamese_foods.json` được tạo từ bảng đó ngày 2026-07-20 trong commit `5af9e83`. Các giá trị `nutrientsPer100g` và `nutrientsPerUnit` được di chuyển mà không tự gán nguồn bên ngoài.
- Repository không lưu tài liệu cho biết bảng legacy ban đầu được lấy từ đâu, ai sở hữu, điều khoản sử dụng, hay giấy phép tái phân phối. Vì vậy trạng thái giấy phép của các số liệu dinh dưỡng legacy là **chưa xác minh**. Tài liệu này không khẳng định chúng là public domain, dữ liệu mở, hoặc đã được cấp quyền phân phối.
- Đây là blocker pháp lý/provenance cho việc phát hành hoặc tái phân phối bộ dữ liệu ra ngoài phạm vi dự án cho đến khi chủ dự án cung cấp nguồn gốc và quyền sử dụng có thể kiểm chứng.

Các bản ghi có `nutrientsPerUnit` dùng `directUnit` để biểu diễn đúng đơn vị có sẵn trong bảng legacy: trứng dùng `PIECE`; phở bò, bún bò Huế, bánh mì kẹp thịt và mì gói dùng `SERVING`. Chỉ khẩu phần `MEDIUM` của đúng `directUnit` được chấp nhận, với lượng dinh dưỡng bằng `nutrientsPerUnit × quantity`; hệ thống không suy diễn gram khi không có dữ liệu theo 100 g.

## Quy ước khẩu phần do dự án tự xây dựng

Các khoảng `householdPortions` cho bát cơm, ức gà, thịt kho, cá chiên và rau luộc là heuristic hiệu chỉnh do chính dự án viết, không phải dữ liệu trích từ một nguồn dinh dưỡng bên ngoài:

- Ngày ghi nhận: bát cơm và direct-unit ngày 2026-07-20; các dải ức gà, thịt kho, cá chiên và rau luộc ngày 2026-07-22.
- Phương pháp: tác giả dự án đặt ba mốc `minGrams`, `midGrams`, `maxGrams` cho từng cỡ khẩu phần, kiểm tra chúng là số dương và tăng đơn điệu, rồi chạy kiểm thử để bảo đảm mọi capability công khai đều được estimator chấp nhận.
- Chưa có phép cân thực nghiệm, bộ mẫu hiệu chỉnh, chuyên gia dinh dưỡng, hay nguồn công bố độc lập đi kèm các dải này.
- Các dải chỉ phục vụ ước tính sản phẩm, cần được hiệu chỉnh bằng phép đo thực tế trước khi coi là đáng tin cậy; chúng không phải khẩu phần chuẩn, dữ liệu y khoa, hoặc tư vấn dinh dưỡng.
- Việc thêm các dải khối lượng không thay đổi giá trị dinh dưỡng legacy.

Mọi bản ghi hoặc hiệu chỉnh sau này phải ghi rõ file/URL nguồn, tác giả hoặc tổ chức sở hữu, ngày truy cập/đo, đơn vị, phương pháp, và giấy phép. Nếu chưa xác minh được một mục thì phải ghi rõ là chưa xác minh, không suy đoán hoặc tự gán giấy phép.

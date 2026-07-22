# Dữ liệu thực phẩm Việt Nam

Các bản ghi ban đầu trong `vietnamese_foods.json` được di chuyển nguyên giá trị dinh dưỡng từ bảng tra cứu nội bộ `server/server.js` của repository này. Bản sao này không thay đổi hằng số legacy; endpoint cũ tiếp tục dùng bảng cũ.

Các giá trị `nutrientsPer100g` và `nutrientsPerUnit` giữ nguyên đơn vị cùng số liệu của bảng nguồn. Khẩu phần bát cơm trắng là quy ước ước lượng của nutrition core và chỉ cung cấp khoảng khối lượng, không thay thế hay sửa số liệu dinh dưỡng nguồn.

Các bản ghi có `nutrientsPerUnit` dùng `directUnit` để biểu diễn chính xác đơn vị có sẵn trong bảng cũ: trứng dùng `PIECE`; phở bò, bún bò Huế, bánh mì kẹp thịt và mì gói dùng `SERVING`. Chỉ khẩu phần `MEDIUM` của đúng `directUnit` được chấp nhận, với lượng dinh dưỡng bằng đúng `nutrientsPerUnit × quantity`; không suy diễn gram hoặc hỗ trợ đơn vị khác khi không có dữ liệu nguồn.

Mọi bản ghi thêm sau đợt di chuyển phải ghi rõ nguồn công khai/chính thức, ngày kiểm tra, đơn vị và trạng thái xác minh trong tài liệu này hoặc metadata của bản ghi. Không được thêm giá trị dinh dưỡng không có nguồn tham chiếu đã ghi nhận.

Tình trạng xác minh hiện tại: toàn bộ bản ghi hiện hữu là bản di chuyển nội bộ, chưa được xác minh độc lập với nguồn ngoài.

## Quy ước khẩu phần ước tính

Các khoảng `householdPortions` mới cho ức gà, thịt kho, cá chiên và rau luộc là quy ước sản phẩm đã được rà soát để hỗ trợ giao diện chọn khẩu phần quen thuộc. Chúng là heuristic ước tính, cần tiếp tục hiệu chỉnh bằng dữ liệu đo thực tế, không phải số liệu y khoa hay khẩu phần chuẩn chính thức. Thay đổi này chỉ bổ sung ánh xạ khối lượng cho bộ ước tính; không thay đổi bất kỳ giá trị dinh dưỡng nguồn nào.

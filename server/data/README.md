# Dữ liệu thực phẩm Việt Nam

Các bản ghi ban đầu trong `vietnamese_foods.json` được di chuyển nguyên giá trị dinh dưỡng từ bảng tra cứu nội bộ `server/server.js` của repository này. Bản sao này không thay đổi hằng số legacy; endpoint cũ tiếp tục dùng bảng cũ.

Các giá trị `nutrientsPer100g` và `nutrientsPerUnit` giữ nguyên đơn vị cùng số liệu của bảng nguồn. Khẩu phần bát cơm trắng là quy ước ước lượng của nutrition core và chỉ cung cấp khoảng khối lượng, không thay thế hay sửa số liệu dinh dưỡng nguồn.

Các bản ghi có `nutrientsPerUnit` dùng `directUnit` để biểu diễn chính xác đơn vị có sẵn trong bảng cũ: trứng chiên, trứng luộc, trứng gà luộc và trứng ốp la dùng `PIECE`; phở bò, bún bò Huế, bánh mì kẹp thịt và mì gói dùng `SERVING`. Chỉ khẩu phần `MEDIUM` của đúng `directUnit` được chấp nhận, với lượng dinh dưỡng bằng đúng `nutrientsPerUnit × quantity`; không suy diễn gram hoặc hỗ trợ đơn vị khác khi không có dữ liệu nguồn.

Mọi bản ghi thêm sau đợt di chuyển phải ghi rõ nguồn công khai/chính thức, ngày kiểm tra, đơn vị, và trạng thái xác minh trong tài liệu này hoặc metadata của bản ghi. Không được thêm giá trị dinh dưỡng không có nguồn tham chiếu đã ghi nhận.

Tình trạng xác minh hiện tại: toàn bộ bản ghi hiện hữu là bản di chuyển nội bộ, chưa được xác minh độc lập với nguồn ngoài.

# Hướng dẫn Publish lên pub.dev

## 1. Chuẩn bị tài khoản

1. Truy cập [pub.dev](https://pub.dev) và đăng nhập bằng Google Account
2. Cài Dart SDK (đi kèm Flutter): `flutter --version` phải ≥ 3.27.0
3. Đăng nhập CLI:

```bash
dart pub login
```

> Lần đầu sẽ mở trình duyệt để xác thực Google OAuth.

---

## 2. Checklist trước khi publish

Chạy lệnh kiểm tra tự động:

```bash
dart pub publish --dry-run
```

Lệnh này kiểm tra mà **không thực sự publish**. Phải không có lỗi nào.

### Checklist thủ công

- [ ] `pubspec.yaml` có đủ `name`, `description` (≥ 60 ký tự), `version`, `homepage`
- [ ] `README.md` tồn tại và có nội dung rõ ràng
- [ ] `CHANGELOG.md` có entry cho version hiện tại
- [ ] `LICENSE` tồn tại
- [ ] `example/` có app chạy được (`flutter run` không lỗi)
- [ ] Không có file nhạy cảm (`.env`, key, token)
- [ ] `flutter analyze` không có lỗi
- [ ] `flutter test` tất cả passed

```bash
# Chạy toàn bộ kiểm tra
flutter analyze && flutter test
```

---

## 3. Đặt tên package đúng

Tên package trên pub.dev phải:
- Toàn chữ thường, chỉ dùng `_` (không dùng `-`)
- Không trùng với package đã có (kiểm tra tại pub.dev)
- Mô tả đúng chức năng

Kiểm tra tên còn trống:

```bash
# Mở trình duyệt tìm kiếm
open https://pub.dev/packages/date_time_picker
```

Nếu đã tồn tại → đổi tên trong `pubspec.yaml` và toàn bộ `import`.

---

## 4. Đánh số phiên bản (Semantic Versioning)

| Loại thay đổi | Ví dụ | Version |
|---|---|---|
| Fix bug, không breaking | Sửa lỗi hiển thị | `0.1.0` → `0.1.1` |
| Thêm tính năng, không breaking | Thêm locale mới | `0.1.0` → `0.2.0` |
| Breaking change API | Đổi tên constructor | `0.1.0` → `1.0.0` |

Cập nhật `CHANGELOG.md` mỗi khi tăng version:

```markdown
## [0.1.1] - 2026-07-10

### Fixed
- Sửa lỗi PageController khi chuyển year picker
```

---

## 5. Publish

### Lần đầu publish

```bash
dart pub publish
```

Sẽ hiện preview danh sách file được upload. Gõ `y` để xác nhận.

> Sau khi publish thành công, **không thể xóa** hoặc sửa nội dung version đó.
> Chỉ có thể retract (ẩn) nếu cần.

### Publish version mới

1. Tăng `version` trong `pubspec.yaml`
2. Thêm entry mới vào `CHANGELOG.md`
3. Chạy lại:

```bash
dart pub publish --dry-run   # kiểm tra
dart pub publish             # publish thật
```

---

## 6. Sau khi publish

### Kiểm tra trang pub.dev

```
https://pub.dev/packages/date_time_picker
```

Pub.dev sẽ tự động:
- Tính điểm **pub points** (tối đa 160)
- Chạy static analysis
- Hiển thị README, API docs

### Điểm pub.dev (pub points)

| Tiêu chí | Điểm |
|---|---|
| Có `README.md` rõ ràng | 20 |
| Có `CHANGELOG.md` | 20 |
| Có `LICENSE` | 20 |
| `dart pub publish --dry-run` không lỗi | 20 |
| Hỗ trợ platform đúng | 20 |
| Null safety | 20 |
| `flutter analyze` sạch | 20 |
| Có ví dụ (`example/`) | 20 |

Mục tiêu: **130+ điểm** để được badge "Verified Publisher".

---

## 7. Tối ưu README cho pub.dev

pub.dev render README theo Markdown. Một số lưu ý:

- **Ảnh** dùng URL tuyệt đối (GitHub raw): `![](https://raw.githubusercontent.com/...)`
- **Badge** đặt ở đầu README:

```markdown
[![pub.dev](https://img.shields.io/pub/v/date_time_picker.svg)](https://pub.dev/packages/date_time_picker)
[![likes](https://img.shields.io/pub/likes/date_time_picker)](https://pub.dev/packages/date_time_picker/score)
[![popularity](https://img.shields.io/pub/popularity/date_time_picker)](https://pub.dev/packages/date_time_picker/score)
[![pub points](https://img.shields.io/pub/points/date_time_picker)](https://pub.dev/packages/date_time_picker/score)
```

- **Topics** trong `pubspec.yaml` giúp tìm kiếm tốt hơn (đã có)

---

## 8. Verified Publisher (tùy chọn)

Để có badge xanh "verified publisher":

1. Vào [pub.dev/publishers](https://pub.dev/publishers)
2. Tạo publisher với domain của bạn (ví dụ: `yourcompany.dev`)
3. Xác minh domain qua DNS TXT record
4. Transfer package về publisher:

```bash
# Trên trang pub.dev → package → Admin → Transfer to publisher
```

---

## 9. Retract version (nếu cần)

Nếu publish nhầm hoặc phát hiện lỗi nghiêm trọng:

```bash
dart pub downgrade  # không có lệnh xóa — chỉ retract trên web
```

Vào pub.dev → package → Admin → Retract version.

> Retract không xóa — chỉ khiến version đó không được resolve tự động nữa.

---

## 10. Tóm tắt lệnh

```bash
# Kiểm tra toàn bộ
flutter analyze && flutter test && dart pub publish --dry-run

# Publish
dart pub publish

# Xem package sau publish
open https://pub.dev/packages/date_time_picker
```

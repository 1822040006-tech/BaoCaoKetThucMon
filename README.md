# DormHub

DormHub là ứng dụng Flutter hỗ trợ quản lý ký túc xá sinh viên. Dự án minh họa cách tập trung các thông tin và quy trình thường gặp trong ký túc xá vào một ứng dụng, với giao diện riêng cho sinh viên, quản lý ký túc xá, kỹ thuật viên và quản trị viên.

> **Trạng thái:** Đây là dự án demo/đang phát triển, chưa phải hệ thống vận hành ký túc xá thực tế. Đăng nhập và hồ sơ tài khoản kết nối Firebase; phần lớn dữ liệu nghiệp vụ hiện vẫn là dữ liệu mẫu trong bộ nhớ.

## Vì sao cần DormHub?

Thông tin đăng ký phòng, hợp đồng, hóa đơn và yêu cầu sửa chữa thường nằm ở nhiều biểu mẫu hoặc kênh liên lạc khác nhau. DormHub hướng tới việc tập trung các quy trình đó để sinh viên dễ theo dõi yêu cầu của mình, còn nhân sự có thể xem và xử lý công việc theo vai trò.

Ứng dụng cũng là nền tảng thực hành cho một ứng dụng Flutter đa vai trò, tích hợp Firebase Authentication và Cloud Firestore. Các lợi ích vận hành nêu trên là mục tiêu thiết kế; chưa phải tất cả đều được hỗ trợ bởi dữ liệu máy chủ trong phiên bản hiện tại.

## Cách ứng dụng hoạt động

1. Ứng dụng khởi tạo Firebase bằng cấu hình nền tảng trong `lib/firebase_options.dart`.
2. Người dùng đăng nhập bằng email và mật khẩu qua Firebase Authentication.
3. Sau khi xác thực, ứng dụng đọc hồ sơ `users/{uid}` trong Cloud Firestore để lấy vai trò và trạng thái tài khoản. Hồ sơ thiếu, không hợp lệ hoặc tài khoản bị khóa sẽ không được vào ứng dụng.
4. Giao diện hiển thị khu vực phù hợp với vai trò. Các chức năng đăng ký sinh viên và gửi email đặt lại mật khẩu cũng sử dụng Firebase.
5. Phần lớn dữ liệu phòng, đăng ký, hợp đồng, sự cố, hóa đơn, báo cáo và một số màn hình quản trị hiện lấy từ `lib/data/demo_store.dart`. Các thay đổi ở đây chỉ tồn tại trong bộ nhớ và sẽ mất khi khởi động lại ứng dụng.

## Đối tượng và phạm vi sử dụng

| Vai trò | Chức năng được thể hiện trong giao diện |
| --- | --- |
| Sinh viên | Xem thông tin phòng, đăng ký phòng, xem hợp đồng và hóa đơn, gửi báo sự cố, xem thông báo và hồ sơ. |
| Quản lý ký túc xá | Theo dõi đơn đăng ký, sinh viên, phòng, hợp đồng, công nợ, điện nước, vi phạm, thông báo và báo cáo. |
| Kỹ thuật viên | Theo dõi yêu cầu sửa chữa, lịch bảo trì, vật tư và báo cáo. |
| Quản trị viên | Xem tổng quan và giao diện quản lý tài khoản, phân quyền, cấu hình và nhật ký. |

### Giới hạn hiện tại

- Dữ liệu nghiệp vụ nêu trên là dữ liệu mẫu; thao tác trên các màn hình đó không được lưu vào Firestore.
- Màn hình quản trị tài khoản chỉ mô phỏng; ứng dụng chưa tạo, xóa hoặc khóa tài khoản Firebase thật từ màn hình này.
- Thanh toán trực tuyến chưa tích hợp cổng thanh toán và xác nhận giao dịch thật. Không dùng bản demo để xử lý tiền hoặc dữ liệu vận hành.
- Firebase được cấu hình cho **Android** và **web**. Các nền tảng iOS, macOS, Windows và Linux chưa được cấu hình trong dự án.
- Muốn triển khai sử dụng thật cần xây dựng backend cho nghiệp vụ, hoàn thiện phân quyền và kiểm thử bảo mật, sao lưu, email, thanh toán cùng quy trình vận hành.

## Tài khoản đăng nhập thử nghiệm

Các tài khoản dưới đây được ghi nhận là tài khoản thử nghiệm của Firebase project đang cấu hình trong ứng dụng. Cả bốn tài khoản dùng chung mật khẩu demo:

**Mật khẩu:** `123456`

| Vai trò | Email đăng nhập |
| --- | --- |
| Quản trị viên | `admin@university.com` |
| Quản lý ký túc xá | `manager@university.com` |
| Kỹ thuật viên | `technician@university.com` |
| Sinh viên (mã số `240001`) | `240001@university.com` |

Tài khoản phải tồn tại trong Firebase Authentication và có hồ sơ tương ứng trong Firestore `users/{uid}` với vai trò/trạng thái hợp lệ. Vì vậy, tài khoản thử nghiệm có thể không dùng được nếu dữ liệu Firebase đã thay đổi hoặc bạn đang kết nối một Firebase project khác.

> **Cảnh báo bảo mật:** `123456` là mật khẩu yếu, chỉ dành cho demo. Không dùng các tài khoản này với dữ liệu thật, không dùng lại mật khẩu cá nhân và không công khai README chứa thông tin đăng nhập nếu các tài khoản vẫn còn hoạt động. Hãy đổi mật khẩu hoặc vô hiệu hóa tài khoản thử nghiệm trước khi chia sẻ hay triển khai ứng dụng. Tính năng quên mật khẩu chỉ hữu ích khi bạn kiểm soát hộp thư của địa chỉ tài khoản.

Sinh viên mới có thể đăng ký bằng mã số gồm đúng sáu chữ số; email được tạo theo dạng `<mã-sinh-viên>@university.com`. Đăng ký công khai chỉ cấp vai trò sinh viên. Tài khoản nhân sự cần được cấp riêng, không thể tự đăng ký vai trò quản lý, kỹ thuật viên hoặc quản trị viên từ ứng dụng.

## Yêu cầu

- Flutter SDK tương thích với Dart `>=3.3.0 <4.0.0` (xem `pubspec.yaml`).
- Google Chrome để chạy web, hoặc thiết bị/máy ảo Android để chạy Android.
- Kết nối Internet và Firebase project được cấu hình, bật phương thức đăng nhập Email/Password, có Firestore database và Security Rules phù hợp.

## Cách chạy ứng dụng

Mở terminal tại thư mục gốc dự án (thư mục chứa `pubspec.yaml`), sau đó tải các package:

```sh
flutter pub get
```

### Chạy trên web

```sh
flutter run -d chrome
```

### Chạy trên Android

Kết nối thiết bị Android hoặc khởi động máy ảo, rồi chạy:

```sh
flutter devices
flutter run -d <device-id>
```

Thay `<device-id>` bằng mã thiết bị được liệt kê. Trong VS Code, có thể chọn thiết bị ở thanh trạng thái rồi chạy cấu hình Flutter từ `lib/main.dart`.

Sau khi ứng dụng mở, đăng nhập bằng một tài khoản thử nghiệm ở trên. Ứng dụng cần mạng để xác thực và đọc hồ sơ Firestore. Nếu không đăng nhập được, hãy kiểm tra Firebase project/cấu hình nền tảng, phương thức Email/Password, tài khoản trong Authentication và document `users/{uid}` cùng các Firestore Rules.

## Công nghệ và cấu hình liên quan

- Flutter và Dart
- Firebase Authentication cho đăng nhập, đăng ký sinh viên, đặt lại mật khẩu
- Cloud Firestore cho hồ sơ người dùng
- `lib/services/auth_service.dart`: xử lý xác thực và đọc hồ sơ
- `lib/config/account_policy.dart`: quy ước email tài khoản nhân sự và mã sinh viên
- `firestore.rules`: quy tắc truy cập Firestore; cần được rà soát trước khi triển khai
- `android/app/google-services.json` và `lib/firebase_options.dart`: cấu hình Firebase cho các nền tảng hiện được hỗ trợ

Firebase client configuration không thay thế cho việc bảo vệ dữ liệu. Trước khi sử dụng thật, hãy kiểm tra Firestore Security Rules, quyền truy cập theo vai trò và quy trình quản lý tài khoản.

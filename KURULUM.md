# Flutter geliştirme ortamı

> Bu belge, uygulama geliştirilmeden önceki ortam kurulumunun tarihsel kaydıdır. Güncel uygulama özellikleri, test sonuçları, ekran görüntüleri ve teslim adımları için [README.md](README.md) dosyasını kullanın.

Doğrulama tarihi: 15 Kasım 2026.

Proje: `D:\Users\melih\Documents\ChatGPT\TNC\flutter-mini-katalog`

Standart Flutter uygulama şablonu oluşturuldu. Mini Katalog ekranları geliştirilmedi. Mevcut TNC projeleri değiştirilmedi.

## Kurulu araçlar

| Bileşen | Sürüm / konum |
| --- | --- |
| Flutter, stable | 3.50.0 — `D:\development\flutter` |
| Dart | 3.14.0 — Flutter SDK ile birlikte |
| Android SDK | `D:\development\android-sdk` |
| Android platformu | API 36, revision 2 |
| Android Build Tools | 36.0.0 |
| Android Platform Tools / ADB | Mevcut 35.0.2 kullanıldı |
| Android Command-line Tools | 22.0 |
| Android NDK | 28.2.13676358 |
| Android Emulator | 37.2.13 |
| Sistem imajı | Android 16 / API 36, Google APIs, x86_64, revision 7 |
| Sanal cihaz | `mini_katalog_api36` |
| Sanal cihaz dosyaları | `D:\development\android-avd` |
| Gradle | 9.5.0 — projenin standart wrapper sürümü |
| Gradle önbelleği | `D:\development\gradle-cache` |
| Java | Mevcut Temurin JDK 21.0.11 kullanıldı |
| VS Code | Mevcut 1.138.0; Flutter ve Dart eklentileri 3.146.0 |

Android Studio kurulmadı; doğrulanan komut satırı ortamında gerekli olmadı. Emülatör mevcut Windows Hypervisor Platform (WHPX) ile çalıştı. Yönetici yetkisi, Windows özelliği veya sürücü değişikliği yapılmadı.

## Ortam değişkenleri

Yalnızca kullanıcı hesabının PATH değişkeni güncellendi. Flutter `bin`, Android `platform-tools`, `emulator` ve `cmdline-tools\latest\bin` yolları eklendi; artık bulunmayan `C:\flutter\bin` girdisi çıkarıldı.

- `ANDROID_HOME` ve `ANDROID_SDK_ROOT`: `D:\development\android-sdk`
- `ANDROID_AVD_HOME`: `D:\development\android-avd`
- `GRADLE_USER_HOME`: `D:\development\gradle-cache`

Yeni ortam değişkenlerini almak için VS Code'u ve açık terminalleri yeniden başlatın.

## Doğrulama sonuçları

| Kontrol | Sonuç |
| --- | --- |
| `flutter --version` | Flutter 3.50.0, stable |
| `dart --version` | Dart 3.14.0 |
| `flutter doctor -v` | `No issues found!` |
| Android SDK lisansları | Kabul edildi |
| Emülatör hızlandırması | WHPX kurulu ve kullanılabilir |
| `flutter analyze` | `No issues found!` |
| `flutter test` | 1 test geçti — `All tests passed!` |
| `flutter build apk --debug` | Başarılı |
| Android çalıştırma kontrolü | APK emülatöre yüklendi; varsayılan sayaç ekranı görsel olarak doğrulandı, uygulama ön planda ve süreç aktif; AndroidRuntime çökme kaydı bulunmadı |

APK: `build\app\outputs\flutter-apk\app-debug.apk`

İlk açılışta Android `am start -W` bekleme süresi doldu; sonrasında uygulamanın açıldığı ekran görüntüsü, aktif süreç ve ön plandaki Activity ile doğrulandı.

## Çalıştırma

Yeni bir PowerShell terminalinde:

```powershell
cd 'D:\Users\melih\Documents\ChatGPT\TNC\flutter-mini-katalog'
flutter emulators --launch mini_katalog_api36
flutter devices
flutter run -d emulator-5554
```

Başka emülatörler de açıksa `flutter devices` çıktısındaki cihaz kimliğini kullanın.

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

## Kaynak kullanımı ve kurulum kayıtları

Makinedeki 16 GB RAM ve C: sürücüsündeki sınırlı boş alan nedeniyle yeni projenin `android\gradle.properties` dosyasında Gradle heap üst sınırı 2 GB, metaspace 1 GB ve worker sayısı 2 olarak ayarlandı. İlk derlemede emülatör ile derleme süreçleri birlikte çalışırken Windows'un sanal bellek dosyası büyüdü. Emülatör geçici olarak kapatılarak alan geri kazanıldı; sistemin sanal bellek ayarları değiştirilmedi. Gerekirse APK derlemesini emülatör kapalıyken tamamlayın.

Gradle 9.5.0 derlemesi başarılıdır; araç zinciri Gradle 10 için kullanım dışı kalacak özellik uyarısı üretmektedir. Bu aşamada wrapper sürümü değiştirilmedi.

İndirme ve doğrulama günlükleri: `D:\development\downloads`

- `flutter-stable-metadata.json`: resmî kararlı sürüm bilgisi
- `user-environment-before.json`: PATH ve Android değişkenlerinin önceki kullanıcı değerleri
- `flutter-doctor-final.log`, `flutter-analyze.log`, `flutter-test.log`
- `flutter-build-apk.log`, `android-install.log`, `android-licenses.log`
- `mini-katalog-emulator.png`: çalışan standart uygulamanın ekran görüntüsü

Flutter ve Android komut satırı araçlarının ZIP dosyaları, resmî yayımlanan SHA-256 değerleriyle doğrulandı. Mevcut C: Android SDK bileşenleri silinmeden gerekli bileşenler D: altına kopyalandı. Başlangıçta C: SDK'ya eklenen komut satırı araçları da korundu.

Resmî kaynaklar: [Flutter kurulumu](https://docs.flutter.dev/install/manual), [Flutter SDK arşivi](https://docs.flutter.dev/install/archive), [Android araçları](https://developer.android.com/studio), [Flutter Android ortamı](https://docs.flutter.dev/platform-integration/android/setup).

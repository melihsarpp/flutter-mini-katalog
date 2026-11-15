# Gerçek Android ekran görüntüleri

15 Kasım 2026 tarihinde Android 16 / API 36 x86_64 `mini_katalog_api36` emülatöründe alınmıştır. PNG dosyaları 1080 × 2400 pikseldir. Tasarım maketi, yapay görsel veya birleştirilmiş ekran değildir.

| Dosya | İçerik |
| --- | --- |
| `01-ana-sayfa.png` | Banner ve kategorilerle ana sayfa |
| `02-urunler-izgara.png` | GridView ürün listesi |
| `03-urunler-liste.png` | ListView.builder görünümü |
| `04-arama.png` | Türkçe karakterleri tolere eden arama |
| `05-kategori.png` | Teknoloji kategorisi filtresi |
| `06-urun-detay.png` | Görsel, açıklama, fiyat ve sepete ekleme |
| `07-sepet.png` | İki ürün adedi ve 4.999,80 ₺ toplam |
| `08-bos-sepet.png` | Ürün kaldırıldıktan sonra boş sepet |
| `09-normal-apk-ana-sayfa.png` | Normal APK'nın Android sistem çubukları dahil ana sayfası |

İlk sekiz görüntü, başarılı `integration_test/catalog_flow_test.dart` çalışması sırasında Flutter'ın `IntegrationTestWidgetsFlutterBinding.takeScreenshot` metodu ile gerçek emülatörün Flutter yüzeyinden alınmıştır. Sürücü, gelen PNG baytlarını değiştirmeden bu klasöre kaydeder. Sistem durum çubuğunun simgeleri bu yüzeyin parçası değildir.

Yeniden üretmek için proje kökünde:

```sh
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/catalog_flow_test.dart -d <android-cihaz-kimligi>
```

Dokuzuncu görüntü, normal `lib/main.dart` APK'sı derlenip yüklendikten sonra Android `adb shell screencap -p` ve `adb pull` komutlarıyla alınmıştır. Bu görüntü entegrasyon sürücüsü tarafından yeniden üretilmez.

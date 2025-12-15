# Vexar Release & Update Guide

## ⚠️ Kritik Bilgi: Güncelleme Mekanizması

Uygulamanızın güncelleme sistemi (`UpdateManager.swift`), **GitHub Releases** üzerindeki etiketleri (tags) kontrol eder. 

- **Mevcut Kod Ayarı:** `MuratGuelr/vexar-app` reposuna bakıyor.
- **Mevcut Uygulama Sürümü:** `1.0` (Info.plist içinde).

Eğer bu uygulamanın ileride kendini güncellemesini istiyorsanız, GitHub üzerinde Release oluştururken şu kurallara uymalısınız:

## 🚀 Release Adımları

1. **GitHub Reponuza Gidin**: [https://github.com/MuratGuelr/vexar-app/releases](https://github.com/MuratGuelr/vexar-app/releases)
2. **"Draft a new release"** butonuna tıklayın.
3. **Choose a tag**: Buraya versiyon numarasını yazın. Önemli: Başında `v` olmalı.
   - Önerilen İlk Sürüm: `v1.0.0`
4. **Release title**: Örn: "Vexar 1.0 - Digital Core Update"
5. **Description**: `README.md` dosyasındaki özellikleri buraya yapıştırabilirsiniz.
6. **Binaries**: Hazırladığım `Vexar_Release.zip` dosyasını sürükleyip bırakın.
7. **Publish release** deyin.

## 🔄 Güncelleme Nasıl Tetiklenir?

Kullanıcıların kullandığı sürüm `1.0` iken, siz gidip `v1.1.0` diye yeni bir Release çıkarsanız:
1. Uygulama açılışta GitHub'ı kontrol eder.
2. `v1.1.0` > `1.0` olduğunu görür.
3. Ekrana "Yeni güncelleme var!" uyarısı basar.
4. "İndir" butonuna basınca sizin yüklediğiniz `.zip` dosyasını indirir.

**Özet**: Özel bir şey yapmanıza gerek yok, sadece **GitHub Release Tag**'lerini `v1.0`, `v1.1` şeklinde düzenli verirseniz sistem otomatik çalışır.

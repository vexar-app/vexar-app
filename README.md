# Vexar - macOS DPI Bypasser GUI

![Vexar Banner](https://via.placeholder.com/1200x500.png?text=Vexar+App) 
*(Örnek görsel)*

**Vexar**, macOS için geliştirilmiş, **SpoofDPI** altyapısını kullanan modern, şık ve güçlü bir menü çubuğu (menu bar) uygulamasıdır. İnternet servis sağlayıcılarının uyguladığı DPI (Deep Packet Inspection) filtrelerini aşmanızı ve sansürsüz, yavaşlatılmamış bir internet deneyimi yaşamanızı sağlar.

Sadece işlevsel değil, aynı zamanda **"Digital Core"** tasarım diliyle görsel olarak zenginleştirilmiş, animasyonlu ve yüksek kaliteli bir kullanıcı deneyimi sunar.

---

## 🌟 Özellikler

### 🎨 Modern "Digital Core" Tasarım
- **Living Background**: Uygulama genelinde sürekli hareket eden, canlı ve dinamik renk değiştiren mesh gradient arka plan.
- **Pulse Core**: Bağlantı durumunu gösteren, dönen halkalar ve neon efektleriyle donatılmış merkezi durum reaktörü.
- **Glassmorphism**: Ayarlar ve menülerde kullanılan yarı saydam, bulanık cam efektleri (frosted glass).
- **Haptic Animations**: Düğmeler ve geçişlerde kullanılan fizik tabanlı yay (spring) animasyonları.

### 🚀 Güçlü Altyapı
- **SpoofDPI Entegrasyonu**: Arkada güçlü `spoofdpi` motorunu kullanarak DPI engellerini aşar.
- **Akıllı Yönetim**: SpoofDPI ve Homebrew kurulumunu otomatik algılar ve henüz yüklü değilse sizi yönlendirir.
- **Dinamik Pencere**: İçeriğe göre otomatik boyutlanan, akıcı arayüz.

### 🛠 Kullanıcı Dostu Araçlar
- **Menu Bar Resident**: Menü çubuğunuzda sessizce çalışır, tek bir tıkla erişilir.
- **Tek Tıkla Bağlantı**: Büyük, belirgin güç düğmesiyle anında aktivasyon.
- **Sistem Logları**: Arka planda neler olduğunu şeffaf bir şekilde görebileceğiniz "Matrix" stili log ekranı.
- **Başlangıçta Çalıştırma**: Bilgisayarınız açıldığında Vexar'ın otomatik başlamasını sağlayan seçenek.

---

## 📸 Ekran Görüntüleri

| Ana Ekran (Bağlı Değil) | Ana Ekran (Bağlı) | Ayarlar |
|:---:|:---:|:---:|
| *Pulse Core yavaşça döner, arka plan sakindir.* | *Core parlar, kalkan aktifleşir.* | *Cam efektli kartlar ve modern toggle.* |

> *Arayüz tasarımı, macOS'in estetiğine uyum sağlarken futuristik bir dokunuş ekler.*

---

## ⚙️ Gereksinimler

- **macOS**: macOS 13.0 (Ventura) ve üzeri.
- **Mimari**: Apple Silicon (M1/M2/M3) veya Intel işlemcili Mac'ler.
- **Bağımlılıklar**: 
  - Uygulama, çalışma zamanında `Homebrew` ve `spoofdpi`'nin yüklü olmasını bekler.
  - Eğer yüklü değilse, uygulama içinde sizi kurulum adımlarına yönlendirecektir.

---

## 📥 Kurulum (Geliştiriciler İçin)

Projeyi kendi bilgisayarınızda derlemek ve çalıştırmak için:

1. **Repoyu Klonlayın:**
   ```bash
   git clone https://github.com/MuratGuelr/vexar-app.git
   cd vexar-app
   ```

2. **Projeyi Xcode ile Açın:**
   `Vexar.xcodeproj` dosyasını çift tıklayarak açın.

3. **Derleyin ve Çalıştırın:**
   Xcode üzerinden `Run` (⌘R) butonuna basın.

---

## 🔧 Nasıl Çalışır?

Vexar, temel olarak bir arayüz (GUI) katmanıdır. Arka planda `Process` yönetimi ile terminal komutlarını çalıştırır.

1. **Bağlan Butonu**: Bastığınızda Vexar, arka planda `spoofdpi` komutunu çalıştırır.
2. **Proxy Ayarları**: SpoofDPI varsayılan olarak `8080` numaralı portta bir SOCKS proxy oluşturur.
3. **Loglama**: `stdOut` ve `stdErr` çıktılarını yakalar ve `LogsView` ekranında renklendirilmiş olarak gösterir.
4. **Durum Takibi**: Bağlantının kopması veya hatası durumunda arayüz anında güncellenir.

---

## 🏗 Proje Yapısı

- **`VexarApp.swift`**: Uygulamanın giriş noktası. Menu bar popover yönetimini yapar.
- **`MenuBarView.swift`**: Ana arayüz. "Pulse Core" animasyonu ve bağlantı butonu buradadır.
- **`SettingsView.swift`**: Ayarlar ekranı. Başlangıçta çalıştırma ve detaylar.
- **`LogsView.swift`**: Canlı sistem loglarını gösteren ekran.
- **`AppState.swift`**: Uygulamanın durumunu (bağlı/bağlı değil, loglar) yöneten merkezi "State Object".
- **`HomebrewManager.swift`**: Sistem bağımlılıklarını (Brew/SpoofDPI) kontrol eden yönetici sınıf.

---

## 👨‍💻 Geliştirici

**ConsolAktif**
- YouTube: [ConsolAktif](https://www.youtube.com/@ConsolAktif)
- GitHub: [MuratGuelr](https://github.com/MuratGuelr)

Bu proje açık kaynaklıdır ve katkılara açıktır.

---

## 📄 Lisans

Bu proje MIT Lisansı ile lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakabilirsiniz.

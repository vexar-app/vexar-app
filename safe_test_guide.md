# Güvenli "İlk Kurulum" Testi

Homebrew'u tamamen silmek (`uninstall`), bilgisayarınızdaki diğer tüm geliştirici araçlarını (Node, Git, Python, vb.) **SİLER**. Bunu sadece Vexar'ı test etmek için yapmanızı önermem.

Bunun yerine, Vexar'ın bu araçları "bulamamasını" sağlayarak aynı deneyimi güvenle test edebiliriz.

## Adım 1: Araçları Gizle (Simülasyon)
Aşağıdaki komutu Terminal'de çalıştırırsanız, bilgisayarınızda sanki Homebrew ve SpoofDPI hiç yokmuş gibi olur.

```bash
# SpoofDPI'ı sil (Bu güvenli, tekrar kurulur)
rm /opt/homebrew/bin/spoofdpi

# Homebrew'u GEÇİCİ olarak gizle (SİLMEZ, ismini değiştirir)
sudo mv /opt/homebrew/bin/brew /opt/homebrew/bin/brew_hidden_vexar
```

## Adım 2: Test Edin
1. Vexar'ı çalıştırın.
2. "Homebrew Gerekli" ekranının geldiğini görün.
3. "Kur" butonuna basın. (Hata verebilir çünkü `brew` komutu gizli, ama arayüzü görebilirsiniz).

## Adım 3: Her Şeyi Geri Getir (Önemli!)
Test bittikten sonra **mutlaka** bu komutu çalıştırın, yoksa diğer projeleriniz çalışmaz:

```bash
sudo mv /opt/homebrew/bin/brew_hidden_vexar /opt/homebrew/bin/brew
```

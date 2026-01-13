#!/bin/bash

# Vexar Release Builder
# Bu script uygulamayı derler, sürüm numarasını günceller ve ZIP/DMG formatlarında paketler.

# Renkli Çıktılar
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ayarlar
APP_NAME="Vexar"
SCHEME_NAME="Vexar"
OUTPUT_DIR="./Release"
BUILD_DIR="./build_temp"
PLIST_PATH="./Vexar/Info.plist"

echo -e "${BLUE}###############################################${NC}"
echo -e "${BLUE}###         VEXAR RELEASE BUILDER           ###${NC}"
echo -e "${BLUE}###############################################${NC}"
echo ""

# 1. Sürüm Yönetimi
# Mevcut sürümü oku
CURRENT_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$PLIST_PATH")
echo -e "Mevcut Sürüm: ${GREEN}$CURRENT_VERSION${NC}"
echo -n "Yeni sürüm numarasını girin (Örn: 1.0.1) [Enter tuşuna basılırsa mevcut kullanılır]: "
read NEW_VERSION

if [ ! -z "$NEW_VERSION" ]; then
    echo -e "Sürüm güncelleniyor: ${GREEN}$NEW_VERSION${NC}"
    # Info.plist güncelle
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEW_VERSION" "$PLIST_PATH"
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_VERSION" "$PLIST_PATH"
    VERSION_TAG="v$NEW_VERSION"
else
    echo "Sürüm değiştirilmedi."
    VERSION_TAG="v$CURRENT_VERSION"
fi

echo ""
echo -e "${GREEN}🚀 Vexar $VERSION_TAG Release Hazırlanıyor...${NC}"

# 2. Eski dosyaları temizle
echo "🧹 Temizlik yapılıyor..."
rm -rf "$OUTPUT_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"

# 3. Uygulamayı Derle (Build)
echo "🔨 Uygulama derleniyor (Release mod)..."
# CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO: Otomatik imzalamayı kapatır (Daha sonra elle imzalayacağız)
xcodebuild -project "$APP_NAME.xcodeproj" \
           -scheme "$SCHEME_NAME" \
           -configuration Release \
           -derivedDataPath "$BUILD_DIR" \
           -destination 'platform=macOS' \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO \
           CODE_SIGNING_ALLOWED=NO \
           clean build \
           -quiet

# Derleme kontrolü
APP_SOURCE="$BUILD_DIR/Build/Products/Release/$APP_NAME.app"

if [ ! -d "$APP_SOURCE" ]; then
    echo -e "${RED}❌ HATA: Derleme başarısız oldu. '$APP_SOURCE' bulunamadı.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Derleme başarılı.${NC}"

# Uygulamayı çıktı klasörüne kopyala
cp -R "$APP_SOURCE" "$OUTPUT_DIR/"
APP_PATH="$OUTPUT_DIR/$APP_NAME.app"

# 3.1. Manuel İmzalamave Temizlik (Hasarlı uyarısını düzeltmek için)
echo "🔏 Uygulama imzalanıyor (Ad-hoc)..."
# Quarantine ve gereksiz attribute'ları temizle
xattr -cr "$APP_PATH"
# Ad-hoc imzalama yap
codesign --force --deep --sign - "$APP_PATH"

echo -e "${GREEN}✅ İmzalama tamamlandı.${NC}"

# 4. ZIP Dosyası Oluştur (GitHub için)
ZIP_NAME="${APP_NAME}_${VERSION_TAG}.zip"
echo "📦 ZIP dosyası oluşturuluyor: $ZIP_NAME"
cd "$OUTPUT_DIR"
# -r: recursive, -y: symlinkleri koru (macOS appleri için kritik)
zip -r -y "$ZIP_NAME" "$APP_NAME.app"
cd ..
echo -e "${GREEN}✅ ZIP hazır: $OUTPUT_DIR/$ZIP_NAME${NC}"

# 5. DMG Dosyası Oluştur
DMG_NAME="${APP_NAME}_${VERSION_TAG}.dmg"
echo "💿 DMG dosyası oluşturuluyor: $DMG_NAME"
DMG_PATH="$OUTPUT_DIR/$DMG_NAME"

# DMG içeriği için geçici klasör
DMG_CONTENT="$BUILD_DIR/dmg_content"
mkdir -p "$DMG_CONTENT"
cp -R "$APP_PATH" "$DMG_CONTENT/"
ln -s /Applications "$DMG_CONTENT/Applications"

# hdiutil ile DMG oluştur
hdiutil create -volname "$APP_NAME $VERSION_TAG" \
               -srcfolder "$DMG_CONTENT" \
               -ov -format UDZO \
               "$DMG_PATH" \
               -quiet

echo -e "${GREEN}✅ DMG hazır: $DMG_PATH${NC}"

# 6. Geçici dosyaları temizle
rm -rf "$BUILD_DIR"

echo ""
echo -e "${GREEN}🎉 İŞLEM TAMAMLANDI!${NC}"
echo "----------------------------------------"
echo -e "📂 Çıktı Klasörü: ${BLUE}Release/${NC}"
ls -lh "$OUTPUT_DIR" | grep -v ".app$"
echo "----------------------------------------"
echo -e "👉 GitHub'a ${BLUE}$ZIP_NAME${NC} dosyasını yükleyebilirsiniz."

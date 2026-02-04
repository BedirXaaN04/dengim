# DENGİM: GitHub ve Firebase Yayınlama Rehberi

Web sürümü başarıyla derlendi (`build/web` klasöründe hazır).
Aşağıdaki adımları sırasıyla uygulayarak projenizi yayınlayabilirsiniz.

## 🚀 1. GitHub'a Yükleme

1.  [GitHub Yeni Depo](https://github.com/new) adresine gidin.
2.  **Repository name** kısmına `dengim` yazın ve **Create repository** butonuna basın.
3.  VS Code terminalini açın (`Ctrl + J`) ve sırasıyla şu komutları yapıştırın:

```bash
git init
git add .
git commit -m "Dengim v1.0 Release"
git branch -M main

# AŞAĞIDAKİ SATIRI GITHUB'DAN KOPYALADIĞINIZ KENDİ LİNKİNİZLE DEĞİŞTİRİN:
git remote add origin https://github.com/KULLANICI_ADINIZ/dengim.git

git push -u origin main
```

---

## 🌐 2. Firebase Hosting (Canlı Web Sitesi)

Build işlemi zaten yapıldı. Şimdi `build/web` klasörünü Firebase'e göndereceğiz.

### Adım 1: Araçları Yükle & Giriş Yap
Terminalde şu komutları çalıştırın:
```bash
npm install -g firebase-tools
firebase login
```
*(Tarayıcı açılacak, Google hesabınızla giriş yapıp izin verin)*.

### Adım 2: Projeyi Başlat
```bash
firebase init hosting
```
Bu komutu çalıştırdıktan sonra sorulara şöyle cevap verin:
1.  **Project:** `Use an existing project` -> `dengim-kim` (veya proje adınız neyse).
2.  **Public directory:** `build/web`  <-- **(ÇOK ÖNEMLİ! `public` YAZMAYIN, `build/web` YAZIN)**.
3.  **Configure as a single-page app?:** `Yes` (y yazıp enter).
4.  **Set up automatic builds and deploys with GitHub?:** `No` (n yazıp enter).
5.  **File build/web/index.html already exists. Overwrite?:** `No` (n yazıp enter).

### Adım 3: Yayına Al! 🌍
```bash
firebase deploy
```

Komut bitince size bir **Hosting URL** verecek (Örn: `https://dengim-kim.web.app`).
Tebrikler! Uygulamanız artık tüm dünyada erişilebilir.

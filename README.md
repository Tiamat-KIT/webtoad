# webtoad
Tauri-mobile(Alpha)を使ってAndroidアプリを作成する

## [Linux](https://next--tauri.netlify.app/next/guides/getting-started/prerequisites/linux)
1. システム周りの依存関係をダウンロード
  ```bash
  sudo apt update
  sudo apt install libwebkit2gtk-4.1-dev \
    build-essential \
    curl \
    wget \
    libssl-dev \
    libgtk-3-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev
  ```
2. Rustのインストール
   ```bash
   curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
   ```
3. CargoにAndroid開発用パッケージを入れる
   ```bash
   rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
   ```
4. Android Studioを導入する（らしい）
5. JAVA_HOME環境変数にJDKの場所を設定
   ```bash
  export JAVA_HOME=/opt/android-studio/jbr
   ```
6. ANDROID_HOMEとNDK_HOME環境変数を設定
  ```bash
  export ANDROID_HOME="$HOME/Android/Sdk"
  export NDK_HOME="$ANDROID_HOME/ndk/25.0.8775105"
  ```


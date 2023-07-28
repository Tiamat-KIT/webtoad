# webtoad
Tauri-mobile(Alpha)を使ってAndroidアプリを作成する

## [Linux](https://next--tauri.netlify.app/next/guides/getting-started/prerequisites/linux)
- システム周りの依存関係をダウンロード
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
- Rustのインストール
   ```bash
   curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
   ```
- CargoにAndroid開発用パッケージを入れる
   ```bash
   rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
   ```
- Android Studioを導入する（らしい）
- JAVA_HOME環境変数にJDKの場所を設定
   ```bash
   export JAVA_HOME=/opt/android-studio/jbr
   ```
- ANDROID_HOMEとNDK_HOME環境変数を設定
  ```bash
  export ANDROID_HOME="$HOME/Android/Sdk"
  export NDK_HOME="$ANDROID_HOME/ndk/25.0.8775105"
  ```

## [Next.jsの導入](https://next--tauri.netlify.app/next/guides/getting-started/setup/next-js/)
- Next.jsプロジェクトの作成
  ```bash
  npx create-next-app@latest --use-npm --typescript
  ```
- [色々とインストール](https://next--tauri.netlify.app/next/mobile/development/configuration)
  ```bash
  npm install @tauri-apps/cli@next @tauri-apps/api@next
  cd src-tauri
  cargo add tauri@2.0.0-alpha.0
  cargo add tauri-build@2.0.0-alpha.0 --build
  cd ..
  npm install --save-dev internal-ip
  ```
- next.config.jsの設定
  ```js
  const isProd = process.env.NODE_ENV === 'production'
  module.exports = async (phase, { defaultConfig }) => {
    let internalHost = null
    if (!isProd) {
      const { internalIpV4 } = await import('internal-ip')
      internalHost = await internalIpV4()
    }
    /**
     * @type {import('next').NextConfig}
     */
    const nextConfig = {
      reactStrictMode: true,
      swcMinify: true,
      // Note: This experimental feature is required to use NextJS Image in SSG mode.
      // See https://nextjs.org/docs/messages/export-image-api for different workarounds.
      images: {
        unoptimized: true,
      },
      assetPrefix: isProd ? null : `http://${internalHost}:3000`,
    }
    return nextConfig
  }
  ```
  - App Router??
    ```js
    /** @type {import('next').NextConfig} */
    const nextConfig = {
      output: 'export',
    }

    module.exports = nextConfig
    ```
- beforeDevCommandに--hostname $HOSTを追加
- package.jsonの"scripts"にtauri
  ```json
  {
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "export": "next export",
    "start": "next start",
    "tauri": "tauri",
    "lint": "next lint"
  },
  ```
- `src/pages/index.tsx`を以下のように更新
  ```ts
    import { invoke } from '@tauri-apps/api/tauri'
  
    // Note: When working with Next.js in development you have 2 execution contexts:
    // - The server (nodejs), where Tauri cannot be reached, because the current context is inside of nodejs.
    // - The client (webview), where it is possible to interact with the Tauri rust backend.
    // To check if we are currently executing in the client context, we can check the type of the window object;
    const isClient = typeof window !== 'undefined'
    
    // Now we can call our Command!
    // Right-click on the application background and open the developer tools.
    // You will see "Hello, World!" printed in the console.
    isClient &&
      invoke('greet', { name: 'World' }).then(console.log).catch(console.error)
    ```
  - Next.jsのクライアントコンポーネントで動くようにする`componentDidMount`または`useEffect`でTauriコールを使用する
    ```tsx
    // ...
  import { invoke } from '@tauri-apps/api/tauri'
  
  const Greet = () => {
    useEffect(() => {
      invoke('greet', { name: 'World' }).then(console.log).catch(console.error)
    }, [])
  }
  
  export default function Home() {
    Greet()
    // ...
  }
  ```
## [既存プロジェクトへの統合](https://next--tauri.netlify.app/next/mobile/development/integrate)
- `Cargo.toml`に以下を追加
  ```toml
  [lib]
  crate-type = ["staticlib", "cdylib", "rlib"]
  ```
- Rustライブラリのデフォルトのエントリーポイントは`lib.rs`ファイルである。`src-tauri/lib.rs`
  デスクトップとモバイルの両方のターゲットで再利用されるtauri::Builderラッパーを書いてみよう。
  ```rust
  use tauri::App;

  #[cfg(mobile)]
  mod mobile;
  #[cfg(mobile)]
  pub use mobile::*;
  
  pub type SetupHook = Box<dyn FnOnce(&mut App) -> Result<(), Box<dyn std::error::Error>> + Send>;
  
  #[derive(Default)]
  pub struct AppBuilder {
    setup: Option<SetupHook>,
  }
  
  impl AppBuilder {
    pub fn new() -> Self {
      Self::default()
    }
  
    #[must_use]
    pub fn setup<F>(mut self, setup: F) -> Self
    where
      F: FnOnce(&mut App) -> Result<(), Box<dyn std::error::Error>> + Send + 'static,
    {
      self.setup.replace(Box::new(setup));
      self
    }
  
    pub fn run(self) {
      let setup = self.setup;
      tauri::Builder::default()
        .setup(move |app| {
          if let Some(setup) = setup {
            (setup)(app)?;
          }
          Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
    }
  }
  ```
  ## [モバイルワークフロー](https://next--tauri.netlify.app/next/mobile/development/mobile_workflow)
  - モバイルセットアップの生成
    - `npm run tauri android init`
    - `dev`コマンドを使えば、コマンドラインから直接、既存のエミュレーターや接続されたデバイスでアプリを実行できる。代わりに`--open`フラグを使ってAndroid Studioを使うこともできる。 `npm run tauri android dev [--open]`
    - androidアプリのビルド　`npm run tauri android build`


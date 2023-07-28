export ANDROID_HOME="/Users/$USER/Library/Android/sdk"
export NDK_HOME="$ANDROID_HOME/ndk/25.1.8937393"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/microsoft-11.jdk/Contents/Home"
npm run tauri android build
npm run tauri android dev -- --open

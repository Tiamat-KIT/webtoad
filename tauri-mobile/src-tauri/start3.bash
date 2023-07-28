curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
source "$HOME/.cargo/env"
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
cargo add tauri@2.0.0-alpha.0
cargo add tauri-build@2.0.0-alpha.0 --build
cargo install tauri-cli --version "^2.0.0-alpha"
apt install libglib2.0-dev
cargo build
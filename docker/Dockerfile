FROM cirrusci/flutter

ENV ANDROID_NDK_VERSION 22.1.7171670
ENV PATH="/root/.cargo/bin:$PATH"


RUN yes | sdkmanager "ndk;$ANDROID_NDK_VERSION"

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y \
    && . "$HOME/.cargo/env" \
    && rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android \
    && echo "export ANDROID_NDK_HOME=/opt/android-sdk-linux/ndk/$ANDROID_NDK_VERSION" >> $HOME/.bashrc \
    && cargo install cargo-ndk --version 2.6.0

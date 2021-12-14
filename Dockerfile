# syntax=docker/dockerfile:1
FROM ubuntu:21.10

# install essential packages
RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone \
    && sed -i 's/http:\/\/archive.ubuntu.com/http:\/\/mirror.sjtu.edu.cn/g' /etc/apt/sources.list \
    && apt-get -y update && apt-get -y upgrade \
    && apt-get install -y vim zsh curl pkg-config libssl-dev git cmake binutils libstdc++-11-dev \
    clang clang-format clang-tidy clangd libc++-dev libc++abi-dev libunwind-dev \
    && git config --global core.editor vim \
    && chsh -s zsh

SHELL ["zsh", "-c"]
# zsh config
RUN sh -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && echo 'export EDITOR=vim' >> $HOME/.zshrc \
    && git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k \
    && sed -i 's/\(ZSH_THEME=\).*/\1"powerlevel10k\/powerlevel10k"/g' $HOME/.zshrc \
    # install rust toolchain
    && echo 'export RUSTUP_DIST_SERVER=https://mirror.sjtu.edu.cn/rust-static' >> $HOME/.zshrc \
    && echo 'export RUSTUP_UPDATE_ROOT=https://mirror.sjtu.edu.cn/rust-static/rustup' >> $HOME/.zshrc \
    && source $HOME/.zshrc \
    && curl -SL https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup/archive/1.24.3/x86_64-unknown-linux-gnu/rustup-init >> rustup-init \
    && chmod a+x rustup-init && ./rustup-init --default-toolchain nightly -y && rm -rf rustup-init \
    && source $HOME/.cargo/env \
    && echo -e '[source]\n\n[source.mirror]\nregistry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index/"\n\n[source.crates-io]\nreplace-with = "mirror"' \
    >> $HOME/.cargo/config.toml \
    && echo -e '[target.x86_64-unknown-linux-gnu]\nrustflags = ["-C", "linker=clang"]' >> $HOME/.cargo/config.toml \
    && rm -rf $HOME/.cargo/registry \
    && apt-get remove -y pkg-config gcc && apt-get autoremove -y

CMD [ "zsh" ]
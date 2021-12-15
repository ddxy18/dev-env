# syntax=docker/dockerfile:1
FROM ubuntu:21.10

# install essential packages
RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone \
    && sed -i 's/http:\/\/archive.ubuntu.com/http:\/\/mirror.sjtu.edu.cn/g' /etc/apt/sources.list \
    && apt-get -y update && apt-get -y upgrade \
    && apt-get install -y vim zsh curl git cmake binutils \
    clang clang-format clang-tidy clangd libc++-dev libc++abi-dev libunwind-dev \
    && git config --global core.editor vim \
    && chsh -s zsh

SHELL ["zsh", "-c"]
# zsh config
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && echo 'export EDITOR=vim' >> $HOME/.zshrc \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k \
    && sed -i 's/\(ZSH_THEME=\).*/\1"powerlevel10k\/powerlevel10k"/g' $HOME/.zshrc \
    && curl -SL https://raw.githubusercontent.com/ddxy18/dev-env/main/.p10k.zsh >> $HOME/.p10k.zsh \
    && x=`echo '# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.'; \
    echo '# Initialization code that may require console input (password prompts, [y/n]'; \
    echo '# confirmations, etc.) must go above this block; everything else may go below.'; \
    echo 'if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then'; \
    echo 'source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"'; \
    echo -e 'fi\n'; cat $HOME/.zshrc` \
    && echo $x > $HOME/.zshrc \
    && echo -e '# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.\n[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh\n' >> $HOME/.zshrc \
    # install rust toolchain
    && echo 'export RUSTUP_DIST_SERVER=https://mirror.sjtu.edu.cn/rust-static' >> $HOME/.zshrc \
    && echo 'export RUSTUP_UPDATE_ROOT=https://mirror.sjtu.edu.cn/rust-static/rustup' >> $HOME/.zshrc \
    && source $HOME/.zshrc \
    && curl -SL https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init >> rustup-init \
    && chmod a+x rustup-init && ./rustup-init --default-toolchain nightly -y && rm -rf rustup-init \
    && source $HOME/.cargo/env \
    && echo -e '[source]\n\n[source.mirror]\nregistry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index/"\n\n[source.crates-io]\nreplace-with = "mirror"' \
    >> $HOME/.cargo/config.toml \
    && echo -e '[target.x86_64-unknown-linux-gnu]\nrustflags = ["-C", "linker=clang"]' >> $HOME/.cargo/config.toml \
    && rm -rf $HOME/.cargo/registry \
    && apt-get remove -y gcc && apt-get autoremove -y

CMD [ "zsh" ]
if status is-interactive
    set -gx PATH $PATH ~/scripts/
    function tmux_sessionizer
        tmux-sessionizer.sh
    end

    bind \cf tmux_sessionizer
end

set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin $PATH /home/patrick/.ghcup/bin # ghcup-env
# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
export PATH="$HOME/.local/bin:$PATH"
set -x LD_LIBRARY_PATH /usr/local/cuda/lib64 $LD_LIBRARY_PATH

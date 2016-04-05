# Dotfiles

This repo contains three things:

1. dotfiles (.zshrc, etc)
1. scripts to install said dotfiles and their possible prerequisites (oh-my-zsh)
1. instructions for how to consume the above 2 things

## Usage

For best results, install while listening to
[The Cowboy Bebop OST](https://itunes.apple.com/us/album/cowboy-bebop-original-soundtrack/id489780131)

### Prerequisites

These dotfiles work best when dependencies are installed with brew wherever possible,
`*` indicates the dependency is not available via brew.

* xcode CLI tools (`xcode-select --install`) *
* [homebrew](http://brew.sh)
* golang 1.6
* iterm2 (via `brew cask`)
* [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) *

### Installation

It is best to assume that the following paths are required as is unless a specific
exception is noted.

1. clone dotfiles:

    ```bash
    git clone git@github.com:zaksoup/dotfiles.git ~/workspace/dotfiles
    ```
1. run install script

    ```bash
    cd ~/workspace/dotfiles
    ./install
    ```

The install script will:

* clone and install [powerline fonts](https://github.com/powerline/fonts)
* install the [git-duet](https://github.com/git-duet/git-duet) brew package
* add `git ci` as an alias for `git duet-commit`
* overwrite the current `~/.zshrc` with one from this repo
* install the "Zagnoster" ZSH theme (agnoster with git-duet support)
* download and install the [Hybrid colorscheme](https://github.com/w0ng/vim-hybrid) for iTerm

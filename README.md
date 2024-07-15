# .dotfiles

My personal configurations managed by stow

## Install

- Clone repository to home directory
- Run the following code to initialize config

  ```bash
  git submodule sync --recursive && \
  git submodule update --init --recursive && \
  stow --dotfiles .
  ```

- Install [Apps](#apps)

## Apps

### Kitty

```bash
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
```

### Atuin

- Install

  ```bash
  curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
  ```

- Login

  - Grab credentials from bitwarden
  - Login and sync

    ```bash
    atuin login -u <USERNAME>
    atuin sync
    ```

### Gibo

- Install [Golang](#install-these-on-your-own) first

```base
go install github.com/simonwhitaker/gibo@latest
```

### Spring Intitializr Go

- Install [Golang](#install-these-on-your-own) first

```base
go install github.com/eslam-allam/spring-initializer-go/cmd/spring-initializer@latest
```

### Install These On Your Own

- [Neovim](https://github.com/neovim/neovim)
- [Golang](https://go.dev/)
- [Tmux](https://github.com/tmux/tmux)

  - Install GitMux

    ```bash
    go install github.com/arl/gitmux@latest
    ```

  > Don't forget to install plugins \<c-a>I

- Java

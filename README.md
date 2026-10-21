# dotfiles

Mi configuración de Ubuntu 26.04 (bash, vim, ptyxis...).

## Instalación

En una máquina nueva:

    git clone https://github.com/edgarmgg/dotfiles.git ~/dev/dotfiles
    cd ~/dev/dotfiles && ./install.sh

## Qué incluye

| Ruta | Contenido |
|---|---|
| `home/` | Config base (Stow): bash, git, vim (con plantillas), tmux, ssh y VS Code |
| `theme/` | Personalización: Starship, fastfetch, paleta de Ptyxis, ajustes de GNOME |
| `packages/` | Lista de paquetes de apt y de extensiones de VS Code |

## Cómo funciona

`install.sh` instala los paquetes, Starship y la Nerd Font, y enlaza los archivos con
[GNU Stow](https://www.gnu.org/software/stow/). Después carga los ajustes de GNOME con `dconf load`.
`./install.sh` pregunta qué perfil quieres:

- **Básica**: paquetes, bash, git, vim (+ vim-plug y plugins), tmux, ssh y VS Code.
- **Completa**: la básica más Starship, la Nerd Font, la paleta de Ptyxis, fastfetch y los ajustes de GNOME.

Sin preguntas:

    ./install.sh --basic
    ./install.sh --full

Puedes ejecutarlo varias veces sin problema.

## Notas

- Las plantillas de Vim (`.cc`, `.h`, Makefile) están en `home/vim/.vim/templates/`.
- Alias privados (usuario de VPN, etc.) van en `~/.bash_aliases.local`, que no se sube al repo.
- `dotsync` exporta los ajustes y pide confirmación antes de hacer commit y push. Usa `$DOTFILES` si el repo no está en `~/dev/dotfiles`.

## Detalles

- Fuente: JetBrainsMono Nerd Font, 12 pt
- Ventana de terminal: 102x26
- Tema: Custom, con color de resaltado purple

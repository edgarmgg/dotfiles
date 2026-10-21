# dotfiles

Configuración personal de Ubuntu 26.04: bash, vim, tmux, git, VS Code y un tema de terminal propio. Se instala con un solo script y es idempotente.

## Instalación

En una máquina nueva:

    git clone https://github.com/edgarmgg/dotfiles.git ~/dotfiles
    cd ~/dotfiles && ./install.sh

El script pregunta qué perfil instalar. Para evitar la pregunta:

    ./install.sh --basic
    ./install.sh --full

Se puede ejecutar varias veces sin problema.

## Perfiles

| Perfil | Incluye |
|---|---|
| **Básico** | Paquetes de apt, bash, git, vim (con vim-plug y plugins), tmux, ssh y VS Code |
| **Completo** | El básico, más Starship, Nerd Font, paleta de Ptyxis, fastfetch y ajustes de GNOME |

## Estructura

| Ruta | Contenido |
|---|---|
| `home/` | Configuración base, un paquete de Stow por herramienta |
| `theme/` | Starship, fastfetch, paleta de Ptyxis y ajustes de GNOME (`dconf`) |
| `packages/` | Listas de paquetes de apt y de extensiones de VS Code |
| `install.sh` | Instalador modular por pasos |

## Cómo funciona

`install.sh` instala los paquetes, Starship y la Nerd Font, y enlaza los archivos con [GNU Stow](https://www.gnu.org/software/stow/). Después carga los ajustes de GNOME con `dconf load`. Si un archivo existente estorba, lo guarda como `.bak` en lugar de borrarlo.

## Tema

- **Fuente:** JetBrainsMono Nerd Font, 12 pt
- **Terminal:** Ptyxis, ventana de 102x26
- **Paleta:** propia (`theme-edgar`), con color de resaltado morado

## Notas

- Las plantillas de Vim (`.cc`, `.h` y Makefile) están en `home/vim/.vim/templates/`.
- Los datos privados no se suben al repo: los alias van en `~/.bash_aliases.local` y los hosts de SSH en `~/.ssh/config.local`.
- `dotsync` exporta los ajustes actuales de GNOME y pide confirmación antes de hacer commit y push. Se indica la ruta del repo con la variable `$DOTFILES`.

## Licencia

[MIT](LICENSE)

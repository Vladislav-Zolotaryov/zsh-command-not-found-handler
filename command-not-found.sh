export PKGFILE_PROMPT_INSTALL_MISSING=1

command_not_found_handler() {
  local pkgs cmd="$1"

  pkgs=(${(f)"$(pkgfile -b -v -- "$cmd" 2>/dev/null)"})
  if [[ -n "$pkgs" ]]; then

    pkgs_count=${#pkgs[@]}

    if (( $pkgs_count > 1 )); then
      printf 'The application \033[1m%s\033[0m is not installed. It may be found in the following packages:\n' "$cmd"      
      setopt shwordsplit

      for i in {1..$#pkgs}; do echo "  $i. $pkgs[$i]"; done

      printf 'Choose the number of a package or N? ([1..%s]/N)\n' $pkgs_count

      read choice
      if [[ $choice =~ ^[0-9]+$ ]] && ((0 < $choice <= $pkgs_count)); then
          pkgrow="$pkgs[$choice]"
          pkgname=(${(s: :)pkgrow})
          pkgid=${${(s:/:)pkgname[1]}[2]}

          echo 
          echo "Installing $pkgid"
          if which pamac>/dev/null; then
              pamac install $pkgid
          elif which yay>/dev/null; then
              yay -S $pkgid
          else
              sudo pacman -S $pkgid
          fi
      else
          echo " "
      fi
    else
      printf 'The application \033[1m%s\033[0m is not installed. It may be found in the following package:\n' "$cmd"
      printf '  %s\n' $pkgs[@]
      
      setopt shwordsplit

      pkg_array=($pkgs[@])

      pkgname="${${(@s:/:)pkg_array}[2]}"
      printf 'Do you want to Install package %s? (y/N)' $pkgname
      if read -q "choice? "; then
          echo
          echo "Installing $pkgname"
              if which pamac>/dev/null; then
                  pamac install $pkgname
              elif which yay>/dev/null; then
                  yay -S $pkgname
              else
                  sudo pacman -S $pkgname
              fi
      else
          echo " "
      fi
    fi
  else
    printf 'zsh: command not found: %s\n' "$cmd"
  fi 1>&2

  return 127
}

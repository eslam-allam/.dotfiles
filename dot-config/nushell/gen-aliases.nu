#!/usr/bin/env nu

let aliasFile = $"($nu.default-config-dir)/aliases.nu"

def save-alias [...args: string] {
    $"alias ($args | str join ' ')\n" | save -a $aliasFile
}

'' | save -f $aliasFile


if not ( which eza | is-empty ) {
    save-alias "ls = eza --icons auto"
    save-alias "la = eza --header --long --all --group --icons auto"
}

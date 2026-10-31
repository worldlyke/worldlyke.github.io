#!/bin/bash
# Controllo prima di pubblicare site/ (GitHub Pages): fallisce se nelle pagine restano segnaposto [..] o
# <mark class="segnaposto">, se un link interno non porta a un file, se manca la versione nell'altra lingua o il
# link per cambiarla, se manca "Ultimo aggiornamento", o se app-ads.txt è ancora il segnaposto.
#   bash site/check.sh            controllo completo (pubblicazione)
#   bash site/check.sh --bozza    come sopra, ma i segnaposto e app-ads.txt sono solo elencati
#   bash site/check.sh --senza-app-ads   pubblicazione delle sole pagine (app-ads.txt non si carica finché AdMob non dà la riga)
cd "$(dirname "$0")"
draft=0; [ "${1:-}" = "--bozza" ] && draft=1
noads=0; [ "${1:-}" = "--senza-app-ads" ] && noads=1
errors=0
err() { echo "ERRORE: $*"; errors=$((errors + 1)); }

pages=$(find . -name "*.html" | sort)
for page in $pages; do
  dir=$(dirname "$page")
  # link interni: ogni href relativo deve portare a un file (cartella = index.html)
  for href in $(grep -o 'href="[^"]*"' "$page" | sed 's/href="//; s/"$//'); do
    case "$href" in http*|mailto:*|\#*) continue ;; esac
    target="$dir/$href"
    [ -d "$target" ] && target="$target/index.html"
    [ -f "$target" ] || err "$page: link rotto $href"
  done
  # lingue: lang dichiarata, pagina gemella nell'altra lingua, link per cambiarla
  lang=$(grep -o '<html lang="[a-z]*"' "$page" | grep -o '"[a-z]*"' | tr -d '"')
  case "$page" in
    ./en/*) [ "$lang" = "en" ] || err "$page: lang deve essere en"; twin="./${page#./en/}"; other=it ;;
    *) [ "$lang" = "it" ] || err "$page: lang deve essere it"; twin="./en/${page#./}"; other=en ;;
  esac
  [ -f "$twin" ] || err "$page: manca la versione $other ($twin)"
  grep -q "hreflang=\"$other\"" "$page" || err "$page: manca il link alla versione $other"
  grep -qE 'Ultimo aggiornamento|Last updated' "$page" || err "$page: manca la data di ultimo aggiornamento"
  grep -q '<script' "$page" && err "$page: niente JavaScript"
done

# segnaposto
todo=$(grep -noE '\[[^]<>"]{1,120}\]|class="segnaposto"' $pages)
ads=$(grep -v '^#' app-ads.txt | grep -c '[a-z]')
if [ $draft -eq 1 ]; then
  [ -n "$todo" ] && echo "Segnaposto da compilare:" && grep -noE '\[[^]<>"]{1,120}\]' $pages
  [ "$ads" -eq 0 ] && echo "app-ads.txt: ancora segnaposto (non pubblicarlo)"
else
  [ -n "$todo" ] && err "segnaposto ancora presenti (bash site/check.sh --bozza per l'elenco)"
  if [ "$ads" -eq 0 ] && [ $noads -eq 0 ]; then err "app-ads.txt è ancora il segnaposto: compilalo con la riga di AdMob, o usa --senza-app-ads e non caricarlo"; fi
  [ "$ads" -eq 0 ] && [ $noads -eq 1 ] && echo "Ricorda: NON caricare app-ads.txt (è ancora il segnaposto)."
fi

if [ $errors -gt 0 ]; then echo "$errors errori: non pubblicare."; exit 1; fi
if [ $draft -eq 1 ]; then echo "Link e lingue a posto (bozza: compila i segnaposto prima di pubblicare)."; else echo "OK: pronto da pubblicare."; fi

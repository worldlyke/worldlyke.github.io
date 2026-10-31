# Sito di Meltaway (informativa ed eliminazione dei dati)

HTML semplice per GitHub Pages: niente JavaScript, un solo foglio di stile (`style.css`), leggibile da telefono e con il tema scuro del sistema.

## Pagine
| Indirizzo (dopo la pubblicazione) | File | Inglese |
|---|---|---|
| `/` | `index.html` | `en/index.html` |
| `/privacy/` | `privacy/index.html` | `en/privacy/index.html` |
| `/delete-data/` | `delete-data/index.html` | `en/delete-data/index.html` |
| `/app-ads.txt` | `app-ads.txt` | non ha lingua; **segnaposto, non pubblicarlo** finché AdMob non dà la riga |

`README.md` e `check.sh` non vanno pubblicati.

## Prima di pubblicare
1. **Segnaposto:** compila tutti quelli evidenziati in giallo, `[...]`. Per l'elenco: `bash site/check.sh --bozza`.
   - Riguardano: nome legale e indirizzo dello sviluppatore, email di contatto, base giuridica degli annunci non personalizzati, conservazione delle statistiche, età minima, tempi di risposta.
   - Il codice dell'installazione per l'eliminazione dei dati richiede una piccola aggiunta nel gioco: mostrare l'identificativo di Firebase in Impostazioni > I tuoi dati.
2. **Date:** aggiorna "Ultimo aggiornamento" in tutte e sei le pagine se cambi il testo.
3. **Controllo:** `bash site/check.sh` deve dire "OK: pronto da pubblicare". Si ferma se:
   - restano segnaposto;
   - un link interno è rotto;
   - manca una lingua, il link per cambiarla o la data;
   - `app-ads.txt` è ancora il segnaposto.

   Lo stesso controllo c'è come test di Unity: `SiteTests`, categoria "Pubblicazione".

## Pubblicare su GitHub Pages
`app-ads.txt` deve stare nella **radice** del dominio del sito sviluppatore indicato in Play Console. Per questo conviene un repository dedicato `worldlyke.github.io`, che si pubblica nella radice `https://worldlyke.github.io/`. Le pagine di un progetto stanno invece sotto `/nome-repository/`.

1. Su GitHub crea un repository **pubblico** chiamato esattamente `worldlyke.github.io`.
2. Copia il contenuto di `site/` nella radice di quel repository, **senza** `README.md`, `check.sh` e, finché non è compilato, `app-ads.txt`:
   ```
   git clone https://github.com/worldlyke/worldlyke.github.io.git ../sito
   cp -r site/index.html site/style.css site/privacy site/delete-data site/en ../sito/
   cd ../sito && git add . && git commit -m "Informativa ed eliminazione dei dati" && git push
   ```
3. Su GitHub: Settings > Pages > Build and deployment > Source "Deploy from a branch", branch `main`, cartella `/ (root)`. Dopo un minuto il sito è su `https://worldlyke.github.io/`.
4. Spunta "Enforce HTTPS". Con un dominio tuo, inseriscilo in Custom domain e segui le istruzioni DNS.
5. **Indirizzi nel gioco:** già impostati in `Assets/Resources/Data/balance.json` → `links`. Chi gioca in inglese apre le pagine `en/` (`byLanguage`); il test `SiteTests` controlla che ogni indirizzo porti a una pagina del sito.
   - `privacy`: `https://worldlyke.github.io/privacy/`
   - `data`: `https://worldlyke.github.io/delete-data/`
   - `support`: `mailto:worldlykehub@gmail.com`
6. **Play Console:**
   - Contenuti dell'app > Norme sulla privacy: `https://worldlyke.github.io/privacy/`;
   - Sicurezza dei dati > Eliminazione dei dati: `https://worldlyke.github.io/delete-data/`;
   - Dettagli dello store > Sito web: `https://worldlyke.github.io/`, dove AdMob cercherà `app-ads.txt`.

## app-ads.txt
Quando AdMob mostra la riga del tuo account (AdMob > App > app-ads.txt):
1. sostituisci in `app-ads.txt` la riga commentata con quella fornita, senza `#`, e togli i commenti;
2. lancia `bash site/check.sh`;
3. copia anche `app-ads.txt` nel repository del sito.

AdMob lo verifica entro qualche giorno.

## Statistiche: da fare una volta, e a ogni richiesta di eliminazione
**Una volta sola**, in Google Analytics, proprietà collegata a Firebase: Amministrazione > Raccolta e modifica dei dati > Conservazione dei dati > **14 mesi**. Il valore predefinito è 2 mesi; l'informativa promette 14.

**A ogni richiesta** (email con il codice dell'installazione, che il giocatore copia da Impostazioni > Codice dell'installazione):
1. rispondi entro 7 giorni confermando di averla ricevuta;
2. in Google Analytics: Esplora > Esplorazione utente, cerca il codice (è l'ID dell'istanza dell'app, `app_instance_id`), apri l'utente e scegli **Elimina utente**. Google lo toglie dai dati entro 72 ore;
3. annota solo data della richiesta e data di chiusura (si conservano 12 mesi) e cancella l'email;
4. chiudi entro 30 giorni.

**Senza richieste** le statistiche si cancellano da sole dopo 14 mesi.

**Crashlytics** non permette di cancellare una singola persona: le segnalazioni si cancellano da sole dopo 90 giorni, come scritto nella pagina di eliminazione.

**Se nel gioco compare "Nessuna statistica raccolta su questo telefono"** (consenso negato, oppure Firebase non configurato), non c'è nulla da cancellare.

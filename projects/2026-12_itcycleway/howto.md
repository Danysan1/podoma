Questo mese ci occupiamo della navigazione dei più fragili sulle strade, ossia ciclisti (direi commuters in particolare) e pedoni. L'obiettivo è migliorare la mappatura delle pedonali, ciclopedonali e ciclabili presenti sul territorio.

Per chi mappa, un riassunto veloce con le docs per approfondire:

* percorsi solo pedonali: [`highway=footway`](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dfootway); ciclopedonali: aggiungete [`bicycle=designated`](https://wiki.openstreetmap.org/wiki/Bicycle) e `foot`, più `segregated=yes/no` se gli spazi sono separati
* ciclabili: [`highway=cycleway`](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dcycleway) disegnata come linea a parte, sul lato giusto della carreggiata. Se invece la mappate come tag sulla strada, ricordate che [`cycleway:left` e `cycleway:right`](https://wiki.openstreetmap.org/wiki/Key:cycleway) sono relativi al senso di disegno della way, non al vostro punto di vista
* sensi unici: sulla pista `oneway=yes` se lo è davvero; sulle strade con bici ammessa in contro-flusso si usa `oneway:bicycle=no`
* superficie: [`surface=*`](https://wiki.openstreetmap.org/wiki/Key:surface) (`asphalt`, `concrete`, `paving_stones`, `compacted`)
* limiti: `maxspeed=*` sul singolo tratto, sempre, e [`zone:maxspeed=IT:30`](https://wiki.openstreetmap.org/wiki/IT:Key:zone:maxspeed) dove c'è una Zona 30 segnalata
* illuminazione: `lit=yes/no`, da rilevare di sera
* nei changeset: `source=survey` o `source=photo`, insieme a `#nicebike`

Non sapete da dove partire per controllare i percorsi specifici? Partite vicino a: cimiteri, stazioni per il trasporto pubblico, ospedali, scuole ed altri istituti, centri commerciali. E non dimenticate attraversamenti e incroci.

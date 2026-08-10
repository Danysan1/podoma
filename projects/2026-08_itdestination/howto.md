I cartelli di destinazione, in particolare quelli su svincoli e uscite autostradali, sono spesso poco dettagliati in OSM: manca il contenuto dei cartelli con le località raggiungibili proseguendo sulla strada. Completare queste informazioni aiuta i navigatori a dare indicazioni più precise e tempestive.

* Nodi di svincolo ([`highway=motorway_junction`](https://wiki.openstreetmap.org/wiki/IT:Tag:highway%3Dmotorway_junction)): il punto di uscita da un'autostrada, spesso identificato da un numero o nome
* Cartelli di destinazione ([`destination=*`](https://wiki.openstreetmap.org/wiki/Key:destination)/[`destination:forward=*`](https://wiki.openstreetmap.org/wiki/Key:destination)/[`destination:backward=*`](https://wiki.openstreetmap.org/wiki/Key:destination)): riportano il contenuto dei cartelli con le località raggiungibili proseguendo sulla strada
  * [`destination:lanes=*`](https://wiki.openstreetmap.org/wiki/Key:destination:lanes): quando il cartello indica destinazioni diverse per ciascuna corsia
  * [`destination:ref=*`](https://wiki.openstreetmap.org/wiki/Key:destination:ref)/[`destination:ref:forward=*`](https://wiki.openstreetmap.org/wiki/Key:destination:ref)/[`destination:ref:backward=*`](https://wiki.openstreetmap.org/wiki/Key:destination:ref): numero di strada indicato sul cartello
    * [`destination:ref:lanes=*`](https://wiki.openstreetmap.org/wiki/Key:destination:ref): quando il numero di strada indicato varia per corsia
  * [`relation=destination_sign`](https://wiki.openstreetmap.org/wiki/Relation:destination_sign): relazione consigliata per i cartelli più complessi, in particolare in corrispondenza di uscite e svincoli
* Per i dettagli sullo schema di tagging consulta [questa pagina](https://wiki.openstreetmap.org/wiki/User:Mueschel/DestinationTagging); per la verifica e la visualizzazione dei cartelli puoi usare [CheckAutopista](https://k1wiosm.github.io/checkautopista2/) o [questo strumento](https://osm.mueschelsoft.de/destinationsign/)

Questo mese il progetto sulle indicazioni per la navigazione stradale è diviso in tre parti: [cartelli e restrizioni](/projects/2026-08_itsigns), [corsie](/projects/2026-08_itlanes) e destinazioni (qui).

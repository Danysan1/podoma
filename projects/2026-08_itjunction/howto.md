Cartelli stradali, corsie di svolta, indicazioni di destinazione e divieti di svolta sono spesso poco dettagliati in OSM. Completare queste informazioni aiuta i navigatori a dare indicazioni più precise e tempestive, ed evita ricalcoli di percorso inutili.

## Cartelli

* Cartelli stradali ([`traffic_sign=*`](https://wiki.openstreetmap.org/wiki/Key:traffic_sign)): riportano il codice del cartello secondo la segnaletica italiana; consulta la tabella su [IT:Road signs in Italy](https://wiki.openstreetmap.org/wiki/IT:Road_signs_in_Italy) per il tag esatto da usare e per gli eventuali tag aggiuntivi associati a ciascun cartello (es. [`maxspeed=*`](https://wiki.openstreetmap.org/wiki/IT:Key:maxspeed), [`overtaking=*`](https://wiki.openstreetmap.org/wiki/Key:overtaking))

## Corsie

* Numero di corsie ([`lanes=*`](https://wiki.openstreetmap.org/wiki/IT:Key:lanes)/[`lanes:forward=*`](https://wiki.openstreetmap.org/wiki/Key:lanes)/[`lanes:backward=*`](https://wiki.openstreetmap.org/wiki/Key:lanes))
* Corsie di svolta ([`turn:lanes=*`](https://wiki.openstreetmap.org/wiki/Key:turn:lanes)/[`turn:lanes:forward=*`](https://wiki.openstreetmap.org/wiki/Key:turn:lanes)/[`turn:lanes:backward=*`](https://wiki.openstreetmap.org/wiki/Key:turn:lanes)): indicano le direzioni consentite per ciascuna corsia (dritto, sinistra, destra, ecc.)
* Cambio di corsia ([`change:lanes=*`](https://wiki.openstreetmap.org/wiki/Key:change:lanes)/[`change:lanes:forward=*`](https://wiki.openstreetmap.org/wiki/Key:change:lanes)/[`change:lanes:backward=*`](https://wiki.openstreetmap.org/wiki/Key:change:lanes)): indicano dove è consentito o vietato cambiare corsia
* Puoi visualizzare le corsie già mappate con [questo strumento](https://osm.mueschelsoft.de/lanes/render.pl)

## Destinazioni

* Cartelli di destinazione ([`destination=*`](https://wiki.openstreetmap.org/wiki/Key:destination)/[`destination:forward=*`](https://wiki.openstreetmap.org/wiki/Key:destination)/[`destination:backward=*`](https://wiki.openstreetmap.org/wiki/Key:destination)): riportano il contenuto dei cartelli con le località raggiungibili proseguendo sulla strada
  * [`destination:lanes=*`](https://wiki.openstreetmap.org/wiki/Key:destination:lanes): quando il cartello indica destinazioni diverse per ciascuna corsia
  * [`destination:ref=*`](https://wiki.openstreetmap.org/wiki/Key:destination:ref): numero di strada indicato sul cartello
  * [`relation=destination_sign`](https://wiki.openstreetmap.org/wiki/Relation:destination_sign): relazione consigliata per i cartelli più complessi, in particolare in corrispondenza di uscite e svincoli
* Per i dettagli sullo schema di tagging consulta [questa pagina](https://wiki.openstreetmap.org/wiki/User:Mueschel/DestinationTagging); per la verifica e la visualizzazione dei cartelli puoi usare [CheckAutopista](https://k1wiosm.github.io/checkautopista2/) o [questo strumento](https://osm.mueschelsoft.de/destinationsign/)

## Restrizioni

* Divieti e obblighi di svolta ([`type=restriction`](https://wiki.openstreetmap.org/wiki/Relation:restriction) + [`restriction=*`](https://wiki.openstreetmap.org/wiki/Key:restriction)): relazioni che indicano i movimenti vietati o obbligati in un incrocio (es. divieto di svolta a sinistra); è il metodo consigliato rispetto ai soli tag sulla strada
  * [`except=*`](https://wiki.openstreetmap.org/wiki/Key:except): eccezioni al divieto, ad esempio per i mezzi pubblici o le biciclette
* Altre restrizioni di accesso o dimensione (es. [`maxweight=*`](https://wiki.openstreetmap.org/wiki/Key:maxweight), [`maxheight=*`](https://wiki.openstreetmap.org/wiki/Key:maxheight), [`hgv=*`](https://wiki.openstreetmap.org/wiki/Key:hgv))
  * l'elenco completo è nella pagina [Restrictions](https://wiki.openstreetmap.org/wiki/Restrictions)
  * dove possibile riportale tramite [`traffic_sign=*`](https://wiki.openstreetmap.org/wiki/Key:traffic_sign) come nella sezione "Cartelli"
* Puoi verificare le relazioni di svolta con [Ahorn](https://ahorn.lima-city.de/tr/) o [OSM Inspector](https://tools.geofabrik.de/osmi/?view=turn_restrictions)

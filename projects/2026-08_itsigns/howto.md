Cartelli stradali e divieti/obblighi di svolta sono spesso poco dettagliati in OSM. Completare queste informazioni aiuta i navigatori a dare indicazioni più precise e tempestive, ed evita ricalcoli di percorso inutili.

## Cartelli

* Cartelli stradali ([`traffic_sign=*`](https://wiki.openstreetmap.org/wiki/Key:traffic_sign)): riportano il codice del cartello secondo la segnaletica italiana; consulta la tabella su [IT:Road signs in Italy](https://wiki.openstreetmap.org/wiki/IT:Road_signs_in_Italy) per il tag esatto da usare
* Tag aggiuntivi associati ai cartelli, dalla colonna "Tags for affected highways" di [Key:traffic_sign](https://wiki.openstreetmap.org/wiki/Key:traffic_sign#Tags_for_affected_highways):
  * [`hazard=*`](https://wiki.openstreetmap.org/wiki/Key:hazard): pericoli segnalati (animali, caduta massi, ecc.)
  * [`priority=*`](https://wiki.openstreetmap.org/wiki/Key:priority)/[`priority_road=*`](https://wiki.openstreetmap.org/wiki/Key:priority_road): precedenza su strade a traffico alternato o su strade principali
  * [`overtaking=*`](https://wiki.openstreetmap.org/wiki/Key:overtaking): divieto di sorpasso
  * [`junction=*`](https://wiki.openstreetmap.org/wiki/Key:junction): tipo di incrocio (es. rotatoria)
  * [`vehicle=*`](https://wiki.openstreetmap.org/wiki/Key:vehicle): divieto di accesso ai veicoli

## Restrizioni

* Divieti e obblighi di svolta ([`type=restriction`](https://wiki.openstreetmap.org/wiki/Relation:restriction) + [`restriction=*`](https://wiki.openstreetmap.org/wiki/Key:restriction)): relazioni che indicano i movimenti vietati o obbligati in un incrocio (es. divieto di svolta a sinistra); è il metodo consigliato rispetto ai soli tag sulla strada
  * [`except=*`](https://wiki.openstreetmap.org/wiki/Key:except): eccezioni al divieto, ad esempio per i mezzi pubblici o le biciclette
* Altre restrizioni di accesso o dimensione, dalla pagina [Restrictions](https://wiki.openstreetmap.org/wiki/Restrictions):
  * [`maxspeed=*`](https://wiki.openstreetmap.org/wiki/IT:Key:maxspeed)/[`minspeed=*`](https://wiki.openstreetmap.org/wiki/Key:minspeed): limiti di velocità massimi e minimi
  * [`maxweight=*`](https://wiki.openstreetmap.org/wiki/Key:maxweight)/[`maxaxleload=*`](https://wiki.openstreetmap.org/wiki/Key:maxaxleload): limiti di massa totale e per asse
  * [`maxheight=*`](https://wiki.openstreetmap.org/wiki/Key:maxheight)/[`maxwidth=*`](https://wiki.openstreetmap.org/wiki/Key:maxwidth)/[`maxlength=*`](https://wiki.openstreetmap.org/wiki/Key:maxlength): limiti dimensionali
  * [`oneway=*`](https://wiki.openstreetmap.org/wiki/IT:Key:oneway): sensi unici
  * [`hov=*`](https://wiki.openstreetmap.org/wiki/Key:hov): corsie/strade riservate a veicoli ad alta occupazione
  * [`surface=*`](https://wiki.openstreetmap.org/wiki/IT:Key:surface): tipo di pavimentazione, utile per instradare mezzi che devono evitare strade non asfaltate
  * dove possibile riportale tramite [`traffic_sign=*`](https://wiki.openstreetmap.org/wiki/Key:traffic_sign) come nella sezione "Cartelli"
* Puoi verificare le relazioni di svolta con [Ahorn](https://ahorn.lima-city.de/tr/) o [OSM Inspector](https://tools.geofabrik.de/osmi/?view=turn_restrictions)

Questo mese il progetto sulle indicazioni per la navigazione stradale è diviso in tre parti: cartelli e restrizioni (qui), [corsie](/projects/2026-08_itlanes) e [destinazioni](/projects/2026-08_itdestination).

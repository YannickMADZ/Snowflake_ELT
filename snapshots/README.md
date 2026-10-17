# Snapshots — non utilisés (choix argumenté)

Un snapshot dbt historise une table **dont les lignes changent dans le temps**
(SCD de type 2) : à chaque `dbt snapshot`, dbt compare l'état courant à l'état
précédent et ferme/ouvre des versions avec `dbt_valid_from` / `dbt_valid_to`.
Il ne sert que si la **source est mise à jour en place** et que l'ancien état
serait perdu sans lui.

Aucune donnée de ce projet ne remplit cette condition :

| Donnée | Change-t-elle en place ? | Conclusion |
|---|---|---|
| Trajets (Bronze) | Non. Un trajet est un **événement passé** et immuable ; le fichier de janvier 2023 est figé. Une correction éventuelle arriverait sous forme d'un nouveau CSV rechargé en entier. | Un snapshot produirait une seule version par ligne : 3 M de lignes dupliquées, aucune information gagnée. |
| Zones, vendors, paiements, tarifs (seeds) | Rarement, et **toujours via un commit Git** (ce sont des seeds). | L'historique Git EST l'historique de ces référentiels (qui, quand, pourquoi). Un snapshot ferait doublon. |

**Quand en ajouter un ?** Si la TLC redécoupait ses zones (cela s'est produit
par le passé) et que l'on voulait analyser des trajets anciens avec le découpage
de leur époque, on chargerait la table des zones dans la Bronze et on la
snapshoterait (stratégie `check` sur `borough, zone, service_zone`), puis
`dim_location` deviendrait une dimension SCD2 jointe sur la période de validité.

# Projet RDV : reconnaissance de formes
##  Sujet
Utilisation d'un descripteur de Fourier pour la reconnaissance de formes (2D)
## Membres binôme
Gurtner Martin<br>
Duc Romain<br>
## Enonce
~~~
Ce sujet vise à implémenter une version simplifiée de l’article présenté dans
[1]. L’objectif est de retrouver parmi un ensemble d’images noir et blanc, 
représentant des classes d’objets (watch, turtle, truck, etc.), les images 
montrant le même objet que celui représenté dans une image donnée (appelée 
image requête).

Plus exactement, on souhaite pouvoir calculer un score de distance entre 
l’image requête et toutes les images de la base de référence, tel que si l’on 
trie ces scores par ordre croissant, les images représentant la classe d’objet 
de l’image requête apparaissent en premier dans la liste triée. L’algorithme 
idéal obtiendrait ainsi les K images montrant l’objet recherché aux K 
premières places de la liste triée. Bien entendu, cet algorithme n’existe pas,
mais on espère tout du moins que ce soit le cas pour des objets facile à 
reconnaître, et que les résultats soient le moins mauvais possible pour des 
objets difficiles à reconnaître. Par exemple en figure 1, un cheval a été pris 
pour un cerf, mais parmi les cinq meilleurs scores, on trouve tout de même 
quatre images montrant un cerf, y compris un cerf plus petit que dans l’image 
requête et ayant subi une rotation dans l’image
~~~

## Questions (méthode proposée)
1. Calculer le barycentre m des pixels blancs.
2. Pour N valeurs d’un angle t variant de 0 à 2π (le choix de N est laissé à votre appréciation), calculer l’intersection p(t) entre le contour de l’objet et le rayon partant de m formant un angle t avec l’axe horizontal de l’image. Soit r(t) la distance euclidienne entre m et p(t). Nous appellerons profil de la forme la courbe r(t) (cf figure 2).
3. Calculer la TF R(f) de r(t). Le descripteur de Fourier que nous utiliserons pour calculer les scores est le vecteur f d formé par les M premiers coefficients du vecteur |R(f)| / |R(0)|. Le choix de M est également laissé à votre appréciation.
# Kawa

## Fonctionnalités obligatoires

### Arithmétique

L'ensemble des opérations arithmétiques proposées est pris en charge. À savoir :
- l'**addition**
- la **soustraction**
- la **multiplication**
- la **division entière**
- le **modulo**
- l'**opposé**
- l'**égalité**
- l'**inégalité**
- l'**inférieur** stricte et large
- le **supérieur** stricte et large
- le **ET**
- le **OU**
- le **NON**

Par exemple :
```Java
// depuis tests/arith.kwa
...
print(40 - 2 - (3 + 1) * 4 / 8 + 6);
print((false && true) == false)
...
```
affichera `42` puis `true`

### Variables

Des variables peuvent être créées au début du programme ou au sein des méthodes (voir plus loin la partie associée). En supplément des attendus initiaux (**extension**), nous avons choisi de nous **affranchir du mot-clé** `var`, de rendre possible la **déclaration multiple** sur une seule ligne et la déclaration avec une **valeur initiale**.

Ainsi, le fragment de code suivant créera trois variables entières x, y, z et initialisera la variable a à 6.
```Java
// depuis tests/extensions_var_init.kwa et tests/extensions_multi_decl.kwa
int x, y, z;
int a = 6;
...
```

### Instructions

Les instructions disponibles sont :

- le `print`
- l'affectation `x = 2`
- le `if else`
- le `while`
- le `return`
- le `assert` (en extension, ex : `assert(true)` ne lèvera pas d'erreur, tandis que `assert(false)` le fera)
```Java
// depuis tests/instr.kwa
int a;
int n;
int acc;

main {
  a = 2;
  n = 9;
  acc = 1;
  while (n != 0) {
    if (n%2 != 0) { acc = a*acc; } else {}
    a = a*a;
    n = n/2;
  }
  print(acc);
}
```
affichera ainsi `512`.

### Classes, attributs et méthodes

Ici aussi, tout a été implémenté, tant bien les constructeurs avec ou sans argument que les méthodes ou encore l'héritage. En extension, nous avons décidé de supprimer le mot-clé `attribute` de la déclaration d'un attribut d'une classe. Nous avons pris le parti de forcer les noms de classes à commencer par une majuscule (convention répandue). Ainsi, nous distinguons les `IDENT` classiques, représentants des noms de variables, d'attributs ou de méthodes, ne commençant pas par une majuscule des `CIDENT`, les identifiant réservés aux classes, commençant nécessairement par une majuscule.

Pour un exemple d'utilisation, se référer aux fichiers `tests/nclass.kwa` `tests/method.kwa` et `tests/extend.kwa`

## Extensions

Voici un récapitulatif des extensions mises en place et des exemples d'utilisation.

### Nouveaux types

En plus des types de bases qu'étaient les **booléens**, les **entiers** et les **objets**, nous avons ajouter les **chaînes de charactères** et les **tableaux**.

#### Tableaux

Comme le montre le fragment de code suivant, les tableaux supportent :
- l'**affichage**
- la **concaténation**
- la **modification** en place
- l'**accès** à une case via son indice
- les opérateurs d'**égalité** et d'**inégalité**

```Java
int t1[3];
int t2[3];

main {
    t1 = {0, 0, 0}; // création
    t2 = {1, 1, 1};
    print(t1 + t2); // concaténation
    // affiche [ 0, 0, 0, 1, 1, 1 ]
    t1[0] = 5;
    print(t1[0]); // affiche 5
    assert(t1 != t2); // ne lève pas d'erreur
}
```

#### Chaînes de charactères

Les chaînes de charactères supportent :
- l'**affichage**
- la **concaténation**
- les opérateurs d'**égalité** et d'**inégalité**

### Instruction `assert`

Cette instruction permet de lever une exception si la condition passée en paramètre est un booléen évalué à `false`. Sa présence nous a semblée indispensable dans un langage de programmation.

Exemple :
```Java
...
i = 0;
assert(i == 0); // ne lève pas d'erreur
assert(i == 5); // lève une erreur
...
```

### Déclaration de variable / attributs

Au lieu de déclaré une variable avec `var int x = 0;`, le mot-clé `var` a désormais été supprimé, pour une écriture allégée : `int x = 0;`, se rapprochant plus de ce qu'on retrouve communément. Il en est de même pour le mot-clé `attribute` au sein d'une classe. les attributs se déclarent désormais comme des variables, mais dans la classe.

Il est également possible de déclarer plusieurs variables de même type sur une même ligne :
```Java
// passant de
int x;
int y;
int z;
// à
int x, y, z;
...
```

Enfin, on peut fournir une valeur initiale à une variable dès sa déclaration :
```Java
// passant de
int x;
int y;
main {
    x = 1;
    y = 4;
    ...
}
// à
int x = 1;
int y = 4;
main {
    ...
}
```
Ceci est valable aussi bien pour les variables globales que pour les variables locales à une méthode.

## Tests

Des tests se trouvent dans le dossier de même nom. La compilation suivie du lancement de l'ensemble des tests peuvent être lancés avec la simple commande `make test`, grâce au fait que tous les tests reposent sur des `assert` et non des `print`, sauf pour tester l'affichage.

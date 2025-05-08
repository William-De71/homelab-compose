# HomeLab & personnal Compose

Fichier docker-compose pour mon utilisation personnel

## Contenu

- <a href="nextcloud"><img src="https://avatars.githubusercontent.com/u/19211038?s=200&v=4" alt="nextcloud" height="30" align="top"/></a> [`Nextcloud`](nextcloud) - Application Nextcloud avec base de donnée MariaDB, Redis et serveur web Caddy.

## Prérequis

### Installation de Docker

Si Docker n'est pas encore installé sur votre machine, vous pouvez l'installer en faisant :

```bash
$ curl -sSL https://get.docker.com | sh
```

Il faut maintenant ajouter votre utilisateur au groupe "docker" pour que votre utilisateur puisse exécuter les commandes Docker avec la commande:

```bash
$ sudo usermod -aG docker nom_utilisateur
```

Ensuite, fermez votre session, puis reconnectez-vous. L'ajout d'un utilisateur a un groupe ne prend effet qu'après une reconnexion.

Pour vérifier que Docker tourne bien, lancez la commande suivante :

```bash
$ docker ps
```

Vous devriez voir une liste des containers qui tournent sur la machine. Comme vous venez d'installer Docker, cette liste doit être vide normalement.

### Installation de Docker Compose

1. Vérification des prérequis : avant d’installer Docker Compose, assurez-vous d’avoir Docker déjà installé sur votre système. En effet, Docker Engine est nécessaire pour le bon fonctionnement. Des privilèges administrateur ou sudo sont nécessaires pour l’installation

2. Installez Docker Compose sur votre plateforme : 

* Pour les distributions base Debian, les commandes à exécuter sont :

```bash
$ sudo apt-get update
$ sudo apt-get install docker-composite-plugin
```

3. Vérifiez que Docker Compose est correctement installé en exécutant la commande suivante:

```bash
$ docker-compose --version
```

Cette commande affichera la version de Docker Compose installée, ce qui confirmera que son installation est réussie.

### Déploiement et gestion des applications

Lorsque vous avez terminé la configuration de vos services, volumes et réseaux dans Docker Compose, vous pouvez déployer et gérer vos applications multi-conteneurs efficacement.

#### Déploiement initial

Pour déployer votre application, il suffit d’exécuter la commande suivante dans le répertoire où se trouve votre fichier Docker Compose :

```bash
$ docker-compose up -d
```
Paramètre -d exécute des conteneurs en arrière-plan.

Cette commande construira les conteneurs nécessaires ainsi que tous les objets définis dans votre fichier Docker Compose (volumes, réseaux, etc), et démarrera les services.

#### Gestion des conteneurs

Voici quelques commandes utiles pour la gestion des conteneurs :

* Pour arrêter et supprimer les conteneurs, réseaux, images et volumes:

```bash
$ docker-compose down
```

* Pour arrêter les services

```bash
$ docker-compose stop
```

* Pour démarrer les services

```bash
$ docker-compose start
```

* Pour redémarrer les services

```bash
$ docker-compose restart
```

* Pour afficher les informations sur les conteneurs en cours d'exécution

```bash
$ docker-compose ps
```

* Surveillance

En cas de problème et d’anomalie, Docker Compose fournit des outils pour examiner les fichiers journaux (logs) des conteneurs. La commande suivante permet de les obtenir :

```bash
$ docker-compose logs <nom-du-service>
```


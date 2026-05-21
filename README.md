# System Architect Lab - Gestion de Garage

> Mini-projet **LIU 2026** - Introduction aux Systèmes d'Exploitation
> Encadrant : Dr. EL BENANY Mohamed Mahmoud

Plateforme de gestion d'une flotte de véhicules de garage automobile, mettant en pratique :

- L'**automatisation Linux** via scripts Bash
- L'**ordonnancement CPU** (comparatif SRTF vs Round Robin)
- La **conteneurisation** avec Docker et `docker-compose`
- La **persistance des données** avec MySQL
- Le **déploiement HTTP** via Apache

---

## 🎯 Structure du projet

```
garage-system/
├── admin_systeme.sh       # Étape 1 : automatisation Bash
├── scheduling.py          # Étape 2 : SRTF vs Round Robin
├── gantt_round_robin.png  # Diagramme de Gantt généré
├── gantt_srtf.png         # Diagramme de Gantt généré
├── docker-compose.yml     # Étape 3 : orchestration
├── mysql_init.sql         # Schéma + procédures CRUD
├── web/index.html         # Serveur Apache
├── rapport.docx           # Rapport technique (10 pages)
└── README.md
```

---

## ⚙️ Étape 1 - Automatisation Shell

Le script `admin_systeme.sh` automatise :

| Fonctionnalité | Description |
|---|---|
| Gestion comptes | Création / suppression d'utilisateurs (`useradd`, `userdel`) |
| Privilèges d'accès | Configuration des droits via `chmod` et `chown` |
| Quota disque | Surveillance de la taille d'un dossier avec seuil |
| CRUD véhicules | Ajouter / afficher / supprimer / rechercher |

**Exécution :**
```bash
chmod +x admin_systeme.sh
sudo ./admin_systeme.sh
```

---

## 🧠 Étape 2 - Ordonnancement CPU

Le script `scheduling.py` compare deux politiques d'ordonnancement
sur un même jeu de processus, et calcule le **Temps d'Attente Moyen (TAM)**.

**Jeu de test :**

| Processus | Arrivée | Burst |
|---|---|---|
| P1 | 0 | 8 |
| P2 | 1 | 4 |
| P3 | 2 | 9 |
| P4 | 3 | 5 |

Quantum Round Robin : 3

**Exécution :**
```bash
pip install matplotlib
python3 scheduling.py
```

Deux fichiers PNG sont générés automatiquement :
`gantt_round_robin.png` et `gantt_srtf.png`.

**Résultat (validé) :**
- TAM Round Robin = 13.50
- TAM SRTF = 6.50
- → **SRTF est plus efficace** sur ce jeu de processus

---

## 🐳 Étape 3 - Infrastructure et Conteneurisation

Trois services orchestrés via `docker-compose` :

| Service | Image | Port | Rôle |
|---|---|---|---|
| `database` | mysql:8.0 | 3306 | Stockage des véhicules |
| `lab-bash` | debian:stable-slim | - | Laboratoire Bash interactif |
| `web` | httpd:2.4 | 8080 | Serveur HTTP Apache |

**Démarrage :**
```bash
docker-compose up -d
```

**Vérifier l'état :**
```bash
docker-compose ps
```

**Accéder aux services :**
```bash
# Apache (navigateur)
http://localhost:8080

# Conteneur Debian
docker exec -it debian_lab bash

# Base MySQL
docker exec -it garage_mysql mysql -u root -p
# mot de passe : root_password_fst
```

**Tester les procédures CRUD :**
```sql
USE garage;
CALL lister_vehicules();
CALL ajouter_vehicule('7890-IJ-05', 'Peugeot', '208', 2023, 5000);
CALL modifier_kilometrage('1234-AB-01', 150000);
CALL supprimer_vehicule('5678-CD-02');
```

**Arrêter proprement :**
```bash
docker-compose down
```

---

## 👥 Équipe et matrice de contribution

| Étudiant | ID | Tâches principales |
|---|---|---|
| Hamady Abdel Malick | 12530133 | Scripting Bash + Simulation CPU |
| Mohamed Vall Ebbou | 12530162 | Dockerisation + MySQL + Apache |
| Rédaction du rapport et vidéo | — | Travail collectif |

---

## 📦 Pré-requis

- Docker + Docker Compose
- Python 3 avec `matplotlib`
- Bash (système Linux ou WSL2 sur Windows)

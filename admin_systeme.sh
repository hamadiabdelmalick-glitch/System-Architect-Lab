#!/bin/bash
# =============================================================
# admin_systeme.sh
# Étape 1 : Automatisation Shell
# Auteurs : Groupe System Architect Lab - LIU 2026
# =============================================================
# Ce script automatise :
#  1. La gestion des comptes utilisateurs (création / suppression)
#  2. La configuration des privilèges d'accès (chmod / chown)
#  3. La gestion d'un quota disque simplifié sur un dossier
#  4. La gestion CRUD d'une flotte de véhicules (theme du projet)
# =============================================================

FILE="vehicules.txt"
DATA_DIR="/var/garage_data"

# Création du fichier de données s'il n'existe pas
touch "$FILE"

# -------------------------------------------------------------
# 1. Gestion des utilisateurs
# -------------------------------------------------------------
creer_utilisateur() {
    read -p "Nom du nouvel utilisateur : " username
    if id "$username" &>/dev/null; then
        echo "[!] L'utilisateur '$username' existe déjà."
    else
        useradd -m -s /bin/bash "$username" 2>/dev/null \
            && echo "[OK] Utilisateur '$username' créé." \
            || echo "[!] Échec (lancez le script avec sudo)."
    fi
}

supprimer_utilisateur() {
    read -p "Nom de l'utilisateur à supprimer : " username
    if id "$username" &>/dev/null; then
        userdel -r "$username" 2>/dev/null \
            && echo "[OK] Utilisateur '$username' supprimé." \
            || echo "[!] Échec (lancez le script avec sudo)."
    else
        echo "[!] Utilisateur introuvable."
    fi
}

# -------------------------------------------------------------
# 2. Privilèges d'accès (chmod / chown)
# -------------------------------------------------------------
configurer_privileges() {
    read -p "Chemin du fichier ou dossier : " chemin
    read -p "Propriétaire (utilisateur) : " proprio
    read -p "Permissions (ex: 750) : " perms
    if [ ! -e "$chemin" ]; then
        echo "[!] Chemin inexistant."
        return
    fi
    chown "$proprio":"$proprio" "$chemin" 2>/dev/null \
        && echo "[OK] Propriétaire : $proprio" \
        || echo "[!] chown a échoué."
    chmod "$perms" "$chemin" 2>/dev/null \
        && echo "[OK] Permissions : $perms" \
        || echo "[!] chmod a échoué."
}

# -------------------------------------------------------------
# 3. Quota disque (version simplifiée par taille de dossier)
# -------------------------------------------------------------
verifier_quota() {
    read -p "Dossier à surveiller [$DATA_DIR] : " dossier
    dossier=${dossier:-$DATA_DIR}
    read -p "Quota maximum en Mo : " quota_mo
    if [ ! -d "$dossier" ]; then
        echo "[!] Dossier inexistant. Création..."
        mkdir -p "$dossier" 2>/dev/null || { echo "[!] Permission refusée."; return; }
    fi
    taille_ko=$(du -sk "$dossier" 2>/dev/null | cut -f1)
    taille_mo=$((taille_ko / 1024))
    echo "Taille actuelle : ${taille_mo} Mo / ${quota_mo} Mo"
    if [ "$taille_mo" -ge "$quota_mo" ]; then
        echo "[!] QUOTA DÉPASSÉ"
    else
        echo "[OK] Quota respecté."
    fi
}

# -------------------------------------------------------------
# 4. CRUD : Gestion d'une flotte de véhicules
# -------------------------------------------------------------
ajouter_vehicule() {
    read -p "Immatriculation : " imm
    read -p "Marque : " marque
    read -p "Modèle : " modele
    read -p "Année : " annee
    read -p "Kilométrage : " km
    echo "$imm | $marque | $modele | $annee | $km" >> "$FILE"
    echo "[OK] Véhicule ajouté."
}

afficher_vehicules() {
    echo "===== FLOTTE DE VÉHICULES ====="
    if [ ! -s "$FILE" ]; then
        echo "(aucun véhicule enregistré)"
    else
        printf "%-12s %-10s %-12s %-6s %-10s\n" "IMMAT" "MARQUE" "MODELE" "ANNEE" "KM"
        echo "-------------------------------------------------------"
        awk -F'|' '{printf "%-12s %-10s %-12s %-6s %-10s\n", $1, $2, $3, $4, $5}' "$FILE"
    fi
}

supprimer_vehicule() {
    read -p "Immatriculation à supprimer : " imm
    if grep -q "^$imm " "$FILE"; then
        grep -v "^$imm " "$FILE" > temp.txt && mv temp.txt "$FILE"
        echo "[OK] Véhicule supprimé."
    else
        echo "[!] Immatriculation introuvable."
    fi
}

rechercher_vehicule() {
    read -p "Mot-clé à rechercher : " mot
    resultat=$(grep -i "$mot" "$FILE")
    if [ -z "$resultat" ]; then
        echo "[!] Aucun résultat."
    else
        echo "$resultat"
    fi
}

# -------------------------------------------------------------
# Menu principal
# -------------------------------------------------------------
while true; do
    echo ""
    echo "============================================"
    echo "  ADMINISTRATION SYSTEME - GARAGE LIU 2026"
    echo "============================================"
    echo " --- Administration ---"
    echo "  1. Créer un utilisateur"
    echo "  2. Supprimer un utilisateur"
    echo "  3. Configurer privilèges (chmod/chown)"
    echo "  4. Vérifier quota disque"
    echo " --- Gestion des véhicules ---"
    echo "  5. Ajouter un véhicule"
    echo "  6. Afficher les véhicules"
    echo "  7. Supprimer un véhicule"
    echo "  8. Rechercher un véhicule"
    echo " --- Système ---"
    echo "  9. Quitter"
    read -p "Choix : " choix

    case $choix in
        1) creer_utilisateur ;;
        2) supprimer_utilisateur ;;
        3) configurer_privileges ;;
        4) verifier_quota ;;
        5) ajouter_vehicule ;;
        6) afficher_vehicules ;;
        7) supprimer_vehicule ;;
        8) rechercher_vehicule ;;
        9) echo "Au revoir."; exit 0 ;;
        *) echo "[!] Choix invalide." ;;
    esac
done

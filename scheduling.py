#!/usr/bin/env python3
# =============================================================
# scheduling.py
# Étape 2 : Modélisation d'Ordonnancement
# Comparatif SRTF vs Round Robin
# - Calcul du Temps d'Attente Moyen (TAM)
# - Génération automatique des diagrammes de Gantt
# =============================================================

import matplotlib
matplotlib.use("Agg")  # backend non-interactif (fonctionne dans un conteneur)
import matplotlib.pyplot as plt

# =============================================================
# Jeu de processus partagé entre les deux algorithmes
# =============================================================
PROCESSES = ["P1", "P2", "P3", "P4"]
ARRIVAL   = [0, 1, 2, 3]
BURST     = [8, 4, 9, 5]
QUANTUM   = 3


# =============================================================
# 1. Round Robin
# =============================================================
def round_robin(processes, arrival, burst, quantum):
    n = len(processes)
    remaining = burst[:]
    timeline = []          # liste de tuples (process, start, end)
    completion = [0] * n
    time = 0
    queue = []
    visited = [False] * n

    # On enfile les processus arrivés à t=0
    for i in range(n):
        if arrival[i] <= time:
            queue.append(i)
            visited[i] = True

    while queue:
        i = queue.pop(0)
        exec_time = min(quantum, remaining[i])
        timeline.append((processes[i], time, time + exec_time))
        time += exec_time
        remaining[i] -= exec_time

        # Ajout des nouveaux processus arrivés pendant l'exécution
        for j in range(n):
            if not visited[j] and arrival[j] <= time:
                queue.append(j)
                visited[j] = True

        if remaining[i] > 0:
            queue.append(i)
        else:
            completion[i] = time

    waiting = [completion[i] - arrival[i] - burst[i] for i in range(n)]
    return timeline, waiting


# =============================================================
# 2. SRTF (Shortest Remaining Time First)
# =============================================================
def srtf(processes, arrival, burst):
    n = len(processes)
    remaining = burst[:]
    timeline = []
    completion = [0] * n
    time = 0
    completed = 0
    last = -1
    start_segment = 0

    while completed < n:
        # On choisit le processus arrivé ayant le temps restant minimal (> 0)
        idx = -1
        min_rem = float("inf")
        for i in range(n):
            if arrival[i] <= time and remaining[i] > 0 and remaining[i] < min_rem:
                min_rem = remaining[i]
                idx = i

        if idx == -1:
            # CPU idle
            time += 1
            continue

        # Détection d'un changement de processus pour le diagramme
        if idx != last:
            if last != -1:
                timeline.append((processes[last], start_segment, time))
            start_segment = time
            last = idx

        remaining[idx] -= 1
        time += 1

        if remaining[idx] == 0:
            completed += 1
            completion[idx] = time
            timeline.append((processes[idx], start_segment, time))
            last = -1

    waiting = [completion[i] - arrival[i] - burst[i] for i in range(n)]
    return timeline, waiting


# =============================================================
# 3. Génération d'un diagramme de Gantt
# =============================================================
def tracer_gantt(timeline, titre, fichier_sortie, processes):
    fig, ax = plt.subplots(figsize=(10, 3))
    couleurs = {p: c for p, c in zip(processes, ["#4A90E2", "#E27D60", "#85DCB0", "#E8A87C", "#C38D9E"])}

    for nom, debut, fin in timeline:
        ax.barh(0, fin - debut, left=debut, height=0.5,
                color=couleurs.get(nom, "#888"), edgecolor="black")
        ax.text((debut + fin) / 2, 0, nom, ha="center", va="center",
                color="white", fontsize=10, fontweight="bold")

    fin_total = timeline[-1][2]
    ax.set_xlim(0, fin_total + 1)
    ax.set_xticks(range(0, fin_total + 1))
    ax.set_yticks([])
    ax.set_xlabel("Temps")
    ax.set_title(titre)
    plt.tight_layout()
    plt.savefig(fichier_sortie, dpi=150)
    plt.close()
    print(f"[OK] Diagramme enregistré : {fichier_sortie}")


# =============================================================
# 4. Affichage texte des résultats
# =============================================================
def afficher_resultats(nom_algo, timeline, waiting, processes):
    print(f"\n===== {nom_algo} =====")
    print("Chronologie d'exécution :")
    for nom, debut, fin in timeline:
        print(f"  {nom} : {debut} -> {fin}")

    print("\nTemps d'attente :")
    for i, p in enumerate(processes):
        print(f"  {p} = {waiting[i]}")

    tam = sum(waiting) / len(waiting)
    print(f"\nTemps d'Attente Moyen ({nom_algo}) = {tam:.2f}")
    return tam


# =============================================================
# 5. Programme principal
# =============================================================
if __name__ == "__main__":
    print("=============================================")
    print("  ÉTAPE 2 : Comparatif SRTF vs Round Robin")
    print("=============================================")
    print(f"Processus   : {PROCESSES}")
    print(f"Arrivées    : {ARRIVAL}")
    print(f"Bursts      : {BURST}")
    print(f"Quantum (RR): {QUANTUM}")

    # Round Robin
    tl_rr, w_rr = round_robin(PROCESSES, ARRIVAL, BURST, QUANTUM)
    tam_rr = afficher_resultats("ROUND ROBIN", tl_rr, w_rr, PROCESSES)
    tracer_gantt(tl_rr, "Diagramme de Gantt - Round Robin",
                 "gantt_round_robin.png", PROCESSES)

    # SRTF
    tl_srtf, w_srtf = srtf(PROCESSES, ARRIVAL, BURST)
    tam_srtf = afficher_resultats("SRTF", tl_srtf, w_srtf, PROCESSES)
    tracer_gantt(tl_srtf, "Diagramme de Gantt - SRTF",
                 "gantt_srtf.png", PROCESSES)

    # Conclusion
    print("\n=============================================")
    print("              CONCLUSION")
    print("=============================================")
    print(f"  TAM Round Robin = {tam_rr:.2f}")
    print(f"  TAM SRTF        = {tam_srtf:.2f}")
    meilleur = "SRTF" if tam_srtf < tam_rr else "Round Robin"
    print(f"  -> Algorithme le plus efficace : {meilleur}")

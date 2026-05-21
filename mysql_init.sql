-- =============================================================
-- mysql_init.sql
-- Étape 3 : Initialisation de la base 'garage' et procédures CRUD
-- =============================================================

CREATE DATABASE IF NOT EXISTS garage;
USE garage;

-- -------------------------------------------------------------
-- Table : vehicules
-- -------------------------------------------------------------
DROP TABLE IF EXISTS vehicules;

CREATE TABLE vehicules (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    immatriculation VARCHAR(20) NOT NULL UNIQUE,
    marque          VARCHAR(50) NOT NULL,
    modele          VARCHAR(50) NOT NULL,
    annee           INT NOT NULL,
    kilometrage     INT NOT NULL DEFAULT 0,
    cree_le         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- Données de démonstration
-- -------------------------------------------------------------
INSERT INTO vehicules (immatriculation, marque, modele, annee, kilometrage) VALUES
    ('1234-AB-01', 'Toyota',     'Hilux',   2018, 145000),
    ('5678-CD-02', 'Renault',    'Clio',    2020,  60000),
    ('9012-EF-03', 'Hyundai',    'Tucson',  2022,  25000),
    ('3456-GH-04', 'Mercedes',   'Sprinter',2017, 210000);

-- =============================================================
-- Procédures stockées : CRUD
-- =============================================================

DELIMITER //

-- CREATE -----------------------------------------------------
DROP PROCEDURE IF EXISTS ajouter_vehicule //
CREATE PROCEDURE ajouter_vehicule(
    IN p_imm VARCHAR(20),
    IN p_marque VARCHAR(50),
    IN p_modele VARCHAR(50),
    IN p_annee INT,
    IN p_km INT
)
BEGIN
    INSERT INTO vehicules (immatriculation, marque, modele, annee, kilometrage)
    VALUES (p_imm, p_marque, p_modele, p_annee, p_km);
END //

-- READ -------------------------------------------------------
DROP PROCEDURE IF EXISTS lister_vehicules //
CREATE PROCEDURE lister_vehicules()
BEGIN
    SELECT id, immatriculation, marque, modele, annee, kilometrage
    FROM vehicules
    ORDER BY id;
END //

-- UPDATE -----------------------------------------------------
DROP PROCEDURE IF EXISTS modifier_kilometrage //
CREATE PROCEDURE modifier_kilometrage(
    IN p_imm VARCHAR(20),
    IN p_nouveau_km INT
)
BEGIN
    UPDATE vehicules
    SET kilometrage = p_nouveau_km
    WHERE immatriculation = p_imm;
END //

-- DELETE -----------------------------------------------------
DROP PROCEDURE IF EXISTS supprimer_vehicule //
CREATE PROCEDURE supprimer_vehicule(IN p_imm VARCHAR(20))
BEGIN
    DELETE FROM vehicules WHERE immatriculation = p_imm;
END //

DELIMITER ;

-- =============================================================
-- Test rapide (visible dans les logs MySQL au démarrage)
-- =============================================================
SELECT '--- Vehicules initiaux ---' AS info;
CALL lister_vehicules();

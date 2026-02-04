# Projet-Base-de-Donn-es-Avanc-es-SQL-Server
Base de donnée avancée
Fichier README : Projet d'Intégration de Données Ontario 511
Date de génération du document : 2026-02-04
1. L'énoncé du problème
La gestion du réseau routier de l'Ontario nécessite un accès constant à des informations fiables et à jour sur les conditions de circulation, les travaux, les incidents et les événements. Les données brutes, bien que disponibles via l'API Ontario 511, sont souvent dispersées et nécessitent un traitement complexe pour être transformées en informations exploitables.
L'objectif de ce projet est de  concevoir et mettre en œuvre un système d'intégration de données entièrement automatisé, robuste et centralisé. Ce système doit collecter, nettoyer, stocker et analyser les données routières de l'Ontario pour fournir des indicateurs de performance (KPI) et des rapports analytiques pertinents. La finalité est de doter les décideurs (ex: Ministère des Transports, gestionnaires de la circulation) d'un outil puissant pour le suivi en temps réel, l'analyse des tendances et la prise de décision stratégique, sans dépendre de scripts externes ou de processus manuels.
2. Métriques de succès
Le succès de ce projet est mesuré par les critères quantitatifs et qualitatifs suivants :
•	Fiabilité de l'automatisation :  Le job SQL Server Agent doit s'exécuter avec succès toutes les 2 heures, avec un taux de réussite supérieur à 99.9%. Le journal LogsExecution sert de preuve d'exécution et de diagnostic.
•	Intégrité des données :  Un taux d'erreur d'importation inférieur à 0.1%. Les contraintes de la base de données ( NOT NULL, CHECK) et les mécanismes de validation ( MERGE) doivent empêcher l'insertion de données corrompues ou dupliquées.
•	Performance du système :  Le temps d'exécution complet du job d'importation et de traitement doit rester inférieur à un seuil défini (par exemple, 10 minutes), garantissant que le système est prêt pour le cycle suivant sans chevauchement.
•	Pertinence des rapports :  Les procédures de rapport ( GenererRapport...) doivent produire des résultats cohérents, précis et immédiatement exploitables, répondant aux questions métier clés (ex: quelle est la rue la plus encombrée par les travaux ?).
•	Maintenabilité et audit :  La capacité à tracer l'historique des modifications (via la table HistoriqueEvenements) et à diagnostiquer rapidement les échecs (via LogsExecution) est un indicateur clé de la robustesse et de la maintenabilité du système.
3. L'ensemble de données
Les données proviennent de l'API  Ontario 511, un service gouvernemental fournissant des informations sur les transports et la circulation dans la province de l'Ontario. Pour ce projet, nous supposons qu'un processus externe interroge cette API et dépose les données sous forme de quatre fichiers CSV distincts.
Ces fichiers ont été choisis car ils couvrent les aspects les plus critiques de la gestion routière :
Fichier CSV	Description	Justification du choix
evenements.csv	Événements routiers en temps réel (accidents, fermetures, dangers).	Essentiel pour la gestion des incidents et la sécurité des usagers.
constructions.csv	Travaux routiers planifiés ou en cours.	Crucial pour la planification des trajets et la gestion des perturbations à long terme.
cameras.csv	Emplacement et métadonnées des caméras de surveillance.	Permet une surveillance visuelle et l'analyse de la couverture de surveillance du réseau.
roadcondition.csv	Conditions météorologiques et de surface de la route.	Vital pour la sécurité en hiver et l'adaptation des stratégies d'entretien.
4. Hypothèses
Le développement de ce système repose sur les hypothèses suivantes :
•	Disponibilité des fichiers :  Les quatre fichiers CSV sont déposés de manière régulière (toutes les 2 heures) dans le répertoire cible : C:\Ontario511_Data\Imports\.
•	Permissions d'accès :  Le compte de service exécutant SQL Server dispose des permissions de lecture sur le répertoire mentionné ci-dessus.
•	Format des fichiers :  Les fichiers respectent un format constant : encodage UTF-8, séparateur virgule ( ,), présence d'une ligne d'en-tête, et gestion des valeurs manquantes par des chaînes vides.
•	Stabilité de la structure :  La structure des colonnes dans les fichiers CSV ne change pas sans une mise à jour correspondante des scripts d'importation.
•	Fiabilité du processus externe :  Le processus qui génère et dépose les fichiers CSV est considéré comme fiable et n'est pas géré dans le cadre de ce projet.
5. Notre Processus : Architecture et Implémentation
Le projet est entièrement contenu dans  SQL Server, exploitant ses fonctionnalités natives pour créer un pipeline ETL (Extract, Transform, Load) et d'analyse complet.
5.1. Architecture Globale
L'architecture est centrée sur le  SQL Server Agent, qui orchestre l'ensemble du processus. Aucune dépendance externe (comme Python ou SSIS) n'est requise, ce qui simplifie le déploiement et la maintenance.
1. Source :  Fichiers CSV dans un dossier partagé.
2. Ingestion :  Un Job SQL planifié utilise la commande BULK INSERT pour charger les données dans des tables de transit (temporaires).
3. Transformation & Chargement :  Des procédures stockées valident, nettoient et transfèrent les données vers les tables de production en utilisant la logique MERGE pour gérer les insertions et mises à jour.
4. Archivage & Audit :  Des triggers et des procédures dédiées gèrent l'historisation des données modifiées et l'archivage des enregistrements obsolètes.
5. Analyse :  Des procédures de rapport et des fonctions calculent des KPI et génèrent des analyses métier à la demande.
6. Journalisation :  Chaque étape est journalisée dans la table LogsExecution, assurant une traçabilité complète.
5.2. Schéma Relationnel
Le modèle est principalement dénormalisé pour optimiser les performances des requêtes d'analyse. Les relations clés sont limitées à des fins de traçabilité.
Table	Rôle
Evenements, Constructions, Cameras, RoadCondition	Tables principales stockant les données métier actuelles.
HistoriqueEvenements	Archive des événements terminés, modifiés ou supprimés pour l'audit.
Statistiques	Stocke les indicateurs de performance clés (KPI) calculés périodiquement.
LogsExecution	Journal de toutes les exécutions du job d'importation, avec statut (Succès/Échec) et messages.
Contraintes notables :  PRIMARY KEY sur chaque table, NOT NULL pour les champs critiques, CHECK pour la validation des données (ex: latitude/longitude), et DEFAULT GETDATE() pour les timestamps de création.
5.3. Composants SQL Clés
Procédures Stockées
•	ImporterDonneesDepuisTemp(@Type): Cœur du processus ETL, transfère les données des tables temporaires vers les tables cibles.
•	ArchiverEvenementsObsoletes(): Nettoie la table Evenements en déplaçant les enregistrements terminés vers HistoriqueEvenements.
•	CalculerIndicateursKPI(): Met à jour la table Statistiques avec des métriques comme le nombre total d'événements, la durée moyenne, etc.
•	GenererRapport[...]: Une suite de procédures pour extraire des insights (ex: GenererRapportRuePlusCamera, GenererRapportConditionParRegion).
Triggers
•	TR_HistoriqueEvenements: Sur UPDATE ou DELETE de la table Evenements, copie l'ancienne version de la ligne dans HistoriqueEvenements.
•	TR_UpdateTimestamp: Met à jour automatiquement le champ DateModification lors d'une mise à jour sur les tables métier.
•	TR_MiseAJourStatistiques: Déclenche la procédure CalculerIndicateursKPI() après une insertion pour maintenir les statistiques à jour.
Fonctions
•	fn_NombreEvenementsParJour(@Date): Retourne le nombre d'événements actifs pour une date donnée.
•	fn_ConditionDominanteParRue(@RoadwayName): Retourne la condition météo la plus fréquente pour une rue spécifique.
6. Défis et Solutions
Défi	Solution Implémentée
Chargement performant de gros volumes de données CSV.	Utilisation de la commande BULK INSERT, optimisée nativement par SQL Server pour des importations massives et rapides, bien plus efficace qu'une insertion ligne par ligne.
Gestion efficace des doublons et des mises à jour  lors de l'importation.	Implémentation de l'instruction MERGE dans la procédure ImporterDonneesDepuisTemp. Elle permet de gérer en une seule opération atomique les cas d'insertion ( WHEN NOT MATCHED) et de mise à jour ( WHEN MATCHED).
Assurer la robustesse et la journalisation  de l'ensemble du processus automatisé.	Encapsulation de chaque étape critique dans des blocs TRY...CATCH. En cas d'erreur, celle-ci est capturée et une entrée détaillée est insérée dans la table LogsExecution avec le statut "Échec", permettant un diagnostic rapide.
Maintenir un historique des modifications  pour l'audit et l'analyse des tendances.	Création d'un trigger ( TR_HistoriqueEvenements) qui se déclenche après chaque mise à jour ou suppression sur la table Evenements et insère une copie de l'enregistrement dans la table HistoriqueEvenements avec le type d'action.
Garder les indicateurs de performance (KPI) à jour  en quasi-temps réel.	Mise en place d'une double stratégie : la procédure CalculerIndicateursKPI() est appelée à la fin de chaque job d'importation, mais aussi déclenchée par un trigger ( TR_MiseAJourStatistiques) lors d'insertions, garantissant la fraîcheur des données.
7. Conclusions Finales et Impact Commercial
Ce projet démontre avec succès qu'il est possible de construire un système d'intégration et d'analyse de données sophistiqué en utilisant  exclusivement les fonctionnalités de SQL Server. La solution est non seulement automatisée et robuste, mais aussi performante et facile à maintenir grâce à son architecture centralisée.
Principaux Enseignements
•	L'exploitation judicieuse de BULK INSERT, des procédures stockées, des triggers et du SQL Server Agent permet de remplacer des solutions ETL externes plus complexes.
•	Une bonne stratégie de journalisation ( LogsExecution) et d'archivage ( HistoriqueEvenements) est fondamentale pour la fiabilité et l'auditabilité d'un système de données.
•	La séparation de la logique en modules (procédures, fonctions) rend le système évolutif et plus facile à déboguer.
Impact Commercial et Opérationnel
Pour une organisation comme le Ministère des Transports de l'Ontario, l'impact est direct et significatif :
•	Prise de décision éclairée :  Les rapports générés (ex: EXEC GenererRapportConditionParRegion;) fournissent une vision synthétique et immédiate de l'état du réseau, permettant d'allouer les ressources de maintenance (déneigement, réparations) plus efficacement.
•	Amélioration de la sécurité publique :  L'analyse des événements ( EXEC RechercherEvenementsFiltres @Type = 'Accident') aide à identifier les zones à haut risque et à mettre en place des mesures préventives.
•	Optimisation de la planification :  Le suivi des chantiers ( EXEC GenererRapportRuePlusConstruction;) permet de mieux communiquer sur les perturbations et de coordonner les travaux futurs.
•	Gain d'efficacité :  L'automatisation complète du processus libère des ressources humaines qui peuvent se concentrer sur l'analyse des données plutôt que sur leur collecte et leur nettoyage.
En résumé, ce système transforme des données brutes en intelligence stratégique, offrant un avantage concurrentiel tangible dans la gestion d'une infrastructure routière complexe.

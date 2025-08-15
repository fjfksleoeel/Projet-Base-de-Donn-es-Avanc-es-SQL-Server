USE Ontario511;
GO

-- Activer xp_cmdshell si tu veux vérifier les fichiers (optionnel)
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
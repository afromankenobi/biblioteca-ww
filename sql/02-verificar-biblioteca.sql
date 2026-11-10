USE [master];
GO
SELECT name, type_desc, default_database_name
FROM sys.server_principals WHERE name = N'AdminBiblioteca';
SELECT name, SUSER_SNAME(owner_sid) AS Propietario
FROM sys.databases WHERE name = N'BibliotecaDB';
SELECT SERVERPROPERTY('ProductVersion') AS VersionSQL,
       SERVERPROPERTY('IsIntegratedSecurityOnly') AS SoloAutenticacionWindows;
GO
USE [BibliotecaDB];
GO
SELECT c.name AS Columna, t.name AS Tipo, c.max_length AS LongitudBytes,
       c.is_nullable AS PermiteNulos, c.is_identity AS EsIdentity,
       ic.seed_value AS Inicio, ic.increment_value AS Incremento
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
LEFT JOIN sys.identity_columns ic ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE c.object_id = OBJECT_ID(N'dbo.Libros')
ORDER BY c.column_id;
SELECT i.name AS ClavePrimaria, c.name AS Columna
FROM sys.indexes i
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID(N'dbo.Libros') AND i.is_primary_key = 1;
SELECT Id, NombreLibro, Autor, NumPaginas, FechaPublicacion FROM dbo.Libros ORDER BY Id;
GO

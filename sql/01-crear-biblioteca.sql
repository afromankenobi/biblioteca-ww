-- Ejecutar con una cuenta administradora en una instancia SQL Server de laboratorio.
-- Credenciales de práctica exigidas por la pauta; no usarlas en producción.
-- El script no borra bases, no vacía tablas y no cambia contraseñas existentes.
USE [master];
GO
IF CONVERT(int, SERVERPROPERTY('IsIntegratedSecurityOnly')) = 1
    THROW 50001, 'La instancia debe admitir SQL Server Authentication (modo mixto).', 1;
GO
IF SUSER_ID(N'AdminBiblioteca') IS NULL
    CREATE LOGIN [AdminBiblioteca] WITH PASSWORD = 'Admin12345',
        DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
GO
IF DB_ID(N'BibliotecaDB') IS NULL
    CREATE DATABASE [BibliotecaDB];
GO
-- Solo se cambia la propiedad en una base vacía recién preparada para esta actividad.
IF SUSER_SNAME((SELECT owner_sid FROM sys.databases WHERE name = N'BibliotecaDB')) <> N'AdminBiblioteca'
BEGIN
    IF EXISTS (SELECT 1 FROM BibliotecaDB.sys.tables WHERE is_ms_shipped = 0)
        THROW 50002, 'BibliotecaDB ya contiene tablas y pertenece a otra cuenta. Revisar antes de continuar.', 1;
    ALTER AUTHORIZATION ON DATABASE::[BibliotecaDB] TO [AdminBiblioteca];
END;
GO
USE [BibliotecaDB];
GO
IF OBJECT_ID(N'dbo.Libros', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Libros
    (
        Id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Libros PRIMARY KEY,
        NombreLibro varchar(50) NOT NULL,
        Autor varchar(50) NOT NULL,
        NumPaginas int NOT NULL,
        FechaPublicacion date NOT NULL
    );
END;
GO

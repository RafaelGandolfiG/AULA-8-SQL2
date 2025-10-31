--15_exercicio_triggers.sql

IF NOT EXISTS (
	SELECT 1 FROM sys.databases
	WHERE name = 'triggers'
	)
	CREATE DATABASE triggers;
GO

USE triggers;
GO

IF OBJECT_ID('usuarios','U') IS NOT NULL
	DROP TABLE usuarios;
GO

IF OBJECT_ID('auditoria_usuarios','U') IS NOT NULL
	DROP TABLE auditoria_usuarios;
GO

IF OBJECT_ID('trg_auditoriaInsercao','TR') IS NOT NULL
	DROP TRIGGER trg_auditoriaInsercao;
GO

CREATE TABLE usuarios(
	id_usuario INT PRIMARY KEY,
	nome_usuario NVARCHAR(100),
	email_usuario NVARCHAR(100),
	senha_usuario NVARCHAR(100)
);
GO

CREATE TABLE auditoria_usuarios(
	id_auditoria INT PRIMARY KEY IDENTITY(1,1),
	id_usuario INT,
	operacao NVARCHAR(10),
	data_operacao DATETIME,
	nome_usuario NVARCHAR(100)
);

--------------------TRIGGERS-------------------------

CREATE TRIGGER trg_auditoriaInsercao
	ON usuarios
	AFTER INSERT
	AS
	BEGIN
		INSERT INTO auditoria_usuarios
			(id_usuario,operacao,data_operacao,nome_usuario)
		SELECT id_usuario, 'INSERT', GETDATE(), SYSTEM_USER
		FROM inserted;
		PRINT 'OPERAÇÃO DE INSERIR REALIZADA COM SUCESSO!!';
	END;
GO

---------------------TESTES-------------------------------
INSERT INTO usuarios (id_usuario,nome_usuario,email_usuario,senha_usuario)
VALUES
(1,'rafael','rafael@gmail.com','Fera2007'),
(2,'caio','caio@gmail.com','Fera2008'),
(3,'rodrigo','rodrigo@gmail.com','Fera2009'),
(4,'gustavo','gustavo@gmail.com','Fera2010');
--------------------EXIBIR RESULTADOS----------------------
SELECT * FROM usuarios;
SELECT * FROM auditoria_usuarios;
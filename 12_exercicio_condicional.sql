--12_exercicio_condicional.sql

USE db1410_alter_condicional;
GO

IF OBJECT_ID ('clientes', 'U') IS NULL
	BEGIN
	PRINT 'A TABELA [CLIENTES] NAO EXISTE CRIANDO A TABELA...'
	CREATE TABLE clientes(
		cliente_id INT PRIMARY KEY,
		nome_cliente VARCHAR(100),
		data_cadastro DATETIME
		);
		PRINT 'TABELA [CLIENTES] CRIADA COM SUCESSO'
	END
ELSE
	BEGIN
		PRINT 'A TABELA [CLIENTES] JA EXISTE'
	END;
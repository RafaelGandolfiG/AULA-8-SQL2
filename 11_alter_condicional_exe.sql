--11_alter_condicoional_exe.sql

USE db1410_alter_condicional;
GO
--verifica se a tabela existe antes de tentar qualquer operação

IF OBJECT_ID('clientes','U') IS NOT NULL
	BEGIN
		PRINT ' A TABELA [CLIENTES] EXISTE!
		VERIFICANDO A QUANTIDADE DE DADOS...'
		DECLARE @num_dados INT;

		SELECT @num_dados = COUNT(*)
		FROM clientes
		WHERE nome_cliente IS NOT NULL;

		IF @num_dados=0
			BEGIN
				INSERT INTO clientes
				(cliente_id,nome_cliente,data_cadastro)
				VALUES
				(1, 'Caio','2025-01-01'),
				(2,'Gustavo','2025-01-02'),
				(3, 'Rodrigo','2025-01-03'),
				(4,'Rafael','2025-01-04');
				PRINT 'DADOS INSERIDOS COM SUCESSO'
			END
		ELSE
			BEGIN
				PRINT 'A TABELA JA POSSUI DADOS'
			END
	END
ELSE
	BEGIN
		PRINT 'A TABELA CLIENTES NAO EXISTE'
	END;

SELECT * FROM clientes
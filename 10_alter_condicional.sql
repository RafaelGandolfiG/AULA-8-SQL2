
CREATE DATABASE db1410_alter_condicional;
GO

USE db1410_alter_condicional;
GO

DROP TABLE IF EXISTS clientes;
CREATE TABLE clientes(
	cliente_id INT PRIMARY KEY,
	nome_cliente VARCHAR(100),
	data_cadastro DATETIME
);

INSERT INTO clientes
(cliente_id,nome_cliente,data_cadastro)
VALUES
(1, 'Caio','2025-01-01'),
(2,'Gustavo','2025-01-02'),
(3, 'Rodrigo','2025-01-03'),
(4,'Rafael','2025-01-04');

SELECT * FROM clientes

-----------contando e mostrando o total de dados -----------------
DECLARE @num_dados INT;

SELECT @num_dados=COUNT(*)
FROM clientes
WHERE nome_cliente IS NOT NULL;

PRINT 'Quantidade de dados na tabela: '+CAST(@num_dados AS VARCHAR);
-------------------------------------------------------------------

/*
Altera a coluna apenas se a quantidade de dados for zero
Um alter condicional
*/

IF @num_dados =0
	BEGIN
		ALTER TABLE clientes
		ALTER COLUMN nome_cliente TEXT;
		PRINT 'TIPO DE DADO ALTERADO PARA TEXT';
	END

ELSE
	BEGIN
	PRINT 'A COLUNA CONTEM DADOS E NAO PODE SER ALTERADA
	PARA UM NOVO TIPO'
	END

--verifica a estrutura da tabela com todos os detalhes
EXEC sp_columns 'clientes'

--verifica a estrutura da tabela mas com escolha do que deseja exibir
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME ='clientes'

----------------exercicio (que faremos juntos hehe)-------------------


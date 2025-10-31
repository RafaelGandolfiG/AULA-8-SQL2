--17_partcionamento.sql

CREATE DATABASE db1410_particionamento;
GO

USE db1410_particionamento;
GO

/*
Objetivo: Dividir as tabelas grandes em partiçoes menores
para melhorar desempenho e facilitar o gerenciamento de dados

O particionamento vai dividir a tabela com base em um valor
de coluna, nesse exemplo usaremos as datas
*/

IF EXISTS(SELECT * FROM sys.partition_schemes WHERE name = 'ps_ano')
	DROP PARTITION FUNCTION ps_ano;
GO

IF EXISTS (SELECT * FROM sys.partition_functions WHERE name = 'pf_ano')
	DROP PARTITION FUNCTION pf_ano;
GO

--criar a funçao de particionamento
--ela que define como tudo vai ser distribuido

CREATE PARTITION FUNCTION pf_ano (date)
AS RANGE RIGHT FOR VALUES(
	'2010-12-30',
	'2011-12-30',
	'2012-12-30',
	'2013-12-30',
	'2014-12-30',
	'2015-12-30'
);
GO

--criaremos um esquema de particionamento
--o esquema define como as partições serão distribuidas
--nao os dados (nao confundir)

CREATE PARTITION SCHEME ps_ano
AS PARTITION pf_ano
--cada partição será mapeada aqui no TO, nesse caso todas as partições
--estão sendo alocadas no PRIMARY! Mas cada uma em seu campo
TO (
	[PRIMARY],
	[PRIMARY],
	[PRIMARY],
	[PRIMARY],
	[PRIMARY],
	[PRIMARY],
	[PRIMARY]
	);

--agora vamos efetivamente criar a tabela usando o
--esquema de particionamento definido anteriormente

CREATE TABLE vendas(
	id INT NOT NULL,
	data DATE NOT NULL,
	valor DECIMAL(10,2),
	cliente_id INT,
	CONSTRAINT PK_vendas PRIMARY KEY NONCLUSTERED (id, data)
	)
	ON ps_ano (data);
GO

/*
inserir os dados na tabela particionada 
o sql vai colocar automaticamente os dados 
nas partições corretas conforme a coluna de data
*/

INSERT INTO vendas	
	(id, data, valor, cliente_id)
VALUES
	(1, '2010-01-01', 150, 101),
	(2, '2011-02-02', 170, 103),
	(3, '2012-01-03', 152, 104),
	(4, '2013-02-04', 130, 105),
	(5, '2014-01-05', 250, 107),
	(6, '2015-02-06', 550, 111),

	(7, '2010-01-01', 150, 101),
	(8, '2011-02-02', 170, 103),
	(9, '2013-01-03', 152, 104),
	(10, '2013-02-04', 130, 105),
	(11, '2014-01-05', 250, 107),
	(12, '2013-02-06', 550, 111);

--voce pode consultar a tabela normalmente, e o sql vai usar 
--a tabela particionada para acelerar a busca

SELECT * FROM vendas WHERE data='2013-02-04'
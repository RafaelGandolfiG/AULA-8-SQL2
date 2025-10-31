/*====================================

Topicos cobertos

-Idempotencia para montar o banco
-INNER / LEFT JOIN
-CASE WHEN
-WITH
-Funçoes de janela (ROW_NUMBER, RANK)
-ORDER BY e TOP (Equivalente ao limit)
-Subconsulta (Escalares)
-Agregação +GROUP BY + HAVING

======================================*/

---------------CRIANDO E USANDO O BANCO DE DADOS------------------
IF NOT EXISTS (SELECT 1 FROM sys.databases
	WHERE name= 'db1410_final')
	CREATE DATABASE db1410_final;
GO

USE db1410_final;
GO

-------lIMPEZA (IDEMPOTENCIA: RODA VARIAS VEZES SEM ERROS)-------
IF OBJECT_ID('dbo.ItensPedido')IS NOT NULL DROP TABLE dbo.ItensPedido;

IF OBJECT_ID('dbo.Pedidos')IS NOT NULL DROP TABLE dbo.Pedidos;

IF OBJECT_ID('dbo.Produtos')IS NOT NULL DROP TABLE dbo.Produtos;

IF OBJECT_ID('dbo.Clientes')IS NOT NULL DROP TABLE dbo.Clientes;

-------------------------CRIANDO AS TABELAS-----------------------
CREATE TABLE dbo.Clientes(
	ClienteID		INT IDENTITY (1,1) PRIMARY KEY,
	Nome			NVARCHAR(100) NOT NULL,
	Cidade			NVARCHAR(60) NULL
);

CREATE TABLE dbo.Produtos(
	ProdutoID		INT IDENTITY(1,1) PRIMARY KEY,
	Nome			NVARCHAR(100) NOT NULL,
	Categoria		NVARCHAR(50) NOT NULL,
	Preco			DECIMAL (10,2) NOT NULL CHECK (Preco>=0),
	Ativo			BIT NOT NULL DEFAULT 1
);

CREATE TABLE dbo.Pedidos(
	PedidoId		INT IDENTITY (1,1) PRIMARY KEY,
	ClienteID		INT NOT NULL,
	DataPedido		DATE NOT NULL,
	CONSTRAINT FK_Pedidos_Clientes
		FOREIGN KEY (ClienteID) REFERENCES dbo.Clientes(ClienteID)
);

CREATE TABLE dbo.ItensPedido(
	ItemID			INT IDENTITY (1,1) PRIMARY KEY,
	PedidoID		INT NOT NULL,
	ProdutoID		INT NOT NULL,
	Quantidade		INT NOT NULL CHECK (Quantidade>0),
	PrecoUnit		DECIMAL(10,2) NOT NULL CHECK (PrecoUnit>=0),
	CONSTRAINT FK_ItensPedidos
		FOREIGN KEY (PedidoID) REFERENCES dbo.Pedidos(PedidoID),
	CONSTRAINT FK_Itens_Produtos
		FOREIGN KEY (ProdutoID) REFERENCES dbo.Produtos(ProdutoID)
);

------------------------INSERINDO OS DADOS-------------------------------
--CLIENTES
INSERT INTO dbo.Clientes(Nome,Cidade)VALUES
	('Caio Rossi',		'São Paulo'),
	('Gustavo Duarte',	'Rio de Janeiro'),
	('Rafael Gandolfi',	'São Paulo'),
	('Rodrigo Mauri',	'Curitiba'),
	('Eduarda Ramos',	'São Paulo'),
	('Carla Lima',		'Rio de Janeiro');

--PRODUTOS
INSERT INTO dbo.Produtos(Nome, Categoria, Preco, Ativo) VALUES
	('Mouse Optico',		'Perifericos',	60.00,	1),
	('Teclado Mecanico',	'Perifericos',	350.00, 1),
	('Monitor 24',			'Monitores',	899.00,	1),
	('Cabo HDMI',			'Acessorios',	39.00,	1),
	('Notebook 14',			'Computadores',	2999.00,1),
	('Headset USB',			'Acessorios',	199.00,	1);

--PEDIDOS
INSERT INTO dbo.Pedidos (ClienteID, DataPedido) VALUES
	(1, DATEADD(DAY, -40, GETDATE())),
	(1, DATEADD(DAY, -10, GETDATE())),
	(2, DATEADD(DAY, -5, GETDATE())),
	(3, DATEADD(DAY, -70, GETDATE())),
	(4, DATEADD(DAY, -15, GETDATE()));

--ITENS (preço unitario é 'congelado' do produto no momento do pedido)
INSERT INTO dbo.ItensPedido (PedidoID, ProdutoID, Quantidade, PrecoUnit) VALUES
	--PEDIDO 1 (Caio - Há 40 dias)
		(1, 1, 1, 60.00), --Mouse
		(1, 4, 2, 39.00), --2x Cabo HDMI
	--PEDIDO 2 Gustavo - Há 10 dias)
		(2, 2, 1, 350.00), --Teclado
		(2, 3, 1, 899.00), --Monitor
	--PEDIDO 3 (Rafael - Há 5 dias)
		(3, 4, 3, 39.00), --3x cabo HDMI
		(3, 6, 1, 199.00), --Headset
	--PEDIDO 4 (Rodrigo - Há 70 dias)
		(4, 1, 2, 60.00), --2x Mouse
	--PEDIDO 5 (caio - Há 40 dias)
		(5, 5, 1, 2999.00); --Notebook

/*-------------------------------------------------------------
	2) Consulta Completa ( Unica com todos os pontos do Módulo)
	Objetivo: Gerar um relatório final por cliente com:
	1-total gasto, numero de pedidos e ticket medio
	2-produto mais comprado por cliente (função janela)
	3-classificação do cliente (case when)
	4-filtrar apenas clientes com gasto < media geral (having)
	5-mostrar tambem clientes sem pedido (LEFT JOIN)
	6-e garantir que o produto final do cliente tenha preço
	acima da media de preços (subconsulta escalar no where)
--------------------------------------------------------------*/


;WITH
	--2.1) 'Fato' de vendas (Inner Joins entre tabelas
Vendas AS(
	SELECT
		pe.PedidoID,
		pe.DataPedido,
		c.ClienteID,
		c.Nome AS NomeCliente,
		pr.ProdutoID,
		pr.Nome AS NomeProduto,
		pr.Categoria,
		it.Quantidade,
		it.PrecoUnit,
		CAST(it.Quantidade*it.PrecoUnit AS DECIMAL (10,2)) AS ValorItem
	FROM dbo.Pedidos AS pe
	INNER JOIN dbo.Clientes AS c ON c.ClienteID=pe.ClienteID
	INNER JOIN dbo.ItensPedido AS it ON it.PedidoID=pe.PedidoID
	INNER JOIN dbo.Produtos AS pr ON pr.ProdutoID=it.ProdutoID
),

	--2.2) Agregação por cliente (Group By +Having)
GastoPorCliente AS (
	SELECT
		v.ClienteID,
		MIN(v.NomeCliente) AS NomeCliente,
		COUNT(DISTINCT v.PedidoID) AS QtdePedidos,
		SUM(v.valorItem) AS TotalGasto,
		AVG(CAST(v.ValorItem AS DECIMAL (10,2))) AS TicketMedio
		FROM Vendas v
		GROUP BY v.ClienteID
		--Filtro de agregação(so quem gastou mais de 100)
		HAVING SUM (v.ValorItem)>100
),

	--2.3) Produto mais comprado por cliente
ProdutoTopPorCliente AS (
	SELECT
			v.ClienteID,
			v.ProdutoID,
			MIN(v.NomeProduto) AS NomeProduto,
			SUM(v.Quantidade) AS QtdeTotal,
			ROW_NUMBER() OVER(
				PARTITION BY v.ClienteID ORDER BY SUM(v.Quantidade) DESC) AS rn
				FROM Vendas v
				GROUP BY v.ClienteID, v.ProdutoID
),

	--2.4) Ranking global de produtos por volume
RankingProdutos AS (
	SELECT 
		v.ProdutoID,
		MIN(v.NomeProduto) AS NomeProduto,
		SUM(v.Quantidade) AS QtdeVendida,
		RANK() OVER(ORDER BY SUM(v.Quantidade) DESC) AS RankGlobal
	FROM Vendas v
	GROUP BY v.ProdutoID
),

	--2.5) Clientes com e sem pedido
ClientesComOuSemPedido AS (
	SELECT
		c.ClienteID,
		c.Nome AS NomeCliente,
		c.Cidade,
		CASE WHEN p.PedidoID IS NULL THEN 0 ELSE 1 END AS TemPedido
	FROM dbo.Clientes c
	--Left: mantem cliente mesmo sem pedido
	LEFT JOIN dbo.Pedidos p ON p.ClienteID = c.ClienteID
	GROUP BY c.ClienteID, c.Nome, c.Cidade,
		CASE WHEN p.PedidoId IS NULL THEN 0 ELSE 1 END
)

	--2.6) Select final (reune tudo)
SELECT TOP (10)--TOP= limit no sql server
	base.ClienteID,
	base.NomeCliente,
	base.Cidade,
	ISNULL(g.QtdePedidos, 0)	AS QtdePedidos,
	ISNULL(g.TotalGasto, 0.00)	AS TotalGasto,
	ISNULL(g.TicketMedio, 0.00)	AS TicketMedio,
	ISNULL(pt.NomeProduto, '---')	AS ProdutoTopCliente,
	ISNULL(rp.RankGlobal, NULL)	AS RankProdutoGlobal,
	--CASE WHEN para classificar o cliente por gasto
	CASE
		WHEN TotalGasto>=2000	THEN 'VIP'
		WHEN TotalGasto>=500	THEN 'BOM'
		WHEN TotalGasto>=0	THEN 'NOVO'
		ELSE 'SEM COMPRAS'
	END AS CategoriaCliente
	FROM ClientesComOuSemPedido AS base
	--Junta agregados( pode ser null se o cliente nao tiver nenhum pedido)
	LEFT JOIN GastoPorCliente g
		ON g.ClienteID=base.ClienteID
	--pega apenas o produto #1 por cliente (rn=1)
	LEFT JOIN ProdutoTopPorCliente pt
		ON pt.ClienteId=base.ClienteID AND pt.rn=1
	--Ranking Global do Produto top
	--(pode ser null se o cliente nao tiver produto top)
	LEFT JOIN RankingProdutos rp
		ON rp.ProdutoID=pt.ProdutoID
	WHERE (pt.ProdutoID IS NULL)--permite listar clientes sem compras 
		OR (pt.ProdutoID IS NOT NULL AND
		(SELECT AVG(Preco) FROM dbo.Produtos)<
		(SELECT Preco FROM dbo.Produtos WHERE ProdutoID=pt.ProdutoID))
	ORDER BY g.TotalGasto DESC;
GO


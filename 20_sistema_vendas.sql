------------------IDEMPOTENCIA DO BANCO DE DADOS-------------------
IF NOT EXISTS (SELECT 1 FROM sys.databases
WHERE name='db_sistemaVendas')
	CREATE DATABASE db_sistemaVendas;
GO

USE db_sistemaVendas;
GO

-----------------IDEMPOTENCIA DAS TABELAS----------------------

IF OBJECT_ID ('clientes', 'U') IS NOT NULL
DROP TABLE clientes;

IF OBJECT_ID ('produtos', 'U') IS NOT NULL
DROP TABLE produtos;

IF OBJECT_ID ('vendas', 'U') IS NOT NULL
DROP TABLE vendas;

IF OBJECT_ID ('auditoria_vendas', 'U') IS NOT NULL
DROP TABLE auditoria_vendas;

-------------------IDEMPOTENCIA DAS TRIGGERS----------------------

IF OBJECT_ID ('trg_VendasInsersao', 'TR') IS NOT NULL
DROP TABLE trg_vendasInsersao;

IF OBJECT_ID ('trg_VendasExclusao', 'TR') IS NOT NULL
DROP TABLE trg_VendasExclusao;

IF OBJECT_ID ('trg_VendasAtualizacao', 'TR') IS NOT NULL
DROP TABLE trg_VendasAtualizacao;

-----------------------CRIANDO AS TABELAS--------------------------

CREATE TABLE clientes(
	cliente_id INT PRIMARY KEY IDENTITY(1,1),
	nome_cliente VARCHAR(100),
	email_cliente VARCHAR(100),
	data_cadastro DATETIME DEFAULT GETDATE()
);

CREATE TABLE produtos(
	produto_id INT PRIMARY KEY IDENTITY(1,1),
	nome_produto VARCHAR (100) NOT NULL,
	preco DECIMAL (10,2) NOT NULL
);

CREATE TABLE vendas(
	venda_id INT PRIMARY KEY IDENTITY(1,1),
	cliente_id INT NOT NULL,
	produto_id INT NOT NULL,
	quantidade INT NOT NULL,
	valor_total DECIMAL (10,2),
	data_venda DATETIME DEFAULT GETDATE(),
	FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id) ON DELETE CASCADE,
	FOREIGN KEY (produto_id) REFERENCES produtos(produto_id) ON DELETE CASCADE
);

CREATE TABLE auditoria_vendas(
	 auditoia_id INT PRIMARY KEY IDENTITY(1,1),
	 venda_id INT,
	 cliente_id INT,
	 produto_id INT,
	 quantidade INT,
	 valor_total DECIMAL (10,2),
	 data_venda DATETIME,
	 operacao NVARCHAR(100),
	 data_operacao DATETIME DEFAULT GETDATE(),
	 usuario NVARCHAR(100) DEFAULT system_user
);
GO
------------------------CRIANDO AS TRIGGERS--------------------------------

CREATE TRIGGER trg_VendasInsersao
	ON vendas
	AFTER INSERT
	AS
	BEGIN
		INSERT INTO auditoria_vendas
		(venda_id,cliente_id,produto_id, quantidade,valor_total,data_venda,operacao)
		SELECT
		venda_id,cliente_id,produto_id, quantidade,valor_total,data_venda, 'INSERIDO'
		FROM inserted
	END;
GO

CREATE TRIGGER trg_VendasExclusao
	ON vendas
	AFTER DELETE
	AS 
	BEGIN
		INSERT INTO auditoria_vendas
		(venda_id,cliente_id,produto_id, quantidade,valor_total,data_venda,operacao)
		SELECT
		venda_id,cliente_id,produto_id, quantidade,valor_total,data_venda, 'EXCLUIDO'
		FROM deleted
	END;
GO

CREATE TRIGGER trg_VendasAtualizacao
	ON vendas
	AFTER UPDATE
	AS
	BEGIN
		INSERT INTO auditoria_vendas
		(venda_id,cliente_id,produto_id, quantidade,valor_total,data_venda,operacao)
		SELECT
		venda_id,cliente_id,produto_id, quantidade,valor_total,data_venda, 'ATUALIZADO'
		FROM inserted
	END;
GO

-------------------INSERINDO OS DADOS NAS TABELAS---------------------------

INSERT INTO clientes
	(nome_cliente,email_cliente)
VALUES
	('Caio','caio@gmail.com'),
	('Rodrigo','rodrigo@gmail.com'),
	('Rafael','rafael@gmail.com'),
	('Gustavo','gustavo@gmail.com');

INSERT INTO produtos
	(nome_produto,preco)
VALUES
	('Notebook', 3500.00),
	('Smartphone', 800.00),
	('TV 90 polegadas',1200.00),
	('Fone Cebrutius',240.00);

INSERT INTO vendas
	(cliente_id,produto_id,quantidade,valor_total)
VALUES
	(1,1,1,3500.00),
	(2,1,2,3500.00),
	(3,2,3,3500.00),
	(4,2,4,3500.00),
	(1,3,5,3500.00),
	(2,3,6,3500.00),
	(3,4,7,3500.00);

-----SELECTS PARA CONFIRMAR SE TUDO FOI INSERIDO COM SUCESSO--------

SELECT * FROM vendas
SELECT * FROM clientes
SELECT * FROM produtos
SELECT * FROM auditoria_vendas

------------------------------CONSULTAS----------------------------------

PRINT'------TOTAL DE VENDAS POR CLIENTE-------';
SELECT c.nome_cliente, SUM(v.valor_total) AS 'total de vendas'
FROM vendas v
JOIN clientes c ON v.cliente_id=c.cliente_id
GROUP BY c.nome_cliente
ORDER BY 'total de vendas' DESC;

PRINT '---------TOP 3 PRODUTOS MAIS VENDIDOS------------';
SELECT TOP 3 p.nome_produto , SUM(v.quantidade) AS 'total vendido'
FROM vendas v
JOIN produtos p ON v.produto_id=p.produto_id
GROUP BY p.nome_produto
ORDER BY 'total vendido' DESC;

PRINT '--------TOTAL DE VENDAS POR PRODUTO--------';
SELECT p.nome_produto, SUM(v.quantidade) AS 'total vendido', SUM(v.valor_total) AS 'valor total'
FROM produtos p
JOIN vendas v ON p.produto_id=v.produto_id
GROUP BY p.nome_produto
ORDER BY 'total vendido' DESC;


PRINT '---------TOP 3 CLIENTES QUE MAIS COMPRARAM--------';
SELECT TOP 3 c.nome_cliente, SUM(v.valor_total) AS 'total vendido'
FROM clientes c
JOIN vendas v ON c.cliente_id=v.cliente_id
GROUP BY c.nome_cliente
ORDER BY 'total vendido' DESC;

PRINT'-----------VALOR MEDIO POR CLIENTE------------';
SELECT c.nome_cliente, AVG(v.valor_total) AS 'media', COUNT(v.venda_id) as 'total'
FROM clientes c
JOIN VENDAS V ON c.cliente_id=v.cliente_id
GROUP BY c.nome_cliente
ORDER BY 'media' DESC;

PRINT'-------TOP 3 CLIENTES QUE MAIS COMPRARAM (QUANTIDADE)-------';
SELECT TOP 3 c.nome_cliente, SUM(v.quantidade) AS 'total vendido'
FROM clientes c
JOIN vendas v ON c.cliente_id=v.cliente_id
GROUP BY c.nome_cliente
ORDER BY 'total vendido' DESC;

-----------------------LUCRO SIMULADO-------------------------

ALTER TABLE  produtos ADD custo DECIMAL (10,2) NULL;
UPDATE produtos SET custo=preco*0.7-------custo estimado 70%

PRINT'------LUCRO ESTIMADO POR PRODUTO-------';
SELECT p.nome_produto, SUM(v.quantidade*(p.preco-p.custo)) AS 'total lucro'
FROM vendas v
JOIN produtos p ON v.produto_id=p.produto_id
GROUP BY p.nome_produto
ORDER BY 'total lucro' DESC;

-------------------------CRIANDO VIEWS------------------------------
PRINT'-------CRIANDO UMA VIEW PARA O RELATORIO-------';
CREATE VIEW vw_relatorio_vendas AS
	SELECT
		v.venda_id,
		c.nome_cliente,
		p.nome_produto,
		v.quantidade,
		p.preco,
		v.valor_total,
		v.data_venda
	FROM vendas v
	JOIN clientes c ON v.cliente_id=c.cliente_id
	JOIN produtos p ON v.produto_id=p.produto_id;
GO

SELECT * FROM vw_relatorio_vendas

PRINT'-------CRIANDO UMA VIEW PARA O TOTAL DE VENDAS POR CLIENTE-------';
CREATE VIEW vw_vendas_cliente AS
	SELECT c.nome_cliente, SUM(v.valor_total) AS 'total de vendas'
	FROM vendas v
	JOIN clientes c ON v.cliente_id=c.cliente_id
	GROUP BY c.nome_cliente;
GO

SELECT * FROM vw_vendas_cliente;

PRINT'-------CRIANDO UMA VIEW PARA TOP 3 PRODUTOS MAIS VENDIDOS-------';

PRINT'-------CRIANDO UMA VIEW PARA O RELATORIO-------';

PRINT'-------CRIANDO UMA VIEW PARA O RELATORIO-------';

PRINT'-------CRIANDO UMA VIEW PARA O RELATORIO-------';

PRINT'-------CRIANDO UMA VIEW PARA O RELATORIO-------';

----------------------SVIEWS CRIADAS------------------------------
--13_subquery.sql

CREATE DATABASE db1410_subquery
GO

USE db1410_subquery
GO

DROP TABLE IF EXISTS clientes;
CREATE TABLE clientes(
	cliente_id INT PRIMARY KEY,
	nome_cliente VARCHAR(100),
	total_pedidos DECIMAL(10,2),
	status_cliente VARCHAR(50) DEFAULT 'Ativo'
);

DROP TABLE IF EXISTS pedidos;
CREATE TABLE pedidos(
	pedido_id INT PRIMARY KEY,
	cliente_id INT,
	valor_pedido DECIMAL(10,2),
	data_pedido DATETIME,
	FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
); 

--vale o comentario: primeiro executamos insert de clientes, depois de pedidos

INSERT INTO clientes
	(cliente_id,nome_cliente)
VALUES
	(10,'Caio'),
	(20,'Rodrigo'),
	(30,'Rafael'),
	(40,'Gustavo');

INSERT INTO pedidos
	(pedido_id, cliente_id, valor_pedido, data_pedido)
VALUES
	(1, 1, 100.00, '2025-01-01'),
	(2, 2, 150.00, '2025-01-02'),
	(3, 3, 200.00, '2025-01-03'),
	(4, 4, 250.00, '2025-01-04'),
	(5, 1, 300.00, '2025-01-05'),
	(6, 2, 350.00, '2025-01-06');

--condição garantir para atualizar apenas clientes com pedidos
UPDATE clientes
--atualizar o campo de total_pedidos na tabela clientes
SET total_pedidos=(
	SELECT SUM(valor_pedido)
	FROM pedidos
	WHERE pedidos.cliente_id=clientes.cliente_id
)
--essa é a condição que permite atualizar somente clientes com pedidos
WHERE cliente_id IN (SELECT cliente_id FROM pedidos)
--consultar o resultado final
SELECT * FROM clientes

SELECT * FROM pedidos

--exemplo de update com condição avançada

UPDATE clientes
SET status_cliente= 'inativo'
WHERE total_pedidos<100.00 OR total_pedidos IS NULL;

SELECT * FROM clientes

UPDATE pedidos
SET valor_pedido= valor_pedido*2
WHERE cliente_id=1 AND data_pedido	 <'2025-01-04';

SELECT * FROM pedidos

/*
	DESAFIO
	classificar clientes corretamente de acordo com seu volume de compras 
	ou seja, clientes que compraram mais de 500 sao vips
	clientes com pedidos maiores que 0 são ativos
	caso contrario serao inativos
*/

UPDATE clientes
SET status_cliente= 'inativo'
WHERE total_pedidos<0.00 OR total_pedidos IS NULL;

UPDATE clientes
SET status_cliente='ativo'
WHERE total_pedidos>0.00 AND total_pedidos<500;

UPDATE clientes 
SET status_cliente='vip'
WHERE total_pedidos>=500.00;

SELECT * FROM clientes

DECLARE @tier01 AS VARCHAR(50)='VIP';
DECLARE @tier02 AS VARCHAR(50)='ATIVO';
DECLARE @tier03 AS VARCHAR(50)='INATIVO';


UPDATE clientes
SET status_cliente =
	CASE
		WHEN total_pedidos>=500 THEN @tier01
		WHEN total_pedidos>0 THEN @tier02
		ELSE @tier03
	END;
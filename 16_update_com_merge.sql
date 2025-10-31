--16_update_com_murge.sql

CREATE DATABASE db1410_updateMerge;
GO

USE db1410_updateMerge;
GO

CREATE TABLE clientes(
	cliente_id INT PRIMARY KEY,
	nome_cliente VARCHAR(100),
	total_pedidos DECIMAL(10,2) DEFAULT 0.00,
	status_cliente VARCHAR(100) DEFAULT 'ATIVO'
);

CREATE TABLE pedidos(
	pedido_id INT PRIMARY KEY,
	cliente_id INT,
	valor_pedido DECIMAL (10,2),
	data_pedido DATETIME,
	FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);

INSERT INTO clientes
(cliente_id,nome_cliente)
VALUES
(1,'Caio'),
(2,'Rodrigo'),
(3,'Rafael'),
(4,'Gustavo');

INSERT INTO pedidos
(pedido_id,cliente_id,valor_pedido,data_pedido)
VALUES
(1,1,100.00,'2025-01-01'),
(2,1,150.00,'2025-01-02'),
(3,2,200.00,'2025-01-03'),
(4,3,250.00,'2025-01-04'),
(5,3,300.00,'2025-01-05');

/*
A ideia aqui é comparar os dados dessa tabela com a tabela de pedidos
atualizando os pedidos existentes e inserindo novos pedidos e excluindo
pedidos que nao sao mais necessarios
*/

CREATE TABLE novos_pedidos(
	pedido_id INT PRIMARY KEY,
	cliente_id INT,
	valor_pedido DECIMAL (10,2),
	data_pedido DATETIME
);

INSERT INTO novos_pedidos
(pedido_id,cliente_id,valor_pedido,data_pedido)
VALUES
(2,1,160.00, '2025-01-01'),--pedido existente (atualização)
(6,2,450.00, '2025-01-01'),--novo pedido
(7,3,500.00, '2025-01-01');--novo pedido

--Usaremos o merge para sincronizar a tabela de pedidos com a 
--tabela de novos pedidos

MERGE INTO pedidos AS target
USING novos_pedidos AS source
ON target.pedido_id=source.pedido_id

--quando houver a correspondencia de pedidos fazer o uopdate
WHEN MATCHED THEN
	UPDATE SET
	target.valor_pedido=source.valor_pedido,
	target.data_pedido=source.data_pedido

--quando nao houver a correspondencia de pedidos fazer o insert
WHEN NOT MATCHED BY TARGET THEN
	INSERT (pedido_id,cliente_id,valor_pedido,data_pedido)
	VALUES(source.pedido_id,source.cliente_id,source.valor_pedido,source.data_pedido)

WHEN NOT MATCHED BY source THEN
	DELETE;

--verificar a tabela pedidos
SELECT * FROM pedidos
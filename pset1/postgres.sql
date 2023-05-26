-- Bom Isso aqui vai começar o script, mas antes precisamos do usuario e do banco.

--  Só pra acessar a raiz.
-- psql -U postgres
-- computacao@raiz

-- Só para garantir, remover o usuário e o banco para repetir esse processo
-- E sim, precisa remover em ordem, Schemas -> Databse -> User
DROP SCHEMA IF EXISTS lojas; -- Lojas
DROP DATABASE IF EXISTS uvv; -- Banco
DROP USER IF EXISTS malu; -- Usuário

-- Agora criar o usuário
CREATE USER malu WITH
    SUPERUSER
    CREATEDB 
    CREATEROLE 
    LOGIN 
    ENCRYPTED PASSWORD 'theprincess';

-- Após o usuário criar o Banco
CREATE DATABASE uvv
    WITH 
    OWNER = malu
    TEMPLATE = template0
    ENCODING = 'UTF8'
    LC_COLLATE = 'pt_BR.UTF-8'
    LC_CTYPE = 'pt_BR.UTF-8'
    ALLOW_CONNECTIONS = true;

-- Conectando ao usuário, ou trocando de "role".
SET role malu;

-- Conectando no banco de dados "uvv"
-- Essa informação eu consegui de uma dica e uma grandiosa ajuda de um amigo
-- chamado Matheus Endlich do CC1MA, ele conseguiu resolver o meu maior problema no ligamento do usuário.
\c "host=localhost dbname=uvv user=malu password=theprincess";

-- Definindo permissão pro schemas pro usuário;
CREATE SCHEMA lojas AUTHORIZATION malu;

-- Alterando o Search_Path padrão do Postgres para o usuario e incluindo o esquema.
SHOW SEARCH_PATH;
SELECT CURRENT_SCHEMA();
SET SEARCH_PATH TO lojas, "\$user", public;
ALTER USER malu SET SEARCH_PATH TO lojas, "\$user", public;

-- Criando a tabela lojas
CREATE TABLE lojas (
                loja_id NUMERIC(38) NOT NULL,
                nome VARCHAR(255) NOT NULL,
                endereco_web VARCHAR(100),
                endereco_fisico VARCHAR(512),
                latitude NUMERIC,
                longitude NUMERIC,
                logo BYTEA,
                logo_mime_type VARCHAR(512),
                logo_arquivo VARCHAR(512),
                logo_charset VARCHAR(512),
                logo_ultima_atualizacao DATE,
                CONSTRAINT loja_pk PRIMARY KEY (loja_id)
);
-- Comentários da tabela
COMMENT ON TABLE lojas IS 'Tabela que armazena informações sobre as lojas';
COMMENT ON COLUMN lojas.loja_id IS 'Identificador único da loja';
COMMENT ON COLUMN lojas.nome IS 'Nome da loja';
COMMENT ON COLUMN lojas.endereco_web IS 'Endereço web da loja';
COMMENT ON COLUMN lojas.endereco_fisico IS 'Endereço físico da loja';
COMMENT ON COLUMN lojas.latitude IS 'Latitude geográfica da localização da loja';
COMMENT ON COLUMN lojas.longitude IS 'Longitude geográfica da localização da loja';
COMMENT ON COLUMN lojas.logo IS 'Caminho do arquivo de logotipo da loja';
COMMENT ON COLUMN lojas.logo_mime_type IS 'Tipo MIME do logotipo da loja';
COMMENT ON COLUMN lojas.logo_arquivo IS 'Nome do arquivo de logotipo da loja';
COMMENT ON COLUMN lojas.logo_charset IS 'Charset utilizado para o logotipo da loja';

-- Checkers verificar se alguma dos dois (endereco_web e endereco_fisico) esta definido pelo menos 1 deles no banco
ALTER TABLE lojas ADD CONSTRAINT endereco_check 
CHECK (
    (endereco_web IS NULL OR endereco_fisico IS NOT NULL) OR
    (endereco_web IS NOT NULL OR endereco_fisico IS NULL)
);

-- Latitude e Longitude n pode ser maior/menor que 180/-180 e 90/-90
ALTER TABLE lojas
ADD CONSTRAINT latitude_check
CHECK (latitude >= -90 AND latitude <= 90),
ADD CONSTRAINT longitude_check
CHECK (longitude >= -180 AND longitude <= 180);

-- Tabela Produtos
CREATE TABLE produtos (
                produto_id NUMERIC(38) NOT NULL,
                nome VARCHAR(255) NOT NULL,
                preco_unitario NUMERIC(10,2),
                detalhes BYTEA,
                imagem BYTEA,
                imagem_mime_type VARCHAR(512),
                imagem_arquivo VARCHAR(512),
                imagem_charset VARCHAR(512),
                imagem_ultima_atualizacao DATE,
                CONSTRAINT produto_pk PRIMARY KEY (produto_id)
);
-- Comentários da tabela
COMMENT ON TABLE produtos IS 'Tabela que armazena informações sobre os produtos da loja';
COMMENT ON COLUMN produtos.produto_id IS 'Identificador único do produto';
COMMENT ON COLUMN produtos.preco_unitario IS 'Preço unitário do produto';
COMMENT ON COLUMN produtos.detalhes IS 'Detalhes e informações adicionais sobre o produto';
COMMENT ON COLUMN produtos.imagem IS 'Dados binários da imagem do produto';
COMMENT ON COLUMN produtos.imagem_mime_type IS 'Tipo MIME da imagem do produto';
COMMENT ON COLUMN produtos.imagem_arquivo IS 'Nome do arquivo da imagem do produto';
COMMENT ON COLUMN produtos.imagem_charset IS 'Charset da imagem do produto';
COMMENT ON COLUMN produtos.imagem_ultima_atualizacao IS 'Data da última atualização da imagem do produto';


-- Criando a tabela estoques
CREATE TABLE estoques (
                estoque_id NUMERIC(38) NOT NULL,
                loja_id NUMERIC(38) NOT NULL,
                produto_id NUMERIC(38) NOT NULL,
                quantidade NUMERIC(38) NOT NULL,
                CONSTRAINT estoque_pk PRIMARY KEY (estoque_id)
);
-- Comentários da tabela
COMMENT ON TABLE estoques IS 'Tabela que armazena informações sobre os estoques da loja e seus respectivos produtos';
COMMENT ON COLUMN estoques.estoque_id IS 'Identificador único do estoque';
COMMENT ON COLUMN estoques.loja_id IS 'Identificador da loja associada ao estoque';
COMMENT ON COLUMN estoques.produto_id IS 'Identificador do produto relacionado ao estoque';
COMMENT ON COLUMN estoques.quantidade IS 'Quantidade disponível do produto no estoque';

-- Criando a tabela clientes
CREATE TABLE clientes (
                cliente_id NUMERIC(38) NOT NULL,
                email VARCHAR(255) NOT NULL,
                nome VARCHAR(255) NOT NULL,
                telefone1 VARCHAR(20),
                telefone2 VARCHAR(20),
                telefone3 VARCHAR(20),
                CONSTRAINT cliente_pk PRIMARY KEY (cliente_id)
);
-- Comentários da tabela
COMMENT ON TABLE clientes IS 'Tabela que armazena informações dos clientes';
COMMENT ON COLUMN clientes.cliente_id IS 'Identificador único do cliente';
COMMENT ON COLUMN clientes.nome IS 'Nome do cliente';
COMMENT ON COLUMN clientes.telefone1 IS 'Primeiro número de telefone do cliente';
COMMENT ON COLUMN clientes.telefone2 IS 'Segundo número de telefone do cliente';
COMMENT ON COLUMN clientes.telefone3 IS 'Terceiro número de telefone do cliente';

-- Criando a tabela envios
CREATE TABLE envios (
                envio_id NUMERIC(38) NOT NULL,
                loja_id NUMERIC(38) NOT NULL,
                cliente_id NUMERIC(38) NOT NULL,
                endereco_entrega VARCHAR(512) NOT NULL,
                status VARCHAR(15) NOT NULL,
                CONSTRAINT envio_pk PRIMARY KEY (envio_id)
);
-- Comentários da tabela
COMMENT ON TABLE envios IS 'Tabela que armazena informações sobre os envios';
COMMENT ON COLUMN envios.envio_id IS 'Identificador único do envio';
COMMENT ON COLUMN envios.loja_id IS 'Identificador da loja relacionada ao envio';
COMMENT ON COLUMN envios.cliente_id IS 'Identificador do cliente relacionado ao envio';
COMMENT ON COLUMN envios.endereco_entrega IS 'Endereço de entrega do envio';
COMMENT ON COLUMN envios.status IS 'Status atual do envio';

-- Verificacao Checker para envios
ALTER TABLE envios  ADD CONSTRAINT status_envios_check 
CHECK  (
    status = 'CRIADO'    OR 
	status = 'ENVIADO'   OR
	status = 'TRANSITO'  OR
	status = 'ENTREGUE'
);

-- Criando a tabela pedidos
CREATE TABLE pedidos (
                pedido_id NUMERIC(38) NOT NULL,
                data_hora TIMESTAMP NOT NULL,
                cliente_id NUMERIC(38) NOT NULL,
                stauts VARCHAR(15) NOT NULL,
                loja_id NUMERIC(38) NOT NULL,
                CONSTRAINT pedido_pk PRIMARY KEY (pedido_id)
);
-- Comentários da tabela
COMMENT ON TABLE pedidos IS 'Tabela que armazena os pedidos dos clientes';
COMMENT ON COLUMN pedidos.pedido_id IS 'Identificador único dos pedidos';
COMMENT ON COLUMN pedidos.cliente_id IS 'Identificador do cliente relacionado ao pedido';
COMMENT ON COLUMN pedidos.status IS 'Status atual do pedido';
COMMENT ON COLUMN pedidos.loja_id IS 'Identificador da loja relacionada ao pedido';

ALTER TABLE pedidos ADD CONSTRAINT status_check 
CHECK  (
    status = 'CANCELADO'    OR 
	status = 'COMPLETO'     OR
	status = 'ABERTO'       OR
	status = 'PAGO'	        OR
	status = 'REEMBOLSADO'	OR
	status = 'ENVIADO'
);

-- Criando a tabela pedidos_itens
CREATE TABLE pedidos_itens (
                pedido_id NUMERIC(38) NOT NULL,
                produto_id NUMERIC(38) NOT NULL,
                numero_da_linha NUMERIC(38) NOT NULL,
                preco_unitario NUMERIC(10,2) NOT NULL,
                quantidade NUMERIC(38) NOT NULL,
                envio_id NUMERIC(38),
                CONSTRAINT pedidos_itens_pk PRIMARY KEY (pedido_id, produto_id)
);
-- Comentários da tabela
COMMENT ON TABLE pedidos_itens IS 'Tabela que armazena os itens dos pedidos';
COMMENT ON COLUMN pedidos_itens.pedido_id IS 'Identificador único do pedido relacionado ao item';
COMMENT ON COLUMN pedidos_itens.produto_id IS 'Identificador único do produto relacionado ao item';
COMMENT ON COLUMN pedidos_itens.numero_da_linha IS 'Número da linha que o item ocupa no pedido';
COMMENT ON COLUMN pedidos_itens.preco_unitario IS 'Preço unitário do produto no pedido';
COMMENT ON COLUMN pedidos_itens.quantidade IS 'Quantidade do produto no pedido';
COMMENT ON COLUMN pedidos_itens.envio_id IS 'Identificador do envio relacionado ao item do pedido';

-- São scripts para fazer os ligamentos entre as tabelas e seus referenciamentos
-- Ou famosos FK (Foreing Key) e definindo a chave primária (PK)

ALTER TABLE pedidos_itens ADD CONSTRAINT produtos_pedidos_itens_fk
FOREIGN KEY (produto_id)
REFERENCES produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE estoques ADD CONSTRAINT produtos_estoques_fk
FOREIGN KEY (produto_id)
REFERENCES produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE pedidos ADD CONSTRAINT lojas_pedidos_fk
FOREIGN KEY (loja_id)
REFERENCES lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE estoques ADD CONSTRAINT lojas_estoques_fk
FOREIGN KEY (loja_id)
REFERENCES lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE envios ADD CONSTRAINT lojas_envios_fk
FOREIGN KEY (loja_id)
REFERENCES lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE pedidos ADD CONSTRAINT clientes_pedidos_fk
FOREIGN KEY (cliente_id)
REFERENCES clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE envios ADD CONSTRAINT clientes_envios_fk
FOREIGN KEY (cliente_id)
REFERENCES clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE pedidos_itens ADD CONSTRAINT envios_pedidos_itens_fk
FOREIGN KEY (envio_id)
REFERENCES envios (envio_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE pedidos_itens ADD CONSTRAINT pedidos_pedidos_itens_fk
FOREIGN KEY (pedido_id)
REFERENCES pedidos (pedido_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;
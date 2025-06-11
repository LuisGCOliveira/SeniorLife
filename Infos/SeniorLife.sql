CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE acompanhante (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
nome VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
senha TEXT NOT NULL,
criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dependente (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
nome VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
senha TEXT NOT NULL,
criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE relacao_acompanhante_dependente (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
id_acompanhante UUID REFERENCES acompanhante(id) ON DELETE CASCADE,
id_dependente UUID REFERENCES dependente(id) ON DELETE CASCADE,
data_vinculo TIMESTAMP DEFAULT NOW(),
criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SELECT * FROM dependente;

INSERT INTO acompanhante (nome, email, senha)
VALUES ('João Silva', 'joao@email.com', 'senha123');

INSERT INTO dependente (nome, email, senha)
VALUES ('Maria Oliveira', 'maria@email', 'senha123')

SELECT
 a.nome AS acompanhante,
 d.nome AS dependente,
 r.data_vinculo
FROM relacao_acompanhante_dependente r
JOIN acompanhante a ON r.id_acompanhante = a.id
JOIN dependente d ON r.id_dependente = d.id;

SELECT * FROM relacao_acompanhante_dependente;

INSERT INTO relacao_acompanhante_dependente (id_acompanhante, id_dependente) VALUES ('b58d9992-0d12-40f4-8011-08cf9963fdf0', 'c0474f2d-b0b8-4274-92f2-dfb5fa1799c3')
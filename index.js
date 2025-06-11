//importando os pacotes para uso no arquivo index.js

const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const bodyParser = require('body-parser');
const { MongoDB, PostgresDB } = require('./Model/conn');

const mongo = new MongoDB('mongodb://localhost:27017/seniorlife');
mongo.connect();

const pg = new PostgresDB({
    host: 'localhost',
    user: 'seu_usuario',
    password: 'sua_senha',
    database: 'seniorlife',
    port: 5432,
});
const knexInstance = pg.getConnection();
//criando um servidor express

const app = express();

// aplicando as configuraçes dentro do servidor express, adicionando os pacotes

app.use(morgan('dev'));
app.use(cors());
app.use(bodyParser.json());
/* O body-parser.urlencoded() no Express.js é um middleware que analisa o corpo de uma requisição HTTP que contém dados codificados como URL. Isso é útil quando você está recebendo dados de formulários ou dados que foram enviados no formato application/x-www-form-urlencoded, que é o formato padrão para envio de dados de formulários HTML*/
app.use(bodyParser.urlencoded({ extended: true }));

knexInstance('usuarios').select('*').then(usuarios => {
    console.log(usuarios);
}).catch(err => {
    console.error('Erro ao buscar usuários:', err);
});

// o servidor irá rodar dentro da porta 3000
app.listen(3000, () => {
    console.log('Servidor rodando na porta 3000');
});

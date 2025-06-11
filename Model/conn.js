import { connect as _connect } from 'mongoose';
import knex from 'knex';


class MongoDB {
    constructor(uri) {
        this.uri = uri;
        this.connection = null;
    }

    async connect() {
        if (!this.connection) {
            try {
                this.connection = await _connect(this.uri, {
                    useNewUrlParser: true,
                    useUnifiedTopology: true,
                });
                console.log('Conectado ao MongoDB!');
            } catch (err) {
                console.error('Erro ao conectar ao MongoDB:', err);
            }
        }
        return this.connection;
    }
}



class PostgresDB {
    constructor(config) {
        this.config = config;
        this.knex = knex({
            client: 'pg',
            connection: this.config,
        });
    }

    getConnection() {
        return this.knex;
    }
}

const _PostgresDB = PostgresDB;
export { _PostgresDB as PostgresDB };
const _MongoDB = MongoDB;
export { _MongoDB as MongoDB };
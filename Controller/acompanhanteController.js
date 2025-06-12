import { criarAcompanhante, listarAcompanhantes, editarAcompanhante, excluirAcompanhante } from '../Model/acompanhanteModel.js';
import bcrypt from 'bcrypt';
/**
 * Controller responsável por lidar com a requisição de criação de acompanhante.
 * Recebe os dados do acompanhante pelo corpo da requisição (req.body).
 * Retorna o acompanhante criado em formato JSON ou um erro.
 */
export async function criar(req, res) {
  try {
    // Chama a função do model para criar o acompanhante com os dados recebidos
    const novo = await criarAcompanhante(req.body);

    // Retorna o acompanhante criado com status 201 (Created)
    res.status(201).json(novo);
  } catch (err) {
    // Em caso de erro, retorna status 400 (Bad Request) e a mensagem de erro
    res.status(400).json({ erro: err.message });
  }
}

/**
 * Controller responsável por retornar todos os acompanhantes cadastrados.
 */
export async function consultar(req, res) {
  try {
    const lista = await listarAcompanhantes();
    res.status(200).json({
      mensagem: 'Consulta realizada com sucesso!',
      acompanhantes: lista,
    });
  } catch (err) {
    res.status(500).json({ erro: err.message });
  }
}

/**
 * Controller responsável por editar um acompanhante.
 * Espera o ID como parâmetro de rota e os novos dados no corpo da requisição.
 */
export async function editar(req, res) {
  try {
    const { id } = req.params; // Pega o ID da URL
    const dados = req.body;    // Novos dados do acompanhante

    const atualizado = await editarAcompanhante(id, dados);

    if (!atualizado) {
      // Se não encontrou acompanhante para atualizar
      return res.status(404).json({ mensagem: 'Acompanhante não encontrado.' });
    }

    res.status(200).json({
      mensagem: 'Acompanhante atualizado com sucesso!',
      acompanhante: atualizado,
    });
  } catch (err) {
    res.status(400).json({ erro: err.message });
  }
}

/**
 * Controller responsável por excluir um acompanhante pelo ID.
 * Espera o ID como parâmetro de rota.
 */
export async function excluir(req, res) {
  try {
    const { id } = req.params; // Pega o ID da URL

    const excluido = await excluirAcompanhante(id);

    if (!excluido) {
      // Se não encontrou acompanhante para excluir
      return res.status(404).json({ mensagem: 'Acompanhante não encontrado.' });
    }

    res.status(200).json({ mensagem: 'Acompanhante excluído com sucesso!' });
  } catch (err) {
    res.status(400).json({ erro: err.message });
  }
}

/**
 * Controller responsável por cadastrar um novo acompanhante.
 * Espera nome, email e senha no corpo da requisição.
 */
export async function cadastrar(req, res) {
  try {
    const { nome, email, senha } = req.body;
    // Gera o hash da senha antes de salvar
    const senhaHash = await bcrypt.hash(senha, 10);
    const novoAcompanhante = await criarAcompanhante({ nome, email, senha: senhaHash });
    res.status(201).json({
      mensagem: 'Acompanhante cadastrado com sucesso!',
      acompanhante: novoAcompanhante,
    });
  } catch (err) {
    res.status(400).json({ erro: err.message });
  }
}

/**
 * Controller responsável pelo login do acompanhante.
 * Espera email e senha no corpo da requisição.
 */
export async function login(req, res) {
  const { email, senha } = req.body;

  if (!email || !senha) {
    return res.status(400).json({ erro: 'Email e senha são obrigatórios.' });
  }

  try {
    const acompanhante = await buscarAcompanhantePorEmail(email);

    if (!acompanhante) {
      return res.status(401).json({ erro: 'Email ou senha inválidos.' });
    }

    // Compara a senha informada com o hash salvo
    const senhaCorreta = await bcrypt.compare(senha, acompanhante.senha);
    if (!senhaCorreta) {
      return res.status(401).json({ erro: 'Email ou senha inválidos.' });
    }
    //Autenticação com JWT
    const token = jwt.sign(
     { id: acompanhante.id, tipo: 'acompanhante' }, // payload
     process.env.JWT_SECRET || 'seuSegredoJWT',     // segredo seguro
     { expiresIn: '1h' }
);

    res.status(200).json({
      mensagem: 'Login realizado com sucesso!',
      acompanhante: {
        id: acompanhante.id,
        nome: acompanhante.nome,
        email: acompanhante.email,
      },
    });
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao realizar login.' });
  }
}

import {criarDependente,listarDependentes,editarDependente,excluirDependente} from '../Model/dependenteModel.js';
import bcrypt from 'bcrypt';

/**
 * Controller responsável por criar um novo dependente (Create).
 * Recebe nome, email e senha no corpo da requisição.
 */
export async function criar(req, res) {
  try {
    const { nome, email, senha } = req.body;

    if (!nome || !email || !senha) {
      return res.status(400).json({ erro: 'Nome, email e senha são obrigatórios.' });
    }

    const novoDependente = await criarDependente({ nome, email, senha });

    res.status(201).json({
      mensagem: 'Dependente criado com sucesso!',
      dependente: novoDependente,
    });
  } catch (err) {
    res.status(400).json({ erro: err.message });
  }
}
/**
 * Controller responsável por listar todos os dependentes.
 * Retorna uma mensagem de sucesso e a lista de dependentes.
 */
export async function consultar(req, res) {
  try {
    const lista = await listarDependentes();
    res.status(200).json({
      mensagem: 'Consulta realizada com sucesso!',
      dependentes: lista,
    });
  } catch (err) {
    res.status(500).json({ erro: err.message });
  }
}

/**
 * Controller responsável por editar um dependente.
 * Espera o ID como parâmetro de rota e os novos dados no corpo da requisição.
 */
export async function editar(req, res) {
  try {
    const { id } = req.params; // ID do dependente a ser editado
    const { nome, email, senha } = req.body; // Novos dados

    const atualizado = await editarDependente(id, { nome, email, senha });

    if (!atualizado) {
      return res.status(404).json({ mensagem: 'Dependente não encontrado.' });
    }

    res.status(200).json({
      mensagem: 'Dependente atualizado com sucesso!',
      dependente: atualizado,
    });
  } catch (err) {
    res.status(400).json({ erro: err.message });
  }
}

/**
 * Controller responsável por excluir um dependente.
 * Espera o ID como parâmetro de rota.
 */
export async function excluir(req, res) {
  try {
    const { id } = req.params; // ID do dependente a ser excluído

    const excluido = await excluirDependente(id);

    if (!excluido) {
      return res.status(404).json({ mensagem: 'Dependente não encontrado.' });
    }

    res.status(200).json({ mensagem: 'Dependente excluído com sucesso!' });
  } catch (err) {
    res.status(400).json({ erro: err.message });
  }
}

/**
 * Controller responsável por cadastrar um novo dependente.
 * Espera nome, email e senha no corpo da requisição (enviados pelo acompanhante).
 */
export async function cadastrar(req, res) {
  try {
    const { nome, email, senha } = req.body;

    // Validação básica dos campos
    if (!nome || !email || !senha) {
      return res.status(400).json({ erro: 'Nome, email e senha são obrigatórios.' });
    }

    // Gera o hash da senha antes de salvar
    const senhaHash = await bcrypt.hash(senha, 10);

    // Cria o dependente no banco de dados
    const novoDependente = await criarDependente({ nome, email, senha: senhaHash });

    res.status(201).json({
      mensagem: 'Dependente cadastrado com sucesso!',
      dependente: novoDependente,
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

  // Validação dos campos obrigatórios
  if (!email || !senha) {
    return res.status(400).json({ erro: 'Email e senha são obrigatórios.' });
  }

  try {
    // Busca o acompanhante pelo email
    const acompanhante = await buscarAcompanhantePorEmail(email);

    // Verifica se encontrou e se a senha está correta
    if (!acompanhante || !(await bcrypt.compare(senha, acompanhante.senha))) {
      return res.status(401).json({ erro: 'Email ou senha inválidos.' });
    }

    // Login bem-sucedido
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
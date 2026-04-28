# API Factory para Delphi (Integração com APIs REST)

## 📌 Descrição

Este repositório apresenta a implementação de uma camada de integração para consumo de APIs REST em sistemas legados desenvolvidos em Delphi.

A solução foi desenvolvida como parte de um Trabalho de Conclusão de Curso (TCC), com o objetivo de reduzir a complexidade, a verbosidade e o acoplamento presentes em integrações diretas com APIs na linguagem Object Pascal, promovendo maior organização, reutilização de código e padronização das requisições.

---

## 🎯 Objetivo

Prover uma abstração para comunicação com APIs REST, centralizando:

* Requisições HTTP (GET, POST, PUT, DELETE)
* Configuração de headers e autenticação
* Manipulação de dados em JSON
* Tratamento de erros e exceções
* Padronização das respostas

---

## 🛠 Tecnologias Utilizadas

* Delphi 12 Community Edition
* Linguagem: Object Pascal
* Bibliotecas nativas:

  * System.Net.HttpClient
  * System.JSON
  * System.SysUtils
  * System.Classes

> ⚠️ Não foi utilizado nenhum framework externo, reforçando a aplicabilidade da solução em sistemas legados reais.


---

## ⚙️ Funcionalidades

* Abstração da comunicação HTTP/HTTPS
* Suporte aos métodos GET, POST, PUT e DELETE
* Autenticação via token (ex: Bearer/JWT)
* Serialização e desserialização de JSON
* Tratamento centralizado de erros
* Retorno padronizado para consumo no sistema

---

## 🚀 Como Utilizar

1. Adicione a unit `APIFactory.pas` ao seu projeto Delphi
2. Configure a URL base da API
3. Defina os headers necessários (ex: Authorization)
4. Utilize os métodos disponíveis da classe para realizar requisições
5. Trate os dados retornados conforme a necessidade do sistema

---

## 🔄 Fluxo de Utilização

A arquitetura segue o seguinte fluxo:

Sistema Legado (Form) → API Factory → API REST (Nuvem)

Onde:

* O **Form Delphi** realiza chamadas para a classe
* A **API Factory** centraliza e executa as requisições
* A **API REST** processa e retorna os dados em JSON

---

## 🧪 Validação

A solução foi validada por meio de:

* Testes funcionais (requisições HTTP e respostas)
* Verificação do tratamento de erros
* Análise da organização e reutilização de código
* Coleta de percepção de desenvolvedores (questionário aplicado no TCC)

---

## 🎓 Contexto Acadêmico

Este projeto foi desenvolvido como parte de um Trabalho de Conclusão de Curso (TCC), com foco na melhoria da integração entre sistemas legados Delphi e APIs REST modernas.

O código-fonte foi disponibilizado para garantir a reprodutibilidade da pesquisa e permitir a análise prática da solução proposta.


---

## 👤 Autor

Cauã Rocha Leite

---

## 📄 Licença

Uso acadêmico

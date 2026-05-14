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

# 🚀 Exemplos de Utilização

## 📥 GET - Retorno RAW

```delphi
var
  Resp: string;
begin
  Resp :=
    TApiFactory.New
      .BaseURL('https://viacep.com.br')
      .Resource('/ws/01001000/json/')
      .Get
      .Raw;

  ShowMessage(Resp);
end;
```

---

## 📥 GET - Conversão automática para classe

```delphi
var
  Endereco: TEnderecoData;
begin
  Endereco :=
    TApiFactory.New
      .BaseURL('https://viacep.com.br')
      .Resource('/ws/01001000/json/')
      .Get
      .AsType<TEnderecoData>;

  ShowMessage(
    'CEP: ' + Endereco.cep + sLineBreak +
    'Cidade: ' + Endereco.localidade
  );
end;
```

---

## 🔐 Autenticação com Token Bearer

```delphi
var
  LoginReq: TLoginRequest;
  User: TUserData;
  objAPI: IApiClient;
begin

  objAPI :=
    TApiFactory.New
      .BaseURL('https://dummyjson.com');

  LoginReq := TLoginRequest.Create;
  try
    LoginReq.username := 'emilys';
    LoginReq.password := 'emilyspass';

    objAPI.AuthProvider
      (
        TAuthProvider.Create(
          objAPI.Resource('/auth/login')
            .AddBody(LoginReq)
            .Post
            .AsType<TLoginResponse>.accessToken
        )
      );

  finally
    LoginReq.Free;
  end;

  User :=
    objAPI
      .Resource('/auth/me')
      .Get
      .AsType<TUserData>;

  ShowMessage(User.firstname);
end;
```

---

## 📤 POST - Envio de objeto JSON

```delphi
var
  ProdutoReq: TprodutoData;
  ProdutoResp: TprodutoData;
begin

  ProdutoReq := TprodutoData.Create;
  try
    ProdutoReq.title := 'Meu novo produto';
    ProdutoReq.price := 99.9;

    ProdutoResp :=
      TApiFactory.New
        .BaseURL('https://dummyjson.com')
        .Resource('/products/add')
        .AddBody(ProdutoReq)
        .Post
        .AsType<TprodutoData>;

  finally
    ProdutoReq.Free;
  end;

  ShowMessage(ProdutoResp.title);
end;
```

---

## ✏️ PUT - Atualização de dados

```delphi
var
  ProdutoResp: TprodutoData;
  Json: TJSONObject;
begin

  Json := TJSONObject.Create;
  try

    Json.AddPair('title', 'iPhone 15 Pro Max Atualizado');

    ProdutoResp :=
      TApiFactory.New
        .BaseURL('https://dummyjson.com')
        .Resource('/products/1')
        .AddBody(Json.ToString)
        .Put
        .AsType<TprodutoData>;

  finally
    Json.Free;
  end;

  ShowMessage(ProdutoResp.title);
end;
```

---

## 📚 Conversão automática de Arrays

```delphi
var
  Users: TArray<TUserData>;
  User: TUserData;
  lMessage: string;
begin

  Users :=
    TApiFactory.New
      .BaseURL('https://jsonplaceholder.typicode.com')
      .Resource('/posts')
      .Get
      .AsArray<TUserData>;

  for User in Users do
  begin
    lMessage := lMessage +
      'Id: ' + User.id.ToString + sLineBreak +
      'Title: ' + User.title + sLineBreak;
  end;

  ShowMessage(lMessage);
end;
```

---

# 🔄 Comparação com a abordagem tradicional do Delphi

## Utilizando componentes REST nativos

```delphi
var
  Client: TRESTClient;
  Request: TRESTRequest;
  Response: TRESTResponse;
  JSONObj: TJSONObject;
begin

  Client := TRESTClient.Create('https://viacep.com.br');
  Request := TRESTRequest.Create(nil);
  Response := TRESTResponse.Create(nil);

  try
    Request.Client := Client;
    Request.Response := Response;
    Request.Method := rmGET;
    Request.Resource := '/ws/01001000/json/';

    Request.AddParameter(
      'Content-Type',
      'application/json',
      pkHTTPHEADER
    );

    Request.Execute;

    JSONObj :=
      TJSONObject.ParseJSONValue(Response.Content)
        as TJSONObject;

    ShowMessage(
      JSONObj.GetValue<string>('logradouro')
    );

  finally
    Client.Free;
    Request.Free;
    Response.Free;
  end;
end;
```

---

## Utilizando a API Factory

```delphi
var
  Endereco: TEnderecoData;
begin

  Endereco :=
    TApiFactory.New
      .BaseURL('https://viacep.com.br')
      .Resource('/ws/01001000/json/')
      .Get
      .AsType<TEnderecoData>;

  ShowMessage(Endereco.logradouro);
end;
```

---

## 📊 Benefícios da abstração proposta

| Abordagem Tradicional | API Factory |
|---|---|
| Maior quantidade de código boilerplate | Redução significativa de código |
| Configuração manual de componentes | Configuração centralizada |
| Conversão JSON manual | Serialização automática |
| Alto acoplamento | Baixo acoplamento |
| Repetição de código | Reutilização e padronização |
| Maior dificuldade de manutenção | Código mais limpo e organizado |

---

## 🚀 Como Utilizar

1. Adicione a unit `APIFactory.pas` ao seu projeto Delphi
2. Configure a URL base da API
3. Defina os headers necessários (ex: Authorization)
4. Utilize os métodos disponíveis da classe para realizar requisições
5. Trate os dados retornados conforme a necessidade do sistema

---

## 🔄 Fluxo de Utilização

Sistema Legado (Form) → API Factory → API REST (Nuvem)

Onde:

* O Form Delphi realiza chamadas para a classe
* A API Factory centraliza e executa as requisições
* A API REST processa e retorna os dados em JSON

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


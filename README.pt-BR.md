<p align="left">
  <a href="https://github.com/adrianosantostreina/ADRConnection/blob/main/img/ADRConnection_ComFundo_Branco_No_Circulo.png">
    <img alt="ADRConnection" height="200" src="https://github.com/adrianosantostreina/ADRConnection/blob/main/img/ADRConnection_ComFundo_Branco_No_Circulo.png">
  </a>  
</p>

# ADRConnection

**ADRConnection** é uma poderosa biblioteca de abstração de conexão com banco de dados para Delphi. Ela encapsula múltiplos componentes de acesso a dados em uma única interface fluente e intuitiva, permitindo que você troque o motor de banco de dados (driver) sem alterar a lógica de negócios da sua aplicação.

## 🚀 Recursos Principais

- **Abstração de Componentes:** Suporte a FireDAC, UniDAC, Zeos e PGDAC.
- **Múltiplos Bancos de Dados:** Compatível com Firebird, PostgreSQL, MySQL, SQLite, Oracle, SQL Server e MongoDB.
- **API Fluente:** Configuração de conexão e construção de queries e parâmetros de forma encadeada e limpa.
- **Connection Pooling:** Gerenciamento eficiente de conexões para aplicações de alta performance.
- **Suporte a DAO:** Classe base para implementação rápida do padrão Data Access Object.
- **Configuração Automática:** Leitura de parâmetros de conexão via arquivo INI.
- **Operações em Lote:** Suporte a Batch Updates para inserções em massa.

## 🧬 Componentes Suportados

Para utilizar um componente específico, basta definir a diretiva de compilação correspondente no seu projeto:

| Componente | Diretiva | Documentação |
| :--- | :--- | :--- |
| **FireDAC** | `ADRCONN_FIREDAC` | [Embarcadero FireDAC](https://www.embarcadero.com/br/products/rad-studio/firedac) |
| **UniDAC** | `ADRCONN_UNIDAC` | [DevArt UniDAC](https://www.devart.com/unidac/) |
| **ZeosLib** | `ADRCONN_ZEOS` | [ZeosLib SourceForge](https://sourceforge.net/projects/zeoslib) |
| **PgDAC** | `ADRCONN_PGDAC` | [DevArt PgDAC](https://www.devart.com/pgdac) |

## ⚙️ Instalação

A instalação é feita utilizando o [`boss`](https://github.com/HashLoad/boss):

```sh
boss install github.com/adrianosantostreina/ADRConnection
```

## ⚡️ Como Usar

### 1. Criando uma Conexão

Você pode configurar a conexão manualmente utilizando a interface fluente:

```delphi
uses
  ADRConn.Model.Interfaces;

var
  LConnection: IADRConnection;
begin
  LConnection := CreateConnection;
  
  LConnection.Params
    .Driver(adrPostgres)
    .Database('minhabase')
    .Server('127.0.0.1')
    .Port(5432)
    .UserName('postgres')
    .Password('senha')
    .AddParam('CharacterSet', 'UTF8'); // Parâmetros customizados
    
  LConnection.Connect;
end;
```

### 2. Executando Queries

A execução de comandos SQL também segue o padrão fluente:

```delphi
var
  LQuery: IADRQuery;
begin
  LQuery := CreateQuery(LConnection);
  
  // Select
  LQuery.SQL('select id, nome, email from clientes')
        .SQL('where id = :id')
        .ParamAsInteger('id', 1)
        .Open;

  // Insert/Update/Delete
  LQuery.Clear
        .SQL('update clientes set nome = :nome where id = :id')
        .ParamAsString('nome', 'Novo Nome')
        .ParamAsInteger('id', 1)
        .ExecSQL;
end;
```

### 3. Configuração via Arquivo INI

A classe `TADRConnConfigIni` facilita a leitura das configurações de um arquivo `.ini` (nomeado igual ao executável):

```delphi
uses
  ADRConn.Config.IniFile;

var
  LConfig: TADRConnConfigIni;
begin
  LConfig := TADRConnConfigIni.GetInstance;
  
  // A conexão pode ser configurada lendo diretamente do INI
  FConnection.Params
    .Driver(LConfig.Driver)
    .Database(LConfig.Database)
    .Server(LConfig.Server)
    .Port(LConfig.Port)
    .UserName(LConfig.UserName)
    .Password(LConfig.Password);
end;
```

Exemplo de estrutura do INI:
```ini
[CONFIG]
Driver=Postgres
Database=meubanco
User_Name=postgres
Password=senha
Server=localhost
Port=5432
VendorLib=libpq.dll
```

### 4. Connection Pooling

Para aplicações que exigem alta concorrência, utilize o Pool de Conexões:

```delphi
uses
  ADRConnection.Pool,
  ADRConn.Model.Interfaces;

// Inicialização do Pool (geralmente no início da aplicação)
TADRConnectionPoolBuilder.New
  .MinPoolCount(5)
  .MaxIdleSeconds(60)
  .OnGetConnection(
    function: IADRConnection
    begin
      // Retorna uma nova instância de conexão configurada
      Result := CreateConnection;
      Result.Params
        .Driver(adrFirebird)
        .Database('banco.fdb')
        ...
    end)
  .Build;

// Obtendo uma conexão do Pool
var
  LPoolItem: TPoolItem<TADRConnectionPoolItem>;
begin
  LPoolItem := GetPoolItem; 
  // LPoolItem.Value.Connection está pronta para uso
  LPoolItem.Value.Connection.StartTransaction;
  try
    // ... operações ...
    LPoolItem.Value.Connection.Commit;
  except
    LPoolItem.Value.Connection.Rollback;
  end;
end; // A conexão volta para o pool automaticamente aqui
```

### 5. Padrão DAO (Data Access Object)

A biblioteca fornece uma classe base `TADRConnDAOBase` para facilitar a criação de DAOs:

```delphi
uses
  ADRConn.DAO.Base;

type
  TClienteDAO = class(TADRConnDAOBase)
  public
    procedure Salvar(cliente: TCliente);
  end;

procedure TClienteDAO.Salvar(cliente: TCliente);
begin
  FQuery.Clear
        .SQL('insert into clientes (nome) values (:nome)')
        .ParamAsString('nome', cliente.Nome)
        .ExecSQL;
end;
```

### 6. Tratamento de Erros e Logs

Você pode interagir com eventos de erro e log da conexão:

```delphi
LConnection.Events
  .OnLog(
    procedure(ALog: string)
    begin
      Writeln('Log do Banco: ' + ALog);
    end)
  .OnHandleException(
    function(E: Exception): Boolean
    begin
      // Retorne True se o erro foi tratado
      Writeln('Erro capturado: ' + E.Message);
      Result := False; 
    end);
```

## 📋 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE.md](LICENSE.md) para detalhes.

---
🇺🇸 [English Version](README.md)

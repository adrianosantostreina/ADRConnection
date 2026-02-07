<p align="left">
  <a href="https://github.com/adrianosantostreina/ADRConnection/blob/main/img/ADRConnection_ComFundo_Branco_No_Circulo.png">
    <img alt="ADRConnection" height="200" src="https://github.com/adrianosantostreina/ADRConnection/blob/main/img/ADRConnection_ComFundo_Branco_No_Circulo.png">
  </a>  
</p>

# ADRConnection

**ADRConnection** is a powerful database connection abstraction library for Delphi. It encapsulates multiple data access components into a single fluent and intuitive interface, allowing you to switch the database engine (driver) without changing your application's business logic.

## 🚀 Key Features

- **Component Abstraction:** Support for FireDAC, UniDAC, Zeos, and PGDAC.
- **Multiple Databases:** Compatible with Firebird, PostgreSQL, MySQL, SQLite, Oracle, SQL Server, and MongoDB.
- **Fluent API:** Connection configuration, and query/parameter construction in a clean, chained manner.
- **Connection Pooling:** Efficient connection management for high-performance applications.
- **DAO Support:** Base class for quick implementation of the Data Access Object pattern.
- **Automatic Configuration:** Read connection parameters from an INI file.
- **Batch Operations:** Support for Batch Updates for bulk insertions.

## 🧬 Supported Components

To use a specific component, define the corresponding compiler directive in your project:

| Component | Directive | Documentation |
| :--- | :--- | :--- |
| **FireDAC** | `ADRCONN_FIREDAC` | [Embarcadero FireDAC](https://www.embarcadero.com/br/products/rad-studio/firedac) |
| **UniDAC** | `ADRCONN_UNIDAC` | [DevArt UniDAC](https://www.devart.com/unidac/) |
| **ZeosLib** | `ADRCONN_ZEOS` | [ZeosLib SourceForge](https://sourceforge.net/projects/zeoslib) |
| **PgDAC** | `ADRCONN_PGDAC` | [DevArt PgDAC](https://www.devart.com/pgdac) |

## ⚙️ Installation

Installation is done using [`boss`](https://github.com/HashLoad/boss):

```sh
boss install github.com/adrianosantostreina/ADRConnection
```

## ⚡️ Usage

### 1. Creating a Connection

You can manually configure the connection using the fluent interface:

```delphi
uses
  ADRConn.Model.Interfaces;

var
  LConnection: IADRConnection;
begin
  LConnection := CreateConnection;
  
  LConnection.Params
    .Driver(adrPostgres)
    .Database('mydatabase')
    .Server('127.0.0.1')
    .Port(5432)
    .UserName('postgres')
    .Password('password')
    .AddParam('CharacterSet', 'UTF8'); // Custom parameters
    
  LConnection.Connect;
end;
```

### 2. Executing Queries

Executing SQL commands also follows the fluent pattern:

```delphi
var
  LQuery: IADRQuery;
begin
  LQuery := CreateQuery(LConnection);
  
  // Select
  LQuery.SQL('select id, name, email from customers')
        .SQL('where id = :id')
        .ParamAsInteger('id', 1)
        .Open;

  // Insert/Update/Delete
  LQuery.Clear
        .SQL('update customers set name = :name where id = :id')
        .ParamAsString('name', 'New Name')
        .ParamAsInteger('id', 1)
        .ExecSQL;
end;
```

### 3. Configuration via INI File

The `TADRConnConfigIni` class facilitates reading settings from an `.ini` file (named after the executable):

```delphi
uses
  ADRConn.Config.IniFile;

var
  LConfig: TADRConnConfigIni;
begin
  LConfig := TADRConnConfigIni.GetInstance;
  
  // The connection can be configured by reading directly from the INI
  FConnection.Params
    .Driver(LConfig.Driver)
    .Database(LConfig.Database)
    .Server(LConfig.Server)
    .Port(LConfig.Port)
    .UserName(LConfig.UserName)
    .Password(LConfig.Password);
end;
```

Example INI structure:
```ini
[CONFIG]
Driver=Postgres
Database=mydatabase
User_Name=postgres
Password=password
Server=localhost
Port=5432
VendorLib=libpq.dll
```

### 4. Connection Pooling

For applications requiring high concurrency, use the Connection Pool:

```delphi
uses
  ADRConnection.Pool,
  ADRConn.Model.Interfaces;

// Pool Initialization (usually at application start)
TADRConnectionPoolBuilder.New
  .MinPoolCount(5)
  .MaxIdleSeconds(60)
  .OnGetConnection(
    function: IADRConnection
    begin
      // Returns a new configured connection instance
      Result := CreateConnection;
      Result.Params
        .Driver(adrFirebird)
        .Database('database.fdb')
        ...
    end)
  .Build;

// Getting a connection from the Pool
var
  LPoolItem: TPoolItem<TADRConnectionPoolItem>;
begin
  LPoolItem := GetPoolItem; 
  // LPoolItem.Value.Connection is ready for use
  LPoolItem.Value.Connection.StartTransaction;
  try
    // ... operations ...
    LPoolItem.Value.Connection.Commit;
  except
    LPoolItem.Value.Connection.Rollback;
  end;
end; // The connection automatically returns to the pool here
```

### 5. DAO Pattern (Data Access Object)

The library provides a base class `TADRConnDAOBase` to facilitate DAO creation:

```delphi
uses
  ADRConn.DAO.Base;

type
  TCustomerDAO = class(TADRConnDAOBase)
  public
    procedure Save(customer: TCustomer);
  end;

procedure TCustomerDAO.Save(customer: TCustomer);
begin
  FQuery.Clear
        .SQL('insert into customers (name) values (:name)')
        .ParamAsString('name', customer.Name)
        .ExecSQL;
end;
```

### 6. Error Handling and Logs

You can interact with connection error and log events:

```delphi
LConnection.Events
  .OnLog(
    procedure(ALog: string)
    begin
      Writeln('Database Log: ' + ALog);
    end)
  .OnHandleException(
    function(E: Exception): Boolean
    begin
      // Return True if the error was handled
      Writeln('Error captured: ' + E.Message);
      Result := False; 
    end);
```

## 📋 License

This project is licensed under the MIT license - see the [LICENSE.md](LICENSE.md) file for details.

---
🇧🇷 [Versão em Português](README.pt-BR.md)

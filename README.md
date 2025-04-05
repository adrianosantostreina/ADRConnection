<p align="left">
  <a href="https://github.com/adrianosantostreina/ADRConnection/blob/main/img/ADRConnection_ComFundo_Branco_No_Circulo.png">
    <img alt="ADRConnection" height="200" src="https://github.com/adrianosantostreina/ADRConnection/blob/main/img/ADRConnection_ComFundo_Branco_No_Circulo.png">
  </a>  
</p>

# ADRConnection
Database connection abstraction. Encapsulates multiple connection components into a single interface.

## 🧬Available Components

| Component | Delphi | Directive
| ------------------------------------------------------------------- | -------------------- | -------------------- |
|  [Firedac](https://www.embarcadero.com/br/products/rad-studio/firedac) | &nbsp;&nbsp;&nbsp;✔️ | ADRCONN_FIREDAC |
|  [PGDAC](https://www.devart.com/pgdac)   | &nbsp;&nbsp;&nbsp;✔️ | ADRCONN_PGDAC |
|  [Unidac](https://www.devart.com/unidac/?gad_source=1&gclid=Cj0KCQjwqcO_BhDaARIsACz62vNi-vTROkelJb-VKVWJTM5sKaEOy9C3i5IPwrhCCcU_l2wvhm8h2TAaAik_EALw_wcB)  | &nbsp;&nbsp;&nbsp;✔️ | ADRCONN_UNIDAC |
|  [ZEOS](https://sourceforge.net/projects/zeoslib)  | &nbsp;&nbsp;&nbsp;✔️ | ADRCONN_ZEOS |

## ⚙️ Installation
Installation is done using the [`boss install`](https://github.com/HashLoad/boss) command:
``` sh
boss install github.com/adrianosantostreina/ADRConnection
```

## ⚡️ Quickstart
```delphi
// Create a Connection
uses
  ADRConn.Model.Interfaces;

var
  FConnection: IADRConnection;
begin
  FConnection := CreateConnection;
  FConnection.Params
    .Driver(adrPostgres)
    .Database('demoadrconnection')
    .Server('127.0.0.1')
    .Port(5432)
    .UserName('postgres')
    .Password('postgres');

  FConnection.Connect;    
end.
```

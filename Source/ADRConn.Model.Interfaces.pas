unit ADRConn.Model.Interfaces;

interface

uses
  Data.DB,
  System.Classes;

type
  TADRDriverConn = (adrFirebird, adrPostgres, adrMySql, adrSQLite);
  IADRConnectionParams = interface;

  IADRConnection = interface
    ['{681E59C7-6AAC-47DE-AE6D-F649C1922565}']
    function Connection: TCustomConnection;
    function Component : TComponent;

    function Params: IADRConnectionParams;

    function Connect          : IADRConnection;
    function Disconnect       : IADRConnection;
    function StartTransaction : IADRConnection;
    function Commit           : IADRConnection;
    function Rollback         : IADRConnection;
    function InTransaction    : Boolean;
  end;

  IADRConnectionParams = interface
    ['{439941DC-9841-478E-9E9A-BCAB3015DB9C}']
    function Database   (Value: string): IADRConnectionParams; overload;
    function UserName   (Value: string): IADRConnectionParams; overload;
    function Password   (Value: string): IADRConnectionParams; overload;
    function Server     (Value: string): IADRConnectionParams; overload;
    function Schema     (Value: String): IADRConnectionParams; overload;
    function Lib        (Value: string): IADRConnectionParams; overload;
    function Port       (Value: Integer): IADRConnectionParams; overload;
    function AutoCommit (Value: Boolean): IADRConnectionParams; overload;
    function Driver     (Value: TADRDriverConn): IADRConnectionParams; overload;

    function Database   : string; overload;
    function UserName   : string; overload;
    function Password   : string; overload;
    function Server     : string; overload;
    function Schema     : string; overload;
    function Lib        : string; overload;
    function Port       : Integer; overload;
    function AutoCommit : Boolean; overload;
    function Driver     : TADRDriverConn; overload;

    function &End: IADRConnection;
  end;

  IADRQuery = interface
    ['{2038E15B-0654-4A00-A7A8-CA7BBC33E684}']
    function SQL(Value: String): IADRQuery; overload;
    function SQL(Value: string; const Args: array of const): IADRQuery; overload;

    function Open: TDataSet;
    function ExecSQL: IADRQuery;
    function ExecSQLAndCommit: IADRQuery;
  end;

  TADRDriverConnHelper = record helper for TADRDriverConn
  public
    function toString: String;
  end;

function CreateConnection: IADRConnection;

implementation

uses
  ADRConn.Model.Firedac.Connection;

function CreateConnection: IADRConnection;
begin
  result := TADRConnModelFiredacConnection.New;
end;

{ TADRDriverConnHelper }

function TADRDriverConnHelper.toString: String;
begin
  case Self of
    adrFirebird : result := 'Firebird';
    adrPostgres : result := 'Postgres';
    adrMySql    : result := 'MySQL';
    adrSQLite   : result := 'SQLite';
  end;
end;

end.

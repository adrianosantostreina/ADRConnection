unit ADRConn.Model.Interfaces;

interface

uses
  Data.DB,
  System.Classes,
  System.SysUtils;

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
    function Settings   : TFormatSettings;

    function &End: IADRConnection;
  end;

  IADRQuery = interface
    ['{AE3BE608-658C-46D4-AC60-6F4EDB6AF90D}']
    function SQL(Value: String): IADRQuery; overload;
    function SQL(Value: string; const Args: array of const): IADRQuery; overload;

    function ParamAsInteger      (Name: String; Value: Integer): IADRQuery;
    function ParamAsCurrency     (Name: String; Value: Currency): IADRQuery;
    function ParamAsFloat        (Name: String; Value: Double): IADRQuery;
    function ParamAsString       (Name: String; Value: String): IADRQuery;
    function ParamAsDateTime     (Name: String; Value: TDateTime): IADRQuery;
    function ParamAsDate         (Name: String; Value: TDateTime): IADRQuery;
    function ParamAsTime         (Name: String; Value: TDateTime): IADRQuery;
    function ParamAsBoolean      (Name: String; Value: Boolean): IADRQuery;

    function Open: TDataSet;
    function ExecSQL: IADRQuery;
    function ExecSQLAndCommit: IADRQuery;
  end;

  TADRDriverConnHelper = record helper for TADRDriverConn
  public
    function toString: String;
  end;

function CreateConnection: IADRConnection;
function CreateQuery(Connection: IADRConnection): IADRQuery;

implementation

uses
  ADRConn.Model.Firedac.Connection,
  ADRConn.Model.Firedac.Query;

function CreateConnection: IADRConnection;
begin
  result := TADRConnModelFiredacConnection.New;
end;

function CreateQuery(Connection: IADRConnection): IADRQuery;
begin
  result := TADRConnModelFiredacQuery.New(Connection);
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

unit ADRConn.Model.Interfaces;

interface

uses
  Data.DB,
  System.Classes,
  System.SysUtils;

type
  TADRDriverConn = (adrFirebird, adrPostgres, adrMySql, adrSQLite);
  IADRConnectionParams = interface;
  IADRGenerator = interface;

  IADRConnection = interface
    ['{681E59C7-6AAC-47DE-AE6D-F649C1922565}']
    function Connection: TCustomConnection;
    function Component : TComponent;

    function Params: IADRConnectionParams;

    function Connect: IADRConnection;
    function Disconnect: IADRConnection;
    function StartTransaction: IADRConnection;
    function Commit: IADRConnection;
    function Rollback: IADRConnection;
    function InTransaction: Boolean;
  end;

  IADRConnectionParams = interface
    ['{439941DC-9841-478E-9E9A-BCAB3015DB9C}']
    function Database(Value: string): IADRConnectionParams; overload;
    function Database: string; overload;
    function UserName(Value: string): IADRConnectionParams; overload;
    function UserName: string; overload;
    function Password(Value: string): IADRConnectionParams; overload;
    function Password: string; overload;
    function Server(Value: string): IADRConnectionParams; overload;
    function Server: string; overload;
    function Schema(Value: String): IADRConnectionParams; overload;
    function Schema: string; overload;
    function Lib(Value: string): IADRConnectionParams; overload;
    function Lib: string; overload;
    function Port(Value: Integer): IADRConnectionParams; overload;
    function Port: Integer; overload;
    function AutoCommit(Value: Boolean): IADRConnectionParams; overload;
    function AutoCommit: Boolean; overload;
    function Driver(Value: TADRDriverConn): IADRConnectionParams; overload;
    function Driver: TADRDriverConn; overload;
    function Settings: TFormatSettings;

    function &End: IADRConnection;
  end;

  IADRQuery = interface
    ['{AE3BE608-658C-46D4-AC60-6F4EDB6AF90D}']
    function SQL(Value: String): IADRQuery; overload;
    function SQL(Value: string; const Args: array of const): IADRQuery; overload;

    function DataSource(Value: TDataSource): IADRQuery;

    function ParamAsInteger(Name: String; Value: Integer): IADRQuery;
    function ParamAsCurrency(Name: String; Value: Currency): IADRQuery;
    function ParamAsFloat(Name: String; Value: Double): IADRQuery;
    function ParamAsString(Name: String; Value: String): IADRQuery;
    function ParamAsDateTime(Name: String; Value: TDateTime): IADRQuery;
    function ParamAsDate(Name: String; Value: TDateTime): IADRQuery;
    function ParamAsTime(Name: String; Value: TDateTime): IADRQuery;
    function ParamAsBoolean(Name: String; Value: Boolean): IADRQuery;

    function OpenDataSet: TDataSet;
    function Open: IADRQuery;
    function ExecSQL: IADRQuery;
    function ExecSQLAndCommit: IADRQuery;

    function Generator: IADRGenerator;
  end;

  IADRGenerator = interface
    ['{ABAB66A1-F210-4BD4-8594-F67F1781158A}']
    function GetCurrentSequence(Name: String): Double;
    function GetNextSequence(Name: String): Double;
  end;

  TADRDriverConnHelper = record helper for TADRDriverConn
  public
    function toString: String;
    procedure fromString(Value: String);
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

procedure TADRDriverConnHelper.fromString(Value: String);
var
  driver: string;
begin
  driver := Value.Trim.ToLower;
  if driver.Equals('firebird') then
  begin
    Self := adrFirebird;
    Exit;
  end;

  if driver.Equals('postgres') then
  begin
    Self := adrPostgres;
    Exit;
  end;

  if driver.Equals('mysql') then
  begin
    Self := adrMySql;
    Exit;
  end;

  if driver.Equals('sqlite') then
  begin
    Self := adrSQLite;
    Exit;
  end;
end;

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

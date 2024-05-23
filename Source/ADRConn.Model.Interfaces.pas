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
    function Component: TComponent;

    function Params: IADRConnectionParams;

    function Connected: Boolean;
    function Connect: IADRConnection;
    function Disconnect: IADRConnection;
    function StartTransaction: IADRConnection;
    function Commit: IADRConnection;
    function Rollback: IADRConnection;
    function InTransaction: Boolean;
  end;

  IADRConnectionParams = interface
    ['{439941DC-9841-478E-9E9A-BCAB3015DB9C}']
    function Database(AValue: string): IADRConnectionParams; overload;
    function Database: string; overload;
    function UserName(AValue: string): IADRConnectionParams; overload;
    function UserName: string; overload;
    function Password(AValue: string): IADRConnectionParams; overload;
    function Password: string; overload;
    function Server(AValue: string): IADRConnectionParams; overload;
    function Server: string; overload;
    function Schema(AValue: string): IADRConnectionParams; overload;
    function Schema: string; overload;
    function Lib(AValue: string): IADRConnectionParams; overload;
    function Lib: string; overload;
    function Port(AValue: Integer): IADRConnectionParams; overload;
    function Port: Integer; overload;
    function AutoCommit(AValue: Boolean): IADRConnectionParams; overload;
    function AutoCommit: Boolean; overload;
    function Driver(AValue: TADRDriverConn): IADRConnectionParams; overload;
    function Driver: TADRDriverConn; overload;
    function Settings: TFormatSettings;

    function AddParam(AName, AValue: string): IADRConnectionParams;
    function ParamNames: TArray<string>;
    function ParamByName(AName: string): string;

    function &End: IADRConnection;
  end;

  IADRQuery = interface
    ['{AE3BE608-658C-46D4-AC60-6F4EDB6AF90D}']
    function SQL(AValue: string): IADRQuery; overload;
    function SQL(AValue: string; const Args: array of const): IADRQuery; overload;

    function Component: TComponent;
    function DataSet: TDataSet;
    function DataSource(AValue: TDataSource): IADRQuery;

    function ParamAsInteger(AName: string; AValue: Integer; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsCurrency(AName: string; AValue: Currency; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsFloat(AName: string; AValue: Double; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsString(AName: string; AValue: string; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsDateTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsDate(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsBoolean(AName: string; AValue: Boolean; ANullIfEmpty: Boolean = False): IADRQuery; overload;

    function ArraySize(AValue: Integer): IADRQuery;
    function ParamAsInteger(AIndex: Integer; AName: string; AValue: Integer; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsCurrency(AIndex: Integer; AName: string; AValue: Currency; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsFloat(AIndex: Integer; AName: string; AValue: Double; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsString(AIndex: Integer; AName: string; AValue: string; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsDateTime(AIndex: Integer; AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsDate(AIndex: Integer; AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsTime(AIndex: Integer; AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsBoolean(AIndex: Integer; AName: string; AValue: Boolean; ANullIfEmpty: Boolean = False): IADRQuery; overload;

    function OpenDataSet: TDataSet;
    function Open: IADRQuery;
    function ExecSQL: IADRQuery;
    function ExecSQLAndCommit: IADRQuery;

    function Generator: IADRGenerator;
  end;

  IADRGenerator = interface
    ['{ABAB66A1-F210-4BD4-8594-F67F1781158A}']
    function GetCurrentSequence(AName: string): Double;
    function GetNextSequence(AName: string): Double;
  end;

  TADRDriverConnHelper = record helper for TADRDriverConn
  public
    function ToString: string;
    procedure fromString(AValue: string);
  end;

function CreateConnection: IADRConnection;
function CreateQuery(AConnection: IADRConnection): IADRQuery;

implementation

uses
  ADRConn.Model.Firedac.Connection,
  ADRConn.Model.Firedac.Query;

function CreateConnection: IADRConnection;
begin
  Result := TADRConnModelFiredacConnection.New;
end;

function CreateQuery(AConnection: IADRConnection): IADRQuery;
begin
  Result := TADRConnModelFiredacQuery.New(AConnection);
end;

{ TADRDriverConnHelper }

procedure TADRDriverConnHelper.fromString(AValue: string);
var
  LDriver: string;
begin
  LDriver := AValue.Trim.ToLower;
  if LDriver.Equals('firebird') then
  begin
    Self := adrFirebird;
    Exit;
  end;

  if LDriver.Equals('postgres') then
  begin
    Self := adrPostgres;
    Exit;
  end;

  if LDriver.Equals('mysql') then
  begin
    Self := adrMySql;
    Exit;
  end;

  if LDriver.Equals('sqlite') then
  begin
    Self := adrSQLite;
    Exit;
  end;
end;

function TADRDriverConnHelper.ToString: string;
begin
  case Self of
    adrFirebird:
      Result := 'Firebird';
    adrPostgres:
      Result := 'Postgres';
    adrMySql:
      Result := 'MySQL';
    adrSQLite:
      Result := 'SQLite';
  end;
end;

end.

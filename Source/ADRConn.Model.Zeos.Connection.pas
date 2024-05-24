unit ADRConn.Model.Zeos.Connection;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Params,
  System.Classes,
  System.SysUtils,
  Data.DB,
  ZCompatibility,
  ZConnection,
  ZDatasetUtils;

type
  TADRConnModelZeosConnection = class(TInterfacedObject, IADRConnection)
  private
    FConnection: TZConnection;
    FParams: IADRConnectionParams;

    function  GetProtocol: string;
    procedure Setup;
  protected
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
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IADRConnection;
  end;

implementation

{ TADRConnModelZeosConnection }

function TADRConnModelZeosConnection.Commit: IADRConnection;
begin
  Result := Self;
  FConnection.Commit;
end;

function TADRConnModelZeosConnection.Component: TComponent;
begin
  Result := FConnection;
end;

function TADRConnModelZeosConnection.Connect: IADRConnection;
begin
  Result := Self;
  if not FConnection.Connected then
  begin
    Setup;
    FConnection.Connected := True;
  end;
end;

function TADRConnModelZeosConnection.Connected: Boolean;
begin
  Result := FConnection.Connected;
end;

function TADRConnModelZeosConnection.Connection: TCustomConnection;
begin
  raise ENotSupportedException.Create('Function not supported to Zeos Driver.');
end;

constructor TADRConnModelZeosConnection.Create;
begin
  FParams := TADRConnModelParams.New(Self);
  FConnection := TZConnection.Create(nil);
  FConnection.Name := 'Conn';
end;

destructor TADRConnModelZeosConnection.Destroy;
begin
  FConnection.Free;
  inherited;
end;

function TADRConnModelZeosConnection.Disconnect: IADRConnection;
begin
  Result := Self;
  FConnection.Connected := False;
end;

function TADRConnModelZeosConnection.GetProtocol: string;
begin
  case FParams.Driver of
    adrMySql: Result := 'mysql';
    adrOracle: Result := 'oracle';
    adrSQLite: Result := 'sqlite';
    adrMSSQL: Result := 'mssql';
    adrPostgres: Result := 'postgresql';
    adrFirebird: Result := 'firebird';
  else
    raise ENotImplemented.CreateFmt('Not Implemented driver %s.', [FParams.Driver.ToString]);
  end;
end;

function TADRConnModelZeosConnection.InTransaction: Boolean;
begin
  Result := FConnection.InTransaction;
end;

class function TADRConnModelZeosConnection.New: IADRConnection;
begin
  Result := Self.Create;
end;

function TADRConnModelZeosConnection.Params: IADRConnectionParams;
begin
  Result := FParams;
end;

function TADRConnModelZeosConnection.Rollback: IADRConnection;
begin
  Result := Self;
  FConnection.Rollback;
end;

procedure TADRConnModelZeosConnection.Setup;
begin
  FConnection.AutoCommit := False;
  FConnection.Protocol := GetProtocol;
  FConnection.ControlsCodePage := TZControlsCodePage.cCP_UTF16;
  FConnection.HostName := FParams.Server;
  FConnection.Port := FParams.Port;
  FConnection.Database := FParams.Database;
  FConnection.User := FParams.UserName;
  FConnection.Password := FParams.Password;
{$IF CompilerVersion < 34.0}
  FConnection.AutoEncodeStrings := True;
{$ENDIF}

  if FParams.Driver = adrMSSQL then
    FConnection.LibraryLocation := ExtractFilePath(GetModuleName(HInstance)) + 'ntwdblib.dll';
end;

function TADRConnModelZeosConnection.StartTransaction: IADRConnection;
begin
  Result := Self;
  FConnection.StartTransaction;
end;

end.

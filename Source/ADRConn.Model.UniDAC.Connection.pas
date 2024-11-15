unit ADRConn.Model.UniDAC.Connection;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Params,
  ADRConn.Model.Events,
  System.Classes,
  System.SysUtils,
{$IF (not Defined(ANDROID)) and (not Defined(IOS))}
  InterBaseUniProvider,
  MySQLUniProvider,
  OracleUniProvider,
  PostgreSQLUniProvider,
  SQLServerUniProvider,
{$ENDIF}
  SQLiteUniProvider,
  Data.DB,
  MemDS,
  DBAccess,
  Uni;

type
  TADRConnModelUniDACConnection = class(TInterfacedObject, IADRConnection)
  private
    FConnection: TUniConnection;
    FEvents: IADRConnectionEvents;
    FParams: IADRConnectionParams;

    procedure Setup;
    function TryHandleException(AException: Exception): Boolean;
  protected
    function Connection: TCustomConnection;
    function Component: TComponent;
    function Events: IADRConnectionEvents;

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

{ TADRConnModelUniDACConnection }

function TADRConnModelUniDACConnection.Commit: IADRConnection;
begin
  Result := Self;
  FConnection.Commit;
end;

function TADRConnModelUniDACConnection.Component: TComponent;
begin
  Result := FConnection;
end;

function TADRConnModelUniDACConnection.Connect: IADRConnection;
begin
  Result := Self;
  try
    if not FConnection.Connected then
    begin
      Setup;
      FConnection.Connected := True;
    end;
  except
    on E: Exception do
      if not TryHandleException(E) then
        raise;
  end;
end;

function TADRConnModelUniDACConnection.Connected: Boolean;
begin
  Result := (Assigned(FConnection)) and (FConnection.Connected);
end;

function TADRConnModelUniDACConnection.Connection: TCustomConnection;
begin
  Result := FConnection;
end;

constructor TADRConnModelUniDACConnection.Create;
begin
  FConnection := TUniConnection.Create(nil);
  FParams := TADRConnModelParams.New(Self);
end;

destructor TADRConnModelUniDACConnection.Destroy;
begin
  FConnection.Free;
  inherited;
end;

function TADRConnModelUniDACConnection.Disconnect: IADRConnection;
begin
  Result := Self;
  FConnection.Connected := False;
end;

function TADRConnModelUniDACConnection.Events: IADRConnectionEvents;
begin
  if not Assigned(FEvents) then
    FEvents := TADRConnConnectionModelEvents.New;
  Result := FEvents;
end;

function TADRConnModelUniDACConnection.InTransaction: Boolean;
begin
  Result := FConnection.InTransaction;
end;

class function TADRConnModelUniDACConnection.New: IADRConnection;
begin
  Result := Self.Create;
end;

function TADRConnModelUniDACConnection.Params: IADRConnectionParams;
begin
  Result := FParams;
end;

function TADRConnModelUniDACConnection.Rollback: IADRConnection;
begin
  Result := Self;
  FConnection.Rollback;
end;

procedure TADRConnModelUniDACConnection.Setup;
var
  LParams: TArray<string>;
  LName: string;
  LValue: string;
begin
  FConnection.Database := FParams.Database;
  FConnection.Username := FParams.UserName;
  FConnection.Password := FParams.Password;
  FConnection.Server := FParams.Server;
  FConnection.Port := FParams.Port;

{$IF (not Defined(ANDROID)) and (not Defined(IOS))}
  case FParams.Driver of
    adrFirebird:
      FConnection.ProviderName := 'Interbase';
    adrPostgres:
      FConnection.ProviderName := 'PostgreSQL';
    adrMySql:
      FConnection.ProviderName := 'MySQL';
    adrSQLite:
      FConnection.ProviderName := 'SQLite';
    adrMSSQL:
      FConnection.ProviderName := 'SQL Server';
    adrOracle:
      FConnection.ProviderName := 'Oracle';
  end;
{$ELSE}
  FConnection.ProviderName := 'SQLite';
{$ENDIF}

  LParams := FParams.ParamNames;
  for LName in LParams do
  begin
    LValue := FParams.ParamByName(LName);
    FConnection.SpecificOptions.Values[FConnection.ProviderName + '.' + LName] := LValue;
  end;
end;

function TADRConnModelUniDACConnection.StartTransaction: IADRConnection;
begin
  Result := Self;
  FConnection.StartTransaction;
end;

function TADRConnModelUniDACConnection.TryHandleException(AException: Exception): Boolean;
begin
  Result := Events.TryHandleException(AException);
end;

end.

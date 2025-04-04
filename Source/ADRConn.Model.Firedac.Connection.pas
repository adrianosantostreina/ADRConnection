unit ADRConn.Model.Firedac.Connection;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Events,
  ADRConn.Model.Params,
  ADRConn.Model.Firedac.Driver,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
{$IFDEF MSWINDOWS}
  FireDAC.Comp.UI,
  FireDAC.VCLUI.Wait,
  FireDAC.UI.Intf,
{$ENDIF}
{$IFDEF LINUX}
  FireDAC.ConsoleUI.Wait,
{$ENDIF}
  Firedac.Phys,
  FireDAC.DApt,
  System.Classes,
  System.SysUtils;

type
  TADRConnModelFiredacConnection = class(TInterfacedObject, IADRConnection)
  private
    FOwner: Boolean;
    FEvents: IADRConnectionEvents;
    FConnection: TFDConnection;
{$IF (not Defined(ANDROID)) and (not Defined(IOS))}
    FCursor: TFDGUIxWaitCursor;
{$ENDIF}
    FDriver: TFDPhysDriverLink;
    FParams: IADRConnectionParams;

    procedure Setup;
    procedure CreateDriver;
    function GetDriverId: string;
    function TryHandleException(AException: Exception): Boolean;
  protected
    function Events: IADRConnectionEvents;
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
    constructor Create; overload;
    class function New: IADRConnection; overload;
    constructor Create(AComponent: TComponent); overload;
    class function New(AComponent: TComponent): IADRConnection; overload;
    destructor Destroy; override;
  end;

implementation

{ TADRConnModelFiredacConnection }

function TADRConnModelFiredacConnection.Commit: IADRConnection;
begin
  Result := Self;
  FConnection.Commit;
end;

function TADRConnModelFiredacConnection.Component: TComponent;
begin
  Result := FConnection;
end;

function TADRConnModelFiredacConnection.Connect: IADRConnection;
begin
  Result := Self;
  try
    if not FConnection.Connected then
    begin
      if FOwner then
        Setup;
      FConnection.Connected := True;
    end;
  except
    on E: Exception do
      if not TryHandleException(E) then
        raise;
  end;
end;

function TADRConnModelFiredacConnection.Connected: Boolean;
begin
  Result := (Assigned(FConnection)) and (FConnection.Connected);
end;

function TADRConnModelFiredacConnection.Connection: TCustomConnection;
begin
  Result := FConnection;
end;

constructor TADRConnModelFiredacConnection.Create;
begin
  FOwner := True;
  FConnection := TFDConnection.Create(nil);
  FParams := TADRConnModelParams.New(Self);
{$IF (not Defined(ANDROID)) and (not Defined(IOS))}
  FCursor := TFDGUIxWaitCursor.Create(nil);
{$ENDIF}
end;

constructor TADRConnModelFiredacConnection.Create(AComponent: TComponent);
begin
  FConnection := TFDConnection(AComponent);
  FOwner := False;
end;

procedure TADRConnModelFiredacConnection.CreateDriver;
begin
  FreeAndNil(FDriver);
  FDriver := TADRConnModelFiredacDriver.GetDriver(FParams);
  FDriver.VendorLib := FParams.Lib;
end;

destructor TADRConnModelFiredacConnection.Destroy;
begin
  if FOwner then
  begin
    FConnection.Free;
    FDriver.Free;
{$IF (not Defined(ANDROID)) and (not Defined(IOS))}
    FCursor.Free;
{$ENDIF}
  end;
  inherited;
end;

function TADRConnModelFiredacConnection.Disconnect: IADRConnection;
begin
  Result := Self;
  FConnection.Connected := False;
end;

function TADRConnModelFiredacConnection.Events: IADRConnectionEvents;
begin
  if not Assigned(FEvents) then
    FEvents := TADRConnConnectionModelEvents.New;
  Result := FEvents;
end;

function TADRConnModelFiredacConnection.GetDriverId: string;
begin
  case FParams.Driver of
    adrFirebird:
      Result := 'FB';
    adrMSSQL:
      Result := 'MSSQL';
    adrMySql:
      Result := 'MySQL';
    adrSQLite:
      Result := 'SQLite';
    adrPostgres:
      Result := 'PG';
    adrOracle:
      Result := 'Ora';
    adrMongoDB:
      Result := 'Mongo';
  else
    raise Exception.CreateFmt('Driver Firedac not found for %s.', [FParams.Driver.toString]);
  end;
end;

function TADRConnModelFiredacConnection.InTransaction: Boolean;
begin
  Result := FConnection.InTransaction;
end;

class function TADRConnModelFiredacConnection.New(AComponent: TComponent): IADRConnection;
begin
  Result := Self.Create(AComponent);
end;

class function TADRConnModelFiredacConnection.New: IADRConnection;
begin
  Result := Self.Create;
end;

function TADRConnModelFiredacConnection.Params: IADRConnectionParams;
begin
  Result := FParams;
end;

function TADRConnModelFiredacConnection.Rollback: IADRConnection;
begin
  Result := Self;
  FConnection.Rollback;
end;

procedure TADRConnModelFiredacConnection.Setup;
var
  LParams: TArray<string>;
  LName: string;
  LValue: string;
begin
  FConnection.DriverName := GetDriverId;
  FConnection.Params.Values['Database'] := FParams.Database;
  FConnection.Params.Values['User_Name'] := FParams.UserName;
  FConnection.Params.Values['Password'] := FParams.Password;
  FConnection.Params.Values['Server'] := FParams.Server;
  FConnection.Params.Values['Port'] := IntToStr(FParams.Port);
  FConnection.Params.Values['ApplicationName'] := FParams.AppName;
  FConnection.TxOptions.AutoCommit := FParams.AutoCommit;

  LParams := FParams.ParamNames;
  for LName in LParams do
  begin
    LValue := FParams.ParamByName(LName);
    FConnection.Params.Values[LName] := LValue;
  end;

  CreateDriver;
end;

function TADRConnModelFiredacConnection.StartTransaction: IADRConnection;
begin
  Result := Self;
  FConnection.StartTransaction;
end;

function TADRConnModelFiredacConnection.TryHandleException(AException: Exception): Boolean;
begin
  Result := Events.HandleException(AException);
end;

end.


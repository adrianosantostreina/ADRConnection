unit ADRConn.Model.Firedac.Connection;

interface

uses
  ADRConn.Model.Interfaces,
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
    FConnection: TFDConnection;
{$IF (not Defined(ANDROID)) and (not Defined(IOS))}
    FCursor: TFDGUIxWaitCursor;
{$ENDIF}
    FDriver: TFDPhysDriverLink;
    FParams: IADRConnectionParams;

    procedure Setup;
    procedure CreateDriver;
    function GetDriverId: string;
  protected
    function Connection: TCustomConnection;
    function Component: TComponent;

    function Params: IADRConnectionParams;

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
  if not FConnection.Connected then
  begin
    Setup;
    FConnection.Connected := True;
  end;
end;

function TADRConnModelFiredacConnection.Connection: TCustomConnection;
begin
  Result := FConnection;
end;

constructor TADRConnModelFiredacConnection.Create;
begin
  FConnection := TFDConnection.Create(nil);
  FParams := TADRConnModelParams.New(Self);
{$IF (not Defined(ANDROID)) and (not Defined(IOS))}
  FCursor := TFDGUIxWaitCursor.Create(nil);
{$ENDIF}
end;

procedure TADRConnModelFiredacConnection.CreateDriver;
begin
  FreeAndNil(FDriver);
  FDriver := TADRConnModelFiredacDriver.GetDriver(FParams);
  FDriver.VendorLib := FParams.Lib;
end;

destructor TADRConnModelFiredacConnection.Destroy;
begin
  FConnection.Free;
  FDriver.Free;
{$IF (not Defined(ANDROID)) and (not Defined(IOS))}
  FCursor.Free;
{$ENDIF}
  inherited;
end;

function TADRConnModelFiredacConnection.Disconnect: IADRConnection;
begin
  Result := Self;
  FConnection.Connected := False;
end;

function TADRConnModelFiredacConnection.GetDriverId: string;
begin
  case FParams.Driver of
    adrFirebird:
      Result := 'FB';
    adrMySql:
      Result := 'MySQL';
    adrSQLite:
      Result := 'SQLite';
    adrPostgres:
      Result := 'PG';
  else
    raise Exception.CreateFmt('Driver Firedac not found for %s.', [FParams.Driver.toString]);
  end;
end;

function TADRConnModelFiredacConnection.InTransaction: Boolean;
begin
  Result := FConnection.InTransaction;
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

end.

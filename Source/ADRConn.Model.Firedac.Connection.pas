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

type TADRConnModelFiredacConnection = class(TInterfacedObject, IADRConnection)

  private
    FConnection: TFDConnection;
    FCursor: TFDGUIxWaitCursor;
    FDriver: TFDPhysDriverLink;
    FParams: IADRConnectionParams;

    procedure Setup;
    procedure CreateDriver;
    function GetDriverId: String;

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
    constructor create;
    destructor Destroy; override;
    class function New: IADRConnection;

end;

implementation

{ TADRConnModelFiredacConnection }

function TADRConnModelFiredacConnection.Commit: IADRConnection;
begin
  result := Self;
  FConnection.Commit;
end;

function TADRConnModelFiredacConnection.Component: TComponent;
begin
  result := FConnection;
end;

function TADRConnModelFiredacConnection.Connect: IADRConnection;
begin
  result := Self;
  if not FConnection.Connected then
  begin
    Setup;
    FConnection.Connected := True;
  end;
end;

function TADRConnModelFiredacConnection.Connection: TCustomConnection;
begin
  result := FConnection;
end;

constructor TADRConnModelFiredacConnection.create;
begin
  FConnection := TFDConnection.Create(nil);
  FCursor := TFDGUIxWaitCursor.Create(nil);
  FParams := TADRConnModelParams.New(Self);
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
  FCursor.Free;
  inherited;
end;

function TADRConnModelFiredacConnection.Disconnect: IADRConnection;
begin
  result := Self;
  FConnection.Connected := False;
end;

function TADRConnModelFiredacConnection.GetDriverId: String;
begin
  case FParams.Driver of
    adrFirebird : Result := 'FB';
    adrMySql : Result := 'MySQL';
    adrSQLite : Result := 'SQLite';
    adrPostgres : result := 'PG';
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
  result := Self.create;
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
begin
  FConnection.DriverName := GetDriverId;
  FConnection.Params.Values['Database'] := FParams.Database;
  FConnection.Params.Values['User_Name'] := FParams.UserName;
  FConnection.Params.Values['Password'] := FParams.Password;
  FConnection.Params.Values['Server'] := FParams.Server;
  FConnection.Params.Values['Port'] := IntToStr(FParams.Port);
  FConnection.TxOptions.AutoCommit := FParams.AutoCommit;

  CreateDriver;
end;

function TADRConnModelFiredacConnection.StartTransaction: IADRConnection;
begin
  Result := Self;
  FConnection.StartTransaction;
end;

end.

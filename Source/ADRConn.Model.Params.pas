unit ADRConn.Model.Params;

interface

uses
  ADRConn.Model.Interfaces,
  System.SysUtils;

type TADRConnModelParams = class(TInterfacedObject, IADRConnectionParams)

  private
    [WeakAttribute]
    FConnection: IADRConnection;

    FDatabase: String;
    FUserName: String;
    FPassword: String;
    FServer: String;
    FSchema: string;
    FLib: string;
    FFormatSettings: TFormatSettings;
    FPort: Integer;
    FAutoCommit: Boolean;
    FDriver: TADRDriverConn;

  protected
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

  public
    constructor create(Connection: IADRConnection);
    class function New(Connection: IADRConnection): IADRConnectionParams;
end;

implementation

{ TADRConnModelParams }

function TADRConnModelParams.AutoCommit: Boolean;
begin
  result := FAutoCommit;
end;

function TADRConnModelParams.AutoCommit(Value: Boolean): IADRConnectionParams;
begin
  result := Self;
  FAutoCommit := Value;
end;

constructor TADRConnModelParams.create(Connection: IADRConnection);
begin
  FConnection := Connection;
  FAutoCommit := True;
  FDriver := adrFirebird;

  FFormatSettings := TFormatSettings.Create;
  FFormatSettings.DateSeparator := '-';
  FFormatSettings.ShortDateFormat := 'yyyy-MM-dd';
  FFormatSettings.TimeSeparator := ':';
  FFormatSettings.ShortTimeFormat := 'hh:mm';
  FFormatSettings.LongTimeFormat := 'hh:mm:ss';
end;

function TADRConnModelParams.Database(Value: string): IADRConnectionParams;
begin
  result := Self;
  FDatabase := Value;
end;

function TADRConnModelParams.Database: string;
begin
  result := FDatabase;
end;

function TADRConnModelParams.Driver(Value: TADRDriverConn): IADRConnectionParams;
begin
  result := Self;
  FDriver := Value;
end;

function TADRConnModelParams.Driver: TADRDriverConn;
begin
  result := FDriver;
end;

function TADRConnModelParams.&End: IADRConnection;
begin
  Result := FConnection;
end;

function TADRConnModelParams.Lib: string;
begin
  result := FLib;
end;

function TADRConnModelParams.Lib(Value: string): IADRConnectionParams;
begin
  result := Self;
  FLib   := Value;
end;

class function TADRConnModelParams.New(Connection: IADRConnection): IADRConnectionParams;
begin
  result := Self.create(Connection);
end;

function TADRConnModelParams.Password(Value: string): IADRConnectionParams;
begin
  result := Self;
  FPassword := Value;
end;

function TADRConnModelParams.Password: string;
begin
  result := FPassword;
end;

function TADRConnModelParams.Port(Value: Integer): IADRConnectionParams;
begin
  result := Self;
  FPort  := Value;
end;

function TADRConnModelParams.Port: Integer;
begin
  result := FPort;
end;

function TADRConnModelParams.Schema: string;
begin
  result := FSchema;
end;

function TADRConnModelParams.Schema(Value: String): IADRConnectionParams;
begin
  result := Self;
  FSchema := Value;
end;

function TADRConnModelParams.Server(Value: string): IADRConnectionParams;
begin
  result := Self;
  FServer := Value;
end;

function TADRConnModelParams.Server: string;
begin
  result := FServer;
end;

function TADRConnModelParams.Settings: TFormatSettings;
begin
  result := FFormatSettings;
end;

function TADRConnModelParams.UserName: string;
begin
  result := FUserName;
end;

function TADRConnModelParams.UserName(Value: string): IADRConnectionParams;
begin
  result := Self;
  FUserName := Value;
end;

end.

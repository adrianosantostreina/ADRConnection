unit ADRConn.Model.Params;

interface

uses
  ADRConn.Model.Interfaces,
  System.Generics.Collections,
  System.SysUtils;

type
  TADRConnModelParams = class(TInterfacedObject, IADRConnectionParams)
  private
    [WeakAttribute]
    FConnection: IADRConnection;
    FDatabase: string;
    FUserName: string;
    FPassword: string;
    FServer: string;
    FSchema: string;
    FLib: string;
    FFormatSettings: TFormatSettings;
    FPort: Integer;
    FAutoCommit: Boolean;
    FDriver: TADRDriverConn;
    FAppName: string;
    FParams: TDictionary<string, string>;
  protected
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
    function AppName(AValue: string): IADRConnectionParams; overload;
    function AppName: string; overload;
    function Settings: TFormatSettings;

    function AddParam(AName, AValue: string): IADRConnectionParams;
    function ParamNames: TArray<string>;
    function ParamByName(AName: string): string;
    function &End: IADRConnection;
  public
    constructor Create(AConnection: IADRConnection);
    class function New(AConnection: IADRConnection): IADRConnectionParams;
    destructor Destroy; override;
  end;

implementation

{ TADRConnModelParams }

function TADRConnModelParams.AddParam(AName, AValue: string): IADRConnectionParams;
begin
  Result := Self;
  FParams.AddOrSetValue(AName, AValue);
end;

function TADRConnModelParams.AppName: string;
begin
  Result := FAppName;
end;

function TADRConnModelParams.AppName(AValue: string): IADRConnectionParams;
begin
  Result := Self;
  FAppName := AValue;
end;

function TADRConnModelParams.AutoCommit: Boolean;
begin
  Result := FAutoCommit;
end;

function TADRConnModelParams.AutoCommit(AValue: Boolean): IADRConnectionParams;
begin
  Result := Self;
  FAutoCommit := AValue;
end;

constructor TADRConnModelParams.Create(AConnection: IADRConnection);
begin
  FConnection := AConnection;
  FParams := TDictionary<string, string>.Create;
  FAutoCommit := True;
  FDriver := adrFirebird;
  FAppName := ExtractFileName(GetModuleName(HInstance));

  FFormatSettings := TFormatSettings.Create;
  FFormatSettings.DateSeparator := '-';
  FFormatSettings.ShortDateFormat := 'yyyy-MM-dd';
  FFormatSettings.TimeSeparator := ':';
  FFormatSettings.ShortTimeFormat := 'hh:mm';
  FFormatSettings.LongTimeFormat := 'hh:mm:ss';
end;

function TADRConnModelParams.Database(AValue: string): IADRConnectionParams;
begin
  Result := Self;
  FDatabase := AValue;
end;

function TADRConnModelParams.Database: string;
begin
  Result := FDatabase;
end;

destructor TADRConnModelParams.Destroy;
begin
  FParams.Free;
  inherited;
end;

function TADRConnModelParams.Driver(AValue: TADRDriverConn): IADRConnectionParams;
begin
  Result := Self;
  FDriver := AValue;
end;

function TADRConnModelParams.Driver: TADRDriverConn;
begin
  Result := FDriver;
end;

function TADRConnModelParams.&End: IADRConnection;
begin
  Result := FConnection;
end;

function TADRConnModelParams.Lib: string;
begin
  Result := FLib;
end;

function TADRConnModelParams.Lib(AValue: string): IADRConnectionParams;
begin
  Result := Self;
  FLib := AValue;
end;

class function TADRConnModelParams.New(AConnection: IADRConnection): IADRConnectionParams;
begin
  Result := Self.create(AConnection);
end;

function TADRConnModelParams.Password(AValue: string): IADRConnectionParams;
begin
  Result := Self;
  FPassword := AValue;
end;

function TADRConnModelParams.ParamByName(AName: string): string;
begin
  Result := EmptyStr;
  if FParams.ContainsKey(AName) then
    Result := FParams.Items[AName];
end;

function TADRConnModelParams.ParamNames: TArray<string>;
begin
  Result := FParams.Keys.ToArray;
end;

function TADRConnModelParams.Password: string;
begin
  Result := FPassword;
end;

function TADRConnModelParams.Port(AValue: Integer): IADRConnectionParams;
begin
  Result := Self;
  FPort := AValue;
end;

function TADRConnModelParams.Port: Integer;
begin
  Result := FPort;
end;

function TADRConnModelParams.Schema: string;
begin
  Result := FSchema;
end;

function TADRConnModelParams.Schema(AValue: string): IADRConnectionParams;
begin
  Result := Self;
  FSchema := AValue;
end;

function TADRConnModelParams.Server(AValue: string): IADRConnectionParams;
begin
  Result := Self;
  FServer := AValue;
end;

function TADRConnModelParams.Server: string;
begin
  Result := FServer;
end;

function TADRConnModelParams.Settings: TFormatSettings;
begin
  Result := FFormatSettings;
end;

function TADRConnModelParams.UserName: string;
begin
  Result := FUserName;
end;

function TADRConnModelParams.UserName(AValue: string): IADRConnectionParams;
begin
  Result := Self;
  FUserName := AValue;
end;

end.

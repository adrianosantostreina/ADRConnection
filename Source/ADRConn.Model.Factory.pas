unit ADRConn.Model.Factory;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Config.IniFile,
  System.SysUtils;

type
  TADRConnConfigIni = ADRConn.Config.IniFile.TADRConnConfigIni;

  TADRConnModelFactory = class
  public
    class function GetConnectionIniFile(ASection: string = ''): IADRConnection;
    class function GetConnection: IADRConnection;
    class function GetQuery(AConnection: IADRConnection): IADRQuery;
  end;

implementation

{ TADRConnModelFactory }

class function TADRConnModelFactory.GetConnection: IADRConnection;
begin
  Result := CreateConnection;
end;

class function TADRConnModelFactory.GetConnectionIniFile(ASection: string = ''): IADRConnection;
var
  LIniConfig: TADRConnConfigIni;
begin
  LIniConfig := TADRConnConfigIni.GetInstance(ASection);
  Result := CreateConnection;
  Result.Params
    .Driver(LIniConfig.Driver)
    .Server(LIniConfig.Server)
    .Database(LIniConfig.Database)
    .UserName(LIniConfig.UserName)
    .Password(LIniConfig.Password);

  if LIniConfig.Port > 0 then
    Result.Params.Port(LIniConfig.Port);

  if not LIniConfig.VendorLib.IsEmpty then
    Result.Params.Lib(LIniConfig.VendorLib);
end;

class function TADRConnModelFactory.GetQuery(AConnection: IADRConnection): IADRQuery;
begin
  Result := CreateQuery(AConnection);
end;

end.

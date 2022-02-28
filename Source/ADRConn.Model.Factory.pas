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
    class function GetConnectionIniFile(ASection: String = ''): IADRConnection;
    class function GetConnection: IADRConnection;
    class function GetQuery(AConnection: IADRConnection): IADRQuery;
end;

implementation

{ TADRConnModelFactory }

class function TADRConnModelFactory.GetConnection: IADRConnection;
begin
  result := CreateConnection;
end;

class function TADRConnModelFactory.GetConnectionIniFile(ASection: String): IADRConnection;
var
  iniConfig: TADRConnConfigIni;
begin
  iniConfig := TADRConnConfigIni.GetInstance(ASection);
  Result := CreateConnection;
  Result.Params
    .Driver(iniConfig.Driver)
    .Server(iniConfig.Server)
    .Database(iniConfig.Database)
    .UserName(iniConfig.UserName)
    .Password(iniConfig.Password);

  if iniConfig.Port > 0 then
    Result.Params.Port(iniConfig.Port);

  if not iniConfig.VendorLib.IsEmpty then
    Result.Params.Lib(iniConfig.VendorLib);
end;

class function TADRConnModelFactory.GetQuery(AConnection: IADRConnection): IADRQuery;
begin
  result := CreateQuery(AConnection);
end;

end.

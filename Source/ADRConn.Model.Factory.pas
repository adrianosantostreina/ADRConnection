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
    class function GetConnectionIniFile: IADRConnection;
end;

implementation

{ TADRConnModelFactory }

class function TADRConnModelFactory.GetConnectionIniFile: IADRConnection;
var
  iniConfig: TADRConnConfigIni;
begin
  iniConfig := TADRConnConfigIni.Create;
  try
    Result := CreateConnection;
    Result.Params
      .Server(iniConfig.Server)
      .Database(iniConfig.Database)
      .UserName(iniConfig.UserName)
      .Password(iniConfig.Password);

    if iniConfig.Port > 0 then
      Result.Params.Port(iniConfig.Port);

    if not iniConfig.VendorLib.IsEmpty then
      Result.Params.Lib(iniConfig.VendorLib);
  finally
    iniConfig.Free;
  end;
end;

end.

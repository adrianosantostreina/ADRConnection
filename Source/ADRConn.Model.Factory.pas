unit ADRConn.Model.Factory;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Config.IniFile,
  System.SysUtils;

type TADRConnModelFactory = class

  public
    class function GetConnectionIniFile: IADRConnection;
end;

implementation

{ TADRConnModelFactory }

class function TADRConnModelFactory.GetConnectionIniFile: IADRConnection;
begin
  Result := CreateConnection;
  Result.Params
    .Server(TADRConnConfigIni.Server)
    .Database(TADRConnConfigIni.Database)
    .UserName(TADRConnConfigIni.UserName)
    .Password(TADRConnConfigIni.Password);

  if TADRConnConfigIni.Port > 0 then
    Result.Params.Port(TADRConnConfigIni.Port);

  if not TADRConnConfigIni.VendorLib.IsEmpty then
    Result.Params.Lib(TADRConnConfigIni.VendorLib);
end;

end.

unit ADRConn.Config.IniFile;

interface

uses
  System.IniFiles,
  System.SysUtils;

type TADRConnConfigIni = class

  protected
    class var FFileName    : string;
    class var FDriverName  : string;
    class var FDatabase    : string;
    class var FServer      : string;
    class var FUserName    : string;
    class var FPassword    : string;
    class var FPort        : Integer;
    class var FVendorLib   : string;
    class var FProtocol    : string;

    class function GetIniFile: TIniFile;
  public
    class constructor Create;

    class property FileName   : string   read FFileName   write FFileName;
    class property DriverName : string   read FDriverName write FFileName;
    class property Database   : string   read FDatabase   write FDatabase;
    class property UserName   : string   read FUserName   write FUserName;
    class property Password   : string   read FPassword   write FPassword;
    class property Server     : string   read FServer     write FServer;
    class property Port       : Integer  read FPort       write FPort;
    class property VendorLib  : string   read FVendorLib  write FVendorLib;
    class property Protocol   : string   read FProtocol   write FProtocol;
end;

implementation

{ TADRConnConfigIni }

class constructor TADRConnConfigIni.Create;
var
  IniFile : TIniFile;
begin
  if FFileName = EmptyStr then
    FFileName :=  ChangeFileExt(GetModuleName(HInstance), '.ini');

  IniFile := TIniFile.Create(FFileName);
  try
    FDriverName  := IniFile.ReadString('CONFIG' , 'DriverName' , FDriverName);
    FDatabase    := IniFile.ReadString('CONFIG' , 'Database'   , FDatabase);
    FUserName    := IniFile.ReadString('CONFIG' , 'User_Name'   , FUserName);
    FPassword    := IniFile.ReadString('CONFIG' , 'Password'   , FPassword);
    FServer      := IniFile.ReadString('CONFIG' , 'Server'     , FServer);
    FPort        := IniFile.ReadInteger('CONFIG', 'Port'       , FPort);
    FVendorLib   := IniFile.ReadString('CONFIG' , 'VendorLib'  , FVendorLib);
    FProtocol    := IniFile.ReadString('CONFIG' , 'Protocol'   , FProtocol);
  finally
    IniFile.Free;
  end;
end;

class function TADRConnConfigIni.GetIniFile: TIniFile;
begin
  if FFileName = EmptyStr then
    FFileName :=  ExtractFilePath(ParamStr(0)) + 'Config.ini';

  result := TIniFile.Create(FFileName);
end;

end.

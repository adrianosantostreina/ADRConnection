unit ADRConn.Config.IniFile;

interface

uses
  ADRConn.Model.Interfaces
  System.IniFiles,
  System.SysUtils;

type TADRConnConfigIni = class

  private
    FFileName    : string;
    FDriverName  : string;
    FDatabase    : string;
    FServer      : string;
    FUserName    : string;
    FPassword    : string;
    FPort        : Integer;
    FVendorLib   : string;
    FProtocol    : string;

  protected
    function GetIniFile: TIniFile; virtual;

  public
    constructor Create;

    property FileName   : string   read FFileName   write FFileName;
    property DriverName : string   read FDriverName write FFileName;
    property Database   : string   read FDatabase   write FDatabase;
    property UserName   : string   read FUserName   write FUserName;
    property Password   : string   read FPassword   write FPassword;
    property Server     : string   read FServer     write FServer;
    property Port       : Integer  read FPort       write FPort;
    property VendorLib  : string   read FVendorLib  write FVendorLib;
    property Protocol   : string   read FProtocol   write FProtocol;
end;

implementation

{ TADRConnConfigIni }

constructor TADRConnConfigIni.Create;
var
  IniFile : TIniFile;
begin
  IniFile := GetIniFile;
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

function TADRConnConfigIni.GetIniFile: TIniFile;
begin
  result := TIniFile.Create(FFileName);
end;

end.

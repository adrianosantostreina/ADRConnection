unit ADRConn.Config.IniFile;

interface

uses
  ADRConn.Model.Interfaces,
  System.IniFiles,
  System.SysUtils;

const
  SECTION_DATABASE = 'CONFIG';

type TADRConnConfigIni = class

  private
    FFileName    : string;
    FDatabase    : string;
    FServer      : string;
    FUserName    : string;
    FPassword    : string;
    FPort        : Integer;
    FVendorLib   : string;
    FProtocol    : string;
    FDriver: TADRDriverConn;

  protected
    function GetIniFileName: string;
    function GetIniFile: TIniFile; virtual;

    procedure Initialize;
  public
    constructor Create;

    property Driver     : TADRDriverConn read FDriver write FDriver;
    property FileName   : string   read FFileName   write FFileName;
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
  Initialize;
  IniFile := GetIniFile;
  try
    FDriver.fromString(IniFile.ReadString(SECTION_DATABASE, 'Driver', 'Firebird'));

    FDatabase    := IniFile.ReadString(SECTION_DATABASE , 'Database'   , FDatabase);
    FUserName    := IniFile.ReadString(SECTION_DATABASE , 'User_Name'   , FUserName);
    FPassword    := IniFile.ReadString(SECTION_DATABASE , 'Password'   , FPassword);
    FServer      := IniFile.ReadString(SECTION_DATABASE , 'Server'     , FServer);
    FVendorLib   := IniFile.ReadString(SECTION_DATABASE , 'VendorLib'  , FVendorLib);
    FProtocol    := IniFile.ReadString(SECTION_DATABASE , 'Protocol'   , FProtocol);
    FPort        := IniFile.ReadInteger(SECTION_DATABASE, 'Port'       , FPort);
  finally
    IniFile.Free;
  end;
end;

function TADRConnConfigIni.GetIniFile: TIniFile;
begin
  result := TIniFile.Create(GetIniFileName);
end;

function TADRConnConfigIni.GetIniFileName: string;
begin
  result := ChangeFileExt(GetModuleName(HInstance), '.ini');
end;

procedure TADRConnConfigIni.Initialize;
var
  fileName: String;
  iniFile : TIniFile;
begin
  fileName := GetIniFileName;
  if not FileExists(fileName) then
  begin
    iniFile := GetIniFile;
    try
      iniFile.WriteString(SECTION_DATABASE, 'Driver', FDriver.toString);
      iniFile.WriteString(SECTION_DATABASE, 'Database', 'adrconntest');
      iniFile.WriteString(SECTION_DATABASE, 'User_Name', 'sysdba');
      iniFile.WriteString(SECTION_DATABASE, 'Password', 'masterkey');
      iniFile.WriteString(SECTION_DATABASE, 'Server', '127.0.0.1');
      iniFile.WriteString(SECTION_DATABASE, 'VendorLib', 'fbclient.dll');
      iniFile.WriteString(SECTION_DATABASE, 'Protocol', 'http');
      iniFile.WriteInteger(SECTION_DATABASE, 'Port', 3050);
    finally
      iniFile.Free;
    end;
  end;
end;

end.

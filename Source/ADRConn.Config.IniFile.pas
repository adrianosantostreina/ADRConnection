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

    class var FInstance: TADRConnConfigIni;

    constructor CreatePrivate;

    function InternalReadString (const Ident: string; const Default: String = ''; const Section: String = SECTION_DATABASE): string;
    function InternalReadInteger(const Ident: string; const Default: Integer = 0; const Section: String = SECTION_DATABASE): Integer;
    function InternalReadBool   (const Ident: string; const Default: Boolean = False; const Section: String = SECTION_DATABASE): Boolean;

    function InternalWriteString (const Ident: string; const Value: string; const Section: String = SECTION_DATABASE): TADRConnConfigIni;
    function InternalWriteInteger(const Ident: string; const Value: Integer; const Section: String = SECTION_DATABASE): TADRConnConfigIni;
    function InternalWriteBool   (const Ident: string; const Value: Boolean; const Section: String = SECTION_DATABASE): TADRConnConfigIni;

  protected
    class function GetDefaultInstance: TADRConnConfigIni;
    function GetIniFileName: string;
    function GetIniFile: TIniFile; virtual;

    procedure Initialize;
  public
    constructor create;

    property Driver     : TADRDriverConn read FDriver write FDriver;
    property FileName   : string   read FFileName   write FFileName;
    property Database   : string   read FDatabase   write FDatabase;
    property UserName   : string   read FUserName   write FUserName;
    property Password   : string   read FPassword   write FPassword;
    property Server     : string   read FServer     write FServer;
    property Port       : Integer  read FPort       write FPort;
    property VendorLib  : string   read FVendorLib  write FVendorLib;
    property Protocol   : string   read FProtocol   write FProtocol;

    class function ReadString (const Ident: string; const Default: String = ''; const Section: String = SECTION_DATABASE): string;
    class function ReadBool   (const Ident: string; const Default: Boolean = False; const Section: String = SECTION_DATABASE): Boolean;
    class function ReadInteger(const Ident: string; const Default: Integer; const Section: String = SECTION_DATABASE): Integer;

    class function WriteString (const Ident: string; const Value: string; const Section: String = SECTION_DATABASE): TADRConnConfigIni;
    class function WriteInteger(const Ident: string; const Value: Integer; const Section: String = SECTION_DATABASE): TADRConnConfigIni;
    class function WriteBool   (const Ident: string; const Value: Boolean; const Section: String = SECTION_DATABASE): TADRConnConfigIni;

    class function GetInstance: TADRConnConfigIni;
    class destructor UnInitialize;
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

constructor TADRConnConfigIni.CreatePrivate;
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

class function TADRConnConfigIni.GetDefaultInstance: TADRConnConfigIni;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TADRConnConfigIni.CreatePrivate;
  end;

  result := FInstance;
end;

function TADRConnConfigIni.GetIniFile: TIniFile;
begin
  result := TIniFile.Create(GetIniFileName);
end;

function TADRConnConfigIni.GetIniFileName: string;
begin
  result := ChangeFileExt(GetModuleName(HInstance), '.ini');
end;

class function TADRConnConfigIni.GetInstance: TADRConnConfigIni;
begin
  result := TADRConnConfigIni.GetDefaultInstance;
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

class function TADRConnConfigIni.ReadBool(const Ident: string; const Default: Boolean = False; const Section: String = SECTION_DATABASE): Boolean;
begin
  result := Self.GetInstance.InternalReadBool(Ident, Default, Section);
end;

class function TADRConnConfigIni.ReadInteger(const Ident: string; const Default: Integer; const Section: String): Integer;
begin
  result := Self.GetInstance.InternalReadInteger(Ident, Default, Section);
end;

function TADRConnConfigIni.InternalReadBool(const Ident: string; const Default: Boolean; const Section: String): Boolean;
var
  iniFile: TIniFile;
begin
  iniFile := GetIniFile;
  try
    result := iniFile.ReadBool(Section, Ident, Default);
    iniFile.WriteBool(Section, Ident, Result);
  finally
    iniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalReadInteger(const Ident: string; const Default: Integer; const Section: String): Integer;
var
  iniFile: TIniFile;
begin
  iniFile := GetIniFile;
  try
    result := iniFile.ReadInteger(Section, Ident, Default);
    iniFile.WriteInteger(Section, Ident, result);
  finally
    iniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalReadString(const Ident, Default, Section: String): string;
var
  iniFile: TIniFile;
begin
  iniFile := GetIniFile;
  try
    result := iniFile.ReadString(Section, Ident, Default);
    iniFile.WriteString(Section, Ident, result);
  finally
    iniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalWriteBool(const Ident: string; const Value: Boolean; const Section: String): TADRConnConfigIni;
var
  iniFile: TIniFile;
begin
  result := Self;
  iniFile := GetIniFile;
  try
    iniFile.WriteBool(Section, Ident, Value);
  finally
    iniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalWriteInteger(const Ident: string; const Value: Integer; const Section: String): TADRConnConfigIni;
var
  iniFile: TIniFile;
begin
  result := Self;
  iniFile := GetIniFile;
  try
    iniFile.WriteInteger(Section, Ident, Value);
  finally
    iniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalWriteString(const Ident, Value, Section: String): TADRConnConfigIni;
var
  iniFile: TIniFile;
begin
  result := Self;
  iniFile := GetIniFile;
  try
    iniFile.WriteString(Section, Ident, Value);
  finally
    iniFile.Free;
  end;
end;

class function TADRConnConfigIni.ReadString(const Ident, Default, Section: String): string;
begin
  result := Self.GetInstance.InternalReadString(Ident, Default, Section);
end;

class destructor TADRConnConfigIni.UnInitialize;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
end;

class function TADRConnConfigIni.WriteBool(const Ident: string; const Value: Boolean; const Section: String): TADRConnConfigIni;
begin
  result := Self.GetInstance.InternalWriteBool(Ident, Value, Section);
end;

class function TADRConnConfigIni.WriteInteger(const Ident: string; const Value: Integer; const Section: String): TADRConnConfigIni;
begin
  result := Self.GetInstance.InternalWriteInteger(Ident, Value, Section);
end;

class function TADRConnConfigIni.WriteString(const Ident, Value, Section: String): TADRConnConfigIni;
begin
  result := Self.GetInstance.InternalWriteString(Ident, Value, Section);
end;

end.

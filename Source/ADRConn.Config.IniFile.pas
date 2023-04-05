unit ADRConn.Config.IniFile;

interface

uses
  ADRConn.Model.Interfaces,
  System.IniFiles,
  System.Generics.Collections,
  System.SysUtils;

type
  TADRConnConfigIni = class
  private
    FFileName: string;
    FDatabase: string;
    FServer: string;
    FUserName: string;
    FPassword: string;
    FPort: Integer;
    FVendorLib: string;
    FProtocol: string;
    FDriver: TADRDriverConn;

    class var FInstances: TObjectDictionary<string, TADRConnConfigIni>;

    constructor CreatePrivate(ASection: string);

    function InternalReadString(const AIdent: string; const ADefault: string = ''; const ASection: string = ''): string;
    function InternalReadInteger(const AIdent: string; const ADefault: Integer = 0; const ASection: string = ''): Integer;
    function InternalReadBool(const AIdent: string; const ADefault: Boolean = False; const ASection: string = ''): Boolean;

    function InternalWriteString(const AIdent: string; const AValue: string; const ASection: string = ''): TADRConnConfigIni;
    function InternalWriteInteger(const AIdent: string; const AValue: Integer; const ASection: string = ''): TADRConnConfigIni;
    function InternalWriteBool(const AIdent: string; const AValue: Boolean; const ASection: string = ''): TADRConnConfigIni;
  protected
    class function GetDefaultInstance(ASection: string): TADRConnConfigIni;
    function GetIniFileName: string;
    function GetIniFile: TIniFile; virtual;

    procedure Initialize(ASection: string);
  public
    constructor Create;
    class function GetInstance(ASection: string = ''): TADRConnConfigIni;
    class destructor UnInitialize;

    class function ReadString(const AIdent: string; const ADefault: string = ''; const ASection: string = ''): string;
    class function ReadBool(const AIdent: string; const ADefault: Boolean = False; const ASection: string = ''): Boolean;
    class function ReadInteger(const AIdent: string; const ADefault: Integer; const ASection: string = ''): Integer;

    class function WriteString(const AIdent: string; const AValue: string; const ASection: string = ''): TADRConnConfigIni;
    class function WriteInteger(const AIdent: string; const AValue: Integer; const ASection: string = ''): TADRConnConfigIni;
    class function WriteBool(const AIdent: string; const AValue: Boolean; const ASection: string = ''): TADRConnConfigIni;

    property Driver: TADRDriverConn read FDriver write FDriver;
    property FileName: string read FFileName write FFileName;
    property Database: string read FDatabase write FDatabase;
    property UserName: string read FUserName write FUserName;
    property Password: string read FPassword write FPassword;
    property Server: string read FServer write FServer;
    property Port: Integer  read FPort write FPort;
    property VendorLib: string read FVendorLib write FVendorLib;
    property Protocol: string read FProtocol write FProtocol;
  end;

implementation

const
  SECTION_DATABASE = 'CONFIG';

{ TADRConnConfigIni }

constructor TADRConnConfigIni.Create;
begin
  raise Exception.Create('Use GetInstance...');
end;

constructor TADRConnConfigIni.CreatePrivate(ASection: string);
var
  LIniFile: TIniFile;
begin
  Initialize(ASection);
  LIniFile := GetIniFile;
  try
    FDriver.fromString(LIniFile.ReadString(ASection, 'Driver', 'Firebird'));

    FDatabase := LIniFile.ReadString(ASection, 'Database', FDatabase);
    FUserName := LIniFile.ReadString(ASection, 'User_Name', FUserName);
    FPassword := LIniFile.ReadString(ASection, 'Password', FPassword);
    FServer := LIniFile.ReadString(ASection, 'Server', FServer);
    FVendorLib := LIniFile.ReadString(ASection, 'VendorLib', FVendorLib);
    FProtocol := LIniFile.ReadString(ASection, 'Protocol', FProtocol);
    FPort := LIniFile.ReadInteger(ASection, 'Port', FPort);
  finally
    LIniFile.Free;
  end;
end;

class function TADRConnConfigIni.GetDefaultInstance(ASection: string): TADRConnConfigIni;
begin
  if not Assigned(FInstances) then
    FInstances := TObjectDictionary<string, TADRConnConfigIni>.create;

  if not FInstances.TryGetValue(ASection, Result) then
  begin
    Result := TADRConnConfigIni.CreatePrivate(ASection);
    FInstances.Add(ASection, Result);
  end;
end;

function TADRConnConfigIni.GetIniFile: TIniFile;
begin
  Result := TIniFile.Create(GetIniFileName);
end;

function TADRConnConfigIni.GetIniFileName: string;
begin
  Result := ChangeFileExt(GetModuleName(HInstance), '.ini');
end;

class function TADRConnConfigIni.GetInstance(ASection: string): TADRConnConfigIni;
var
  LSection: string;
begin
  LSection := ASection;
  if LSection = EmptyStr then
    LSection := SECTION_DATABASE;

  Result := TADRConnConfigIni.GetDefaultInstance(LSection);
end;

procedure TADRConnConfigIni.Initialize(ASection: string);
var
  LFileName: string;
  LIniFile: TIniFile;
begin
  LFileName := GetIniFileName;
  if not FileExists(LFileName) then
  begin
    LIniFile := GetIniFile;
    try
      LIniFile.WriteString(ASection, 'Driver', FDriver.toString);
      LIniFile.WriteString(ASection, 'Database', 'adrconntest');
      LIniFile.WriteString(ASection, 'User_Name', 'sysdba');
      LIniFile.WriteString(ASection, 'Password', 'masterkey');
      LIniFile.WriteString(ASection, 'Server', '127.0.0.1');
      LIniFile.WriteString(ASection, 'VendorLib', 'fbclient.dll');
      LIniFile.WriteString(ASection, 'Protocol', 'http');
      LIniFile.WriteInteger(ASection, 'Port', 3050);
    finally
      LIniFile.Free;
    end;
  end;
end;

class function TADRConnConfigIni.ReadBool(const AIdent: string; const ADefault: Boolean = False; const ASection: string = ''): Boolean;
begin
  Result := Self.GetInstance.InternalReadBool(AIdent, ADefault, ASection);
end;

class function TADRConnConfigIni.ReadInteger(const AIdent: string; const ADefault: Integer; const ASection: string = ''): Integer;
begin
  Result := Self.GetInstance.InternalReadInteger(AIdent, ADefault, ASection);
end;

function TADRConnConfigIni.InternalReadBool(const AIdent: string; const ADefault: Boolean = False; const ASection: string = ''): Boolean;
var
  LIniFile: TIniFile;
begin
  LIniFile := GetIniFile;
  try
    Result := LIniFile.ReadBool(ASection, AIdent, ADefault);
    LIniFile.WriteBool(ASection, AIdent, Result);
  finally
    LIniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalReadInteger(const AIdent: string; const ADefault: Integer = 0; const ASection: string = ''): Integer;
var
  LIniFile: TIniFile;
begin
  LIniFile := GetIniFile;
  try
    Result := LIniFile.ReadInteger(ASection, AIdent, ADefault);
    LIniFile.WriteInteger(ASection, AIdent, Result);
  finally
    LIniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalReadString(const AIdent: string; const ADefault: string = ''; const ASection: string = ''): string;
var
  LIniFile: TIniFile;
begin
  LIniFile := GetIniFile;
  try
    Result := LIniFile.ReadString(ASection, AIdent, ADefault);
    LIniFile.WriteString(ASection, AIdent, Result);
  finally
    LIniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalWriteBool(const AIdent: string; const AValue: Boolean; const ASection: string = ''): TADRConnConfigIni;
var
  LIniFile: TIniFile;
begin
  Result := Self;
  LIniFile := GetIniFile;
  try
    LIniFile.WriteBool(ASection, AIdent, AValue);
  finally
    LIniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalWriteInteger(const AIdent: string; const AValue: Integer; const ASection: string = ''): TADRConnConfigIni;
var
  LIniFile: TIniFile;
begin
  Result := Self;
  LIniFile := GetIniFile;
  try
    LIniFile.WriteInteger(ASection, AIdent, AValue);
  finally
    LIniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalWriteString(const AIdent: string; const AValue: string; const ASection: string = ''): TADRConnConfigIni;
var
  LIniFile: TIniFile;
begin
  Result := Self;
  LIniFile := GetIniFile;
  try
    LIniFile.WriteString(ASection, AIdent, AValue);
  finally
    LIniFile.Free;
  end;
end;

class function TADRConnConfigIni.ReadString(const AIdent: string; const ADefault: string = ''; const ASection: string = ''): string;
begin
  Result := Self.GetInstance.InternalReadString(AIdent, ADefault, ASection);
end;

class destructor TADRConnConfigIni.UnInitialize;
var
  LKey: string;
begin
  if Assigned(FInstances) then
  begin
    for LKey in FInstances.Keys do
      FInstances.Items[LKey].Free;
    FreeAndNil(FInstances);
  end;
end;

class function TADRConnConfigIni.WriteBool(const AIdent: string; const AValue: Boolean; const ASection: string = ''): TADRConnConfigIni;
begin
  Result := Self.GetInstance.InternalWriteBool(AIdent, AValue, ASection);
end;

class function TADRConnConfigIni.WriteInteger(const AIdent: string; const AValue: Integer; const ASection: string = ''): TADRConnConfigIni;
begin
  Result := Self.GetInstance.InternalWriteInteger(AIdent, AValue, ASection);
end;

class function TADRConnConfigIni.WriteString(const AIdent: string; const AValue: string; const ASection: string = ''): TADRConnConfigIni;
begin
  Result := Self.GetInstance.InternalWriteString(AIdent, AValue, ASection);
end;

end.

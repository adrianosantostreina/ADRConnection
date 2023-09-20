unit ADRConn.Model.Firedac.Driver;

interface

uses
  ADRConn.Model.Interfaces,
  FireDAC.Phys,
{$IF (not Defined(ANDROID)) and (not Defined(IOS))}
  FireDAC.Phys.FB,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.PG,
{$ENDIF}
  FireDAC.Phys.SQLite,
  System.SysUtils;

type
  TADRConnModelFiredacDriver = class
  private
{$IF (not Defined(ANDROID)) and (not Defined(IOS))}
    class function GetFirebirdDriver: TFDPhysDriverLink;
    class function GetPostgresDriver: TFDPhysDriverLink;
    class function GetMySQLDriver: TFDPhysDriverLink;
{$ENDIF}
    class function GetSQLiteDriver: TFDPhysDriverLink;
  public
    class function GetDriver(AParams: IADRConnectionParams): TFDPhysDriverLink;
  end;

implementation

{ TADRConnModelFiredacDriver }

class function TADRConnModelFiredacDriver.GetDriver(AParams: IADRConnectionParams): TFDPhysDriverLink;
begin
  case AParams.Driver of
{$IF (not Defined(ANDROID)) and (not Defined(IOS))}
  adrMySql:
      Result := GetMySQLDriver;
    adrFirebird:
      Result := GetFirebirdDriver;
    adrPostgres:
      Result := GetPostgresDriver;
{$ENDIF}
    adrSQLite:
      Result := GetSQLiteDriver;
  else
    raise Exception.CreateFmt('Driver %s not found.', [AParams.Driver.ToString]);
  end;
end;

{$IF (not Defined(ANDROID)) and (not Defined(IOS))}
class function TADRConnModelFiredacDriver.GetFirebirdDriver: TFDPhysDriverLink;
begin
  Result := TFDPhysFBDriverLink.Create(nil);
  Result.VendorLib := 'fbclient.dll';
end;
{$ENDIF}

{$IF (not Defined(ANDROID)) and (not Defined(IOS))}
class function TADRConnModelFiredacDriver.GetMySQLDriver: TFDPhysDriverLink;
begin
  Result := TFDPhysMySQLDriverLink.Create(nil);
  Result.VendorLib := 'libmysql.dll';
end;
{$ENDIF}

{$IF (not Defined(ANDROID)) and (not Defined(IOS))}
class function TADRConnModelFiredacDriver.GetPostgresDriver: TFDPhysDriverLink;
begin
  Result := TFDPhysPgDriverLink.Create(nil);
  Result.VendorLib := '';
end;
{$ENDIF}

class function TADRConnModelFiredacDriver.GetSQLiteDriver: TFDPhysDriverLink;
begin
  Result := TFDPhysSQLiteDriverLink.Create(nil);
  Result.VendorLib := 'sqlite3.dll';
end;

end.

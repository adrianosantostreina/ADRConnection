unit ADRConn.Model.Firedac.Driver;

interface

uses
  ADRConn.Model.Interfaces,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.PG,
  FireDAC.Phys.SQLite,
  System.SysUtils;

type TADRConnModelFiredacDriver = class

  private

  public
    class function GetDriver(Params: IADRConnectionParams): TFDPhysDriverLink;

end;

implementation

{ TADRConnModelFiredacDriver }

class function TADRConnModelFiredacDriver.GetDriver(Params: IADRConnectionParams): TFDPhysDriverLink;
begin
  case Params.Driver of
    adrMySql    : result := TFDPhysMySQLDriverLink.Create(nil);
    adrFirebird : result := TFDPhysFBDriverLink.Create(nil);
    adrPostgres : result := TFDPhysPgDriverLink.Create(nil);
    adrSQLite   : result := TFDPhysSQLiteDriverLink.Create(nil);
  else
    raise Exception.CreateFmt('Driver %s not found.', [Params.Driver.toString]);
  end;
end;

end.

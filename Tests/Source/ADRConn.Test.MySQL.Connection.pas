unit ADRConn.Test.MySQL.Connection;

interface

uses
  DUnitX.TestFramework,
  ADRConn.Model.Interfaces,
  ADRConn.Test.Base,
  System.SysUtils;

type
  [TestFixture]
  TADRConnTestMySQL = class(TADRConnTestBase)
  public
    [Test]
    procedure TestConnection;
  end;

implementation

{ TADRConnTestMySQL }

procedure TADRConnTestMySQL.TestConnection;
begin
  FConnection := CreateConnection;
  FConnection.Params
    .Lib('D:\Desenvolvimento\workspace\Delphi\Frameworks\ADRFrameworks\ADRLicense\Bin\libmysql.dll')
    .Driver(adrMySql)
    .Database('adrconn')
    .UserName('root')
    .Password('root')
    .Port(3306)
  .&End;

  Assert.WillNotRaise(TestConnect);
end;

end.


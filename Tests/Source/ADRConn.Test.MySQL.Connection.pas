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
    .Driver(adrMySql)
    .Database('adrconntest')
    .UserName('root')
    .Password('rootg')
    .Port(3306)
  .&End;

  Assert.WillNotRaise(TestConnect);
end;

end.


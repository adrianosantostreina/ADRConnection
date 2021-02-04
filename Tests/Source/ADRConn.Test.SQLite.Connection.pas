unit ADRConn.Test.SQLite.Connection;

interface

uses
  DUnitX.TestFramework,
  ADRConn.Model.Interfaces,
  ADRConn.Test.Base,
  System.SysUtils;

type
  [TestFixture]
  TADRConnTestSQLite = class(TADRConnTestBase)

  public
    [Test]
    procedure TestConnection;
  end;


implementation

{ TADRConnTestSQLite }

procedure TADRConnTestSQLite.TestConnection;
begin
  FConnection := CreateConnection;
  FConnection.Params
    .Driver(adrSQLite)
    .Database('pdvmobile.db3')
  .&End;

  Assert.WillNotRaise(TestConnect);
end;

end.


unit ADRConn.Test.Firebird.Connection;

interface

uses
  DUnitX.TestFramework,
  ADRConn.Model.Interfaces,
  ADRConn.Test.Base,
  System.SysUtils;

type
  [TestFixture]
  TADRConnTestFirebird = class(TADRConnTestBase)

  public
    [Test]
    procedure TestConnection;

    [Test]
    procedure TestConnectionVPS;
  end;


implementation

{ TADRConnTestFirebird }

procedure TADRConnTestFirebird.TestConnection;
begin
  FConnection := CreateConnection;
  FConnection.Params
    .Driver(adrFirebird)
    .Database('turbomobile.fdb')
    .UserName('sysdba')
    .Password('masterkey')
  .&End;

  Assert.WillNotRaise(TestConnect);
end;

procedure TADRConnTestFirebird.TestConnectionVPS;
begin
  FConnection := CreateConnection;
  FConnection.Params
    .Driver(adrFirebird)
    .Server('69.162.92.41')
    .Port(3050)
    .Database('c:\Databases\Firebird\turbomobile.fdb')
    .UserName('sysdba')
    .Password('masterkey')
  .&End;

  Assert.WillNotRaise(TestConnect);
end;

end.


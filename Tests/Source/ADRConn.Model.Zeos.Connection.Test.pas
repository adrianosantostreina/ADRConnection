unit ADRConn.Model.Zeos.Connection.Test;

interface

{$IFDEF ADRCONN_ZEOS}
uses
  DUnitX.TestFramework,
  ADRConn.Model.Interfaces,
  ADRConn.Model.Zeos.Connection,
  System.SysUtils,
  ZExceptions;

type
  [TestFixture]
  TADRConnModelZeosConnectionTest = class
  private
    FConnection: IADRConnection;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure PostgresConnection;

    [Test]
    procedure PostgresConnectionError;
  end;
{$ENDIF}

implementation

{$IFDEF ADRCONN_ZEOS}

{ TADRConnModelZeosConnectionTest }

procedure TADRConnModelZeosConnectionTest.PostgresConnection;
begin
  FConnection.Params
    .Database('RP')
    .UserName('postgres')
    .Password('123')
    .Driver(adrPostgres);

  Assert.IsFalse(FConnection.Connected);
  FConnection.Connect;
  Assert.IsTrue(FConnection.Connected);
end;

procedure TADRConnModelZeosConnectionTest.PostgresConnectionError;
begin
  FConnection.Params
    .Database('RP123')
    .UserName('postgres')
    .Password('123456')
    .Driver(adrPostgres);

  Assert.IsFalse(FConnection.Connected);
  Assert.WillRaise(
    procedure
    begin
      FConnection.Connect;
    end,
    EZSQLException);
end;

procedure TADRConnModelZeosConnectionTest.Setup;
begin
  FConnection := TADRConnModelZeosConnection.New;
end;

procedure TADRConnModelZeosConnectionTest.TearDown;
begin
end;

{$ENDIF}

end.

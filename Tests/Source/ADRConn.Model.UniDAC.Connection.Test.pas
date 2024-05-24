unit ADRConn.Model.UniDAC.Connection.Test;

interface

uses
  DUnitX.TestFramework,
  ADRConn.Model.Interfaces,
  ADRConn.Model.UniDAC.Connection,
  System.SysUtils,
  Uni;

type
  [TestFixture]
  TADRConnModelUniDACConnectionTest = class
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

    [Test]
    procedure SQLiteConnection;
  end;

implementation

{ TADRConnModelUniDACConnectionTest }

procedure TADRConnModelUniDACConnectionTest.PostgresConnection;
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

procedure TADRConnModelUniDACConnectionTest.PostgresConnectionError;
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
    EUniError);
end;

procedure TADRConnModelUniDACConnectionTest.Setup;
begin
  FConnection := TADRConnModelUniDACConnection.New;
end;

procedure TADRConnModelUniDACConnectionTest.SQLiteConnection;
var
  LFileName: string;
begin
  LFileName := ExtractFilePath(GetModuleName(HInstance)) + 'pdvmobile.db3';
  FConnection.Params
    .Database(LFileName)
    .Driver(adrSQLite)
    .AddParam('ConnectMode', 'cmReadWrite')
    .AddParam('LockingMode', 'lmNormal');

  Assert.IsFalse(FConnection.Connected);
  FConnection.Connect;
  Assert.IsTrue(FConnection.Connected);
end;

procedure TADRConnModelUniDACConnectionTest.TearDown;
begin
end;

end.

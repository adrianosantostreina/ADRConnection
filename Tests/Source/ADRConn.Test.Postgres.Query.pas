unit ADRConn.Test.Postgres.Query;

interface

uses
  DUnitX.TestFramework,
  ADRConn.Model.Interfaces,
  ADRConn.Test.Query.Base,
  Data.DB,
  System.DateUtils,
  System.SysUtils;

type
  [TestFixture]
  TADRConnTestQueryPostgres = class(TADRConnTestBaseQuery)

  protected
    function getConnection: IADRConnection; override;

  public
    constructor create;

    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestFindAll;

    [Test]
    procedure TestFindWithStrParams;

    [Test]
    procedure TestFindWithIntegerParams;

    [Test]
    procedure TestFindWithDateTimeParams;

    [Test]
    procedure TestNextSequence;

    [Test]
    procedure TestInsertWithParams;
  end;


implementation

{ TADRConnTestQueryPostgres }

constructor TADRConnTestQueryPostgres.create;
begin
  initializeQuery;
end;

function TADRConnTestQueryPostgres.getConnection: IADRConnection;
begin
  result := CreateConnection;
  result.Params
    .Driver(adrPostgres)
    .Server('127.0.0.1')
    .Database('adrconntest')
    .UserName('postgres')
    .Password('postgres')
    .Port(5432)
  .&End
  .Connect;
end;

procedure TADRConnTestQueryPostgres.Setup;
begin
  FConnection.StartTransaction;
end;

procedure TADRConnTestQueryPostgres.TestNextSequence;
var
  nextSequence: Double;
begin
  nextSequence := FQuery.Generator.GetNextSequence('idaccount');
  Assert.IsTrue(nextSequence > 0);
end;

procedure TADRConnTestQueryPostgres.TearDown;
begin
  FConnection.Rollback;
end;

procedure TADRConnTestQueryPostgres.TestFindAll;
var
  dataSet: TdataSet;
begin
  dataSet := FQuery.SQL('select * from person').Open;
  try
    Assert.IsTrue(dataSet.RecordCount > 0);
    Assert.IsFalse(dataSet.FieldByName('name').AsString.IsEmpty);
  finally
    dataSet.Free;
  end;
end;

procedure TADRConnTestQueryPostgres.TestFindWithDateTimeParams;
var
  dataSet: TdataSet;
begin
  FQuery
    .SQL('select * from person')
    .SQL('where birthdayDate = :data')
    .ParamAsDateTime('data', EncodeDate(1990, 2, 13));

  dataSet := FQuery.Open;
  try
    Assert.IsTrue(dataSet.RecordCount > 0);
  finally
    dataSet.Free;
  end;
end;

procedure TADRConnTestQueryPostgres.TestFindWithIntegerParams;
var
  dataSet: TdataSet;
begin
  FQuery
    .SQL('select * from person')
    .SQL('where id = :id')
    .ParamAsInteger('id', 1);

  dataSet := FQuery.Open;
  try
    Assert.IsTrue(dataSet.RecordCount > 0);
    Assert.AreEqual('person 1', dataSet.FieldByName('name').AsString);
  finally
    dataSet.Free;
  end;
end;

procedure TADRConnTestQueryPostgres.TestFindWithStrParams;
var
  dataSet: TdataSet;
begin
  FQuery
    .SQL('select * from person')
    .SQL('where name = :name')
    .ParamAsString('name', 'person 1');

  dataSet := FQuery.Open;
  try
    Assert.IsTrue(dataSet.RecordCount > 0);
    Assert.AreEqual('person 1', dataSet.FieldByName('name').AsString);
  finally
    dataSet.Free;
  end;
end;

procedure TADRConnTestQueryPostgres.TestInsertWithParams;
begin
  FQuery
    .SQL('insert into person (id, name, birthdayDate)')
    .SQL('values (:id, :name, :birthdayDate)')
    .ParamAsFloat('id', FQuery.Generator.GetNextSequence('idperson'))
    .ParamAsString('name', 'test 2')
    .ParamAsDateTime('birthdayDate', now);

  Assert.WillNotRaise(
    procedure
    begin
      FQuery.ExecSQL;
    end);
end;

end.

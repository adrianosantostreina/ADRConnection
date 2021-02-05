unit ADRConn.Test.MySQL.Query;

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
  TADRConnTestQueryMySQL = class(TADRConnTestBaseQuery)

  protected
    function getConnection: IADRConnection; override;

  public
    constructor create;

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
  end;


implementation

{ TADRConnTestQueryMySQL }

constructor TADRConnTestQueryMySQL.create;
begin
  initializeQuery;
end;

function TADRConnTestQueryMySQL.getConnection: IADRConnection;
begin
  result := CreateConnection;
  result.Params
    .Driver(adrMySql)
    .Database('adrconntest')
    .UserName('root')
    .Password('rootg')
    .Server('localhost')
    .Port(3306)
  .&End
  .Connect;
end;

procedure TADRConnTestQueryMySQL.TestNextSequence;
var
  nextSequence: Double;
begin
  nextSequence := FQuery.Generator.GetNextSequence('account');
  Assert.IsTrue(nextSequence > 0);
end;

procedure TADRConnTestQueryMySQL.TestFindAll;
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

procedure TADRConnTestQueryMySQL.TestFindWithDateTimeParams;
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
    Assert.AreEqual(1, dataSet.FieldByName('id').AsInteger);
  finally
    dataSet.Free;
  end;
end;

procedure TADRConnTestQueryMySQL.TestFindWithIntegerParams;
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

procedure TADRConnTestQueryMySQL.TestFindWithStrParams;
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

end.

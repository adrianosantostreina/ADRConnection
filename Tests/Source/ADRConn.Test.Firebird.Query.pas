unit ADRConn.Test.Firebird.Query;

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
  TADRConnTestQueryFirebird = class(TADRConnTestBaseQuery)

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
    procedure TestCurrentSequence;
  end;


implementation

{ TADRConnTestQueryFirebird }

constructor TADRConnTestQueryFirebird.create;
begin
  initializeQuery;
end;

function TADRConnTestQueryFirebird.getConnection: IADRConnection;
begin
  result := CreateConnection;
  result.Params
    .Driver(adrFirebird)
    .Database('turbomobile.fdb')
    .UserName('sysdba')
    .Password('masterkey')
  .&End
  .Connect;
end;

procedure TADRConnTestQueryFirebird.TestCurrentSequence;
var
  sequence: Double;
  nextSequence: Double;
begin
  sequence := FQuery.Generator.GetCurrentSequence('GEN_TB_CIDADE_ID');
  nextSequence := FQuery.Generator.GetNextSequence('GEN_TB_CIDADE_ID');
  Assert.IsTrue(sequence > 0);
  Assert.IsTrue(nextSequence > 0);
  Assert.AreEqual((nextSequence - 1).ToString, sequence.ToString);
end;

procedure TADRConnTestQueryFirebird.TestFindAll;
var
  dataSet: TdataSet;
begin
  dataSet := FQuery.SQL('select * from tb_pessoa').Open;
  try
    Assert.IsTrue(dataSet.RecordCount > 0);
    Assert.IsFalse(dataSet.FieldByName('pes_razaosocial').AsString.IsEmpty);
  finally
    dataSet.Free;
  end;
end;

procedure TADRConnTestQueryFirebird.TestFindWithDateTimeParams;
var
  dataSet: TdataSet;
begin
  FQuery
    .SQL('select * from tb_pessoa')
    .SQL('where pes_dtnascimento = :data')
    .ParamAsDateTime('data', EncodeDate(2018, 1, 1));

  dataSet := FQuery.Open;
  try
    Assert.IsTrue(dataSet.RecordCount > 0);
    Assert.AreEqual(10001, dataSet.FieldByName('pes_id').AsInteger);
  finally
    dataSet.Free;
  end;
end;

procedure TADRConnTestQueryFirebird.TestFindWithIntegerParams;
var
  dataSet: TdataSet;
begin
  FQuery
    .SQL('select * from tb_pessoa')
    .SQL('where pes_id = :id')
    .ParamAsInteger('id', 10001);

  dataSet := FQuery.Open;
  try
    Assert.IsTrue(dataSet.RecordCount > 0);
    Assert.AreEqual('Mercado Se 123', dataSet.FieldByName('pes_razaosocial').AsString);
  finally
    dataSet.Free;
  end;
end;

procedure TADRConnTestQueryFirebird.TestFindWithStrParams;
var
  dataSet: TdataSet;
begin
  FQuery
    .SQL('select * from tb_pessoa')
    .SQL('where pes_razaosocial = :razaoSocial')
    .SQL('and pes_fantasia = :nomeFantasia')
    .ParamAsString('razaoSocial', 'Empresa do Tio Ze')
    .ParamAsString('nomeFantasia', 'Tio Ze');

  dataSet := FQuery.Open;
  try
    Assert.IsTrue(dataSet.RecordCount > 0);
    Assert.AreEqual('Empresa do Tio Ze', dataSet.FieldByName('pes_razaosocial').AsString);
  finally
    dataSet.Free;
  end;
end;

end.

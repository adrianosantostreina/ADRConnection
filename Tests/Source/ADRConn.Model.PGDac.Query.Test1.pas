unit ADRConn.Model.PGDac.Query.Test1;

interface

{$IFDEF ADRCONN_PGDAC}

uses
  DUnitX.TestFramework,
  ADRConn.Model.Interfaces,
  ADRConn.Model.PGDac.Connection,
  ADRConn.Model.PGDac.Query,
  Data.DB,
  System.SysUtils,
  System.Classes;

type
  [TestFixture]
  TADRConnModelPgDACQueryTest = class
  private
    FConnection: IADRConnection;
    FQuery: IADRQuery;
    FDataSet: TDataSet;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure Select;

    [Test]
    procedure SelectWithParams;

    [Test]
    procedure UpdateWithParams;

    [Test]
    procedure InsertBatch;
  end;
{$ENDIF}

implementation

{$IFDEF ADRCONN_PGDAC}

{ TADRConnModelPgDACQueryTest }

procedure TADRConnModelPgDACQueryTest.InsertBatch;
var
  I: Integer;
begin
  FQuery.SQL('delete from teste').ExecSQL;
  FQuery.SQL('insert into teste (id, codigo) values (:id, :codigo)');

  for I := 1 to 100 do
  begin
    FQuery.ParamAsInteger(I - 1, 'id', I)
      .ParamAsInteger(I - 1, 'codigo', I);
  end;

  FQuery.ExecSQL;

  FDataSet := FQuery.SQL('select * from teste').OpenDataSet;
  Assert.IsNotNull(FDataSet);
  Assert.AreEqual(100, FDataSet.RecordCount);
  Assert.AreEqual(1, FDataSet.FieldByName('id').AsInteger);

  FDataSet.RecNo := 50;
  Assert.AreEqual(50, FDataSet.FieldByName('id').AsInteger);
end;

procedure TADRConnModelPgDACQueryTest.Select;
begin
  FDataSet := FQuery.SQL('select * from empresas').OpenDataSet;
  Assert.IsNotNull(FDataSet);
  Assert.IsTrue(FDataSet.RecordCount > 0);
  Assert.AreEqual(1, FDataSet.FieldByName('emp_001').AsInteger);
end;

procedure TADRConnModelPgDACQueryTest.SelectWithParams;
begin
  FDataSet := FQuery.SQL('select * from empresas')
    .SQL('where emp_001 = :emp_001')
    .ParamAsInteger('emp_001', 1)
    .OpenDataSet;

  Assert.IsNotNull(FDataSet);
  Assert.AreEqual(1, FDataSet.RecordCount);
  Assert.AreEqual(1, FDataSet.FieldByName('emp_001').AsInteger);
end;

procedure TADRConnModelPgDACQueryTest.Setup;
begin
  FConnection := TADRConnModelPGDacConnection.New;
  FConnection.Params
    .Database('RP')
    .UserName('postgres')
    .Password('123')
    .&End
    .Connect;

  FQuery := TADRConnModelPGDacQuery.New(FConnection);
  FConnection.StartTransaction;
  FDataSet := nil;
end;

procedure TADRConnModelPgDACQueryTest.TearDown;
begin
  FConnection.Rollback;
  FreeAndNil(FDataSet);
end;

procedure TADRConnModelPgDACQueryTest.UpdateWithParams;
begin
  FQuery.SQL('update empresas set emp_007 = :emp_007,')
    .SQL('emp_006 = :emp_006')
    .SQL('where emp_001 = :emp_001')
    .ParamAsInteger('emp_001', 1)
    .ParamAsString('emp_007', EmptyStr, True)
    .ParamAsString('emp_006', EmptyStr)
    .ExecSQL;

  FDataSet := FQuery.SQL('select emp_006, emp_007 from empresas')
    .SQL('where emp_001 = :emp_001')
    .ParamAsInteger('emp_001', 1)
    .OpenDataSet;

  Assert.IsNotNull(FDataSet);
  Assert.AreEqual(1, FDataSet.RecordCount);
  Assert.IsEmpty(FDataSet.FieldByName('emp_006').AsString);
  Assert.IsEmpty(FDataSet.FieldByName('emp_007').AsString);
end;
{$ENDIF}

end.

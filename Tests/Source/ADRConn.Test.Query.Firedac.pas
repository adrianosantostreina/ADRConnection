unit ADRConn.Test.Query.Firedac;

interface

uses
  DUnitX.TestFramework,
  ADRConn.Test.Query.Base,
  ADRConn.Model.Interfaces,
  ADRConn.Model.Firedac.Query,
  System.DateUtils,
  System.Classes,
  System.SysUtils;

type
  [TestFixture]
  TADRConnTestQueryFiredac = class(TADRConnTestBaseQuery)
  private
    FDBCreated: Boolean;

    procedure CreateTable;
  protected
    function GetConnection: IADRConnection; override;
  public
    constructor Create;

    [Setup]
    procedure Setup;

    [Test]
    procedure SimpleInsert;

    [Test]
    procedure InsertBatch;

    [Test]
    procedure InsertValidatorNotEmpty;

    [Test]
    procedure InsertValidatorMinLength;

    [Test]
    procedure InsertValidatorMaxLength;

    [Test]
    procedure InsertValidatorMaxValue;

    [Test]
    procedure InsertValidatorMinValue;
  end;

implementation

{ TADRConnTestQueryFiredac }

constructor TADRConnTestQueryFiredac.Create;
begin
  FDBCreated := False;
end;

procedure TADRConnTestQueryFiredac.CreateTable;
begin
  if not FDBCreated then
  try
    FQuery.SQL('create table if not exists query_firedac(')
      .SQL('id integer primary key autoincrement,')
      .SQL('description varchar(100),')
      .SQL('intTest integer,')
      .SQL('dateTest datetime,')
      .SQL('currTest currency,')
      .SQL('boolTest boolean)')
      .ExecSQL;
  finally
    FDBCreated := True;
  end;
end;

function TADRConnTestQueryFiredac.GetConnection: IADRConnection;
var
  LFile: string;
begin
  if not Assigned(FConnection) then
  begin
    LFile := GetModuleName(HInstance);
    LFile := ChangeFileExt(LFile, '.db3');
    if not FileExists(LFile) then
    begin
      with TStringList.Create do
      try
        SaveToFile(LFile);
      finally
        Free;
      end;
    end;
    FConnection := CreateConnection;
    FConnection.Params
      .Driver(adrSQLite)
      .Database(LFile)
      .AddParam('OpenMode', 'ReadWrite')
      .AddParam('LockingMode', 'Normal')
    .&End
    .Connect;
  end;
  Result := FConnection;
end;

procedure TADRConnTestQueryFiredac.InsertBatch;
var
  I: Integer;
begin
  FQuery.SQL('insert into query_firedac (')
    .SQL('description, intTest, dateTest, currTest, boolTest)')
    .SQL('values (')
    .SQL(':description, :intTest, :dateTest, :currTest, :boolTest)');

  for I := 0 to 4 do
    FQuery.ParamAsString(I, 'description', 'InsertBatch')
      .ParamAsInteger(I, 'intTest', 5 + I)
      .ParamAsDateTime(I, 'dateTest', IncDay(Now, I))
      .ParamAsCurrency(I, 'currTest', 5.5 + I)
      .ParamAsBoolean(I, 'boolTest', True);

  FQuery.ExecSQL;

  FQuery.SQL('select * from query_firedac where description = :description')
    .ParamAsString('description', 'InsertBatch')
    .Open;

  Assert.AreEqual(5, FQuery.DataSet.RecordCount);

  FQuery.SQL('delete from query_firedac').ExecSQL;
end;

procedure TADRConnTestQueryFiredac.InsertValidatorMaxLength;
begin
  FQuery.SQL('insert into query_firedac (')
    .SQL('description, intTest, dateTest, currTest, boolTest)')
    .SQL('values (')
    .SQL(':description, :intTest, :dateTest, :currTest, :boolTest)')
    .Params
      .AsString('description', 'abcd').MaxLength(3).&End
      .AsInteger('intTest', 5).&End
      .AsDateTime('dateTest', EncodeDate(2023, 6, 29)).&End
      .AsCurrency('currTest', 5.5).&End
      .AsBoolean('boolTest', True).&End;

  Assert.WillRaiseWithMessage(
    procedure
    begin
      FQuery.ExecSQL;
    end,
    Exception,
    'Field description must have a maximum size of 3.');
end;

procedure TADRConnTestQueryFiredac.InsertValidatorMaxValue;
begin
  FQuery.SQL('insert into query_firedac (')
    .SQL('description, intTest, dateTest, currTest, boolTest)')
    .SQL('values (')
    .SQL(':description, :intTest, :dateTest, :currTest, :boolTest)')
    .Params
      .AsString('description', 'ab').&End
      .AsInteger('intTest', 7).MaxValue(6).MinValue(2).&End
      .AsDateTime('dateTest', EncodeDate(2023, 6, 29)).&End
      .AsCurrency('currTest', 5.5).&End
      .AsBoolean('boolTest', True).&End;

  Assert.WillRaiseWithMessage(
    procedure
    begin
      FQuery.ExecSQL;
    end,
    Exception,
    'Field intTest must have a maximum value of 6.');
end;

procedure TADRConnTestQueryFiredac.InsertValidatorMinLength;
begin
  FQuery.SQL('insert into query_firedac (')
    .SQL('description, intTest, dateTest, currTest, boolTest)')
    .SQL('values (')
    .SQL(':description, :intTest, :dateTest, :currTest, :boolTest)')
    .Params
      .AsString('description', 'ab').MinLength(3).&End
      .AsInteger('intTest', 5).&End
      .AsDateTime('dateTest', EncodeDate(2023, 6, 29)).&End
      .AsCurrency('currTest', 5.5).&End
      .AsBoolean('boolTest', True).&End;

  Assert.WillRaiseWithMessage(
    procedure
    begin
      FQuery.ExecSQL;
    end,
    Exception,
    'Field description must have a minimum size of 3.');
end;

procedure TADRConnTestQueryFiredac.InsertValidatorMinValue;
begin
  FQuery.SQL('insert into query_firedac (')
    .SQL('description, intTest, dateTest, currTest, boolTest)')
    .SQL('values (')
    .SQL(':description, :intTest, :dateTest, :currTest, :boolTest)')
    .Params
      .AsString('description', 'ab').&End
      .AsInteger('intTest', 1).MaxValue(6).MinValue(2).&End
      .AsDateTime('dateTest', EncodeDate(2023, 6, 29)).&End
      .AsCurrency('currTest', 5.5).&End
      .AsBoolean('boolTest', True).&End;

  Assert.WillRaiseWithMessage(
    procedure
    begin
      FQuery.ExecSQL;
    end,
    Exception,
    'Field intTest must have a minimum value of 2.');
end;

procedure TADRConnTestQueryFiredac.InsertValidatorNotEmpty;
begin
  FQuery.SQL('insert into query_firedac (')
    .SQL('description, intTest, dateTest, currTest, boolTest)')
    .SQL('values (')
    .SQL(':description, :intTest, :dateTest, :currTest, :boolTest)')
    .Params
      .AsString('description', '').NotEmpty(True).&End
      .AsInteger('intTest', 5).&End
      .AsDateTime('dateTest', EncodeDate(2023, 6, 29)).&End
      .AsCurrency('currTest', 5.5).&End
      .AsBoolean('boolTest', True).&End;

  Assert.WillRaiseWithMessage(
    procedure
    begin
      FQuery.ExecSQL;
    end,
    Exception,
    'Field description must not be empty.');
end;

procedure TADRConnTestQueryFiredac.Setup;
begin
  InitializeQuery;
  CreateTable;
end;

procedure TADRConnTestQueryFiredac.SimpleInsert;
begin
  FQuery.SQL('insert into query_firedac (')
    .SQL('description, intTest, dateTest, currTest, boolTest)')
    .SQL('values (')
    .SQL(':description, :intTest, :dateTest, :currTest, :boolTest)')
    .Params
      .AsString('description', 'SimpleInsert').&End
      .AsInteger('intTest', 5).&End
      .AsDateTime('dateTest', EncodeDate(2023, 6, 29)).&End
      .AsCurrency('currTest', 5.5).&End
      .AsBoolean('boolTest', True).&End
    .&End
    .ExecSQL;

  FQuery.SQL('select * from query_firedac where description = :description')
    .Params
      .AsString('description', 'SimpleInsert').&End
    .&End
    .Open;

  Assert.AreEqual('SimpleInsert', FQuery.DataSet.FieldByName('description').AsString);
  Assert.AreEqual<Integer>(5, FQuery.DataSet.FieldByName('intTest').AsInteger);
  Assert.AreEqual<Currency>(5.5, FQuery.DataSet.FieldByName('currTest').AsCurrency);
  Assert.AreEqual<TDateTime>(EncodeDate(2023, 6, 29),
    FQuery.DataSet.FieldByName('dateTest').AsDateTime);
  Assert.AreEqual<Boolean>(True, FQuery.DataSet.FieldByName('boolTest').AsBoolean);

  FQuery.SQL('delete from query_firedac').ExecSQL;
end;

end.

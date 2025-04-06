unit DAO.Person;

interface

uses
  System.SysUtils,
  System.JSON,
  Data.DB,
  DataSet.Serialize,
  GBJSON.Helper,
  ADRConn.Model.Interfaces;

type
  TDAOPerson = class
  private
    FConnection: IADRConnection;
    FQuery: IADRQuery;
  public
    constructor Create(AConnection: IADRConnection);

    function ListAll: TJSONArray;
    function Find(AId: Integer): TJSONObject;
    procedure Insert(AJSON: TJSONObject);
    procedure Update(AJSON: TJSONObject);
    procedure Delete(AId: Integer);
    procedure InsertBatch(AJSONArray: TJSONArray);
  end;

implementation

{ TDAOPerson }

constructor TDAOPerson.Create(AConnection: IADRConnection);
begin
  FConnection := AConnection;
  FQuery := CreateQuery(AConnection);
end;

procedure TDAOPerson.Delete(AId: Integer);
begin
  FQuery.SQL('delete from person where id = :id')
    .ParamAsInteger('id', AId)
    .ExecSQL;
end;

function TDAOPerson.Find(AId: Integer): TJSONObject;
var
  LDataSet: TDataSet;
begin
  LDataSet := FQuery.SQL('select id, name, document, phone')
    .SQL('from person')
    .SQL('where id = :id')
    .ParamAsInteger('id', AId)
    .OpenDataSet;
  try
    if LDataSet.RecordCount > 0 then
      Result := LDataSet.ToJSONObject;
  finally
    LDataSet.Free;
  end;
end;

procedure TDAOPerson.Insert(AJSON: TJSONObject);
begin
  FQuery.SQL('insert into person (')
    .SQL('id, name, document, phone)')
    .SQL('values (')
    .SQL(':id, :name, :document, :phone)')
    .Params
      .AsInteger('id', AJSON.ValueAsInteger('id')).&End
      .AsString('name', AJSON.ValueAsString('name')).NotEmpty(True).MinLength(3).&End
    .&End
    .ParamAsString('document', AJSON.ValueAsString('document'), True)
    .ParamAsString('phone', AJSON.ValueAsString('phone'))
    .ExecSQL;
end;

procedure TDAOPerson.InsertBatch(AJSONArray: TJSONArray);
var
  LJSON: TJSONObject;
  I: Integer;
begin
  FQuery.SQL('insert into person (')
      .SQL('id, name, document, phone)')
      .SQL('values (')
      .SQL(':id, :name, :document, :phone)');

  for I := 0 to Pred(AJSONArray.Count) do
  begin
    LJSON := AJSONArray.ItemAsJSONObject(I);
    FQuery.BatchParams
      .AsInteger(I, 'id', LJSON.ValueAsInteger('id'))
      .AsString(I, 'name', LJSON.ValueAsString('name'))
      .AsString(I, 'document', LJSON.ValueAsString('document'))
      .AsString(I, 'phone', LJSON.ValueAsString('phone'));
  end;

  FQuery.ExecSQL;
end;

function TDAOPerson.ListAll: TJSONArray;
begin
  FQuery.SQL('select id, name, document, phone')
    .SQL('from person')
    .Open;

  Result := FQuery.DataSet.ToJSONArray;
end;

procedure TDAOPerson.Update(AJSON: TJSONObject);
begin
  FQuery.SQL('update person set ')
    .SQL('name = :name, document = :document, phone = :phone ')
    .SQL('where id = :id')
    .ParamAsInteger('id', AJSON.ValueAsInteger('id'))
    .ParamAsString('document', AJSON.ValueAsString('document'))
    .ParamAsString('name', AJSON.ValueAsString('name'))
    .ParamAsString('phone', AJSON.ValueAsString('phone'))
    .ExecSQL;
end;

end.

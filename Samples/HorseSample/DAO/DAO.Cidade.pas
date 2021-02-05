unit DAO.Cidade;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.DAO.Base,
  System.JSON;

type TADRConnDAOCidade = class(TADRConnDAOBase)

  public
    function List: TJSONArray;
end;

implementation

{ TADRConnDAOCidade }

function TADRConnDAOCidade.List: TJSONArray;
var
  dataSet: TDataSet;
  i : Integer;
  json: TJSONObject;
begin
  dataSet := FQuery
              .SQL('select * from tb_cidade')
              .Open;
  try
    result := TJSONArray.Create;
    try
      while not dataSet.Eof do
      begin
        json := TJSONObject.Create;
        for i := 0 to Pred(dataSet.FieldCount) do
          json.AddPair(dataSet.Fields[i].FieldName, dataSet.Fields[i].AsString);
        Result.AddElement(json);
        dataSet.Next;
      end;

    except
      Result.Free;
      raise;
    end;
  finally
    dataSet.Free;
  end;
end;

end.

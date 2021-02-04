unit DAO.Checklist;

interface

uses
  DAO.base,

  Data.DB,

  System.JSON,

  Server.DataSets,
  Server.SQL.Constants.Checklist,

  Utils.DataSet.JSON.Helper;

type
  TDAOChecklist = class(TDAOBase)
    private

    public
      function ListAll(AID_Visita: Integer) : TJSONArray;
  end;


implementation

{ TDAOChecklist }

function TDAOChecklist.ListAll(AID_Visita: Integer): TJSONArray;
var
  MyQuery : TMyQuery;
begin
  try
    MyQuery := SetSQL(C_SQL_LISTALL);
    MyQuery.Query.Params.CreateParam(ftInteger, 'pID_VISITA', ptInput);
    MyQuery.Query.ParamByName('pID_VISITA').AsInteger := AID_Visita;
    MyQuery.Query.Active := True;

    if MyQuery.Query.IsEmpty then
      Result := TJSONArray.Create //('Result', 'Nenhum checklist encontrado.')
    else
      Result := MyQuery.Query.DataSetToJSON();
  finally
    MyQuery.Free;
  end;
end;

end.

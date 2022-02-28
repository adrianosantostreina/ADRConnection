unit DAO.Cidade;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.DAO.Base,
  DataSet.Serialize,
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
begin
  dataSet := FQuery
              .SQL('select * from tb_cidade')
              .OpenDataSet;
  try
    result := dataSet.ToJSONArray;
  finally
    dataSet.Free;
  end;
end;

end.

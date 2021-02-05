unit Controller.Cidade;

interface

uses
  Horse,
  ADRConn.Model.Interfaces,
  ADRConn.Model.Factory,
  System.JSON,
  DAO.Cidade;

procedure RegisterCidade;

procedure List(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegisterCidade;
begin
  THorse.Get('cidade', List);
end;

procedure List(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  connection: IADRConnection;
  dao: TADRConnDAOCidade;
begin
  connection := TADRConnModelFactory.GetConnectionIniFile;
  connection.Connect;
  dao := TADRConnDAOCidade.create(connection);
  try
    Res.Send<TJsonArray>(dao.List);
  finally
    dao.Free;
  end;
end;

end.


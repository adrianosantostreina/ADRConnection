unit Controller.Checklist;

interface

uses
  Horse,

  System.JSON,
  System.StrUtils,
  System.SysUtils,
  System.Character,
  System.Classes,

  Server.Connection,

  DAO.CheckList;

  procedure RegisterChecklist;

  procedure List(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  procedure Find(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  procedure Insert(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  procedure Update(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegisterChecklist;
begin
  THorse.Get   ('/checklist'     , List);
  THorse.Post  ('/checklist'     , Insert);
  THorse.Put   ('/checklist/:id' , Update);
  THorse.Delete('/checklist/:id' , Delete);
end;

procedure List(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LConn         : TConnectionData;
  LDAOChecklist : TDAOChecklist;
  LID_Visita    : Integer;
begin
  //Verifica se o id foi informado
  if not Req.Query.ContainsKey('id_visita') then
    raise Exception.Create('Informe o ID da Visita.');

  //Verifica se o parâmetro é válido
  if not TryStrToInt(Req.Query['id_visita'], LID_Visita) then
    raise Exception.Create('ID da visita inválido. Digite um número inteiro.');

  try
    try
      LConn         := TConnectionData.Create;
      LDAOChecklist := TDAOChecklist.Create(LConn);
      Res.Send<TJSONArray>(LDAOChecklist.ListAll(LID_Visita)).Status(THTTPStatus.OK);
    finally
      LDAOChecklist.Free;
    end;
  finally
    LConn.Free;
  end;
end;

procedure Find(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  //
end;

procedure Insert(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  Res.Send('Insert').Status(THTTPStatus.OK);
end;

procedure Update(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  Res.Send('Alter').Status(THTTPStatus.OK);
end;

procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  Res.Send('Delete').Status(THTTPStatus.OK);
end;

end.

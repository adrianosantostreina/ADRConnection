unit Controller.Visitas;

interface

uses
  Horse,

  System.JSON,
  System.StrUtils,
  System.SysUtils,
  System.Character,
  System.Classes,

  Server.Connection,

  DAO.Visitas;

type
  TVisitas = class
    private
      FID            : Integer;
      FTitulo        : string;
      FDescricao     : string;
      FDataAgendada  : TDateTime;
    public
      property ID            : Integer   read FID            write FID;
      property TITULO        : string    read FTitulo        write FTItulo;
      property DESCRICAO     : string    read FDescricao     write FDescricao;
      property DATA_AGENDADA : TDateTime read FDataAgendada  write FDataAgendada;
  end;

  procedure RegisterVisitas;

  procedure List   (Req: THorseRequest; Res: THorseResponse; Next: TProc);
  procedure Find   (Req: THorseRequest; Res: THorseResponse; Next: TProc);
  procedure Insert (Req: THorseRequest; Res: THorseResponse; Next: TProc);
  procedure Update (Req: THorseRequest; Res: THorseResponse; Next: TProc);
  procedure Delete (Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegisterVisitas;
begin
  THorse.Get('/visitas'     , List);
  THorse.Get('/visitas/:id' , Find);
  THorse.Post('/visitas'    , Insert);
  THorse.Put('/visitas'     , Update);
  THorse.Delete('/visitas'  , Delete);
end;

procedure List(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LConn       : TConnectionData;
  LDAOVisitas : TDAOVisitas;
begin
  try
    LConn := TConnectionData.Create;
    try
      LDAOVisitas := TDAOVisitas.Create(LConn);
      Res.Send<TJSONArray>(LDAOVisitas.List).Status(THTTPStatus.OK);
    finally
      LDAOVisitas.Free;
    end;
  finally
    LConn.Free;
  end;
end;

procedure Find(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LConn       : TConnectionData;
  LDAOVisitas : TDAOVisitas;
  LID         : Integer;
begin
  if not TryStrToInt(Req.Params['id'], LID) then
    raise Exception.Create('ID inválido. Envie um número inteiro.');

  try
    LConn := TConnectionData.Create;
    try
      LDAOVisitas := TDAOVisitas.Create(LConn);
      Res.Send<TJSONArray>(LDAOVisitas.Find(LID)).Status(THTTPStatus.OK);
    finally
      LDAOVisitas.Free;
    end;
  finally
    LConn.Free;
  end;
end;

procedure Insert(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LJSONRecebido : TJSONValue;
  LConn         : TConnectionData;
  LDAOVisitas   : TDAOVisitas;
begin
  //Verifica se foi enviado um body
  if Req.Body.IsEmpty then
    raise Exception.Create('Corpo na requisição inválido. Envie um JSON com os dados a serem inseridos.');

  try
    try
      LConn       := TConnectionData.Create;
      LDAOVisitas := TDAOVisitas.Create(LConn);

      LJSONRecebido := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Req.Body), 0) as TJSONValue;
      Res.Send<TJSONObject>(LDAOVisitas.Insert(LJSONRecebido)).Status(THTTPStatus.Created);
    finally
      LDAOVisitas.Free;
    end;
  finally
    LConn.Free
  end;
end;

procedure Update(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LJSONRecebido : TJSONValue;
  LConn         : TConnectionData;
  LDAOVisitas   : TDAOVisitas;
  LID           : Integer;
  LIDValid      : Integer;
  LJSONResult   : TJSONObject;
begin
  //Verifica se foi enviado um body
  if Req.Body.IsEmpty then
    raise Exception.Create('Corpo na requisição inválido. Envie um JSON com os dados a serem inseridos.');

  LJSONRecebido := TJSONObject.ParseJSONValue(Req.Body);
  if not (LJSONRecebido.TryGetValue<integer>('ID', LID)) then
    raise Exception.Create('ID da visita não enviado.');

  try
    try
      LConn       := TConnectionData.Create;
      LDAOVisitas := TDAOVisitas.Create(LConn);

      LJSONResult := LDAOVisitas.Update(LID, LJSONRecebido);

      if not LJSONResult.TryGetValue('ID', LIDValid) then
        Res.Status(THTTPStatus.NotFound)
      else
        Res.Send<TJSONObject>(LJSONResult).Status(THTTPStatus.NoContent);
    finally
      LDAOVisitas.Free;
    end;
  finally
    LConn.Free
  end;
end;

procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LJSONRecebido : TJSONValue;
  LConn         : TConnectionData;
  LDAOVisitas   : TDAOVisitas;
  LID           : Integer;
  LIDValid      : Integer;
  LJSONResult   : TJSONObject;
begin
  //Verifica se foi enviado um body
  if Req.Body.IsEmpty then
    raise Exception.Create('Corpo na requisição inválido. Envie um JSON com os dados a serem inseridos.');

  LJSONRecebido := TJSONObject.ParseJSONValue(Req.Body);
  if not (LJSONRecebido.TryGetValue<integer>('ID', LID)) then
    raise Exception.Create('ID da visita não enviado.');

  try
    try
      LConn       := TConnectionData.Create;
      LDAOVisitas := TDAOVisitas.Create(LConn);

      LJSONResult := LDAOVisitas.Delete(LID);

      if not LJSONResult.TryGetValue('ID', LIDValid) then
        Res.Status(THTTPStatus.NotFound)
      else
        Res.Send<TJSONObject>(LJSONResult).Status(THTTPStatus.NoContent);
    finally
      LDAOVisitas.Free;
    end;
  finally
    LConn.Free
  end;
end;

end.

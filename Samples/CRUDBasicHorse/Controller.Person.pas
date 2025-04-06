unit Controller.Person;

interface

uses
  System.SysUtils,
  System.JSON,
  Horse,
  ADRConn.Model.Interfaces,
  ADRConnection.Pool,
  PoolManager,
  DAO.Person;

implementation

function GetConnection: IADRConnection;
begin
  Result := CreateConnection;
  Result.Params
    .Driver(adrPostgres)
    .Server('127.0.0.1')
    .Port(5432)
    .Database('demoadrconnection')
    .UserName('postgres')
    .Password('postgres');
  Result.Connect;
  System.Writeln('Nova Conexão');
end;

procedure ListAll(AReq: THorseRequest; ARes: THorseResponse);
var
  LJSONArray: TJSONArray;
  LDAO: TDAOPerson;
  LPoolConnection: TPoolItem<TADRConnectionPoolItem>;
begin
  LPoolConnection := GetPoolItem;
  LDAO := TDAOPerson.Create(LPoolConnection.Acquire.Connection);
  try
    LJSONArray := LDAO.ListAll;
    ARes.Send<TJSONArray>(LJSONArray);
  finally
    LDAO.Free;
    LPoolConnection.Release;
  end;
end;

procedure Find(AReq: THorseRequest; ARes: THorseResponse);
var
  LDAO: TDAOPerson;
  LId: Integer;
  LJSON: TJSONObject;
begin
  LDAO := TDAOPerson.Create(GetConnection);
  try
    LId := AReq.Params.Field('id').AsInteger;
    LJSON := LDAO.Find(LId);
    if not Assigned(LJSON) then
      raise Exception.Create('Não encontrado.');

    ARes.Send<TJSONObject>(LJSON);
  finally
    LDAO.Free;
  end;
end;

procedure Insert(AReq: THorseRequest; ARes: THorseResponse);
var
  LDAO: TDAOPerson;
  LJSON: TJSONObject;
begin
  LDAO := TDAOPerson.Create(GetConnection);
  try
    LJSON := AReq.Body<TJSONObject>;
    LDAO.Insert(LJSON);
    ARes.Send<TJSONObject>(LJSON.Clone as TJSONObject)
      .Status(201);
  finally
    LDAO.Free;
  end;
end;

procedure Update(AReq: THorseRequest; ARes: THorseResponse);
var
  LDAO: TDAOPerson;
  LJSON: TJSONObject;
  LId: Integer;
begin
  LDAO := TDAOPerson.Create(GetConnection);
  try
    LId := AReq.Params.Field('id').AsInteger;
    LJSON := AReq.Body<TJSONObject>;
    LJSON.AddPair('id', TJSONNumber.Create(LId));
    LDAO.Update(LJSON);
    ARes.Send<TJSONObject>(LJSON.Clone as TJSONObject)
      .Status(200);
  finally
    LDAO.Free;
  end;
end;

procedure Delete(AReq: THorseRequest; ARes: THorseResponse);
var
  LDAO: TDAOPerson;
  LId: Integer;
begin
  LDAO := TDAOPerson.Create(GetConnection);
  try
    LId := AReq.Params.Field('id').AsInteger;
    LDAO.Delete(LId);
    ARes.Status(204);
  finally
    LDAO.Free;
  end;
end;

procedure InsertBatch(AReq: THorseRequest; ARes: THorseResponse);
var
  LJSON: TJSONArray;
  LDAO: TDAOPerson;
begin
  LDAO := TDAOPerson.Create(GetConnection);
  try
    LJSON := AReq.Body<TJSONArray>;
    LDAO.InsertBatch(LJSON);
    ARes.Status(204);
  finally
    LDAO.Free;
  end;
end;

initialization
  THorse.Get('person', ListAll)
    .Post('person', Insert)
    .Get('person/:id', Find)
    .Put('person/:id', Update)
    .Delete('person/:id', Delete)
    .Post('person/batch', InsertBatch);

  TADRConnectionPoolBuilder.New
    .MinPoolCount(0)
    .MaxIdleSeconds(10)
    .OnGetConnection(GetConnection)
    .Build;
end.

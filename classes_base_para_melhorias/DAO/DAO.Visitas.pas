unit DAO.Visitas;

interface

uses
  DAO.Base,

  Data.DB,
  Data.SqlTimSt,

  FireDAC.Stan.Option,

  Server.DataSets,
  Server.SQL.Constants.Visitas,

  System.JSON,
  System.SysUtils,

  Utils.DataSet.JSON.Helper;

type
  TDAOVisitas = class(TDAOBase)
    private

    public
      function List                                      : TJSONArray;
      function Find(AID: Integer)                        : TJSONArray;
      function Insert(AValues: TJSONValue)               : TJSONObject;
      function Update(AID: Integer; AValues: TJSONValue) : TJSONObject;
      function Delete(AID: Integer)                      : TJSONObject;
  end;


implementation

{ TDAOVisitas }

function TDAOVisitas.List: TJSONArray;
var
  MyQuery : TMyQuery;
begin
  try
    MyQuery := SetSQL(C_SQL_LIST);
    MyQuery.Query.Active := True;
    if MyQuery.Query.IsEmpty then
      Result := TJSONArray.Create
    else
      Result := MyQuery.Query.DataSetToJSON();
  finally
    MyQuery.Free;
  end;
end;

function TDAOVisitas.Find(AID: Integer): TJSONArray;
var
  MyQuery : TMyQuery;
begin
  try
    MyQuery := SetSQL(C_LIST_BY_ID);
    MyQuery.Query.Params.CreateParam(ftInteger, 'pID', ptInput);
    MyQuery.Query.ParamByName('pID').AsInteger := AID;
    MyQuery.Query.Active := True;

    if MyQuery.Query.IsEmpty then
      Result := TJSONArray.Create
    else
      Result := MyQuery.Query.DataSetToJSON();
  finally
    MyQuery.Free;
  end;
end;

function TDAOVisitas.Insert(AValues: TJSONValue): TJSONObject;
var
  MyQuery        : TMyQuery;
  LValues        : TJSONValue;

  LTitulo        : string;
  LDescricao     : string;
  LDataAgendada  : TDateTime;
  LIDGerado      : Integer;
begin

  try
    MyQuery := SetSQL(C_INSERT);

    LTitulo        := AValues.GetValue<string>('TITULO');
    LDescricao     := AValues.GetValue<string>('DESCRICAO');
    LDataAgendada  := StrToDateTime(AValues.GetValue<string>('DATA_AGENDADA'), FormatSettings);

    MyQuery.Query.ParamByName('pTITULO').AsString          := LTitulo;
    MyQuery.Query.ParamByName('pDESCRICAO').AsString       := LDescricao;
    MyQuery.Query.ParamByName('pDATA_AGENDADA').AsDateTime := LDataAgendada;

    MyQuery.Query.ExecSQL;

    LIDGerado := MyQuery.Query.Connection.GetLastAutoGenValue('GEN_VISITAS_ID');

    Result :=
      TJSONObject.Create(
        TJSONPair.Create('id', TJSONNumber.Create(LIDGerado))
      );
  finally
    MyQuery.Free;
  end;
end;

function TDAOVisitas.Update(AID: Integer; AValues: TJSONValue): TJSONObject;
var
  MyQuery        : TMyQuery;
  LValues        : TJSONValue;

  LTitulo        : string;
  LDescricao     : string;
  LDataAgendada  : TDateTime;
begin
  try
    //Pesquiso no banco o ID recebido junto com o Body
    {
         "ID":50,
         "TITULO":"ALTERACAO",
         ...
    }
    MyQuery := SetSQL(C_LIST_BY_ID);
    MyQuery.Query.Params.CreateParam(ftInteger, 'pID', ptInput);
    MyQuery.Query.ParamByName('pID').AsInteger := AID;
    MyQuery.Query.Active := True;

    //Se não encontrar, retorna o TJSONObject vazio e o status code 404
    if MyQuery.Query.IsEmpty then
    begin
      Result := TJSONObject.Create;
      exit;
    end;

    MyQuery := SetSQL(C_UPDATE);

    LTitulo        := AValues.GetValue<string>('TITULO');
    LDescricao     := AValues.GetValue<string>('DESCRICAO');
    LDataAgendada  := StrToDateTime(AValues.GetValue<string>('DATA_AGENDADA'), FormatSettings);

    MyQuery.Query.ParamByName('pID').AsInteger             := AID;
    MyQuery.Query.ParamByName('pTITULO').AsString          := LTitulo;
    MyQuery.Query.ParamByName('pDESCRICAO').AsString       := LDescricao;
    MyQuery.Query.ParamByName('pDATA_AGENDADA').AsDateTime := LDataAgendada;

    MyQuery.Query.ExecSQL;

    //Se fizer o update correto, retorna o ID do registro alterado
    Result := TJSONObject.Create;
    Result.AddPair('ID', TJSONNumber.Create(AID));

  finally
    MyQuery.Free;
  end;
end;

function TDAOVisitas.Delete(AID: Integer): TJSONObject;
var
  MyQuery        : TMyQuery;
  LValues        : TJSONValue;
begin
  try
    MyQuery := SetSQL(C_LIST_BY_ID);
    MyQuery.Query.Params.CreateParam(ftInteger, 'pID', ptInput);
    MyQuery.Query.ParamByName('pID').AsInteger := AID;
    MyQuery.Query.Active := True;

    if MyQuery.Query.IsEmpty then
    begin
      Result := TJSONObject.Create;
      exit;
    end;

    try
      //Inicia uma transação
      MyQuery.Query.Connection.StartTransaction;
      MyQuery.Query.Connection.TxOptions.AutoCommit := False;
      MyQuery.Query.Connection.TxOptions.DisconnectAction := TFDtxAction.xdRollback;

      //Exclui primeiro os filhos
      MyQuery := SetSQL(C_DELETE_DETAIL);
      MyQuery.Query.ParamByName('pID_VISITA').AsInteger      := AID;
      MyQuery.Query.ExecSQL;

      //Agora exclui a VISITA (pai)
      MyQuery := SetSQL(C_DELETE);
      MyQuery.Query.ParamByName('pID').AsInteger             := AID;
      MyQuery.Query.ExecSQL;

      MyQuery.Query.Connection.Commit;
      MyQuery.Query.Connection.TxOptions.AutoCommit       := True;
      MyQuery.Query.Connection.TxOptions.DisconnectAction := TFDtxAction.xdCommit;

      Result := TJSONObject.Create;
      Result.AddPair('ID', TJSONNumber.Create(AID));
    except on E:Exception do
      begin
        MyQuery.Query.Connection.Rollback;
        MyQuery.Query.Connection.TxOptions.AutoCommit       := True;
        MyQuery.Query.Connection.TxOptions.DisconnectAction := TFDtxAction.xdCommit;
      end;
    end;
  finally
    MyQuery.Free;
  end;
end;

end.

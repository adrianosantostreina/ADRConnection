unit ADRConn.Model.PgDAC.Query;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  ADRConn.Model.Generator.Postgres,
  Data.DB,
  System.Classes,
  System.SysUtils,
  System.Variants,
  System.Generics.Collections,
  MemDS,
  DBAccess,
  PgAccess;

type
  TADRConnModelPgDACQuery = class(TInterfacedObject, IADRQuery)
  private
    [Weak]
    FConnection: IADRConnection;
    FQuery: TPgQuery;
    FGenerator: IADRGenerator;
    FBatchParams: TObjectList<TParams>;
    FParams: TParams;
    FSQL: TStrings;

    function GetBatchParams(AIndex: Integer): TParams;
    procedure ExecSQLDefault;
    procedure ExecSQLBatch;
    function AddParam(AName: string; AValue: Variant; AType: TFieldType;
      ANullIfEmpty: Boolean = False): TParam; overload;
    function AddParam(AParams: TParams; AName: string; AValue: Variant; AType: TFieldType;
      ANullIfEmpty: Boolean = False): TParam; overload;
  protected
    function SQL(AValue: string): IADRQuery; overload;
    function SQL(AValue: string; const Args: array of const): IADRQuery; overload;

    function Component: TComponent;
    function DataSet: TDataSet;
    function DataSource(AValue: TDataSource): IADRQuery;

    function ParamAsInteger(AName: string; AValue: Integer; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsCurrency(AName: string; AValue: Currency; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsFloat(AName: string; AValue: Double; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsString(AName: string; AValue: string; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsDateTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsDate(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsBoolean(AName: string; AValue: Boolean; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsStream(AName: string; AValue: TStream; ADataType: TFieldType = ftBlob; ANullIfEmpty: Boolean = False): IADRQuery; overload;

    function ArraySize(AValue: Integer): IADRQuery;
    function ParamAsInteger(AIndex: Integer; AName: string; AValue: Integer; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsCurrency(AIndex: Integer; AName: string; AValue: Currency; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsFloat(AIndex: Integer; AName: string; AValue: Double; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsString(AIndex: Integer; AName: string; AValue: string; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsDateTime(AIndex: Integer; AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsDate(AIndex: Integer; AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsTime(AIndex: Integer; AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsBoolean(AIndex: Integer; AName: string; AValue: Boolean; ANullIfEmpty: Boolean = False): IADRQuery; overload;

    function OpenDataSet: TDataSet;
    function Open: IADRQuery;
    function ExecSQL: IADRQuery;
    function ExecSQLAndCommit: IADRQuery;

    function Generator: IADRGenerator;
  public
    constructor Create(AConnection: IADRConnection);
    class function New(AConnection: IADRConnection): IADRQuery;
    destructor Destroy; override;
  end;

implementation

{ TADRConnModelPgDACQuery }

function TADRConnModelPgDACQuery.AddParam(AParams: TParams; AName: string;
  AValue: Variant; AType: TFieldType; ANullIfEmpty: Boolean): TParam;
begin
  Result := AParams.AddParameter;
  Result.Name := AName;
  Result.DataType := AType;
  Result.ParamType := ptInput;
  Result.Value := AValue;
end;

function TADRConnModelPgDACQuery.AddParam(AName: string; AValue: Variant;
  AType: TFieldType; ANullIfEmpty: Boolean): TParam;
begin
  Result := AddParam(FParams, AName, AValue, AType, ANullIfEmpty);
end;

function TADRConnModelPgDACQuery.ArraySize(AValue: Integer): IADRQuery;
begin
  Result := Self;
end;

function TADRConnModelPgDACQuery.Component: TComponent;
begin
  Result := FQuery;
end;

constructor TADRConnModelPgDACQuery.Create(AConnection: IADRConnection);
begin
  FConnection := AConnection;
  FQuery := TPgQuery.Create(nil);
  FQuery.Connection := TPgConnection(FConnection.Connection);
  FSQL := TStringList.Create;
  FParams := TParams.Create(nil);
end;

function TADRConnModelPgDACQuery.DataSet: TDataSet;
begin
  Result := FQuery;
end;

function TADRConnModelPgDACQuery.DataSource(AValue: TDataSource): IADRQuery;
begin
  Result := Self;
  if Assigned(AValue) then
    AValue.DataSet := FQuery;
end;

destructor TADRConnModelPgDACQuery.Destroy;
begin
  FQuery.Free;
  FSQL.Free;
  FParams.Free;
  FreeAndNil(FBatchParams);
  inherited;
end;

function TADRConnModelPgDACQuery.ExecSQL: IADRQuery;
begin
  Result := Self;
  if Assigned(FBatchParams) then
    ExecSQLBatch
  else
    ExecSQLDefault;
end;

function TADRConnModelPgDACQuery.ExecSQLAndCommit: IADRQuery;
begin
  Result := Self;
  try
    FConnection.StartTransaction;
    try
      ExecSQL;
      FConnection.Commit;
    except
      FConnection.Rollback;
      raise;
    end;
  finally
    FSQL.Clear;
  end;
end;

procedure TADRConnModelPgDACQuery.ExecSQLBatch;
var
  I, J: Integer;
  LQuery: TPgQuery;
  LParams: TParams;
begin
  LQuery := TPgQuery.Create(nil);
  try
    LQuery.Connection := TPgConnection(FConnection.Component);
    LQuery.SQL.Text := FSQL.Text;
    LQuery.Params.ValueCount := FBatchParams.Count;

    if FBatchParams.Count > 0 then
    begin
      LParams := FBatchParams.Items[0];
      for I := 0 to Pred(LParams.Count) do
        LQuery.Params[I].DataType := LParams[I].DataType;
    end;

    for I := 0 to Pred(FBatchParams.Count) do
    begin
      LParams := FBatchParams.Items[I];
      for J := 0 to Pred(LParams.Count) do
      begin
        if LParams[J].IsNull then
          LQuery.ParamByName(LParams[J].Name)[I].Clear
        else
          LQuery.ParamByName(LParams[J].Name)[I].Value := LParams[J].Value;
      end;
    end;
    LQuery.Execute(FBatchParams.Count);
  finally
    FreeAndNil(FBatchParams);
    FSQL.Clear;
    LQuery.Free;
  end;
end;

procedure TADRConnModelPgDACQuery.ExecSQLDefault;
var
  LQuery: TPgQuery;
  I: Integer;
begin
  LQuery := TPgQuery.Create(nil);
  try
    LQuery.Connection := TPgConnection(FConnection.Component);
    LQuery.SQL.Text := FSQL.Text;
    for I := 0 to Pred(FParams.Count) do
    begin
      LQuery.ParamByName(FParams[I].Name).DataType := FParams[I].DataType;
      LQuery.ParamByName(FParams[I].Name).Value := FParams[I].Value;
    end;

    LQuery.ExecSQL;
  finally
    FParams.Clear;
    FSQL.Clear;
    LQuery.Free;
  end;
end;

function TADRConnModelPgDACQuery.Generator: IADRGenerator;
begin
  if not Assigned(FGenerator) then
    FGenerator := TADRConnModelGeneratorPostgres.New(Self);
  Result := FGenerator;
end;

function TADRConnModelPgDACQuery.GetBatchParams(AIndex: Integer): TParams;
begin
  if not Assigned(FBatchParams) then
    FBatchParams := TObjectList<TParams>.Create;
  if FBatchParams.Count <= AIndex then
    FBatchParams.Add(TParams.Create);
  Result := FBatchParams.Last;
end;

class function TADRConnModelPgDACQuery.New(AConnection: IADRConnection): IADRQuery;
begin
  Result := Self.Create(AConnection);
end;

function TADRConnModelPgDACQuery.Open: IADRQuery;
var
  I: Integer;
begin
  Result := Self;
  if FQuery.Active then
    FQuery.Close;

  FQuery.SQL.Text := FSQL.Text;
  try
    for I := 0 to Pred(FParams.Count) do
    begin
      FQuery.ParamByName(FParams[I].Name).DataType := FParams[I].DataType;
      FQuery.ParamByName(FParams[I].Name).Value := FParams[I].Value;
    end;
    FQuery.Open;
  finally
    FSQL.Clear;
    FParams.Clear;
  end;
end;

function TADRConnModelPgDACQuery.OpenDataSet: TDataSet;
var
  LQuery: TPgQuery;
  I: Integer;
begin
  try
    LQuery := TPgQuery.Create(nil);
    try
      LQuery.Connection := TPgConnection(FConnection.Component);
      LQuery.SQL.Text := FSQL.Text;
      for I := 0 to Pred(FParams.Count) do
      begin
        LQuery.ParamByName(FParams[I].Name).DataType := FParams[I].DataType;
        LQuery.ParamByName(FParams[I].Name).Value := FParams[I].Value;
      end;
      LQuery.Open;
      Result := LQuery;
    except
      LQuery.Free;
      raise;
    end;
  finally
    FSQL.Clear;
    FParams.Clear;
  end;
end;

function TADRConnModelPgDACQuery.ParamAsBoolean(AIndex: Integer;
  AName: string; AValue, ANullIfEmpty: Boolean): IADRQuery;
var
  LParams: TParams;
begin
  Result := Self;
  LParams := GetBatchParams(AIndex);
  AddParam(LParams, AName, AValue, ftBoolean, ANullIfEmpty);
end;

function TADRConnModelPgDACQuery.ParamAsBoolean(AName: string; AValue,
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  AddParam(AName, AValue, ftBoolean, ANullIfEmpty);
end;

function TADRConnModelPgDACQuery.ParamAsCurrency(AName: string;
  AValue: Currency; ANullIfEmpty: Boolean): IADRQuery;
var
  LParam: TParam;
begin
  Result := Self;
  LParam := AddParam(AName, AValue, ftCurrency);
  if (AValue = 0) and (ANullIfEmpty) then
  begin
    LParam.DataType := ftCurrency;
    LParam.Value := Null;
  end;
end;

function TADRConnModelPgDACQuery.ParamAsCurrency(AIndex: Integer;
  AName: string; AValue: Currency; ANullIfEmpty: Boolean): IADRQuery;
var
  LParams: TParams;
  LParam: TParam;
begin
  Result := Self;
  LParams := GetBatchParams(AIndex);
  LParam := AddParam(LParams, AName, AValue, ftCurrency, ANullIfEmpty);
  if (AValue = 0) and (ANullIfEmpty) then
  begin
    LParam.DataType := ftCurrency;
    LParam.Clear;
  end
end;

function TADRConnModelPgDACQuery.ParamAsDate(AIndex: Integer;
  AName: string; AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
var
  LParams: TParams;
  LParam: TParam;
begin
  Result := Self;
  LParams := GetBatchParams(AIndex);
  LParam := AddParam(LParams, AName, AValue, ftDate, ANullIfEmpty);
  if (AValue = 0) and (ANullIfEmpty) then
  begin
    LParam.DataType := ftDate;
    LParam.Clear;
  end
end;

function TADRConnModelPgDACQuery.ParamAsDate(AName: string;
  AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
var
  LParam: TParam;
begin
  Result := Self;
  LParam := AddParam(AName, AValue, ftDate, ANullIfEmpty);
  if (AValue = 0) and (ANullIfEmpty) then
  begin
    LParam.DataType := ftDate;
    LParam.Value := Null;
  end;
end;

function TADRConnModelPgDACQuery.ParamAsDateTime(AName: string;
  AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
var
  LParam: TParam;
begin
  Result := Self;
  LParam := AddParam(AName, AValue, ftDateTime, ANullIfEmpty);
  if (AValue = 0) and (ANullIfEmpty) then
  begin
    LParam.DataType := ftDateTime;
    LParam.Value := Null;
  end;
end;

function TADRConnModelPgDACQuery.ParamAsDateTime(AIndex: Integer;
  AName: string; AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
var
  LParams: TParams;
  LParam: TParam;
begin
  Result := Self;
  LParams := GetBatchParams(AIndex);
  LParam := AddParam(LParams, AName, AValue, ftDateTime, ANullIfEmpty);
  if (AValue = 0) and (ANullIfEmpty) then
  begin
    LParam.DataType := ftDateTime;
    LParam.Clear;
  end
end;

function TADRConnModelPgDACQuery.ParamAsFloat(AIndex: Integer;
  AName: string; AValue: Double; ANullIfEmpty: Boolean): IADRQuery;
var
  LParams: TParams;
  LParam: TParam;
begin
  Result := Self;
  LParams := GetBatchParams(AIndex);
  LParam := AddParam(LParams, AName, AValue, ftFloat, ANullIfEmpty);
  if (AValue = 0) and (ANullIfEmpty) then
  begin
    LParam.DataType := ftFloat;
    LParam.Clear;
  end
end;

function TADRConnModelPgDACQuery.ParamAsFloat(AName: string;
  AValue: Double; ANullIfEmpty: Boolean): IADRQuery;
var
  LParam: TParam;
begin
  Result := Self;
  LParam := AddParam(AName, AValue, ftFloat, ANullIfEmpty);
  if (AValue = 0) and (ANullIfEmpty) then
  begin
    LParam.DataType := ftFloat;
    LParam.Value := Null;
  end;
end;

function TADRConnModelPgDACQuery.ParamAsInteger(AIndex: Integer;
  AName: string; AValue: Integer; ANullIfEmpty: Boolean): IADRQuery;
var
  LParams: TParams;
  LParam: TParam;
begin
  Result := Self;
  LParams := GetBatchParams(AIndex);
  LParam := AddParam(LParams, AName, AValue, ftInteger, ANullIfEmpty);
  if (AValue = 0) and (ANullIfEmpty) then
  begin
    LParam.DataType := ftInteger;
    LParam.Clear;
  end
end;

function TADRConnModelPgDACQuery.ParamAsInteger(AName: string;
  AValue: Integer; ANullIfEmpty: Boolean): IADRQuery;
var
  LParam: TParam;
begin
  Result := Self;
  LParam := AddParam(AName, AValue, ftInteger, ANullIfEmpty);
  if (AValue = 0) and (ANullIfEmpty) then
  begin
    LParam.DataType := ftInteger;
    LParam.Value := Null;
  end;
end;

function TADRConnModelPgDACQuery.ParamAsString(AName, AValue: string;
  ANullIfEmpty: Boolean): IADRQuery;
var
  LParam: TParam;
begin
  Result := Self;
  LParam := AddParam(AName, AValue, ftString, ANullIfEmpty);
  if (AValue = EmptyStr) and (ANullIfEmpty) then
  begin
    LParam.DataType := ftString;
    LParam.Value := Null;
  end;
end;

function TADRConnModelPgDACQuery.ParamAsStream(AName: string;
  AValue: TStream; ADataType: TFieldType;
  ANullIfEmpty: Boolean): IADRQuery;
var
  LParam: TParam;
begin
  Result := Self;
  LParam := AddParam(AName, null, ADataType, ANullIfEmpty);
  if ((Assigned(AValue) and (AValue.Size > 0)) or (not ANullIfEmpty)) then
    LParam.LoadFromStream(AValue, ADataType);
end;

function TADRConnModelPgDACQuery.ParamAsString(AIndex: Integer; AName,
  AValue: string; ANullIfEmpty: Boolean): IADRQuery;
var
  LParams: TParams;
  LParam: TParam;
begin
  Result := Self;
  LParams := GetBatchParams(AIndex);
  LParam := AddParam(LParams, AName, AValue, ftString, ANullIfEmpty);
  if (AValue = EmptyStr) and (ANullIfEmpty) then
  begin
    LParam.DataType := ftString;
    LParam.Clear;
  end
end;

function TADRConnModelPgDACQuery.ParamAsTime(AIndex: Integer;
  AName: string; AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
var
  LParams: TParams;
  LParam: TParam;
begin
  Result := Self;
  LParams := GetBatchParams(AIndex);
  LParam := AddParam(LParams, AName, AValue, ftTime, ANullIfEmpty);
  if (AValue = 0) and (ANullIfEmpty) then
  begin
    LParam.DataType := ftTime;
    LParam.Clear;
  end
end;

function TADRConnModelPgDACQuery.ParamAsTime(AName: string;
  AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
var
  LParam: TParam;
begin
  Result := Self;
  LParam := AddParam(AName, AValue, ftTime, ANullIfEmpty);
  if (AValue = 0) and (ANullIfEmpty) then
  begin
    LParam.DataType := ftTime;
    LParam.Value := Null;
  end;
end;

function TADRConnModelPgDACQuery.SQL(AValue: string): IADRQuery;
begin
  Result := Self;
  FSQL.Add(AValue);
end;

function TADRConnModelPgDACQuery.SQL(AValue: string;
  const Args: array of const): IADRQuery;
begin
  Result := Self;
  SQL(Format(AValue, Args));
end;

end.

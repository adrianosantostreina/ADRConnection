unit ADRConn.Model.Firedac.Query;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  Data.DB,
  System.Classes,
  System.SysUtils,
  System.Variants,
  System.Generics.Collections,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client;

type
  TADRConnModelFiredacQuery = class(TInterfacedObject, IADRQuery)
  private
    [Weak]
    FConnection: IADRConnection;
    FDQuery: TFDQuery;
    FGenerator: IADRGenerator;
    FBatchParams: TObjectList<TParams>;
    FParams: TParams;
    FSQL: TStrings;

    function GetBatchParams(AIndex: Integer): TParams;
    function AddParam(AName: string; AValue: Variant; AType: TFieldType;
      ANullIfEmpty: Boolean = False): TParam; overload;
    function AddParam(AParams: TParams; AName: string; AValue: Variant; AType: TFieldType;
      ANullIfEmpty: Boolean = False): TParam; overload;
    procedure ExecSQLDefault;
    procedure ExecSQLBatch;
  protected
    function SQL(AValue: string): IADRQuery; overload;
    function SQL(AValue: string; const Args: array of const): IADRQuery; overload;
    function Clear: IADRQuery;

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

{ TADRConnModelFiredacQuery }

function TADRConnModelFiredacQuery.AddParam(AName: string; AValue: Variant; AType: TFieldType;
  ANullIfEmpty: Boolean = False): TParam;
begin
  Result := AddParam(FParams, AName, AValue, AType, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.AddParam(AParams: TParams; AName: string; AValue: Variant;
  AType: TFieldType; ANullIfEmpty: Boolean): TParam;
begin
  Result := AParams.AddParameter;
  Result.Name := AName;
  Result.DataType := AType;
  Result.ParamType := ptInput;
  Result.Value := AValue;
end;

function TADRConnModelFiredacQuery.ArraySize(AValue: Integer): IADRQuery;
begin
  Result := Self;
end;

function TADRConnModelFiredacQuery.Clear: IADRQuery;
begin
  Result := Self;
  FSQL.Text := EmptyStr;
end;

function TADRConnModelFiredacQuery.Component: TComponent;
begin
  Result := FDQuery;
end;

constructor TADRConnModelFiredacQuery.Create(AConnection: IADRConnection);
begin
  FConnection := AConnection;
  FDQuery := TFDQuery.Create(nil);
  FDQuery.Connection := TFDConnection(FConnection.Connection);
  FSQL := TStringList.Create;
  FParams := TParams.Create(nil);
end;

function TADRConnModelFiredacQuery.DataSet: TDataSet;
begin
  Result := FDQuery;
end;

function TADRConnModelFiredacQuery.DataSource(AValue: TDataSource): IADRQuery;
begin
  Result := Self;
  if Assigned(AValue) then
    AValue.DataSet := FDQuery;
end;

destructor TADRConnModelFiredacQuery.Destroy;
begin
  FDQuery.Free;
  FSQL.Free;
  FParams.Free;
  FreeAndNil(FBatchParams);
  inherited;
end;

function TADRConnModelFiredacQuery.ExecSQL: IADRQuery;
begin
  Result := Self;
  if Assigned(FBatchParams) then
    ExecSQLBatch
  else
    ExecSQLDefault;
end;

function TADRConnModelFiredacQuery.ExecSQLAndCommit: IADRQuery;
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

procedure TADRConnModelFiredacQuery.ExecSQLBatch;
var
  I, J: Integer;
  LQuery: TFDQuery;
  LParams: TParams;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := TFDConnection(FConnection.Component);
    LQuery.SQL.Text := FSQL.Text;
    LQuery.Params.ArraySize := FBatchParams.Count;
    for I := 0 to Pred(FBatchParams.Count) do
    begin
      LParams := FBatchParams.Items[I];
      for J := 0 to Pred(LParams.Count) do
      begin
        if LParams[J].IsNull then
        begin
          LQuery.ParamByName(LParams[J].Name).DataType := LParams[J].DataType;
          LQuery.ParamByName(LParams[J].Name).Clear(I);
        end
        else
          LQuery.ParamByName(LParams[J].Name).Values[I] := LParams[J].Value;
      end;
    end;
    LQuery.Execute(FBatchParams.Count, 0);
  finally
    FreeAndNil(FBatchParams);
    FSQL.Clear;
    LQuery.Free;
  end;
end;

procedure TADRConnModelFiredacQuery.ExecSQLDefault;
var
  LQuery: TFDQuery;
  I: Integer;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := TFDConnection(FConnection.Component);
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

function TADRConnModelFiredacQuery.Generator: IADRGenerator;
begin
  if not Assigned(FGenerator) then
    FGenerator := TADRConnModelGenerator.NewGenerator(FConnection, Self);
  Result := FGenerator;
end;

function TADRConnModelFiredacQuery.GetBatchParams(AIndex: Integer): TParams;
begin
  if not Assigned(FBatchParams) then
    FBatchParams := TObjectList<TParams>.Create;
  if FBatchParams.Count <= AIndex then
    FBatchParams.Add(TParams.Create);
  Result := FBatchParams.Last;
end;

class function TADRConnModelFiredacQuery.New(AConnection: IADRConnection): IADRQuery;
begin
  Result := Self.Create(AConnection);
end;

function TADRConnModelFiredacQuery.Open: IADRQuery;
var
  I: Integer;
begin
  Result := Self;
  if FDQuery.Active then
    FDQuery.Close;

  FDQuery.SQL.Text := FSQL.Text;
  try
    for I := 0 to Pred(FParams.Count) do
    begin
      FDQuery.ParamByName(FParams[I].Name).DataType := FParams[I].DataType;
      FDQuery.ParamByName(FParams[I].Name).Value := FParams[I].Value;
    end;
    FDQuery.Open;
  finally
    FSQL.Clear;
    FParams.Clear;
  end;
end;

function TADRConnModelFiredacQuery.OpenDataSet: TDataSet;
var
  LQuery : TFDQuery;
  I: Integer;
begin
  try
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := TFDConnection(FConnection.Component);
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

function TADRConnModelFiredacQuery.ParamAsBoolean(AName: string; AValue: Boolean; ANullIfEmpty: Boolean = False): IADRQuery;
begin
  Result := Self;
  AddParam(AName, AValue, ftBoolean, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsCurrency(AName: string; AValue: Currency; ANullIfEmpty: Boolean = False): IADRQuery;
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

function TADRConnModelFiredacQuery.ParamAsDate(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery;
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

function TADRConnModelFiredacQuery.ParamAsDateTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery;
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

function TADRConnModelFiredacQuery.ParamAsFloat(AName: string; AValue: Double; ANullIfEmpty: Boolean = False): IADRQuery;
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

function TADRConnModelFiredacQuery.ParamAsInteger(AName: string; AValue: Integer; ANullIfEmpty: Boolean = False): IADRQuery;
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

function TADRConnModelFiredacQuery.ParamAsString(AName: string; AValue: string; ANullIfEmpty: Boolean = False): IADRQuery;
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

function TADRConnModelFiredacQuery.ParamAsTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery;
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

function TADRConnModelFiredacQuery.SQL(AValue: string): IADRQuery;
begin
  Result := Self;
  FSQL.Add(AValue);
end;

function TADRConnModelFiredacQuery.SQL(AValue: string; const Args: array of const): IADRQuery;
begin
  Result := Self;
  SQL(Format(AValue, Args));
end;

function TADRConnModelFiredacQuery.ParamAsBoolean(AIndex: Integer; AName: string; AValue,
  ANullIfEmpty: Boolean): IADRQuery;
var
  LParams: TParams;
begin
  Result := Self;
  LParams := GetBatchParams(AIndex);
  AddParam(LParams, AName, AValue, ftBoolean, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsCurrency(AIndex: Integer; AName: string; AValue: Currency;
  ANullIfEmpty: Boolean): IADRQuery;
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

function TADRConnModelFiredacQuery.ParamAsDate(AIndex: Integer; AName: string; AValue: TDateTime;
  ANullIfEmpty: Boolean): IADRQuery;
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

function TADRConnModelFiredacQuery.ParamAsDateTime(AIndex: Integer; AName: string;
  AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
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

function TADRConnModelFiredacQuery.ParamAsFloat(AIndex: Integer; AName: string; AValue: Double;
  ANullIfEmpty: Boolean): IADRQuery;
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

function TADRConnModelFiredacQuery.ParamAsInteger(AIndex: Integer; AName: string; AValue: Integer;
  ANullIfEmpty: Boolean): IADRQuery;
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

function TADRConnModelFiredacQuery.ParamAsStream(AName: string;
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

function TADRConnModelFiredacQuery.ParamAsString(AIndex: Integer; AName, AValue: string;
  ANullIfEmpty: Boolean): IADRQuery;
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

function TADRConnModelFiredacQuery.ParamAsTime(AIndex: Integer; AName: string; AValue: TDateTime;
  ANullIfEmpty: Boolean): IADRQuery;
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

end.

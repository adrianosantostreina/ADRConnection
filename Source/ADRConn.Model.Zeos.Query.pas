unit ADRConn.Model.Zeos.Query;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  Data.DB,
  System.Classes,
  System.SysUtils,
  System.Variants,
  System.Generics.Collections,
  ZDataset,
  ZConnection,
  ZDatasetParam;

type
  TADRConnModelZeosQuery = class(TInterfacedObject, IADRQuery)
  private
    [Weak]
    FConnection: IADRConnection;
    FQuery: TZQuery;
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

{ TADRConnModelZeosQuery }

function TADRConnModelZeosQuery.AddParam(AParams: TParams; AName: string;
  AValue: Variant; AType: TFieldType; ANullIfEmpty: Boolean): TParam;
begin
  Result := AParams.AddParameter;
  Result.Name := AName;
  Result.DataType := AType;
  Result.ParamType := ptInput;
  Result.Value := AValue;
end;

function TADRConnModelZeosQuery.AddParam(AName: string; AValue: Variant;
  AType: TFieldType; ANullIfEmpty: Boolean): TParam;
begin
  Result := AddParam(FParams, AName, AValue, AType, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ArraySize(AValue: Integer): IADRQuery;
begin
  Result := Self;
end;

function TADRConnModelZeosQuery.Component: TComponent;
begin
  Result := FQuery;
end;

constructor TADRConnModelZeosQuery.Create(AConnection: IADRConnection);
begin
  FConnection := AConnection;
  FQuery := TZQuery.Create(nil);
  FQuery.Connection := TZConnection(FConnection.Component);
  FSQL := TStringList.Create;
  FParams := TParams.Create(nil);
end;

function TADRConnModelZeosQuery.DataSet: TDataSet;
begin
  Result := FQuery;
end;

function TADRConnModelZeosQuery.DataSource(AValue: TDataSource): IADRQuery;
begin
  Result := Self;
  if Assigned(AValue) then
    AValue.DataSet := FQuery;
end;

destructor TADRConnModelZeosQuery.Destroy;
begin
  FQuery.Free;
  FSQL.Free;
  FParams.Free;
  FreeAndNil(FBatchParams);
  inherited;
end;

function TADRConnModelZeosQuery.ExecSQL: IADRQuery;
begin
  Result := Self;
  if Assigned(FBatchParams) then
    ExecSQLBatch
  else
    ExecSQLDefault;
end;

function TADRConnModelZeosQuery.ExecSQLAndCommit: IADRQuery;
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

procedure TADRConnModelZeosQuery.ExecSQLBatch;
var
  I, J: Integer;
  LQuery: TZQuery;
  LParams: TParams;
  LDataType: TFieldType;
  LParam: TZParam;
begin
  LQuery := TZQuery.Create(nil);
  try
    LQuery.Connection := TZConnection(FConnection.Component);
    LQuery.SQL.Text := FSQL.Text;
    LQuery.Params.BatchDMLCount := FBatchParams.Count;

    for I := 0 to Pred(FBatchParams.Count) do
    begin
      LParams := FBatchParams.Items[I];
      for J := 0 to Pred(LParams.Count) do
      begin
        if LParams[J].IsNull then
        begin
          LQuery.ParamByName(LParams[J].Name).DataType := LParams[J].DataType;
          LQuery.ParamByName(LParams[J].Name).IsNulls[I] := True;
        end
        else
        begin
          LDataType := LParams[J].DataType;
          LParam := LQuery.ParamByName(LParams[J].Name);
          case LDataType of
            ftUnknown: LParam.AsStrings[I] := LParams[J].AsString;
            ftString: LParam.AsStrings[I] := LParams[J].AsString;
            ftSmallint: LParam.AsSmallInts[I] := LParams[J].AsSmallInt;
            ftInteger: LParam.AsIntegers[I] := LParams[J].AsInteger;
            ftWord: LParam.AsWords[I] := LParams[J].AsWord;
            ftBoolean: LParam.AsBooleans[I] := LParams[J].AsBoolean;
            ftFloat: LParam.AsFloats[I] := LParams[J].AsFloat;
            ftCurrency: LParam.AsCurrencys[I] := LParams[J].AsCurrency;
            ftBCD: LParam.AsBCDs[I] := LParams[J].AsBCD;
            ftDate: LParam.AsDates[I] := LParams[J].AsDate;
            ftTime: LParam.AsTimes[I] := LParams[J].AsTime;
            ftDateTime: LParam.AsDateTimes[I] := LParams[J].AsDateTime;
            ftBytes: LParam.AsBytesArray[I] := LParams[J].AsBytes;
            ftVarBytes: LParam.AsBytesArray[I] := LParams[J].AsBytes;
            ftAutoInc: LParam.AsInt64s[I] := LParams[J].AsInteger;
            ftBlob: LParam.AsBlobs[I] := LParams[J].AsBlob;
            ftMemo: LParam.AsMemos[I] := LParams[J].AsMemo;
            ftFmtMemo: LParam.AsMemos[I] := LParams[J].AsMemo;
            ftWideString: LParam.AsWideStrings[I] := LParams[J].AsWideString;
            ftLargeint: LParam.AsLargeInts[I] := LParams[J].AsLargeInt;
            ftOraBlob: LParam.AsBlobs[I] := LParams[J].AsBlob;
            ftOraClob: LParam.AsBlobs[I] := LParams[J].AsBlob;
            ftVariant: LParam.AsStrings[I] := LParams[J].AsString;
            ftGuid: LParam.AsGUIDs[I] := LParams[J].AsGuid;
            ftTimeStamp: LParam.AsDateTimes[I] := LParams[J].AsDateTime;
            ftFMTBcd: LParam.AsFmtBCDs[I] := LParams[J].AsFMTBCD;
            ftFixedWideChar: LParam.AsWideStrings[I] := LParams[J].AsWideString;
            ftWideMemo: LParam.AsWideMemos[I] := LParams[J].AsWideString;
            ftOraTimeStamp: LParam.AsDateTimes[I] := LParams[J].AsDateTime;
            ftLongWord: LParam.AsLongwords[I] := LParams[J].AsLongWord;
            ftShortint: LParam.AsShortInts[I] := LParams[J].AsShortInt;
            ftByte: LParam.AsBytes[I] := LParams[J].AsByte;
            ftExtended: LParam.AsFloats[I] := LParams[J].AsFloat;
            ftTimeStampOffset: LParam.AsDateTimes[I] := LParams[J].AsDateTime;
            ftSingle: LParam.AsSingles[I] := LParams[J].AsSingle;
          end;
        end;
      end;
    end;
    LQuery.ExecSQL;
  finally
    FreeAndNil(FBatchParams);
    FSQL.Clear;
    LQuery.Free;
  end;
end;

procedure TADRConnModelZeosQuery.ExecSQLDefault;
var
  LQuery: TZQuery;
  I: Integer;
begin
  LQuery := TZQuery.Create(nil);
  try
    LQuery.Connection := TZConnection(FConnection.Component);
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

function TADRConnModelZeosQuery.Generator: IADRGenerator;
begin
  if not Assigned(FGenerator) then
    FGenerator := TADRConnModelGenerator.NewGenerator(FConnection, Self);
  Result := FGenerator;
end;

function TADRConnModelZeosQuery.GetBatchParams(AIndex: Integer): TParams;
begin
  if not Assigned(FBatchParams) then
    FBatchParams := TObjectList<TParams>.Create;
  if FBatchParams.Count <= AIndex then
    FBatchParams.Add(TParams.Create);
  Result := FBatchParams.Last;
end;

class function TADRConnModelZeosQuery.New(AConnection: IADRConnection): IADRQuery;
begin
  Result := Self.Create(AConnection);
end;

function TADRConnModelZeosQuery.Open: IADRQuery;
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

function TADRConnModelZeosQuery.OpenDataSet: TDataSet;
var
  LQuery: TZQuery;
  I: Integer;
begin
  try
    LQuery := TZQuery.Create(nil);
    try
      LQuery.Connection := TZConnection(FConnection.Component);
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

function TADRConnModelZeosQuery.ParamAsBoolean(AIndex: Integer;
  AName: string; AValue, ANullIfEmpty: Boolean): IADRQuery;
var
  LParams: TParams;
begin
  Result := Self;
  LParams := GetBatchParams(AIndex);
  AddParam(LParams, AName, AValue, ftBoolean, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsBoolean(AName: string; AValue,
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  AddParam(AName, AValue, ftBoolean, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsCurrency(AName: string;
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

function TADRConnModelZeosQuery.ParamAsCurrency(AIndex: Integer;
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

function TADRConnModelZeosQuery.ParamAsDate(AIndex: Integer;
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

function TADRConnModelZeosQuery.ParamAsDate(AName: string;
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

function TADRConnModelZeosQuery.ParamAsDateTime(AName: string;
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

function TADRConnModelZeosQuery.ParamAsDateTime(AIndex: Integer;
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

function TADRConnModelZeosQuery.ParamAsFloat(AIndex: Integer;
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

function TADRConnModelZeosQuery.ParamAsFloat(AName: string;
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

function TADRConnModelZeosQuery.ParamAsInteger(AIndex: Integer;
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

function TADRConnModelZeosQuery.ParamAsInteger(AName: string;
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

function TADRConnModelZeosQuery.ParamAsString(AName, AValue: string;
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

function TADRConnModelZeosQuery.ParamAsStream(AName: string;
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

function TADRConnModelZeosQuery.ParamAsString(AIndex: Integer; AName,
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

function TADRConnModelZeosQuery.ParamAsTime(AIndex: Integer;
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

function TADRConnModelZeosQuery.ParamAsTime(AName: string;
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

function TADRConnModelZeosQuery.SQL(AValue: string): IADRQuery;
begin
  Result := Self;
  FSQL.Add(AValue);
end;

function TADRConnModelZeosQuery.SQL(AValue: string;
  const Args: array of const): IADRQuery;
begin
  Result := Self;
  SQL(Format(AValue, Args));
end;

end.

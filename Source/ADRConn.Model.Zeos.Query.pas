unit ADRConn.Model.Zeos.Query;

interface

uses
  Data.DB,
  System.Classes,
  System.SysUtils,
  System.Variants,
  System.Generics.Collections,
  ZDataset,
  ZConnection,
  ZDatasetParam,
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  ADRConn.Model.QueryParam;

type
  TADRConnModelZeosQuery = class(TInterfacedObject, IADRQuery)
  private
    [Weak]
    FConnection: IADRConnection;
    FQuery: TZQuery;
    FGenerator: IADRGenerator;
    FQueryParams: IADRQueryParams;
    FBatchParams: IADRQueryBatchParams;
    FSQL: TStrings;

    function TryHandleException(AException: Exception): Boolean;
    procedure ExecSQLDefault;
    procedure ExecSQLBatch;
  protected
    function SQL(AValue: string): IADRQuery; overload;
    function SQL(AValue: string; const Args: array of const): IADRQuery; overload;
    function Clear: IADRQuery;

    function Component: TComponent;
    function DataSet: TDataSet;
    function DataSource(AValue: TDataSource): IADRQuery;

    function Params: IADRQueryParams;
    function BatchParams: IADRQueryBatchParams;

    function ParamAsInteger(AName: string; AValue: Integer; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsCurrency(AName: string; AValue: Currency; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsFloat(AName: string; AValue: Double; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsString(AName: string; AValue: string; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsDateTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsDate(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsBoolean(AName: string; AValue: Boolean; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsStream(AName: string; AValue: TStream; ADataType: TFieldType = ftBlob; ANullIfEmpty: Boolean = False): IADRQuery; overload;

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

function TADRConnModelZeosQuery.BatchParams: IADRQueryBatchParams;
begin
  if not Assigned(FBatchParams) then
    FBatchParams := TADRConnModelQueryBatchParams.New(Self);
  Result := FBatchParams;
end;

function TADRConnModelZeosQuery.Clear: IADRQuery;
begin
  Result := Self;
  FSQL.Text := EmptyStr;
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
  FQueryParams := TADRConnModelQueryParams.New(Self);
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
    try
      LQuery.Connection := TZConnection(FConnection.Component);
      LQuery.SQL.Text := FSQL.Text;
      LQuery.Params.BatchDMLCount := FBatchParams.ArraySize;

      for I := 0 to Pred(FBatchParams.ArraySize) do
      begin
        LParams := FBatchParams.Params(I);
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
    except
      on E: Exception do
      begin
        if not TryHandleException(E) then
          raise;

        ExecSQLBatch;
      end;
    end;
  finally
    FBatchParams := nil;
    FSQL.Clear;
    LQuery.Free;
  end;
end;

procedure TADRConnModelZeosQuery.ExecSQLDefault;
var
  I: Integer;
  LQuery: TZQuery;
  LParams: TParams;
begin
  LQuery := TZQuery.Create(nil);
  try
    try
      LQuery.Connection := TZConnection(FConnection.Component);
      LQuery.SQL.Text := FSQL.Text;
      LParams := FQueryParams.Params;
      for I := 0 to Pred(LParams.Count) do
      begin
        LQuery.ParamByName(LParams[I].Name).DataType := LParams[I].DataType;
        LQuery.ParamByName(LParams[I].Name).Value := LParams[I].Value;
      end;

      LQuery.ExecSQL;
    except
      on E: Exception do
      begin
        if not TryHandleException(E) then
          raise;

        ExecSQLDefault;
      end;
    end;
  finally
    FQueryParams.Clear;
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

class function TADRConnModelZeosQuery.New(AConnection: IADRConnection): IADRQuery;
begin
  Result := Self.Create(AConnection);
end;

function TADRConnModelZeosQuery.Open: IADRQuery;
var
  I: Integer;
  LParams: TParams;
begin
  Result := Self;
  if FQuery.Active then
    FQuery.Close;

  FQuery.SQL.Text := FSQL.Text;
  try
    try
      LParams := FQueryParams.Params;
      for I := 0 to Pred(LParams.Count) do
      begin
        FQuery.ParamByName(LParams[I].Name).DataType := LParams[I].DataType;
        FQuery.ParamByName(LParams[I].Name).Value := LParams[I].Value;
      end;
      FQuery.Open;
    except
      on E: Exception do
      begin
        if not TryHandleException(E) then
          raise;

        Result := Open;
      end;
    end;
  finally
    FSQL.Clear;
    FQueryParams.Clear;
  end;
end;

function TADRConnModelZeosQuery.OpenDataSet: TDataSet;
var
  I: Integer;
  LQuery: TZQuery;
  LParams: TParams;
begin
  try
    LQuery := TZQuery.Create(nil);
    try
      LQuery.Connection := TZConnection(FConnection.Component);
      LQuery.SQL.Text := FSQL.Text;
      LParams := FQueryParams.Params;
      for I := 0 to Pred(LParams.Count) do
      begin
        LQuery.ParamByName(LParams[I].Name).DataType := LParams[I].DataType;
        LQuery.ParamByName(LParams[I].Name).Value := LParams[I].Value;
      end;
      LQuery.Open;
      Result := LQuery;
    except
      on E: Exception do
      begin
        LQuery.Free;
        if not TryHandleException(E) then
          raise;

        Result := OpenDataSet;
      end;
    end;
  finally
    FSQL.Clear;
    FQueryParams.Clear;
  end;
end;

function TADRConnModelZeosQuery.ParamAsBoolean(AIndex: Integer;
  AName: string; AValue, ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsBoolean(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsBoolean(AName: string; AValue,
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  FQueryParams.AsBoolean(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsCurrency(AName: string;
  AValue: Currency; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  FQueryParams.AsCurrency(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsCurrency(AIndex: Integer;
  AName: string; AValue: Currency; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsCurrency(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsDate(AIndex: Integer;
  AName: string; AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsDate(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsDate(AName: string;
  AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  FQueryParams.AsDate(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsDateTime(AName: string;
  AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  FQueryParams.AsDateTime(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsDateTime(AIndex: Integer;
  AName: string; AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsDateTime(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsFloat(AIndex: Integer;
  AName: string; AValue: Double; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsFloat(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsFloat(AName: string;
  AValue: Double; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  FQueryParams.AsFloat(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsInteger(AIndex: Integer;
  AName: string; AValue: Integer; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsInteger(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsInteger(AName: string;
  AValue: Integer; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  FQueryParams.AsInteger(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsString(AName, AValue: string;
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  FQueryParams.AsString(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsStream(AName: string;
  AValue: TStream; ADataType: TFieldType;
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  FQueryParams.AsStream(AName, AValue, ADataType, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsString(AIndex: Integer; AName,
  AValue: string; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsString(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.ParamAsTime(AIndex: Integer;
  AName: string; AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsTime(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelZeosQuery.Params: IADRQueryParams;
begin
  if not Assigned(FQueryParams) then
    FQueryParams := TADRConnModelQueryParams.New(Self);
  Result := FQueryParams;
end;

function TADRConnModelZeosQuery.ParamAsTime(AName: string;
  AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  FQueryParams.AsTime(AName, AValue, ANullIfEmpty);
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

function TADRConnModelZeosQuery.TryHandleException(AException: Exception): Boolean;
begin
  Result := FConnection.Events.HandleException(AException);
end;

end.

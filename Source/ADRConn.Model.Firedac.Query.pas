unit ADRConn.Model.Firedac.Query;

interface

uses
  Data.DB,
  System.Classes,
  System.SysUtils,
  System.Variants,
  System.Generics.Collections,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  ADRConn.Model.QueryParam;

type
  TADRConnModelFiredacQuery = class(TInterfacedObject, IADRQuery)
  private
    [Weak]
    FConnection: IADRConnection;
    FDQuery: TFDQuery;
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

{ TADRConnModelFiredacQuery }

function TADRConnModelFiredacQuery.BatchParams: IADRQueryBatchParams;
begin
  if not Assigned(FBatchParams) then
    FBatchParams := TADRConnModelQueryBatchParams.New(Self);
  Result := FBatchParams;
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
  FQueryParams := TADRConnModelQueryParams.New(Self);
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
    try
      LQuery.Connection := TFDConnection(FConnection.Component);
      LQuery.SQL.Text := FSQL.Text;
      LQuery.Params.ArraySize := FBatchParams.ArraySize;
      for I := 0 to Pred(FBatchParams.ArraySize) do
      begin
        LParams := FBatchParams.Params(I);
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
      LQuery.Execute(FBatchParams.ArraySize, 0);
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

procedure TADRConnModelFiredacQuery.ExecSQLDefault;
var
  I: Integer;
  LQuery: TFDQuery;
  LParams: TParams;
begin
  FQueryParams.ValidateParameters;
  LQuery := TFDQuery.Create(nil);
  try
    try
      LQuery.Connection := TFDConnection(FConnection.Component);
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

function TADRConnModelFiredacQuery.Generator: IADRGenerator;
begin
  if not Assigned(FGenerator) then
    FGenerator := TADRConnModelGenerator.NewGenerator(FConnection, Self);
  Result := FGenerator;
end;

class function TADRConnModelFiredacQuery.New(AConnection: IADRConnection): IADRQuery;
begin
  Result := Self.Create(AConnection);
end;

function TADRConnModelFiredacQuery.Open: IADRQuery;
var
  I: Integer;
  LParams: TParams;
begin
  Result := Self;
  if FDQuery.Active then
    FDQuery.Close;

  FDQuery.SQL.Text := FSQL.Text;
  try
    try
      LParams := FQueryParams.Params;
      for I := 0 to Pred(LParams.Count) do
      begin
        FDQuery.ParamByName(LParams[I].Name).DataType := LParams[I].DataType;
        FDQuery.ParamByName(LParams[I].Name).Value := LParams[I].Value;
      end;
      FDQuery.Open;
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

function TADRConnModelFiredacQuery.OpenDataSet: TDataSet;
var
  I: Integer;
  LQuery : TFDQuery;
  LParams: TParams;
begin
  try
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := TFDConnection(FConnection.Component);
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

function TADRConnModelFiredacQuery.ParamAsBoolean(AName: string; AValue: Boolean; ANullIfEmpty: Boolean = False): IADRQuery;
begin
  Result := Self;
  Params.AsBoolean(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsCurrency(AName: string; AValue: Currency; ANullIfEmpty: Boolean = False): IADRQuery;
begin
  Result := Self;
  Params.AsCurrency(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsDate(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery;
begin
  Result := Self;
  Params.AsDate(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsDateTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery;
begin
  Result := Self;
  Params.AsDateTime(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsFloat(AName: string; AValue: Double; ANullIfEmpty: Boolean = False): IADRQuery;
begin
  Result := Self;
  Params.AsFloat(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsInteger(AName: string; AValue: Integer; ANullIfEmpty: Boolean = False): IADRQuery;
begin
  Result := Self;
  Params.AsInteger(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsString(AName: string; AValue: string; ANullIfEmpty: Boolean = False): IADRQuery;
begin
  Result := Self;
  Params.AsString(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery;
begin
  Result := Self;
  Params.AsTime(AName, AValue, ANullIfEmpty);
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

function TADRConnModelFiredacQuery.TryHandleException(AException: Exception): Boolean;
begin
  Result := FConnection.Events.HandleException(AException);
end;

function TADRConnModelFiredacQuery.ParamAsBoolean(AIndex: Integer; AName: string; AValue,
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsBoolean(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsCurrency(AIndex: Integer; AName: string; AValue: Currency;
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsCurrency(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsDate(AIndex: Integer; AName: string; AValue: TDateTime;
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsDate(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsDateTime(AIndex: Integer; AName: string;
  AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsDateTime(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsFloat(AIndex: Integer; AName: string; AValue: Double;
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsFloat(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsInteger(AIndex: Integer; AName: string; AValue: Integer;
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsInteger(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsStream(AName: string;
  AValue: TStream; ADataType: TFieldType;
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  Params.AsStream(AName, AValue, ADataType, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsString(AIndex: Integer; AName, AValue: string;
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsString(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.ParamAsTime(AIndex: Integer; AName: string; AValue: TDateTime;
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsTime(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelFiredacQuery.Params: IADRQueryParams;
begin
  if not Assigned(FQueryParams) then
    FQueryParams := TADRConnModelQueryParams.New(Self);
  Result := FQueryParams;
end;

end.

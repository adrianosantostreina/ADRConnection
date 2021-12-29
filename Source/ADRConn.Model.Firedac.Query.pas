unit ADRConn.Model.Firedac.Query;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  Data.DB,
  System.Classes,
  System.SysUtils,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client;

type TADRConnModelFiredacQuery = class(TInterfacedObject, IADRQuery)

  private
    [Weak]
    FConnection: IADRConnection;
    FDQuery: TFDQuery;
    FGenerator: IADRGenerator;
    FParams: TParams;
    FSQL: TStrings;

    function AddParam(Name: string; Value: Variant; AType: TFieldType): TParam;

  protected
    function SQL(Value: String): IADRQuery; overload;
    function SQL(Value: string; const Args: array of const): IADRQuery; overload;

    function DataSource(Value: TDataSource): IADRQuery;

    function ParamAsInteger(Name: String; Value: Integer): IADRQuery;
    function ParamAsCurrency(Name: String; Value: Currency): IADRQuery;
    function ParamAsFloat(Name: String; Value: Double): IADRQuery;
    function ParamAsString(Name: String; Value: String): IADRQuery;
    function ParamAsDateTime(Name: String; Value: TDateTime): IADRQuery;
    function ParamAsDate(Name: String; Value: TDateTime): IADRQuery;
    function ParamAsTime(Name: String; Value: TDateTime): IADRQuery;
    function ParamAsBoolean(Name: String; Value: Boolean): IADRQuery;

    function OpenDataSet: TDataSet;
    function Open: IADRQuery;
    function ExecSQL: IADRQuery;
    function ExecSQLAndCommit: IADRQuery;

    function Generator: IADRGenerator;
  public
    constructor create(AConnection: IADRConnection);
    class function New(AConnection: IADRConnection): IADRQuery;
    destructor Destroy; override;
end;

implementation

{ TADRConnModelFiredacQuery }

function TADRConnModelFiredacQuery.AddParam(Name: string; Value: Variant; AType: TFieldType): TParam;
begin
  result := FParams.AddParameter;
  result.Name := Name;
  result.DataType := AType;
  result.Value := Value;
  result.ParamType := ptInput;
end;

constructor TADRConnModelFiredacQuery.create(AConnection: IADRConnection);
begin
  FConnection := AConnection;
  FDQuery := TFDQuery.Create(nil);
  FDQuery.Connection := TFDConnection( FConnection.Connection );
  FSQL := TStringList.Create;
  FParams := TParams.Create(nil);
end;

function TADRConnModelFiredacQuery.DataSource(Value: TDataSource): IADRQuery;
begin
  result := Self;
  if Assigned(Value) then
    Value.DataSet := FDQuery;
end;

destructor TADRConnModelFiredacQuery.Destroy;
begin
  FDQuery.Free;
  FSQL.Free;
  FParams.Free;
  inherited;
end;

function TADRConnModelFiredacQuery.ExecSQL: IADRQuery;
var
  LQuery: TFDQuery;
  i: Integer;
begin
  result := Self;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := TFDConnection(FConnection.Component);
    LQuery.SQL.Text := FSQL.Text;
    for i := 0 to Pred(FParams.Count) do
      LQuery.ParamByName(FParams[i].Name).Value := FParams[i].Value;

    LQuery.ExecSQL;
  finally
    FParams.Clear;
    FSQL.Clear;
    LQuery.Free;
  end;
end;

function TADRConnModelFiredacQuery.ExecSQLAndCommit: IADRQuery;
begin
  result := Self;
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

function TADRConnModelFiredacQuery.Generator: IADRGenerator;
begin
  if not Assigned(FGenerator) then
    FGenerator := TADRConnModelGenerator.NewGenerator(FConnection, Self);
  Result := FGenerator;
end;

class function TADRConnModelFiredacQuery.New(AConnection: IADRConnection): IADRQuery;
begin
  result := Self.create(AConnection);
end;

function TADRConnModelFiredacQuery.Open: IADRQuery;
var
  i: Integer;
begin
  result := Self;
  if FDQuery.Active then
    FDQuery.Close;

  FDQuery.SQL.Text := FSQL.Text;
  try
    for i := 0 to Pred(FParams.Count) do
      FDQuery.ParamByName(FParams[i].Name).Value := FParams[i].Value;

    FDQuery.Open;
  finally
    FSQL.Clear;
    FParams.Clear;
  end;
end;

function TADRConnModelFiredacQuery.OpenDataSet: TDataSet;
var
  LQuery : TFDQuery;
  i: Integer;
begin
  try
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := TFDConnection(FConnection.Component);
      LQuery.SQL.Text := FSQL.Text;
      for i := 0 to Pred(FParams.Count) do
        LQuery.ParamByName(FParams[i].Name).Value := FParams[i].Value;

      LQuery.Open;

      result := LQuery;
    except
      LQuery.Free;
      raise;
    end;
  finally
    FSQL.Clear;
    FParams.Clear;
  end;
end;

function TADRConnModelFiredacQuery.ParamAsBoolean(Name: String; Value: Boolean): IADRQuery;
begin
  Result := Self;
  AddParam(Name, Value, ftBoolean);
end;

function TADRConnModelFiredacQuery.ParamAsCurrency(Name: String; Value: Currency): IADRQuery;
begin
  Result := Self;
  AddParam(Name, Value, ftCurrency);
end;

function TADRConnModelFiredacQuery.ParamAsDate(Name: String; Value: TDateTime): IADRQuery;
begin
  Result := Self;
  AddParam(Name, Value, ftDate);
end;

function TADRConnModelFiredacQuery.ParamAsDateTime(Name: String; Value: TDateTime): IADRQuery;
begin
  Result := Self;
  AddParam(Name, Value, ftDateTime);
end;

function TADRConnModelFiredacQuery.ParamAsFloat(Name: String; Value: Double): IADRQuery;
begin
  Result := Self;
  AddParam(Name, Value, ftFloat);
end;

function TADRConnModelFiredacQuery.ParamAsInteger(Name: String; Value: Integer): IADRQuery;
begin
  Result := Self;
  AddParam(Name, Value, ftInteger);
end;

function TADRConnModelFiredacQuery.ParamAsString(Name: String; Value: String): IADRQuery;
begin
  Result := Self;
  AddParam(Name, Value, ftString);
end;

function TADRConnModelFiredacQuery.ParamAsTime(Name: String; Value: TDateTime): IADRQuery;
begin
  Result := Self;
  AddParam(Name, Value, ftTime);
end;

function TADRConnModelFiredacQuery.SQL(Value: String): IADRQuery;
begin
  Result := Self;
  FSQL.Add(Value);
end;

function TADRConnModelFiredacQuery.SQL(Value: string; const Args: array of const): IADRQuery;
begin
  result := Self;
  SQL(Format(Value, Args));
end;

end.

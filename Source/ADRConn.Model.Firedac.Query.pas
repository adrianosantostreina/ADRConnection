unit ADRConn.Model.Firedac.Query;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  Data.DB,
  System.Classes,
  System.SysUtils,
  System.Variants,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client;

type
  TADRConnModelFiredacQuery = class(TInterfacedObject, IADRQuery)
  private
    [Weak]
    FConnection: IADRConnection;
    FDQuery: TFDQuery;
    FGenerator: IADRGenerator;
    FParams: TParams;
    FSQL: TStrings;

    function AddParam(AName: string; AValue: Variant; AType: TFieldType; ANullIfEmpty: Boolean = False): TParam;
  protected
    function SQL(AValue: string): IADRQuery; overload;
    function SQL(AValue: string; const Args: array of const): IADRQuery; overload;

    function DataSet: TDataSet;
    function DataSource(AValue: TDataSource): IADRQuery;

    function ParamAsInteger(AName: string; AValue: Integer; ANullIfEmpty: Boolean = False): IADRQuery;
    function ParamAsCurrency(AName: string; AValue: Currency; ANullIfEmpty: Boolean = False): IADRQuery;
    function ParamAsFloat(AName: string; AValue: Double; ANullIfEmpty: Boolean = False): IADRQuery;
    function ParamAsString(AName: string; AValue: string; ANullIfEmpty: Boolean = False): IADRQuery;
    function ParamAsDateTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery;
    function ParamAsDate(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery;
    function ParamAsTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery;
    function ParamAsBoolean(AName: string; AValue: Boolean; ANullIfEmpty: Boolean = False): IADRQuery;

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

function TADRConnModelFiredacQuery.AddParam(AName: string; AValue: Variant; AType: TFieldType; ANullIfEmpty: Boolean = False): TParam;
begin
  Result := FParams.AddParameter;
  Result.Name := AName;
  Result.DataType := AType;
  Result.ParamType := ptInput;
  Result.Value := AValue;
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
  inherited;
end;

function TADRConnModelFiredacQuery.ExecSQL: IADRQuery;
var
  LQuery: TFDQuery;
  I: Integer;
begin
  Result := Self;
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

end.

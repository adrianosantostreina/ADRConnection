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
    FDQuery : TFDQuery;
    FGenerator: IADRGenerator;

  protected
    function SQL(Value: String): IADRQuery; overload;
    function SQL(Value: string; const Args: array of const): IADRQuery; overload;

    function ParamAsInteger      (Name: String; Value: Integer): IADRQuery;
    function ParamAsCurrency     (Name: String; Value: Currency): IADRQuery;
    function ParamAsFloat        (Name: String; Value: Double): IADRQuery;
    function ParamAsString       (Name: String; Value: String): IADRQuery;
    function ParamAsDateTime     (Name: String; Value: TDateTime): IADRQuery;
    function ParamAsDate         (Name: String; Value: TDateTime): IADRQuery;
    function ParamAsTime         (Name: String; Value: TDateTime): IADRQuery;
    function ParamAsBoolean      (Name: String; Value: Boolean): IADRQuery;

    function Open: TDataSet;
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

constructor TADRConnModelFiredacQuery.create(AConnection: IADRConnection);
begin
  FConnection := AConnection;
  FDQuery := TFDQuery.Create(nil);
  FDQuery.Connection := TFDConnection( FConnection.Connection );
end;

destructor TADRConnModelFiredacQuery.Destroy;
begin
  FDQuery.Free;
  inherited;
end;

function TADRConnModelFiredacQuery.ExecSQL: IADRQuery;
begin
  result := Self;
  try
    FDQuery.ExecSQL;
  finally
    FDQuery.SQL.Clear;
  end;
end;

function TADRConnModelFiredacQuery.ExecSQLAndCommit: IADRQuery;
begin
  result := Self;
  try
    FConnection.StartTransaction;
    try
      FDQuery.ExecSQL;
      FConnection.Commit;
    except
      FConnection.Rollback;
      raise;
    end;
  finally
    FDQuery.SQL.Clear;
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

function TADRConnModelFiredacQuery.Open: TDataSet;
var
  query : TFDQuery;
  i: Integer;
begin
  try
    query := TFDQuery.Create(nil);
    try
      query.Connection := TFDConnection(FConnection.Component);
      query.SQL.Text := FDQuery.SQL.Text;
      for i := 0 to Pred(FDQuery.ParamCount) do
        query.ParamByName(FDQuery.Params[i].Name).Value := FDQuery.Params[i].Value;

      query.Open;

      result := query;
    except
      query.Free;
      raise;
    end;
  finally
    FDQuery.SQL.Clear;
  end;
end;

function TADRConnModelFiredacQuery.ParamAsBoolean(Name: String; Value: Boolean): IADRQuery;
begin
  Result := Self;
  FDQuery.ParamByName(Name).AsBoolean := Value;
end;

function TADRConnModelFiredacQuery.ParamAsCurrency(Name: String; Value: Currency): IADRQuery;
begin
  Result := Self;
  FDQuery.ParamByName(Name).AsCurrency := Value;
end;

function TADRConnModelFiredacQuery.ParamAsDate(Name: String; Value: TDateTime): IADRQuery;
begin
  Result := Self;
  FDQuery.ParamByName(Name).AsDate := Value;
end;

function TADRConnModelFiredacQuery.ParamAsDateTime(Name: String; Value: TDateTime): IADRQuery;
begin
  Result := Self;
  FDQuery.ParamByName(Name).AsDateTime := Value;
end;

function TADRConnModelFiredacQuery.ParamAsFloat(Name: String; Value: Double): IADRQuery;
begin
  Result := Self;
  FDQuery.ParamByName(Name).AsFloat := Value;
end;

function TADRConnModelFiredacQuery.ParamAsInteger(Name: String; Value: Integer): IADRQuery;
begin
  Result := Self;
  FDQuery.ParamByName(Name).AsInteger := Value;
end;

function TADRConnModelFiredacQuery.ParamAsString(Name: String; Value: String): IADRQuery;
begin
  Result := Self;
  FDQuery.ParamByName(Name).AsString := Value;
end;

function TADRConnModelFiredacQuery.ParamAsTime(Name: String; Value: TDateTime): IADRQuery;
begin
  Result := Self;
  FDQuery.ParamByName(Name).AsTime := Value;
end;

function TADRConnModelFiredacQuery.SQL(Value: String): IADRQuery;
begin
  Result := Self;
  FDQuery.SQL.Add( Value );
end;

function TADRConnModelFiredacQuery.SQL(Value: string; const Args: array of const): IADRQuery;
begin
  result := Self;
  SQL(Format(Value, Args));
end;

end.

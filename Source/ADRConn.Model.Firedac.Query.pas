unit ADRConn.Model.Firedac.Query;

interface

uses
  ADRConn.Model.Interfaces,
  Data.DB,
  System.Classes,
  System.SysUtils,
  FireDAC.Comp.Client;

type TADRConnModelFiredacQuery = class(TInterfacedObject, IADRQuery)

  private
    [Weak]
    FConnection: IADRConnection;
    FDQuery : TFDQuery;

  public
    function SQL(Value: String): IADRQuery; overload;
    function SQL(Value: string; const Args: array of const): IADRQuery; overload;

    function Open: TDataSet;
    function ExecSQL: IADRQuery;
    function ExecSQLAndCommit: IADRQuery;

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

class function TADRConnModelFiredacQuery.New(AConnection: IADRConnection): IADRQuery;
begin
  result := Self.create(AConnection);
end;

function TADRConnModelFiredacQuery.Open: TDataSet;
var
  query : TFDQuery;
begin
  try
    query := TFDQuery.Create(nil);
    try
      query.Connection := TFDConnection(FConnection.Component);
      query.SQL.Text := FDQuery.SQL.Text;
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

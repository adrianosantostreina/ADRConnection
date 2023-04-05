unit ADRConn.DAO.Base;

interface

uses
  ADRConn.Model.Interfaces,
  Data.DB;

type
  TDataSet = Data.DB.TDataSet;

  TADRConnDAOBase = class(TInterfacedObject)
  private
    FManagerTransaction: Boolean;
  protected
    FConnection: IADRConnection;
    FQuery: IADRQuery;

    function ManagerTransaction: Boolean; overload;
    procedure ManagerTransaction(AValue: Boolean); overload;
  public
    constructor Create(AConnection: IADRConnection);

    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
  end;

implementation

{ TADRConnDAOBase }

procedure TADRConnDAOBase.Commit;
begin
  if ManagerTransaction then
    FConnection.Commit;
end;

constructor TADRConnDAOBase.Create(AConnection: IADRConnection);
begin
  FConnection := AConnection;
  FQuery := CreateQuery(FConnection);
  FManagerTransaction := True;
end;

procedure TADRConnDAOBase.ManagerTransaction(AValue: Boolean);
begin
  FManagerTransaction := AValue;
end;

procedure TADRConnDAOBase.Rollback;
begin
  if ManagerTransaction then
    FConnection.Rollback;
end;

procedure TADRConnDAOBase.StartTransaction;
begin
  if ManagerTransaction then
    FConnection.StartTransaction;
end;

function TADRConnDAOBase.ManagerTransaction: Boolean;
begin
  Result := FManagerTransaction;
end;

end.

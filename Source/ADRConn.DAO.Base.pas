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
    procedure ManagerTransaction(Value: Boolean); overload;
  public
    constructor create(Connection: IADRConnection);

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

constructor TADRConnDAOBase.create(Connection: IADRConnection);
begin
  FConnection := Connection;
  FQuery := CreateQuery(FConnection);
  FManagerTransaction := True;
end;

procedure TADRConnDAOBase.ManagerTransaction(Value: Boolean);
begin
  FManagerTransaction := Value;
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
  result := FManagerTransaction;
end;

end.

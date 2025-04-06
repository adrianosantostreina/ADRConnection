unit Demo.DMConnection;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Dialogs,
  ADRConn.Model.Interfaces;

type
  TDMConnection = class(TDataModule)
  private
    FConnection: IADRConnection;
    function GetConnection: IADRConnection;
    { Private declarations }
  public
    function NewQuery: IADRQuery;

    property Connection: IADRConnection read GetConnection;
  end;

var
  DMConnection: TDMConnection;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TDMConnection }

function TDMConnection.GetConnection: IADRConnection;
begin
  if not Assigned(FConnection) then
  begin
    FConnection := CreateConnection;
    FConnection.Params
      .Driver(adrPostgres)
      .Database('demoadrconnection')
      .Server('127.0.0.1')
      .Port(5432)
      .UserName('postgres')
      .Password('postgres');

    FConnection.Connect;
    ShowMessage('Conectado usando o componente ' + FConnection.Component.ClassName);
  end;
  Result := FConnection;
end;

function TDMConnection.NewQuery: IADRQuery;
begin
  Result := CreateQuery(GetConnection);
end;

end.

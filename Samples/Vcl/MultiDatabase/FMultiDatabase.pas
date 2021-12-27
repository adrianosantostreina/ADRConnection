unit FMultiDatabase;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ADRConn.Model.Interfaces,
  ADRConn.Model.Factory, Vcl.ExtCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    pnlLeft: TPanel;
    pnlRight: TPanel;
    Label1: TLabel;
    edtDatabase1: TEdit;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    edtDatabase2: TEdit;
    Label2: TLabel;
    dsDatabase1: TDataSource;
    dsDatabase2: TDataSource;
    btnOpenDB1: TButton;
    btnOpenDB2: TButton;
    procedure btnOpenDB1Click(Sender: TObject);
    procedure btnOpenDB2Click(Sender: TObject);
  private
    FConn1: IADRConnection;
    FConn2: IADRConnection;

    FQuery1: IADRQuery;
    FQuery2: IADRQuery;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnOpenDB1Click(Sender: TObject);
begin
  // Create Connection
  if not Assigned(FConn1) then
  begin
    FConn1 := TADRConnModelFactory.GetConnectionIniFile(edtDatabase1.Text);
    FConn1.Connect;
  end;

  // Create Query
  if not Assigned(FQuery1) then
    FQuery1 := TADRConnModelFactory.GetQuery(FConn1);

  FQuery1
    .DataSource(dsDatabase1)
    .SQL('select id, name')
    .SQL('from person')
    .Open;
end;

procedure TForm1.btnOpenDB2Click(Sender: TObject);
begin
  // Create Connection
  if not Assigned(FConn2) then
  begin
    FConn2 := TADRConnModelFactory.GetConnectionIniFile(edtDatabase2.Text);
    FConn2.Connect;
  end;

  // Create Query
  if not Assigned(FQuery2) then
    FQuery2 := TADRConnModelFactory.GetQuery(FConn2);

  FQuery2
    .DataSource(dsDatabase2)
    .SQL('select id, name')
    .SQL('from person')
    .Open;
end;

initialization
  ReportMemoryLeaksOnShutdown := true;

end.

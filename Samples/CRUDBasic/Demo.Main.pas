unit Demo.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage,
  Demo.DMConnection, Data.DB, Vcl.Grids, Vcl.DBGrids,
  ADRConn.Model.Interfaces;

type
  TFrmDemoADRConnection = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Image1: TImage;
    BtnConnect: TButton;
    DataSourcePerson: TDataSource;
    DBGrid1: TDBGrid;
    BtnListPersons: TButton;
    BtnSave: TButton;
    BtnDelete: TButton;
    EdtFilter: TEdit;
    BtnSearch: TButton;
    procedure BtnConnectClick(Sender: TObject);
    procedure BtnListPersonsClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnSearchClick(Sender: TObject);
  private
    FQueryPerson: IADRQuery;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmDemoADRConnection: TFrmDemoADRConnection;

implementation

{$R *.dfm}

procedure TFrmDemoADRConnection.BtnConnectClick(Sender: TObject);
begin
  DMConnection.Connection;
end;

procedure TFrmDemoADRConnection.BtnDeleteClick(Sender: TObject);
begin
  FQueryPerson.DataSet.Delete;
end;

procedure TFrmDemoADRConnection.BtnListPersonsClick(Sender: TObject);
begin
  if not Assigned(FQueryPerson) then
  begin
    FQueryPerson := DMConnection.NewQuery;
    DataSourcePerson.DataSet := FQueryPerson.DataSet;
  end;

  FQueryPerson.SQL('select id, name, document, phone')
    .SQL('from person')
    .Open;
end;

procedure TFrmDemoADRConnection.BtnSaveClick(Sender: TObject);
begin
  FQueryPerson.DataSet.Post;
end;

procedure TFrmDemoADRConnection.BtnSearchClick(Sender: TObject);
begin
  FQueryPerson.SQL('select id, name, document, phone ')
    .SQL('from person')
    .SQL('where id = %s', [EdtFilter.Text])
    .Open;
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.

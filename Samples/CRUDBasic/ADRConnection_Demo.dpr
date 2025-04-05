program ADRConnection_Demo;

uses
  Vcl.Forms,
  Demo.Main in 'Demo.Main.pas' {FrmDemoADRConnection},
  Demo.DMConnection in 'Demo.DMConnection.pas' {DMConnection: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmDemoADRConnection, FrmDemoADRConnection);
  Application.CreateForm(TDMConnection, DMConnection);
  Application.Run;
end.

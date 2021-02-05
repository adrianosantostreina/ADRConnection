unit Controller.Visita;

interface

uses
  Horse,
  ADRConn.Model.Interfaces,
  ADRConn.Model.Factory;

procedure RegisterVisitas;

procedure List(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegisterVisitas;
begin
  THorse.Get('visita', List);
end;

procedure List(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  connection: IADRConnection;
begin
  connection := TADRConnModelFactory.GetConnectionIniFile;
  connection.Connect;

end;

end.


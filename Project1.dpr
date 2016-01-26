program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  formload in 'formload.pas',
  openvpn in 'openvpn.pas',
  DialVpn in 'DialVpn.pas',
  Unit2 in 'Unit2.pas' {Form2},
  Unit3 in 'Unit3.pas',
  Unit4 in 'Unit4.pas',
  Unit5 in 'Unit5.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '¼²·çÍøÂç¼ÓËÙÆ÷';
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.


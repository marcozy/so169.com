unit Unit5;

interface

uses
  Classes,SysUtils;

type
  allxiancheng = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure allxiancheng.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ allxiancheng }

uses
  Unit1,Unit4,Unit3;
  
procedure allxiancheng.Execute;
var
  i: Integer;
begin
  { Place thread code here }
  Connect.Create(False);
  for i := 1 to 1000 do
  begin
    Sleep(300);
    if threadconnectend then
    begin
      Unit4.routing.Create(False);
      exit;
    end;
  end;
end;

end.


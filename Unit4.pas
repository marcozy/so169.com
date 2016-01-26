unit Unit4;

interface

uses
  SysUtils, Windows, Classes, Forms, Dialogs, StrUtils;

type
  routing = class(TThread)
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

    procedure nic.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ routing }
uses
  unit1, Unit2, openvpn;

procedure routing.Execute;
var
  listroute: TStrings;
  getroute: string;
  i: Integer;
begin
  { Place thread code here }
  if Form1.button1.caption = '¶Ï¿ª' then
  begin
    RouteAddCustom(PChar(dns), PChar('255.255.255.255'), PChar(gateway));

    try
      getroute := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?program=true'));
    except
      try
        getroute := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?program=true'));
      except
      end;
    end;
  //ShowMessage(getroute);
    listroute := Tstringlist.Create;
    listroute.Delimiter := ' ';
    listroute.DelimitedText := getroute;
    for i := 0 to listroute.Count - 1 do // Iterate
    begin
      //ShowMessage(listroute[i]);
      RouteAdd(PChar(listroute[i]), PChar(gateway));
    end;


    Form1.atpgrdr1.CheckUpdate(False);
  end;
end;

end.

 
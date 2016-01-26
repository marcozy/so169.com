unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, formload, StdCtrls, ExtCtrls, jpeg, Registry;

type
  TForm2 = class(TForm)
    img1: TImage;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  Pidlist: TStrings;
  term: Boolean;

implementation

uses Unit1;


{$R *.dfm}
{$R uac.res}



procedure TForm2.FormCreate(Sender: TObject);
begin
  if formload.IsAdmin then
  begin
    reg := TRegistry.Create;
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if reg.KeyExists('SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\360safe.exe') then
    begin
      case Application.MessageBox('360安全卫士可能会造成疾风使用不正常是否继续？', '疾风网络加速器', MB_OKCANCEL + MB_ICONQUESTION) of
        IDOK:
          begin
            //Application.MessageBox('如果疾风不正常请尝试卸载360安全卫士！',
             // '', MB_OK + MB_ICONINFORMATION);
          end;
        IDCANCEL:
          begin
            term := True;
            Application.Terminate;
          end;
      end;
    end;

    if RunningInWow64 then
    begin
      if reg.KeyExists('SOFTWARE\Wow6432Node\KSafe') then
      begin
        case Application.MessageBox('金山安全卫士可能会造成疾风使用不正常是否继续？', '疾风网络加速器', MB_OKCANCEL + MB_ICONQUESTION) of
          IDOK:
            begin
              //Application.MessageBox('如果疾风不正常请尝试卸载金山安全卫士！',
              //  '', MB_OK + MB_ICONINFORMATION);
            end;
          IDCANCEL:
            begin
              term := True;
              Application.Terminate;
            end;
        end;
      end;
    end
    else
    begin
      if reg.KeyExists('SOFTWARE\KSafe') then
      begin
        case Application.MessageBox('金山安全卫士可能会造成疾风使用不正常是否继续？', '疾风网络加速器', MB_OKCANCEL + MB_ICONQUESTION) of
          IDOK:
            begin
              Application.MessageBox('如果疾风不正常请尝试卸载金山安全卫士！',
                '', MB_OK + MB_ICONINFORMATION);
            end;
          IDCANCEL:
            begin
              term := True;
              Application.Terminate;
            end;
        end;
      end;
    end;
    reg.CloseKey;
    reg.Free;
  end;
  checkprocess;
end;
end.


unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, formload, openvpn, DialVpn, Registry, StrUtils,
  RzBHints, RzTray, DialUp, IdBaseComponent, IdComponent, IdTCPConnection, ShellAPI,
  IdTCPClient, IdHTTP, IpHlpApi, WinSvc, auHTTP, auAutoUpgrader;

procedure checkpermission;
procedure createtunnle;
function IsWin8: Boolean;

type
  // is win8 or not
  TOSVersionInfoEx = record
    dwOSVersionInfoSize: DWORD;
    dwMajorVersion: DWORD;
    dwMinorVersion: DWORD;
    dwBuildNumber: DWORD;
    dwPlatformId: DWORD;
    szCSDVersion: array[0..127] of AnsiChar;
    wServicePackMajor: Word;
    wServicePackMinor: Word;
    wSuiteMask: Word;
    wProductType: Byte;
    wReserved: Byte;
  end;
  // is win8 or not

  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    GroupBox1: TGroupBox;
    Edit1: TEdit;
    Edit2: TEdit;
    CheckBox1: TCheckBox;
    Button1: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    tmrCVPN: TTimer;
    grp1: TGroupBox;
    noproxy: TRadioButton;
    httpproxy: TRadioButton;
    Socksproxy: TRadioButton;
    grp2: TGroupBox;
    useie: TRadioButton;
    proxyadd: TEdit;
    proxyport: TEdit;
    puser: TEdit;
    ppass: TEdit;
    chk1: TCheckBox;
    rzblnhnts1: TRzBalloonHints;
    rztrycn1: TRzTrayIcon;
    tmrPPTP: TTimer;
    idhtp1: TIdHTTP;
    chk2: TCheckBox;
    atpgrdr1: TauAutoUpgrader;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Edit1Enter(Sender: TObject);
    procedure Edit2Enter(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure tmrCVPNTimer(Sender: TObject);
    procedure noproxyClick(Sender: TObject);
    procedure useieClick(Sender: TObject);
    procedure httpproxyClick(Sender: TObject);
    procedure chk1Click(Sender: TObject);
    procedure SocksproxyClick(Sender: TObject);
    procedure proxyaddEnter(Sender: TObject);
    procedure puserEnter(Sender: TObject);
    procedure ppassEnter(Sender: TObject);
    procedure proxyportEnter(Sender: TObject);
    procedure rztrycn1MinimizeApp(Sender: TObject);
    procedure rztrycn1LButtonDblClick(Sender: TObject);
    procedure tmrPPTPTimer(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure proxyaddKeyPress(Sender: TObject; var Key: Char);
    procedure proxyportKeyPress(Sender: TObject; var Key: Char);
    procedure puserKeyPress(Sender: TObject; var Key: Char);
    procedure ppassKeyPress(Sender: TObject; var Key: Char);
    procedure CheckBox1Click(Sender: TObject);
    procedure chk2Click(Sender: TObject);
    procedure Edit2KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StatusBar1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StatusBar1Click(Sender: TObject);

  private
    { Public declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  p, nEnable: Integer;
  reg: TRegistry;
  regproxy: string;
  regproxyaddress: string;
  regproxyport: string;
  username: Boolean;
  password: Boolean;
  paddress: Boolean;
  pport: Boolean;
  proxyuser: Boolean;
  proxypwd: Boolean;
  pptpcheck: Boolean;
  server: string;
  Uname: string;
  Pword: string;
  pptpstate: Integer;
  userlist: string;
  usertime: string;
  usertype: string;
  useronline: string;
  cmwap: Boolean;
  update: Boolean;
  version: string;
  threadconnectend, endprocdure: Boolean;
  goodroute: Boolean;
  offline: Boolean;
  offlist: Boolean;
  dns, gateway: string;
  server1, server2: string;
  Connection: Integer = 3;
  mousex: Integer;
  RespData: TStream;

implementation

uses Unit2, Unit3, Unit4, Unit5;



{$R *.dfm}
{$R openvpn.res}
{$R ssl.res}
{$R tcping.res}
{$R srvp.res}
{$R UtilDll.res}
{$R 32.res}
{$R 64.res}


procedure TForm1.FormCreate(Sender: TObject);
begin
  if term = True then
  begin
    Exit;
  end
  else
  begin
    application.processmessages;
    form_load1;
  end;
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var i: Integer;
begin
  if (Form1.Button1.Caption = '连接') and (Form1.Button1.Enabled = True) then
  begin
    Form1.Hide;
    if FindProcess('srvp.exe') then
    begin
      EndProcess('srvp.exe');
    end;
    RouteUninit;
    Sleep(1000);
    FreeLibrary(DllHandle);
    DeleteFile('ssl.ocx');
    DeleteFile('tcping.exe');
    DeleteFile('srvp.exe');
    DeleteFile('openvpn.exe');
    DeleteFile('UtilDll.dll');
    if FileExists('tapinstall.exe') then
    begin
      DeleteFile('tapinstall.exe');
      DeleteFile('tap0901.sys');
      DeleteFile('tap0901.cat');
      DeleteFile('OemWin2k.inf');
    end;
    Form1.Hide;
  end
  else
  begin
    if MessageBox(Handle, '确认要退出并断开吗?', '疾风OpenVPN', MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = IDYES then
    begin
      if CanClose = true then
      begin
        Button1.Enabled := False;
        HangUpVPN;
        cvpn;
        Form1.Hide;
        if FindProcess('srvp.exe') then
        begin
          EndProcess('srvp.exe');
        end;
        RouteUninit;
        Sleep(1000);
        FreeLibrary(DllHandle);
        DeleteFile('ssl.ocx');
        DeleteFile('tcping.exe');
        DeleteFile('srvp.exe');
        DeleteFile('openvpn.exe');
        DeleteFile('UtilDll.dll');
        if FileExists('tapinstall.exe') then
        begin
          DeleteFile('tapinstall.exe');
          DeleteFile('tap0901.sys');
          DeleteFile('tap0901.cat');
          DeleteFile('OemWin2k.inf');
        end;
        DeleteFile('srvp.exe');
        DeleteFile('openvpn.exe');
      end;
    end
    else
    begin
      CanClose := false;
    end;
  end;
end;



{服务器地址列表与名称列表同步}

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  ComboBox2.ItemIndex := ComboBox1.ItemIndex;
  //ShowMessage(IntToStr(ComboBox2.ItemIndex));
end;



procedure TForm1.noproxyClick(Sender: TObject);
begin
  Form1.proxyadd.Enabled := False;
  Form1.proxyport.Enabled := False;
  Form1.puser.Enabled := False;
  Form1.ppass.Enabled := False;
  form1.chk1.Enabled := False;
  Form1.chk1.Checked := False;
  form1.chk2.Enabled := False;
  Form1.chk2.Checked := False;
  Form1.proxyadd.Text := '代理服务器地址';
  Form1.proxyport.Text := '代理端口';
  Form1.puser.Text := '代理用户名';
  Form1.ppass.Text := '代理密码';
  cmwap := False;
end;

procedure TForm1.useieClick(Sender: TObject);
begin
  Form1.proxyadd.Enabled := False;
  Form1.proxyport.Enabled := False;
  //Form1.proxyadd.Text := '';
  //Form1.proxyport.Text := '';
  Form1.puser.Enabled := False;
  Form1.ppass.Enabled := False;
  form1.chk1.Enabled := False;
  Form1.chk1.Checked := False;
  form1.chk2.Enabled := False;
  Form1.chk2.Checked := False;

  reg := TRegistry.Create;
  reg.RootKey := HKEY_CURRENT_USER;
  reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Internet Settings', True);
  nEnable := reg.ReadInteger('ProxyEnable');
  if nEnable = 1 then
  begin
    regproxy := reg.ReadString('ProxyServer');
    regproxyaddress := LeftStr(regproxy, Pos(':', regproxy) - 1);
    regproxyport := StringReplace(regproxy, regproxyaddress + ':', '', []);
    form1.proxyadd.Text := regproxyaddress;
    Form1.proxyport.Text := regproxyport;
  end
  else
  begin
    Application.MessageBox('你忽悠我呢？IE根本没启用代理服务器！',
      '网络加速器', MB_OK + MB_ICONSTOP);
    noproxy.Checked := True;
    noproxy.SetFocus;
  end;
  reg.CloseKey;
  reg.Free;
end;

procedure TForm1.httpproxyClick(Sender: TObject);
begin
  Form1.proxyadd.Enabled := True;
  Form1.proxyport.Enabled := True;
  Form1.puser.Enabled := False;
  Form1.ppass.Enabled := False;
  Form1.chk1.Enabled := True;
  form1.chk2.Enabled := False;
  Form1.chk1.Checked := False;
  Form1.chk2.Checked := False;
  Form1.puser.Text := '代理用户名';
  Form1.ppass.Text := '代理密码';
end;

procedure TForm1.chk1Click(Sender: TObject);
begin
  if form1.chk1.Checked = True then
  begin
    Form1.proxyadd.Enabled := True;
    Form1.proxyport.Enabled := True;
    Form1.puser.Enabled := True;
    Form1.ppass.Enabled := True;
    Form1.chk1.Enabled := True;
    form1.chk2.Enabled := True;

    //Application.MessageBox('如果您是Windows域用户。' + #13#10#13#10 +
    //  'HTTP代理服务器用户名密码很可能就是您登陆域的用户名密码。', '疾风网络加速器', MB_OK +
    //  MB_ICONINFORMATION);
  end
  else
  begin
    Form1.puser.Enabled := False;
    Form1.ppass.Enabled := False;
    form1.chk2.Enabled := False;
    Form1.chk2.Checked := False;
    form1.ppass.PasswordChar := #0;
    Form1.puser.Text := '代理用户名';
    Form1.ppass.Text := '代理密码';
  end;
end;

procedure TForm1.SocksproxyClick(Sender: TObject);
begin
  Form1.proxyadd.Enabled := True;
  Form1.proxyport.Enabled := True;
  Form1.ppass.Enabled := False;
  form1.puser.Enabled := False;
  form1.ppass.PasswordChar := #0;
  Form1.puser.Text := '代理用户名';
  Form1.ppass.Text := '代理密码';
  Form1.chk1.Enabled := False;
  form1.chk1.Checked := False;
  form1.chk2.Enabled := False;
  form1.chk2.Checked := False;
  cmwap := False;
end;

procedure TForm1.Edit1Enter(Sender: TObject);
begin
  if not username then
  begin
    form1.Edit1.Text := '';
    username := true;
  end;
end;

procedure TForm1.Edit2Enter(Sender: TObject);
begin
  if not password then
  begin
    form1.Edit2.Text := '';
    form1.Edit2.PasswordChar := '*';
    password := true;
  end;
end;

procedure TForm1.proxyaddEnter(Sender: TObject);
begin
  if not paddress then
  begin
    form1.proxyadd.Text := '';
    paddress := true;
  end;
end;

procedure TForm1.proxyportEnter(Sender: TObject);
begin
  if not pport then
  begin
    form1.proxyport.Text := '';
    pport := true;
  end;
end;

procedure TForm1.puserEnter(Sender: TObject);
begin
  if not proxyuser then
  begin
    form1.puser.Text := '';
    proxyuser := true;
  end;
end;

procedure TForm1.ppassEnter(Sender: TObject);
begin
  if not proxypwd then
  begin
    form1.ppass.Text := '';
    form1.ppass.PasswordChar := '*';
    proxypwd := true;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  allxiancheng.Create(False);
end;



{定时检测输出内容是否含有错误，如果错误即刻断开openvpn}

procedure TForm1.tmrCVPNTimer(Sender: TObject);
begin
  //openvpn判断
  if Needdisconnect = True then
  begin
    cvpn;
  end
  else
    if NeedNIC = True then
    begin
      NeedNIC := False;
      if RunningInWow64 = True then
      begin
        if IsWin8 = True then
        begin
          reg := TRegistry.Create;
          reg.RootKey := HKEY_CURRENT_USER;
          reg.OpenKey('Software\JFVPN\', True);

          if reg.ReadString('NIC') = '8' then
          begin
            formload.extrafiles64;
            winexec(PChar('tapinstall.exe install OemWin2k.inf tap0901'), SW_HIDE);
      //shellexecute(handle, nil, pchar('driver\64\tapinstall.exe install driver\64\OemWin2k.inf tap0901'), nil, nil, sw_shownormal);
            //Application.MessageBox('您的系统没有安装虚拟网卡，请完成安装后再运行疾风网络加速器！',
            //  '疾风网络加速器', MB_OK + MB_ICONSTOP);
            NeedNIC := False;
            reg.WriteString('NIC', '1');
            form1.StatusBar1.Panels[0].Text := '正在安装虚拟网卡，请稍等！';
            //nic.Create(False);
            Exit;
            //Application.Terminate;
          end
          else
          begin
            case
              Application.MessageBox('您是Win8 操作系统，请点击确定重新启动计算机至'
              + #13#10#13#10 +
              '疑难解答->高级选项->启动设置->重启->选7 (禁用驱动程序签名。)' + #13#10 +
              #13#10 + '然后再进行虚拟网卡安装！', '疾风网络加速器', MB_OKCANCEL
              + MB_ICONQUESTION) of
              IDOK:
                begin
                  winexec(PChar('shutdown.exe /r /o /f /t 00'), SW_HIDE);
                  reg.WriteString('NIC', '8');
                end;
              IDCANCEL:
                begin
                  Application.MessageBox('您将无法正常使用本软件！',
                    '疾风网络加速器', MB_OK + MB_ICONSTOP);
                end;
            end;
          end;
        //2016年9月驱动签名过期后需要启用上面内容。
          reg.CloseKey;
          reg.Free;
        end
        else
        begin
          formload.extrafiles64;
          winexec(PChar('tapinstall.exe install OemWin2k.inf tap0901'), SW_HIDE);
      //shellexecute(handle, nil, pchar('driver\64\tapinstall.exe install driver\64\OemWin2k.inf tap0901'), nil, nil, sw_shownormal);
          //Application.MessageBox('您的系统没有安装虚拟网卡，请完成安装后再运行疾风网络加速器！',
          //  '疾风网络加速器', MB_OK + MB_ICONSTOP);
          NeedNIC := False;
          reg := TRegistry.Create;
          reg.RootKey := HKEY_CURRENT_USER;
          reg.OpenKey('Software\JFVPN\', True);
          reg.WriteString('NIC', '1');
          reg.CloseKey;
          reg.Free;
          form1.StatusBar1.Panels[0].Text := '正在安装虚拟网卡，请稍等！';
          //nic.Create(False);
          Exit;
          //Application.Terminate;
        end;
      end
      else
      begin
        formload.extrafiles32;
        winexec(PChar('tapinstall.exe install OemWin2k.inf tap0901'), SW_HIDE);
      //shellexecute(handle, nil, pchar('driver\32\tapinstall.exe install driver\32\OemWin2k.inf tap0901'), nil, nil, sw_shownormal);
        //Application.MessageBox('您的系统没有安装虚拟网卡，请完成安装后再运行疾风网络加速器！',
        //  '疾风网络加速器', MB_OK + MB_ICONSTOP);
        NeedNIC := False;
        reg := TRegistry.Create;
        reg.RootKey := HKEY_CURRENT_USER;
        reg.OpenKey('Software\JFVPN\', True);
        reg.WriteString('NIC', '1');
        reg.CloseKey;
        reg.Free;
        form1.StatusBar1.Panels[0].Text := '正在安装虚拟网卡，请稍等！';
        //nic.Create(False);
        Exit;
        //Application.Terminate;
      end;

    end;

end;


procedure TForm1.rztrycn1MinimizeApp(Sender: TObject);
begin
  rztrycn1.Enabled := True;
  Form1.Hide;
  if form1.StatusBar1.Panels[0].Text = '' then
  begin
    rztrycn1.ShowBalloonHint('疾风网络加速器', '双击这里重新显示界面');
  end
  else
  begin
    rztrycn1.ShowBalloonHint('疾风网络加速器', form1.StatusBar1.Panels[0].Text);
  end;
end;


procedure TForm1.rztrycn1LButtonDblClick(Sender: TObject);
begin
  Form1.Show;
end;

procedure TForm1.tmrPPTPTimer(Sender: TObject);
begin
  //pptpvpn判断
  if CheckIsDisconnected then
  begin
    Form1.Button1.Caption := '连接';
    Form1.Button1.Enabled := True;
    Form1.rztrycn1.ShowBalloonHint('疾风网络加速器', 'PPTP连接断开！');
    tmrPPTP.Enabled := False;
    HangUpVPN;
  end;
end;


function split(s: string; Ch: string): TStringList; //前一个参数是操作的字符串，后一个是分隔符
var
  Temp: string;
  I: Integer;
  chLength: Integer;

begin
  Result := TStringList.Create;
   //如果空字符串则返回空列表

  if s = '' then Exit;
  Temp := s;
  I := Pos(ch, s);
  chLength := Length(ch);

  while I <> 0 do
  begin
    Result.Add(Copy(Temp, 0, I - chLength + 1));
    Delete(Temp, 1, I - 1 + chLength);
    I := pos(ch, Temp);
  end;

  Result.Add(Temp);

end;

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key >= #160 then Key := #0;
end;

procedure TForm1.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
  if Key >= #160 then Key := #0;
end;

procedure TForm1.proxyaddKeyPress(Sender: TObject; var Key: Char);
begin
  if Key >= #160 then Key := #0;
end;

procedure TForm1.proxyportKeyPress(Sender: TObject; var Key: Char);
begin
  if Key >= #160 then Key := #0;
end;

procedure TForm1.puserKeyPress(Sender: TObject; var Key: Char);
begin
  if Key >= #160 then Key := #0;
end;

procedure TForm1.ppassKeyPress(Sender: TObject; var Key: Char);
begin
  if Key >= #160 then Key := #0;
end;

procedure TForm1.Edit2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then Button1.Click;
end;


procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CURRENT_USER;
  if CheckBox1.Checked = False then
  begin
    case Application.MessageBox('您这个操作将会清除已经保存的登陆信息！',
      '疾风网络加速器', MB_YESNO + MB_ICONWARNING) of
      IDYES:
        begin
          if RunningInWow64 = True then
          begin
            formload.extrafiles64;
          end
          else
          begin
            formload.extrafiles64;
          end;
          winexec(PChar('tapinstall.exe remove tap0901'), SW_HIDE);

          if Reg.OpenKey('Software\JFVPN\', true) then
          begin
            Reg.WriteString('NTLM', '0');
            Reg.WriteString('User', '');
            Reg.WriteString('Pass', '');
            Reg.WriteString('Proxy', '');
            Reg.WriteString('ProxyAddr', '');
            Reg.WriteString('ProxyPort', '');
            Reg.WriteString('ProxyUser', '');
            Reg.WriteString('ProxyPass', '');
            reg.WriteString('ListIndex', '');
          end;
        end;

      IDNO:
        begin
          Form1.CheckBox1.Checked := True;
        end;

    end;
    reg.CloseKey;
    reg.Free;

  end;
end;

procedure TForm1.chk2Click(Sender: TObject);
begin
  if form1.chk2.Checked then
  begin
    //Application.MessageBox('如果您是Windows域用户。' + #13#10#13#10 +
    //  '可以尝试选择该选项，解决HTTP代理服务器验证错误。', '疾风网络加速器', MB_OK
    //  + MB_ICONINFORMATION);
  end;
end;

procedure checkpermission;
var
  s: TStringList;
  handle, p: Integer;
begin
  if Form1.chk2.Checked = False then
  begin
    if Form1.chk1.Checked = True then
    begin
      Form1.idhtp1.ProxyParams.ProxyServer := regproxyaddress;
      Form1.idhtp1.ProxyParams.ProxyPort := StrToInt(Form1.proxyport.Text);
      Form1.idhtp1.ProxyParams.ProxyUsername := Form1.puser.Text;
      form1.idhtp1.ProxyParams.ProxyPassword := Form1.ppass.Text;
      try
        userlist := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?username=') + form1.Edit1.Text);
      except
        try
          userlist := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?username=') + form1.Edit1.Text);
        except
          cvpn;
          Application.MessageBox('代理服务器连接失败！请检查代理服务器设置！',
            '网络加速器', MB_OK + MB_ICONWARNING);
          endprocdure := True;
          Exit;
        end;
      end;
      if Pos('Yes', userlist) <> 0 then
      begin
        try
          usertime := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?lang=cn&date=') + form1.Edit1.Text);
        except
          try
            usertime := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?lang=cn&date=') + form1.Edit1.Text);
          except
          end;
        end;

        try
          usertype := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?lang=cn&usergroup=') + form1.Edit1.Text);
        except
          try
            usertype := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?lang=cn&usergroup=') + form1.Edit1.Text);
          except
          end;
        end;

        try
          useronline := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?online=') + form1.Edit1.Text);
        except
          try
            useronline := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?online=') + form1.Edit1.Text);
          except
          end;
        end;

        if useronline = 'Yes' then
        begin
          Application.MessageBox('您已经在线！不能重复登陆！', '疾风OpenVPN',
            MB_OK + MB_ICONWARNING);
          cvpn;
          endprocdure := True;
          Exit;
        end;
      end
      else
        if Pos('No', userlist) <> 0 then
        begin
          cvpn;
          Application.MessageBox('您的用户名并未开通VPN权限，请到网站开通后使用！',
            '疾风网络加速器', MB_OK + MB_ICONSTOP);
          shellexecute(handle, nil, pchar('http://www.so169.com/profile.php?action=buy'), nil, nil, sw_shownormal);
          endprocdure := True;
          Exit;
        end
        else
        begin

        end;
    end
    else
      if Form1.useie.Checked = True then
      begin
        reg := TRegistry.Create;
        reg.RootKey := HKEY_CURRENT_USER;
        reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Internet Settings', True);
        nEnable := reg.ReadInteger('ProxyEnable');
        regproxy := reg.ReadString('ProxyServer');
        s := split(regproxy, ':');
        regproxyaddress := LeftStr(regproxy, Pos(':', regproxy) - 1);
        p := strtoint(s[1]);
        Form1.idhtp1.ProxyParams.ProxyServer := regproxyaddress;
        Form1.idhtp1.ProxyParams.ProxyPort := p;
        try
          userlist := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?username=') + form1.Edit1.Text);
        except
          try
            userlist := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?username=') + form1.Edit1.Text);
          except
            cvpn;
            Application.MessageBox('代理服务器连接失败！请检查代理服务器设置！',
              '疾风网络加速器', MB_OK + MB_ICONWARNING);
            endprocdure := True;
            Exit;
          end;
        end;
      //ShowMessage('通过IE设置代理服务器取回' + userlist);
        reg.Free;
        if Pos('Yes', userlist) <> 0 then
        begin
          try
            usertime := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?lang=cn&date=') + form1.Edit1.Text);
          except
            try
              usertime := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?lang=cn&date=') + form1.Edit1.Text);
            except
            end;
          end;

          try
            usertype := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?lang=cn&usergroup=') + form1.Edit1.Text);
          except
            try
              usertype := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?lang=cn&usergroup=') + form1.Edit1.Text);
            except
            end;
          end;

          try
            useronline := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?online=') + form1.Edit1.Text);
          except
            try
              useronline := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?online=') + form1.Edit1.Text);
            except
            end;
          end;

          if useronline = 'Yes' then
          begin
            Application.MessageBox('您已经在线！不能重复登陆！', '疾风OpenVPN',
              MB_OK + MB_ICONWARNING);
            cvpn;
            endprocdure := True;
            Exit;
          end;
        end
        else
          if Pos('No', userlist) <> 0 then
          begin
            cvpn;
            Application.MessageBox('您的用户名并未开通VPN权限，请到网站开通后使用！',
              '疾风网络加速器', MB_OK + MB_ICONSTOP);
            shellexecute(handle, nil, pchar('http://www.so169.com/profile.php?action=buy'), nil, nil, sw_shownormal);
            endprocdure := True;
            Exit;
          end
          else
          begin

          end;
      end
      else
        if Form1.noproxy.Checked = True then
        begin
          try
            userlist := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?username=') + form1.Edit1.Text);
          except
            try
              userlist := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?username=') + form1.Edit1.Text);
            except
              cvpn;
              Application.MessageBox('网页取回失败！请确认官方网站是否可以访问！',
                '疾风网络加速器', MB_OK + MB_ICONWARNING);
              endprocdure := True;
              Exit;
            end;
          end;

          if Pos('Yes', userlist) <> 0 then
          begin
            try
              usertime := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?lang=cn&date=') + form1.Edit1.Text);
            except
              try
                usertime := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?lang=cn&date=') + form1.Edit1.Text);
              except
              end;
            end;

            try
              usertype := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?lang=cn&usergroup=') + form1.Edit1.Text);
            except
              try
                usertype := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?lang=cn&usergroup=') + form1.Edit1.Text);
              except
              end;
            end;

            try
              useronline := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?online=') + form1.Edit1.Text);
            except
              try
                useronline := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?online=') + form1.Edit1.Text);
              except
              end;
            end;

            if useronline = 'Yes' then
            begin
              cvpn;
              Application.MessageBox('您已经在线！不能重复登陆！', '疾风OpenVPN',
                MB_OK + MB_ICONWARNING);
              endprocdure := True;
              Exit;
            end;
          end
          else
            if Pos('No', userlist) <> 0 then
            begin
              cvpn;
              Application.MessageBox('您的用户名并未开通VPN权限，请到网站开通后使用！',
                '疾风网络加速器', MB_OK + MB_ICONSTOP);
              shellexecute(handle, nil, pchar('http://www.so169.com/profile.php?action=buy'), nil, nil, sw_shownormal);
              endprocdure := True;
              Exit;
            end
            else
            begin

            end;
        end;
  end
  else
    if Form1.httpproxy.Checked = True then
    begin
      Form1.idhtp1.ProxyParams.ProxyServer := form1.proxyadd.Text;
      Form1.idhtp1.ProxyParams.ProxyPort := StrToInt(form1.proxyport.Text);
      try
        userlist := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?username=') + form1.Edit1.Text);
      except
        try
          userlist := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?username=') + form1.Edit1.Text);
        except
          cvpn;
          Application.MessageBox('代理服务器连接失败！请检查代理服务器设置！',
            '疾风网络加速器', MB_OK + MB_ICONWARNING);
          endprocdure := True;
          Exit;
        end;
      end;
            //ShowMessage('通过手动设置代理服务器取回' + userlist);
      if Pos('Yes', userlist) <> 0 then
      begin
        try
          usertime := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?lang=cn&date=') + form1.Edit1.Text);
        except
          try
            usertime := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?lang=cn&date=') + form1.Edit1.Text);
          except
          end;
        end;

        try
          usertype := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?lang=cn&usergroup=') + form1.Edit1.Text);
        except
          try
            usertype := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?lang=cn&usergroup=') + form1.Edit1.Text);
          except
          end;
        end;

        try
          useronline := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?online=') + form1.Edit1.Text);
        except
          try
            useronline := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?online=') + form1.Edit1.Text);
          except
          end;
        end;

        if useronline = 'Yes' then
        begin
          Application.MessageBox('您已经在线！不能重复登陆！', '疾风OpenVPN',
            MB_OK + MB_ICONWARNING);
          cvpn;
          endprocdure := True;
          Exit;
        end;
      end
      else
        if Pos('No', userlist) <> 0 then
        begin
          cvpn;
          Application.MessageBox('您的用户名并未开通VPN权限，请到网站开通后使用！',
            '疾风网络加速器', MB_OK + MB_ICONSTOP);
          shellexecute(handle, nil, pchar('http://www.so169.com/profile.php?action=buy'), nil, nil, sw_shownormal);
          endprocdure := True;
          Exit;
        end
        else
        begin

        end;

    end;
end;


function WinExecAndWait32(FileName: string; Visibility: Integer): Integer;
var
  zAppName: array[0..512] of char;
  zCurDir: array[0..255] of char;
  WorkDir: string;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  StrPCopy(zAppName, FileName);
  GetDir(0, WorkDir);
  StrPCopy(zCurDir, WorkDir);
  FillChar(StartupInfo, Sizeof(StartupInfo), #0);
  StartupInfo.cb := Sizeof(StartupInfo);

  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;

  if not CreateProcess(nil,
    zAppName, {   pointer   to   command   line   string   }
    nil, {   pointer   to   process   security   attributes   }
    nil, {   pointer   to   thread   security   attributes   }
    false, {   handle   inheritance   flag   }
    CREATE_NEW_CONSOLE or {   creation   flags   }
    NORMAL_PRIORITY_CLASS,
    nil, {   pointer   to   new   environment   block   }
    nil, {   pointer   to   current   directory   name   }
    StartupInfo, {   pointer   to   STARTUPINFO   }
    ProcessInfo) then Result := -1 {   pointer   to   PROCESS_INF   }

  else begin
    WaitforSingleObject(ProcessInfo.hProcess, INFINITE);
        //GetExitCodeProcess(ProcessInfo.hProcess,Result);
    Result := 0;
  end;
end;
//WinExecAndWait32(cmd,1);   //调用

procedure createtunnle;
var
  F1: TextFile;
  FileName: string;

  arr: array[0..MAX_PATH] of Char;
  num: UINT;
begin
  if FindProcess('srvp.exe') then
  begin
    EndProcess('srvp.exe');
  end;

  if (Form1.proxyadd.Text = '127.0.0.1') and (form1.proxyport.Text = '1080') then
  begin
    FileName := 'srvp.cfg';
    AssignFile(f1, fileName);
    try
      if fileexists(fileName) then
      begin
        Append(f1)
      end
      else
      begin
        rewrite(f1);
      end;
      writeln(f1, 'AUTH_PASSTHROUGH = 1');
      writeln(f1, 'DATA_SEND_DELAY = 30');
      writeln(f1, 'DATA_SEND_MAXSIMCONN = 3');
      writeln(f1, 'DATA_SEND_RETRYCOUNT = 5');
      writeln(f1, 'DATA_SEND_THRESHHOLD = 10000');
      writeln(f1, 'DATA_SEQUENCE_WRAP = 999');
      writeln(f1, 'ENABLE_ZLIB = 1');
      writeln(f1, 'ID_BANTIMEOUT = 600');
      writeln(f1, 'ID_MAXACCESS = 3');
      writeln(f1, 'ID_TIMEOUT = 30');
      writeln(f1, 'LOGLEVEL = 0');
      writeln(f1, 'MAXTHREADS = 0');
      writeln(f1, 'OUTSOCKET_TIMEOUT = 2');
      if nEnable = 1 then
      begin
        writeln(f1, 'PROXY_PORT = ' + inttostr(p));
        writeln(f1, 'PROXY_SERVER = ' + regproxyaddress);
      end;
      writeln(f1, 'PORT = 443');
      writeln(f1, 'SEC_IP = 127.0.0.1');
      writeln(f1, 'SERVER = 116.255.198.211');
      writeln(f1, 'SOCKS_AUTH = 0');
      writeln(f1, 'SOCKS_ENABLED = 1');
      writeln(f1, 'SOCKS_PORT = 1080');
      writeln(f1, 'THREADS = 30');
      writeln(f1, 'URL = /t/tab.php');
    finally
      closefile(f1);
    end;
    num := GetWindowsDirectory(arr, MAX_PATH);
    RouteAddCustom(PChar('116.255.198.211'), PChar('255.255.255.255'), PChar(gateway));
    //WinExec(PChar(arr + '\system32\route.exe add 116.255.198.211 mask 255.255.255.255 ' + gateway), SW_HIDE);
  //WinExecAndWait32('srvp.exe srvp.ocx',1);
    extrafilestunnle;
    WinExec('srvp.exe srvp.cfg', 0);
    //Winexec(PChar(ExtractFilePath(Application.ExeName) + 'srvp.exe ' + ExtractFilePath(Application.ExeName) + 'srvp.cfg'), SW_HIDE);
    DeleteFile(PChar(ExtractFilePath(Application.ExeName) + filename));
  end
  else
    if (Form1.proxyadd.Text = '127.0.0.1') and (form1.proxyport.Text = '8080') then
    begin
      FileName := 'srvp.cfg';
      AssignFile(f1, fileName);
      try
        if fileexists(fileName) then
        begin
          Append(f1)
        end
        else
        begin
          rewrite(f1);
        end;
        writeln(f1, 'AUTH_PASSTHROUGH = 1');
        writeln(f1, 'DATA_SEND_DELAY = 30');
        writeln(f1, 'DATA_SEND_MAXSIMCONN = 3');
        writeln(f1, 'DATA_SEND_RETRYCOUNT = 5');
        writeln(f1, 'DATA_SEND_THRESHHOLD = 10000');
        writeln(f1, 'DATA_SEQUENCE_WRAP = 999');
        writeln(f1, 'ENABLE_ZLIB = 1');
        writeln(f1, 'ID_BANTIMEOUT = 600');
        writeln(f1, 'ID_MAXACCESS = 3');
        writeln(f1, 'ID_TIMEOUT = 30');
        writeln(f1, 'LOGLEVEL = 0');
        writeln(f1, 'MAXTHREADS = 0');
        writeln(f1, 'OUTSOCKET_TIMEOUT = 2');
        if nEnable = 1 then
        begin
          writeln(f1, 'PROXY_PORT = ' + inttostr(p));
          writeln(f1, 'PROXY_SERVER = ' + regproxyaddress);
          if Form1.chk1.Checked = True then
          begin
            Writeln(f1, 'PROXY_AUTH_TYPE = basic');
            Writeln(f1, 'PROXY_AUTH_USER = ' + Form1.puser.text);
            Writeln(f1, 'PROXY_AUTH_PASS = ' + Form1.ppass.text);
          end;
        end;
        writeln(f1, 'PORT = 443');
        writeln(f1, 'SEC_IP = 127.0.0.1');
        writeln(f1, 'SERVER = 116.255.198.211');
        writeln(f1, 'SOCKS_AUTH = 0');
        writeln(f1, 'SOCKS_ENABLED = 1');
        writeln(f1, 'SOCKS_PORT = 1080');
        writeln(f1, 'THREADS = 3');
        writeln(f1, 'URL = /t/tab.php');
      finally
        closefile(f1);
      end;
      num := GetWindowsDirectory(arr, MAX_PATH);
      RouteAddCustom(PChar('116.255.198.211'), PChar('255.255.255.255'), PChar(gateway));
      //WinExec(PChar(arr + '\system32\route.exe add 116.255.198.211 mask 255.255.255.255 ' + gateway), SW_HIDE);
  //WinExecAndWait32('srvp.exe srvp.ocx',1);
      extrafilestunnle;
      WinExec('srvp.exe srvp.cfg', 0);
    //Winexec(PChar(ExtractFilePath(Application.ExeName) + 'srvp.exe ' + ExtractFilePath(Application.ExeName) + 'srvp.cfg'), SW_HIDE);
      DeleteFile(PChar(ExtractFilePath(Application.ExeName) + filename));
    end;
end;


procedure TForm1.StatusBar1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mousex := X;
end;

procedure TForm1.StatusBar1Click(Sender: TObject);
var
  x_left, x_right, x, i: integer;
begin
  x := mousex;
  x_left := 0;
  x_right := 0;
  for i := 0 to Self.StatusBar1.Panels.Count - 1 do
  begin
    x_left := x_left + x_right;
    if i <> (Self.StatusBar1.Panels.Count - 1) then
      x_right := x_right + StatusBar1.Panels.Items[i].Width
    else
      x_right := StatusBar1.Width;
    if (x >= x_left) and (x <= x_right) then break;
  end;
  //showmessage('你双击了 '+StatusBar1.Panels.Items[i].Text+' 这个分栏')
  if StatusBar1.Panels.Items[i].Text = '官方网站' then
  begin
    shellexecute(handle, nil, pchar('http://www.so169.com/profile.php?action=buy'), nil, nil, sw_shownormal);
  end;
end;

function IsWin8: Boolean;
const VER_NT_WORKSTATION = 1;
var
  osvi: TOSVersionInfoEx;
begin
  ZeroMemory(@osvi, SizeOf(osvi));
  osvi.dwOSVersionInfoSize := SizeOf(osvi);
  GetVersionEx(POSVersionInfo(@osvi)^);
  Result := (osvi.dwMajorVersion = 6) and (osvi.dwMinorVersion = 2) and (osvi.wProductType = VER_NT_WORKSTATION);
end;

end.

unit openvpn;

interface

uses
  Windows, SysUtils, Forms, Dialogs, Registry, formload, ShellAPI, WinInet, Unit4;

type
  TConsoleInput = function(ConsoleIdx: Integer; InputStr: PChar): LongBool; stdcall; //external 'UtilDll.dll';
  //TOnConsoleOutput = procedure(const OutputStr: string); stdcall;
  TOnConsoleOutput = procedure(OutputStr: PChar); stdcall;
  TOpenConsole = function(CmdLine: PChar; WorkDir: PChar; ShowWindow: Word;
    pProcInfo: PProcessInformation; OnConsoleOutput: TOnConsoleOutput): Integer; stdcall; //external 'UtilDll.dll';
  //TConsoleInput = function(ConsoleIdx: Integer; InputStr: PChar): LongBool; //stdcall; external 'UtilDll.dll';
  TCloseConsole = function(ConsoleIdx: Integer): Integer; stdcall; //external 'UtilDll.dll';
  TConsoleInputF4 = function(ConsoleIdx: Integer): Integer; stdcall; //external 'UtilDll.dll';

  TRouteInit = function(LogEnabled: Boolean = False): Boolean; stdcall;
  TRouteAdd = function(ProcName, Gateway: PChar): Boolean; stdcall;
  TRouteGetDefaultGateway = function: PChar; stdcall;
  TRouteRestore = function(ProcName: PChar): Boolean;
  TRouteAddCustom = function(Dest, Mask, Gateway: PChar): Boolean; stdcall;
  TRouteRemoveCustom = function(Dest: PChar): Boolean; stdcall;
  TRouteGetDetectInterval = function: Cardinal; stdcall;
  TRouteSetDetectInterval = function(Interval: Cardinal): Boolean; stdcall;
  TRouteGetRestoreDelay = function(ProcName: PChar): Cardinal; stdcall;
  TRouteSetRestoreDelay = function(ProcName: PChar; Delay: Cardinal): Boolean; stdcall;
  TRouteUninit = function: Boolean; stdcall;

procedure LoadDll(DllFileName: string);
//procedure OnConsoleOutput(const OutputStr: string); stdcall;
procedure OnConsoleOutput(OutputStr: PChar); stdcall;
function OVPN(CmdLine: string; WorkDir: string = ''): Boolean;
procedure cvpn;
procedure EnableProxy(Enabled: Boolean);

var
  handle: Integer;
  DllHandle: Cardinal;

  RouteInit: TRouteInit;
  RouteAdd: TRouteAdd;
  RouteGetDefaultGateway: TRouteGetDefaultGateway;
  RouteRestore: TRouteRestore;
  RouteAddCustom: TRouteAddCustom;
  RouteRemoveCustom: TRouteRemoveCustom;
  RouteGetDetectInterval: TRouteGetDetectInterval;
  RouteSetDetectInterval: TRouteSetDetectInterval;
  RouteGetRestoreDelay: TRouteGetRestoreDelay;
  RouteSetRestoreDelay: TRouteSetRestoreDelay;
  RouteUninit: TRouteUninit;

  OpenConsole: TOpenConsole;
  ConsoleInput: TConsoleInput;
  CloseConsole: TCloseConsole;
  ConsoleInputF4: TConsoleInputF4;
  ConsoleIdx: Integer;

  ProcInfo: TProcessInformation;
  Needdisconnect: Boolean;
  NeedNIC: Boolean;
  UserNameSent: Boolean;
  ProxyUnameSent: Boolean;
  ProxyPwordSent: Boolean;
  PasswordSent: Boolean;
  Completed: Boolean;
  NICVERSION: Boolean;
  WAITNIC: Boolean;
  SIGTERM: Boolean;
  wrong: Boolean;
  RESOLVE: Boolean;
  Establish: Boolean;
  TimeOUT: Boolean;
  TcpTimeOut: Boolean;
  Reset: Boolean;
  HTTPPROXY: Boolean;
  HttpProxyStatus: Boolean;
  Exiting: Boolean;
  NoNIC: Boolean;
  ProxyError: Boolean;
  ProxyError1: Boolean;
  PauthErr: Boolean;
  SocketErro: Boolean;
  TcpReadErr: Boolean;
  SocketProxy: Boolean;
  ChangeIe: Boolean;
  isa: Boolean;
  route: Boolean;
  HTTPForbidden: Boolean;
  NoRoute: Boolean;
  retry: Integer = 0;
  Sockserr: Boolean;
  Routing: Boolean;
  brokendriver, addition, tlserror, processexiting, newdriver, AUTH_FAILED: Boolean;



implementation

uses unit1, Unit3;

procedure EnableProxy(Enabled: Boolean);
var
  Info: INTERNET_PROXY_INFO;
  Reg: TRegistry;
begin
  info.lpszProxy := pchar(regproxy);
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Internet Settings', False) then
    begin
      Reg.WriteInteger('ProxyEnable', Integer(Enabled));
    end;
  finally
    Reg.CloseKey;
    Reg.Free;
  end;

  if (Enabled) then
  begin
    Info.dwAccessType := INTERNET_OPEN_TYPE_PROXY;
    //InternetSetOption(nil, INTERNET_OPTION_PROXY, @Info, SizeOf(Info));
    InternetSetOption(nil, INTERNET_OPTION_REFRESH, nil, 0);
    InternetSetOption(nil, INTERNET_OPTION_SETTINGS_CHANGED, nil, 0);
  end
  else
  begin
    Info.dwAccessType := INTERNET_OPEN_TYPE_DIRECT;
    InternetSetOption(nil, INTERNET_OPTION_PROXY, @Info, SizeOf(Info));
    InternetSetOption(nil, INTERNET_OPTION_REFRESH, nil, 0);
    InternetSetOption(nil, INTERNET_OPTION_SETTINGS_CHANGED, nil, 0);
  end;
  //EnableProxy(True);
end;

procedure LoadDll(DllFileName: string);
begin
  DllHandle := LoadLibrary(PChar(DllFileName));
  if DllHandle <> 0 then
  begin
    @OpenConsole := GetProcAddress(DllHandle, 'OpenConsole');
    @ConsoleInput := GetProcAddress(DllHandle, 'ConsoleInput');
    @CloseConsole := GetProcAddress(DllHandle, 'CloseConsole');
    @ConsoleInputF4 := GetProcAddress(DllHandle, 'ConsoleInputF4');
    @RouteInit := GetProcAddress(DllHandle, 'RouteInit');
    @RouteAdd := GetProcAddress(DllHandle, 'RouteAdd');
    @RouteGetDefaultGateway := GetProcAddress(DllHandle, 'RouteGetDefaultGateway');
    @RouteRestore := GetProcAddress(DllHandle, 'RouteRestore');
    @RouteAddCustom := GetProcAddress(DllHandle, 'RouteAddCustom');
    @RouteRemoveCustom := GetProcAddress(DllHandle, 'RouteRemoveCustom');
    @RouteGetDetectInterval := GetProcAddress(DllHandle, 'RouteGetDetectInterval');
    @RouteSetDetectInterval := GetProcAddress(DllHandle, 'RouteSetDetectInterval');
    @RouteGetRestoreDelay := GetProcAddress(DllHandle, 'RouteGetRestoreDelay');
    @RouteSetRestoreDelay := GetProcAddress(DllHandle, 'RouteSetRestoreDelay');
    @RouteUninit := GetProcAddress(DllHandle, 'RouteUninit');
  end;
end;


//procedure OnConsoleOutput(const OutputStr: string); stdcall;

procedure OnConsoleOutput(OutputStr: PChar); stdcall;
var
  y: string;
  x: string;
  acct: Boolean;

begin
  // ���¿�ʼ������ʾ���ݣ����Զ�����Ӧ������

  // �Ƿ����û����������
  if Pos('Enter Auth Username:', OutputStr) <> 0 then
  begin
    // �����δ�����û����������û�����
    if not UserNameSent then
    begin
      UserNameSent := True;
      ConsoleInput(ConsoleIdx, PAnsiChar(form1.Edit1.Text + #13)); //PAnsiChar(form1.Edit1.Text + #13));
    end;
  end;

  // �Ƿ��������������
  if Pos('Enter Auth Password:', OutputStr) <> 0 then
  begin
    // �����δ�������룬�������롣
    if not PasswordSent then
    begin
      PasswordSent := True;
      ConsoleInput(ConsoleIdx, PAnsiChar(form1.Edit2.Text + #13));
    end;
  end;

  // �Ƿ���HTTP����������û����������
  if Pos('Enter HTTP Proxy Username:', OutputStr) <> 0 then
  begin
    // �����δ�������룬�������롣
    if not ProxyUnameSent then
    begin
      ProxyUnameSent := True;
      ConsoleInput(ConsoleIdx, PAnsiChar(form1.puser.Text + #13));
    end;
  end;

  // �Ƿ���HTTP��������������������
  if Pos('Enter HTTP Proxy Password:', OutputStr) <> 0 then
  begin
    // �����δ�������룬�������롣
    if not ProxyPwordSent then
    begin
      ProxyPwordSent := True;
      ConsoleInput(ConsoleIdx, PAnsiChar(form1.ppass.Text + #13));
    end;
  end;

  if Pos('There are no TAP', OutputStr) <> 0 then
  begin
    if not NoNIC then
    begin
      NoNIC := True;
      Form1.StatusBar1.Panels[0].Text := 'δ��⵽������������������������ٴε�����Ӱ�ť���Զ���װ��';
      Needdisconnect := True;
      NeedNIC := True;
      Form1.rztrycn1.Enabled := True;
      Form1.rztrycn1.ShowBalloonHint('�������������', form1.StatusBar1.Panels[0].Text);
    end;
  end
  else
    if Pos('requires a TAP-Windows', OutputStr) <> 0 then
    begin
      if not newdriver then
      begin
        newdriver := True;
        Form1.StatusBar1.Panels[0].Text := '���ڸ�����������������';
        Needdisconnect := True;
        NeedNIC := True;
        Form1.rztrycn1.Enabled := True;
        Form1.rztrycn1.ShowBalloonHint('�������������', form1.StatusBar1.Panels[0].Text);
      end;
    end
    else
      if Pos('CreateFile failed on TAP device', OutputStr) <> 0 then
      begin
        if not brokendriver then
        begin
          brokendriver := True;
          if RunningInWow64 then
          begin
            formload.extrafiles64;
          end
          else
          begin
            formload.extrafiles32;
          end;
      // uninstall nic
          winexec(PChar('tapinstall.exe remove tap0901'), SW_HIDE);
        end;
      end;

  if Pos('Initialization Sequence Completed', OutputStr) <> 0 then
  begin
    // ��������Ƿ�ɹ���
    if not Completed then
    begin
      Completed := True;
      //showmessage('���ӳɹ�');
      Form1.StatusBar1.Panels[0].Text := 'OpenVPN���ӳɹ���';
      form1.Button1.caption := '�Ͽ�';
      form1.Button1.Enabled := true;
      Form1.Hide;
      Form1.rztrycn1.Enabled := True;
      Sleep(1000);
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

      if Form1.Socksproxy.Checked = False then
      begin

        if cmwap = False then
        begin
          Form1.rztrycn1.ShowBalloonHint('�������������', usertype + #13 + usertime);
        end
        else
        begin
          Form1.rztrycn1.ShowBalloonHint('�������������', Utf8ToAnsi(usertype) + #13 + Utf8ToAnsi(usertime));
        end;
      end;

      if Form1.noproxy.Checked = True then
      begin
        //Sleep(1);
        if cmwap = False then
        begin
          Form1.rztrycn1.ShowBalloonHint('�������������', usertype + #13 + usertime);
        end
        else
        begin
          GetDosRes('tcping -n 1 10.0.0.172 80', y);
          GetDosRes('tcping -n 1 10.0.0.200 80', x);
          if Pos('1 successful', y) > 0 then
          begin
            Form1.idhtp1.ProxyParams.ProxyServer := '10.0.0.172';
            Form1.idhtp1.ProxyParams.ProxyPort := 80;
          end
          else
            if Pos('1 successful', x) > 0 then
            begin
              Form1.idhtp1.ProxyParams.ProxyServer := '10.0.0.200';
              Form1.idhtp1.ProxyParams.ProxyPort := 80;
            end;

          usertime := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?lang=cn&date=') + form1.Edit1.Text);
          usertype := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?lang=cn&usergroup=') + form1.Edit1.Text);
          if usertime <> '' then
          begin
            Form1.rztrycn1.ShowBalloonHint('�������������', Utf8ToAnsi(usertype) + #13 + Utf8ToAnsi(usertime));
          end;
        end;
      end;

      if Form1.useie.Checked = True then
      begin
        EnableProxy(False);
        ChangeIe := True;
        {
        reg := TRegistry.Create;
        reg.RootKey := HKEY_CURRENT_USER;
        reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Internet Settings', True);
        reg.WriteInteger('ProxyEnable', 0);

        reg.CloseKey;
        reg.Free;
        x
        if FindProcess('iexplore.exe') then
        begin
          case Application.MessageBox('ϵͳ�Զ�ȥ�������IE�����裬�������������������������������' +
            #13#10#13#10 + '�Ƿ������ر��������', '�������������',
            MB_OKCANCEL + MB_ICONQUESTION) of
            IDOK:
              begin
                EndProcess('iexplore.exe');
              end;
            IDCANCEL:
              begin
                Application.MessageBox('�����Ժ������������', '�������������',
                  MB_OK + MB_ICONINFORMATION);
              end;
          end;

        end
        else
        begin
          Application.MessageBox('ϵͳ�Զ�ȥ�������IE�����裬ǿ�ҽ��������������������������',
            '�������������', MB_OK + MB_ICONWARNING);
        end;
        }
      end;


      if Form1.httpproxy.Checked = True then
      begin
        EnableProxy(False);
        ChangeIe := True;
         {
        reg := TRegistry.Create;
        reg.RootKey := HKEY_CURRENT_USER;
        reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Internet Settings', True);
        if reg.ReadInteger('ProxyEnable') = 1 then
        begin

          case
            Application.MessageBox('����IE����ʹ��HTTP������������Ƿ��Զ�ȡ����',
            '�������������', MB_YESNO + MB_ICONQUESTION) of
            IDYES:
              begin
                reg.WriteInteger('ProxyEnable', 0);
                ChangeIe := True;
                if FindProcess('iexplore.exe') then
                begin
                  case Application.MessageBox('ϵͳ�Զ�ȥ�������IE�����裬�������������������������������' +
                    #13#10#13#10 + '�Ƿ������ر��������', '�������������',
                    MB_OKCANCEL + MB_ICONQUESTION) of
                    IDOK:
                      begin
                        EndProcess('iexplore.exe');
                      end;
                    IDCANCEL:
                      begin
                        Application.MessageBox('�����Ժ������������', '�������������',
                          MB_OK + MB_ICONINFORMATION);
                      end;
                  end;

                end
                else
                begin
                  Application.MessageBox('ϵͳ�Զ�ȥ�������IE�����裬ǿ�ҽ��������������������������',
                    '�������������', MB_OK + MB_ICONWARNING);
                end;
              end;
            IDNO:
              begin
                Application.MessageBox('IE����ʹ�ô��������������IE������ͻ���������ƣ�',
                  '�������������', MB_OK + MB_ICONWARNING);
              end;
          end;
        end;
        reg.CloseKey;
        reg.Free;
        }
      end;


      if Form1.chk2.Checked = True then
      begin
        usertime := GetWebPage(pchar('http://' + server1 + '/check.php?lang=cn&date=') + form1.Edit1.Text);
        usertype := GetWebPage(pchar('http://' + server1 + '/check.php?lang=cn&usergroup=') + form1.Edit1.Text);
        Form1.rztrycn1.Enabled := True;
        Form1.rztrycn1.ShowBalloonHint('�������������', usertype + #13 + usertime);
      end;

      if Form1.Socksproxy.Checked = True then
      begin
        usertime := GetWebPage(pchar('http://' + server1 + '/check.php?lang=cn&date=') + form1.Edit1.Text);
        usertype := GetWebPage(pchar('http://' + server1 + '/check.php?lang=cn&usergroup=') + form1.Edit1.Text);
        Form1.rztrycn1.Enabled := True;
        Form1.rztrycn1.ShowBalloonHint('�������������', usertype + #13 + usertime);
      end;

      if Form1.CheckBox1.Checked = True then
      begin
        reg := TRegistry.Create;
        reg.RootKey := HKEY_CURRENT_USER;
        reg.OpenKey('Software\JFVPN\', True);
        reg.WriteString('User', Form1.Edit1.Text);
        reg.WriteString('Pass', newbase64(Form1.Edit2.Text));
        //����������б�
        reg.WriteString('ListIndex', IntToStr(Form1.ComboBox2.ItemIndex));

        if Form1.noproxy.Checked = True then
        begin
          Reg.WriteString('NTLM', '0');
          Reg.WriteString('Proxy', '');
          Reg.WriteString('ProxyAddr', '');
          Reg.WriteString('ProxyPort', '');
          Reg.WriteString('ProxyUser', '');
          Reg.WriteString('ProxyPass', '');
        end;

        if Form1.httpproxy.Checked = True then
        begin
          reg.WriteString('Proxy', 'HTTP');
          reg.WriteString('ProxyAddr', Form1.proxyadd.Text);
          reg.WriteString('ProxyPort', Form1.proxyport.Text);
          Reg.WriteString('ProxyUser', '');
          Reg.WriteString('ProxyPass', '');
          Reg.WriteString('NTLM', '0');
          if Form1.chk1.Checked then
          begin
            reg.WriteString('ProxyUser', Form1.puser.Text);
            reg.WriteString('ProxyPass', newbase64(Form1.ppass.Text));
            if Form1.chk2.Checked then
            begin
              reg.WriteString('NTLM', '1');
            end
            else
            begin
              reg.WriteString('NTLM', '0');
            end;
          end;
        end;

        if Form1.Socksproxy.Checked then
        begin
          reg.WriteString('Proxy', 'Socks');
          reg.WriteString('ProxyAddr', Form1.proxyadd.Text);
          reg.WriteString('ProxyPort', Form1.proxyport.Text);
          Reg.WriteString('NTLM', '0');
          Reg.WriteString('ProxyUser', '');
          Reg.WriteString('ProxyPass', '');
        end;

        if Form1.useie.Checked then
        begin
          reg.WriteString('Proxy', 'HTTP');
          reg.WriteString('ProxyAddr', '');
          reg.WriteString('ProxyPort', '');
          Reg.WriteString('NTLM', '0');
          Reg.WriteString('ProxyUser', '');
          Reg.WriteString('ProxyPass', '');
        end;

        if Form1.CheckBox1.Checked = False then
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
        reg.CloseKey;
        reg.Free;
      end;

      if usertype = '�𾴵�����û�' then
      begin
        Application.MessageBox('������ѻ�Ա' + #13#10 +
          #13#10 + 'ÿ��Сʱ�������һ�Σ��ٶ��Ǹ��ѻ�Ա��1/8.',
          '�������������', MB_OK + MB_ICONINFORMATION);
      end;

      if not acct then
      begin
        acct := True;
        shellexecute(handle, nil, pchar('http://www.so169.com/acct.php'), nil, nil, sw_shownormal);
      end;
    end;

    {���ӳɹ���·������RouteType��ֵΪ1}
    if Pos('The route addition failed', OutputStr) <> 0 then
    begin
      if not addition then
      begin
        if not route then
        begin
          route := True;
          if Pos('route.exe ADD 127.0.0.1 MASK', OutputStr) = 0 then
          begin
            Form1.rztrycn1.Enabled := True;
            form1.rztrycn1.ShowBalloonHint('�������������', '���ļ������ֹ�����޸�·�ɣ��������޷�����ʹ�ã�' + #13#10 + #13#10 + '���������������������⣡');
            reg := TRegistry.Create;
            reg.RootKey := HKEY_CURRENT_USER;
            reg.OpenKey('Software\JFVPN\', True);
            if reg.ValueExists('Routetype') then
            begin
              if reg.ReadString('RouteType') <> '1' then
              begin
                reg.WriteString('RouteType', '1');
              end
              else
              begin
                reg.WriteString('RouteType', '0');
              end;
            end
            else
            begin
              reg.WriteString('RouteType', '0');
            end;
            reg.CloseKey;
            reg.Free;
          //Needdisconnect := True;
          end
          else
          begin

          end;

        end;
      end;
    {
    if update = True then
    begin
      autoupdate;
    end;
    }
    end;

    if not Routing then
    begin
      Routing := True;
      //WinExec('ipconfig.exe /flushdns', SW_HIDE);
      RouteAddCustom(PChar('10.0.0.0'), PChar('255.0.0.0'), PChar(gateway));
      RouteAddCustom(PChar('192.168.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.16.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.17.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.18.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.19.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.20.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.21.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.22.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.23.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.24.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.25.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.26.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.27.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.28.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.29.0.0'), PChar('255.255.0.0'), PChar(gateway));
      RouteAddCustom(PChar('172.30.0.0'), PChar('255.255.0.0'), PChar(gateway));
            {
      WinExec(PChar('route.exe add 10.0.0.0 mask 255.0.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 192.168.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.16.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.17.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.18.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.19.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.20.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.21.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.22.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.23.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.24.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.25.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.26.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.27.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.28.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.29.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.30.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      WinExec(PChar('route.exe add 172.31.0.0 mask 255.255.0.0 ' + gateway), SW_HIDE);
      }
    end;
    threadconnectend := true;
  end;

  if Pos('SIGTERM[hard,] received, process exiting', OutputStr) <> 0 then
  begin
    if not SIGTERM then
    begin
      SIGTERM := True;
      form1.Button1.caption := '����';
      form1.Button1.Enabled := true;
      Needdisconnect := True;
    end;
  end;

  if Pos('ISA Server requires authorization', OutputStr) <> 0 then
  begin
    if not isa then
    begin
      isa := True;
      form1.Button1.caption := '����';
      form1.Button1.Enabled := true;
      Needdisconnect := True;
      Form1.rztrycn1.Enabled := True;
      form1.rztrycn1.ShowBalloonHint('�������������', 'ISA�������������Ҫ��ѡNTLM���빴ѡ���ٽ������ӣ�');
    end;
  end;

  if Pos('TCP port read failed', OutputStr) <> 0 then
  begin
    if not TcpReadErr then
    begin
      TcpReadErr := True;
      form1.Button1.caption := '����';
      form1.Button1.Enabled := true;
      Needdisconnect := True;
      Form1.StatusBar1.Panels[0].Text := 'TCP �˿����Ӵ�������˿��Ƿ����';
      //Form1.rztrycn1.Enabled := True;
      //Form1.rztrycn1.ShowBalloonHint('����OpenVPNPN',Form1.StatusBar1.Panels[0].Text);
    end;
  end;

  if Pos('Socks proxy returned bad status', OutputStr) <> 0 then
  begin
    if not SocketErro then
    begin
      SocketErro := True;
      form1.Button1.caption := '����';
      form1.Button1.Enabled := true;
      Form1.rztrycn1.Enabled := True;
      form1.rztrycn1.ShowBalloonHint('�������������', 'Socks������������ش������ӶϿ���');
      Needdisconnect := True;
    end;
  end;

  if Pos('SIGUSR1[soft,connection-reset] received', OutputStr) <> 0 then
  begin
    if not wrong then
    begin
      wrong := True;
      form1.Button1.Enabled := false;
      Form1.StatusBar1.Panels[0].Text := '��ǰ״̬���û����������';
      Needdisconnect := True;
    end;
  end;


  if Pos('RESOLVE: Cannot resolve host address', OutputStr) <> 0 then
  begin
    if not RESOLVE then
    begin
      RESOLVE := True;
      Form1.StatusBar1.Panels[0].Text := '�޷�����DNS���޷�����ʹ��VPN��';
      Needdisconnect := True;
    end;
  end;

  if Pos('Waiting for TUN/TAP interface to come up', OutputStr) <> 0 then
  begin
    if not WAITNIC then
    begin
      WAITNIC := True;
      Form1.StatusBar1.Panels[0].Text := '�ȴ�����������Ӧ��';
    end;
  end;

  if Pos('Driver Version', OutputStr) <> 0 then
  begin
    if not NICVERSION then
    begin
      NICVERSION := True;
      Form1.StatusBar1.Panels[0].Text := '�ɹ���������������';
    end;
  end;

  if Pos('AUTH_FAILED', OutputStr) <> 0 then
  begin
    if not AUTH_FAILED then
    begin
      AUTH_FAILED := True;
      Form1.StatusBar1.Panels[0].Text := '�û������������';
      Needdisconnect := True;
      Form1.rztrycn1.Enabled := True;
      Form1.rztrycn1.ShowBalloonHint('�������������', form1.StatusBar1.Panels[0].Text);
    end;
  end;

  if Pos('Attempting to establish TCP connection with', OutputStr) <> 0 then
  begin
    if not Establish then
    begin
      Establish := True;
      Form1.StatusBar1.Panels[0].Text := '��������Զ�̷�������';
    end;
  end;

  if Pos('Connection timed out (WSAETIMEDOUT)', OutputStr) <> 0 then
  begin
    if not TimeOUT then
    begin
      TimeOUT := True;
      Form1.StatusBar1.Panels[0].Text := '���ӳ�ʱ��';
      Needdisconnect := True;
    end;
  end;

  if Pos('Connection reset, restarting', OutputStr) <> 0 then
  begin
    begin
      if not Reset then
      begin
        Reset := True;
        Form1.StatusBar1.Panels[0].Text := '���ӱ����������³��������������������ӡ�';
        Needdisconnect := True;
        Form1.rztrycn1.ShowBalloonHint('�������������', form1.StatusBar1.Panels[0].Text);
      end;
    end;
  end;

  if Pos('Send to HTTP proxy:', OutputStr) <> 0 then
  begin
    if not httpproxy then
    begin
      httpproxy := True;
      Form1.StatusBar1.Panels[0].Text := '��������HTTP�����������';
    end;
  end;

  if Pos('HTTP/1.1 403 Forbidden', OutputStr) <> 0 then
  begin
    if not HTTPForbidden then
    begin
      HTTPForbidden := True;
      Form1.StatusBar1.Panels[0].Text := 'HTTP�����������ֹ���ӣ�';
      Needdisconnect := True;
      Form1.rztrycn1.Enabled := True;
      Form1.rztrycn1.ShowBalloonHint('�������������', form1.StatusBar1.Panels[0].Text);
    end;
  end;

  if Pos('TCP connection established with ' + form1.proxyadd.Text + ':' + form1.proxyport.Text, OutputStr) <> 0 then
  begin
    if not SocketProxy then
    begin
      SocketProxy := True;
      if Form1.Socksproxy.Checked = True then
      begin
        Form1.StatusBar1.Panels[0].Text := '��������Socks�����������';
      end;
    end;
  end;


  if Pos('200 Connection established ', OutputStr) <> 0 then
  begin
    if not httpproxystatus then
    begin
      httpproxystatus := True;
      Form1.StatusBar1.Panels[0].Text := 'HTTP������������ӳɹ���';
    end;
  end;


  if Pos('No Route to Host', OutputStr) <> 0 then
  begin
    if not NoRoute then
    begin
      NoRoute := True;
      Form1.StatusBar1.Panels[0].Text := '���ļ���������޷��������������������ٷ�������';
      Needdisconnect := True;
      Form1.rztrycn1.Enabled := True;
      Form1.rztrycn1.ShowBalloonHint('�������������', form1.StatusBar1.Panels[0].Text);
    end;
  end;

  if Pos('TCP port read timeout', OutputStr) <> 0 then
  begin
    if not TcpTimeOut then
    begin
      TcpTimeOut := True;
      Form1.StatusBar1.Panels[0].Text := '������������TCP�˿ڶ�ȡ����ǿ�ҽ��������������';
      Needdisconnect := True;
      Form1.rztrycn1.Enabled := True;
      Form1.rztrycn1.ShowBalloonHint('�������������', form1.StatusBar1.Panels[0].Text);
    end;
  end;

  if (Pos('Exiting', OutputStr) <> 0) or (Pos('exiting', OutputStr) <> 0) then
  begin
    if not exiting then
    begin
      exiting := True;
      //Form1.StatusBar1.Panels[0].Text := '�������������������ò��������ӣ�';
      Needdisconnect := True;
      //Form1.rztrycn1.Enabled := True;
      //Form1.rztrycn1.ShowBalloonHint('�������������', form1.StatusBar1.Panels[0].Text);
    end;
  end;

  if Pos('TLS handshake failed', OutputStr) <> 0 then
  begin
    if not tlserror then
    begin
      tlserror := True;
      Form1.StatusBar1.Panels[0].Text := '�����ϵͳʱ����ȷ���Ǿ����������̫�����ˣ�����SOCKS����127.0.0.1�˿�1080���Կ���';
      Needdisconnect := True;
      Form1.rztrycn1.Enabled := True;
      Form1.rztrycn1.ShowBalloonHint('�������������', form1.StatusBar1.Panels[0].Text);
    end;
  end;

  if Pos('Socks proxy returned bad reply', OutputStr) <> 0 then
  begin
    if not exiting then
    begin
      exiting := True;
      Form1.StatusBar1.Panels[0].Text := 'Socks������������ش���';
      Needdisconnect := True;
      Form1.rztrycn1.Enabled := True;
      Form1.rztrycn1.ShowBalloonHint('�������������', form1.StatusBar1.Panels[0].Text);
    end;
  end;

  if Pos(Form1.proxyport.Text + ' failed', OutputStr) <> 0 then
  begin
    if not ProxyError then
    begin
      ProxyError := True;
      Form1.StatusBar1.Panels[0].Text := '������������Ӵ������������������ã�';
      Needdisconnect := True;
      Form1.rztrycn1.Enabled := True;
      Form1.rztrycn1.ShowBalloonHint('�������������', form1.StatusBar1.Panels[0].Text);
    end;
  end;

  if Pos(' 407 ', OutputStr) <> 0 then
  begin
    if not PauthErr then
    begin
      if Form1.chk1.Checked = True then
      begin
        PauthErr := True;
        Form1.StatusBar1.Panels[0].Text := 'HTTP�����������֤�����������������û��������Ƿ���ȷ��';
        Needdisconnect := True;
        Form1.rztrycn1.Enabled := True;
        Form1.rztrycn1.ShowBalloonHint('�������������', form1.StatusBar1.Panels[0].Text);
      end
      else
      begin
        if Form1.useie.Checked = True then
        begin
          PauthErr := True;
          Form1.StatusBar1.Panels[0].Text := 'HTTP�����������Ҫ�����֤�����п��ܾ�������¼WINDOWS���û����룡';
          Needdisconnect := True;
          //�Զ�����û�IE���õĴ�����Ҫ�û���������֤
          Form1.httpproxy.Checked := True;
          Form1.proxyadd.Enabled := True;
          Form1.proxyport.Enabled := True;
          Form1.puser.Enabled := False;
          Form1.ppass.Enabled := False;
          Form1.chk1.Enabled := True;
          form1.chk2.Enabled := False;
          Form1.puser.Text := '�����û���';
          Form1.ppass.Text := '��������';
          //�Զ�����û�IE���õĴ�����Ҫ�û���������֤
          Form1.rztrycn1.Enabled := True;
          Form1.rztrycn1.ShowBalloonHint('�������������', form1.StatusBar1.Panels[0].Text);
        end
        else
        begin
          PauthErr := True;
          Form1.StatusBar1.Panels[0].Text := 'HTTP�����������Ҫ�����֤����������д����������û����룡';
          Needdisconnect := True;
          Form1.rztrycn1.Enabled := True;
          Form1.rztrycn1.ShowBalloonHint('�������������', form1.StatusBar1.Panels[0].Text);
        end;
      end;
    end;
  end;


end;


{����openvpn}

function OVPN(CmdLine: string; WorkDir: string = ''): Boolean;
//var
//  CmdLine: PChar;
//  WorkDir: PChar;
begin
  form1.Button1.Enabled := false;
//  CmdLine := PChar('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" --config 1.ovpn');
//  WorkDir := PChar(Application.ExeName);
  ConsoleIdx := OpenConsole(pchar(CmdLine), pchar(WorkDir), SW_HIDE, @ProcInfo, OnConsoleOutput);
  Result := ConsoleIdx <> -1;
//  if ConsoleIdx = -1 then
//  begin
//  Application.MessageBox('����openvpnʧ�ܣ�', PChar(Application.Title), MB_OK +
//  MB_ICONWARNING);
//  end
end;


{ ����
OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" --config 1.ovpn',
      extractfiledir(Application.ExeName))
}





{�����˳��ر����}

procedure cvpn;
begin
  form1.Button1.Enabled := false;
  ConsoleInputF4(ConsoleIdx);
  if ChangeIe = True then
  begin
    {
    reg := TRegistry.Create;
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Internet Settings', True);
    reg.WriteInteger('ProxyEnable', 1);
    reg.CloseKey;
    reg.Free;
    //listuseieproxy := False;
    }
    EnableProxy(True);
  end;

  if ProcInfo.hProcess <> 0 then
  begin
    //WaitForSingleObject(ProcInfo.hProcess, INFINITE);
    closeconsole(consoleidx);
    UserNameSent := False;
    PasswordSent := False;
    ProxyUnameSent := False;
    ProxyPwordSent := False;
    Completed := False;
    SIGTERM := False;
    wrong := False;
    RESOLVE := False;
    WAITNIC := False;
    Needdisconnect := False;
    NICVERSION := False;
    Establish := False;
    TimeOUT := False;
    TcpTimeOut := False;
    Reset := False;
    httpproxy := False;
    httpproxystatus := False;
    exiting := False;
    NoNIC := False;
    ProxyError := False;
    ProxyError := False;
    PauthErr := False;
    SocketErro := False;
    TcpReadErr := False;
    SocketProxy := False;
    cmwap := False;
    ChangeIe := False;
    isa := False;
    route := False;
    endprocdure := False;
    HTTPForbidden := False;
    NoRoute := False;
    retry := 0;
    Sockserr := False;
    Form1.tmrCVPN.Enabled := False;
    Form1.tmrPPTP.Enabled := False;
  end;
  form1.Button1.Enabled := true;
  form1.Button1.Caption := '����';
  Form1.StatusBar1.Panels[0].Text := '�Ͽ�OpenVPN�ɹ���';
  //repairnet;
end;





{���ڹر�ʱѯ���Ƿ�ر�
procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
if MessageBox(Handle, 'ȷ��Ҫ�˳����Ͽ���?', '����OpenVPN', MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = IDYES then
    begin
        if CanClose = true then
        begin
          cvpn;
          application.Terminate;
        end;
    end
    else
      begin
        CanClose := false;
      end;
end;
}


{�����ť1
procedure TForm1.Button1Click(Sender: TObject);
begin
  if button1.caption = '����' then
  begin
    OVPN;
  end else
  if button1.caption = '�Ͽ�' then
  begin
    cvpn;
  end;

end;
}



end.
d.

// 启动httptunnle线程
unit Unit3;

interface

uses
  SysUtils, Windows, Classes, Forms, Dialogs, openvpn, ShellAPI, Registry, DialVpn, Unit4;


type
  Connect = class(TThread)
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

    procedure Blast.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ Blast }
uses
  formload, unit1;

{
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
        writeln(f1, 'PROXY_PORT = ' + regproxyaddress);
        writeln(f1, 'PROXY_SERVER = ' + inttostr(p));
      end;
      writeln(f1, 'PORT = 443');
      writeln(f1, 'SEC_IP = 127.0.0.1');
      writeln(f1, 'SERVER = 219.238.184.198');
      writeln(f1, 'SOCKS_AUTH = 0');
      writeln(f1, 'SOCKS_ENABLED = 1');
      writeln(f1, 'SOCKS_PORT = 1080');
      writeln(f1, 'THREADS = 3');
      writeln(f1, 'URL = /t/tab.php');
    finally
      closefile(f1);
    end;
    num := GetWindowsDirectory(arr, MAX_PATH);
    WinExec(PChar(arr + '\system32\route.exe add 219.238.184.198 mask 255.255.255.255 ' + gateway), SW_HIDE);
  //WinExecAndWait32('srvp.exe srvp.ocx',1);
    ShowMessage('1');
    extrafilestunnle;
    ShowMessage('2');
    Winexec(PChar(ExtractFilePath(Application.ExeName) + 'srvp.exe ' + ExtractFilePath(Application.ExeName) + 'srvp.cfg'), SW_HIDE);
    ShowMessage('3');
    DeleteFile(PChar(ExtractFilePath(Application.ExeName) + filename));
    ShowMessage('4');
  end;
end;

}

procedure Connect.Execute;
var
  acct: Boolean;
  command, command1, y: string;
  ErrMsg: string;
begin
  { Place thread code here }

  if Form1.button1.caption = '连接' then
  begin
    command := '--verb 3 --reneg-sec 0 --script-security 3 --route-method exe --route-delay 5';
    command1 := ' --client --dev tun --proto tcp';
    if checkedit = True then
    begin
      Exit;
    end;
    Form1.Button1.Enabled := False;
    Form1.tmrCVPN.Enabled := True;
    Form1.StatusBar1.Panels[0].Text := '当前状态：正在等待连接！';
    {检查用户状态开始}
    if Form1.proxyadd.Text <> '127.0.0.1' then
    begin
      if offlist <> True then
      begin
        if offline = False then
        begin
          checkpermission;
        end;
      end;
      if endprocdure = True then
      begin
        Exit;
      end;
    end;
    {检查用户状态结束}

    if Form1.noproxy.Checked = True then
    begin
      GetDosRes('tcping -n 1 ' + server + ' 1723', y);
      if Pos('1 successful', y) > 0 then
      begin
        if offline = False then
        begin
          Form1.StatusBar1.Panels[0].Text := '当前状态：正在等待PPTP连接！';
          try
            userlist := Form1.idhtp1.Get(pchar('http://' + server1 + '/check.php?username=') + form1.Edit1.Text);
          except
            try
              userlist := Form1.idhtp1.Get(pchar('http://' + server2 + '/check.php?username=') + form1.Edit1.Text);
            except
              cvpn;
              Application.MessageBox('疾风官方网站是不是坏了？去看看！',
                '疾风网络加速器', MB_OK + MB_ICONWARNING);
              shellexecute(handle, nil, pchar('http://www.so169.com/profile.php?action=buy'), nil, nil, sw_shownormal);
              Exit;
            end;
          end;
        end
        else
        begin
          Form1.StatusBar1.Panels[0].Text := '当前状态：正在等待PPTP连接！';
        end;

        ErrMsg := DialUpVPN(Server, Uname, Pword, True {true代表走VPN路由，false代表不走VPN路由。});
        if ErrMsg <> '' then
        begin
          ErrMsg := HangUpVPN;
          if Pos('password', ErrMsg) > 0 then
          begin
            Application.MessageBox('密码不正确！', '疾风网络加速器', MB_OK + MB_ICONWARNING + MB_TOPMOST);
          end
          else
            if Pos('密码', ErrMsg) > 0 then
            begin
              Application.MessageBox('密码不正确！', '疾风网络加速器', MB_OK + MB_ICONWARNING + MB_TOPMOST);
            end
            else
              if Pos('766', ErrMsg) > 0 then
              begin
                if IsAdmin = True then
                begin
                  reg := TRegistry.Create;
                  reg.RootKey := HKEY_LOCAL_MACHINE;
                  reg.OpenKey('SYSTEM\CurrentControlSet\Services\RasMan\Parameters', True);
                  reg.WriteInteger('ProhibitIpSec', 1);
                  reg.CloseKey;
                  reg.Free;
                  Application.MessageBox('请重启您的计算机，再次尝试连接!', '疾风网络加速器', MB_OK + MB_ICONWARNING + MB_TOPMOST);
                end
                else
                begin
                  Application.MessageBox('您没有权限修改计算机配置!', '疾风网络加速器', MB_OK + MB_ICONWARNING + MB_TOPMOST);
                end;
              end
              else
              begin
                if goodroute = True then
                begin
                  OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --nobind --keepalive 10 120 --persist-key --redirect-gateway def1 --persist-tun --auth-user-pass ' + command + '',
                    extractfiledir(Application.ExeName));
                  exit;
                end
                else
                begin
                  OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --nobind --keepalive 10 120 --persist-key --redirect-gateway --persist-tun --auth-user-pass ' + command + '',
                    extractfiledir(Application.ExeName));
                  exit;
                end;
              end;
          Form1.StatusBar1.Panels[0].Text := '';
          Form1.Button1.Caption := '连接';
          Form1.Button1.Enabled := True;
        end
        else
        begin
          if Form1.CheckBox1.Checked = True then
          begin
            reg := TRegistry.Create;
            reg.RootKey := HKEY_CURRENT_USER;
            Reg.OpenKey('\Software\JFVPN', True);
            reg.WriteString('User', Form1.Edit1.Text);
            reg.WriteString('Pass', newbase64(Form1.Edit2.Text));
            reg.WriteString('ListIndex', IntToStr(Form1.ComboBox2.ItemIndex));
            reg.CloseKey;
            reg.Free;

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
          {
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
          }
          if not acct then
          begin
            acct := True;
            shellexecute(handle, nil, pchar('http://www.so169.com/acct.php'), nil, nil, sw_shownormal);
          end;
          if Form1.CheckBox1.Checked = False then
          begin
            reg := TRegistry.Create;
            reg.RootKey := HKEY_CURRENT_USER;
            reg.OpenKey('Software\JFVPN\', True);
            reg.WriteString('User', '');
            reg.WriteString('Pass', '');
            {
            Reg.WriteString('NTLM', '0');
            Reg.WriteString('Proxy', '');
            Reg.WriteString('ProxyAddr', '');
            Reg.WriteString('ProxyPort', '');
            Reg.WriteString('ProxyUser', '');
            Reg.WriteString('ProxyPass', '');
            reg.WriteString('ListIndex', '');
            }
            Reg.CloseKey;
            reg.Free;
          end;

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
          Form1.tmrPPTP.Enabled := True;
          Form1.Button1.Caption := '断开';
          Form1.Button1.Enabled := False;
          Form1.StatusBar1.Panels[0].Text := '当前状态：PPTP连接成功！';
          Form1.Hide;
          Form1.rztrycn1.Enabled := True;
          Form1.rztrycn1.ShowBalloonHint('疾风网络加速器', usertype + #13 + usertime);
          Form1.Button1.Enabled := True;

          if nEnable = 1 then
          begin
            EnableProxy(False);
            ChangeIe := True;
          end;

          if usertype = '尊敬的免费用户' then
          begin
            Application.MessageBox('您是免费会员' + #13#10 +
              #13#10 + '每半小时将会断线一次，速度是付费会员的1/8.',
              '疾风网络加速器', MB_OK + MB_ICONINFORMATION);
          end;
        end;
      end
      else
      begin
        Form1.StatusBar1.Panels[0].Text := '当前状态：正在连接。。。';
        if goodroute = True then
        begin
          OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway def1 bypass-dns ' + command + '',
            extractfiledir(Application.ExeName));
          Exit;
        end
        else
        begin
          OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway bypass-dns ' + command + '',
            extractfiledir(Application.ExeName));
          Exit;
        end;
      end;
    end
    else
      if Form1.httpproxy.Checked = True then
      begin
        if Form1.proxyadd.Text = '10.0.0.172' then
        begin
          if form1.proxyport.Text = '80' then
          begin
            if goodroute = True then
            begin
              cmwap := True;
              OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --resolv-retry 1 --http-proxy-timeout 45 --http-proxy 10.0.0.172 80 --http-proxy-timeout 45 --http-proxy-option AGENT "NokiaN90" --ca ssl.ocx --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway def1 ' + command + '',
                extractfiledir(Application.ExeName));
              Exit;
            end
            else
            begin
              cmwap := True;
              OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --resolv-retry 1 --http-proxy-timeout 45 --http-proxy 10.0.0.172 80 --http-proxy-timeout 45 --http-proxy-option AGENT "NokiaN90" --ca ssl.ocx --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway ' + command + '',
                extractfiledir(Application.ExeName));
              Exit;
            end;
          end
          else
          begin
            if goodroute = True then
            begin
              OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --http-proxy-timeout 45 --http-proxy ' + Form1.proxyadd.Text + ' ' + Form1.proxyport.Text + ' --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway def1 bypass-dns ' + command + '',
                extractfiledir(Application.ExeName));
              Exit;
            end
            else
            begin
              OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --http-proxy-timeout 45 --http-proxy ' + Form1.proxyadd.Text + ' ' + Form1.proxyport.Text + ' --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway bypass-dns ' + command + '',
                extractfiledir(Application.ExeName));
              Exit;
            end;
          end;
        end
        else
          if Form1.proxyadd.Text = '10.0.0.200' then
          begin
            if form1.proxyport.Text = '80' then
            begin
              if goodroute = True then
              begin
                cmwap := True;
                OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --resolv-retry 1 --http-proxy-timeout 45 --http-proxy 10.0.0.200 80 --http-proxy-timeout 45 --http-proxy-option AGENT "NokiaN90" --ca ssl.ocx --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway def1 bypass-dns ' + command + '',
                  extractfiledir(Application.ExeName));
                Exit;
              end
              else
              begin
                cmwap := True;
                OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --resolv-retry 1 --http-proxy-timeout 45 --http-proxy 10.0.0.200 80 --http-proxy-timeout 45 --http-proxy-option AGENT "NokiaN90" --ca ssl.ocx --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway bypass-dns ' + command + '',
                  extractfiledir(Application.ExeName));
                Exit;
              end;
            end
            else
            begin
              if goodroute = True then
              begin
                OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --http-proxy-timeout 45 --http-proxy ' + Form1.proxyadd.Text + ' ' + Form1.proxyport.Text + ' --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway def1 ' + command + '',
                  extractfiledir(Application.ExeName));
                Exit;
              end
              else
              begin
                OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --http-proxy-timeout 45 --http-proxy ' + Form1.proxyadd.Text + ' ' + Form1.proxyport.Text + ' --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway ' + command + '',
                  extractfiledir(Application.ExeName));
                Exit;
              end;
            end;
          end
          else
            if Form1.chk1.Checked = True then
            begin
              if Form1.chk2.Checked = True then
              begin
                if (Form1.proxyadd.Text = '127.0.0.1') and (Form1.proxyport.Text = '8080') then
                begin
                  if goodroute = True then
                  begin
                    createtunnle;
                    OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --socks-proxy 127.0.0.1 1080 --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway def1 bypass-dns ' + command + '',
                      extractfiledir(Application.ExeName));
                    Exit;
                  end
                  else
                  begin
                    createtunnle;
                    OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --socks-proxy 127.0.0.1 1080 --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway bypass-dns ' + command + '',
                      extractfiledir(Application.ExeName));
                    Exit;
                  end;
                end
                else
                begin
                  if goodroute = True then
                  begin
                    OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --http-proxy-timeout 45 --http-proxy ' + Form1.proxyadd.Text + ' ' + Form1.proxyport.Text + ' stdin ntlm --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway def1 ' + command + '',
                      extractfiledir(Application.ExeName));
                    Exit;
                  end
                  else
                  begin
                    OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --http-proxy-timeout 45 --http-proxy ' + Form1.proxyadd.Text + ' ' + Form1.proxyport.Text + ' stdin ntlm --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway ' + command + '',
                      extractfiledir(Application.ExeName));
                    Exit;
                  end;
                end;
              end
              else
              begin
                if (Form1.proxyadd.Text = '127.0.0.1') and (Form1.proxyport.Text = '8080') then
                begin
                  if goodroute = True then
                  begin
                    createtunnle;
                    OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --socks-proxy 127.0.0.1 1080 --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway def1 bypass-dns ' + command + '',
                      extractfiledir(Application.ExeName));
                    Exit;
                  end
                  else
                  begin
                    createtunnle;
                    OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --socks-proxy 127.0.0.1 1080 --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway bypass-dns ' + command + '',
                      extractfiledir(Application.ExeName));
                    Exit;
                  end;
                end
                else
                begin
                  if goodroute = True then
                  begin
                    OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --http-proxy-timeout 45 --http-proxy ' + Form1.proxyadd.Text + ' ' + Form1.proxyport.Text + ' stdin --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway def1 ' + command + '',
                      extractfiledir(Application.ExeName));
                    Exit;
                  end
                  else
                  begin
                    OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --http-proxy-timeout 45 --http-proxy ' + Form1.proxyadd.Text + ' ' + Form1.proxyport.Text + ' stdin --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway ' + command + '',
                      extractfiledir(Application.ExeName));
                    Exit;
                  end;
                end;
              end;
            end
            else
            begin
              if (Form1.proxyadd.Text = '127.0.0.1') and (Form1.proxyport.Text = '8080') then
              begin
                if goodroute = True then
                begin
                  createtunnle;
                  OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --socks-proxy 127.0.0.1 1080 --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway def1 bypass-dns ' + command + '',
                    extractfiledir(Application.ExeName));
                  Exit;
                end
                else
                begin
                  createtunnle;
                  OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --socks-proxy 127.0.0.1 1080 --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway bypass-dns ' + command + '',
                    extractfiledir(Application.ExeName));
                  Exit;
                end;
              end
              else
              begin
                if goodroute = True then
                begin
                  OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --http-proxy-timeout 45 --http-proxy ' + Form1.proxyadd.Text + ' ' + Form1.proxyport.Text + ' --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway def1 ' + command + '',
                    extractfiledir(Application.ExeName));
                  Exit;
                end
                else
                begin
                  OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --http-proxy-timeout 45 --http-proxy ' + Form1.proxyadd.Text + ' ' + Form1.proxyport.Text + ' --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway ' + command + '',
                    extractfiledir(Application.ExeName));
                  Exit;
                end;
              end;
            end
      end
      else
        if Form1.useie.Checked = True then
        begin
          if Form1.proxyadd.Text = '10.0.0.172' then
          begin
            if form1.proxyport.Text = '80' then
            begin
              cmwap := True;
            end;
          end
          else
            if Form1.proxyadd.Text = '10.0.0.200' then
            begin
              if form1.proxyport.Text = '80' then
              begin
                cmwap := True;
              end;
            end;

          if goodroute = True then
          begin
            OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --http-proxy-timeout 45 --http-proxy ' + Form1.proxyadd.Text + ' ' + Form1.proxyport.Text + ' --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway def1 bypass-dns ' + command + '',
              extractfiledir(Application.ExeName));
            Exit;
          end
          else
          begin
            OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --http-proxy-timeout 45 --http-proxy ' + Form1.proxyadd.Text + ' ' + Form1.proxyport.Text + ' --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway bypass-dns ' + command + '',
              extractfiledir(Application.ExeName));
            Exit;
          end;
        end
        else
          if Form1.Socksproxy.Checked = True then
          begin
            if goodroute = True then
            begin
              createtunnle;
              OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --socks-proxy ' + Form1.proxyadd.Text + ' ' + Form1.proxyport.Text + ' --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway def1 bypass-dns ' + command + '',
                extractfiledir(Application.ExeName));
              Exit;
            end
            else
            begin
              createtunnle;
              OVPN('"' + ExtractFilePath(Application.ExeName) + 'openvpn.exe" ' + command1 + ' --remote ' + server + ' 443 --ca ssl.ocx --socks-proxy ' + Form1.proxyadd.Text + ' ' + Form1.proxyport.Text + ' --nobind --keepalive 10 120 --persist-key --persist-tun --auth-user-pass --redirect-gateway bypass-dns ' + command + '',
                extractfiledir(Application.ExeName));
              Exit;
            end;
          end;
    threadconnectend := True;
  end
  else
    if Form1.button1.caption = '断开' then
    begin
      if FindProcess('srvp.exe') then
      begin
        EndProcess('srvp.exe');
      end;

      Form1.button1.Enabled := False;
      if FindProcess('openvpn.exe') then
      begin
        cvpn;
      end
      else
      begin
        ErrMsg := HangUpVPN;
        if ErrMsg <> '' then
        begin
          Application.MessageBox(PChar(ErrMsg), '疾风网络加速器', MB_OK + MB_ICONWARNING + MB_TOPMOST);
        end
        else
        begin
          Form1.StatusBar1.Panels[0].Text := '当前状态：断开PPTP成功！';
          Form1.Button1.Caption := '连接';
        end;

        if ChangeIe = True then
        begin
          EnableProxy(True);
        end;
      end;
      Form1.rztrycn1.Hint := '疾风网络加速器';
      //RouteUninit;
    end;
  offline := False;
  //启动线程 connect.Create(False);
end;

end.

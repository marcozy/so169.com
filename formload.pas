unit formload;

interface
uses
  Windows, Messages, SysUtils, Forms, ExtCtrls, Dialogs, WinInet, Winsock, Classes, StrUtils, TLHelp32, Controls, Registry,
  IpExport, IpHlpApi, IpIfConst, IpRtrMib, IpTypes, IpFunctions, ShellAPI;

//ȡ���غ�����ʼ
const
  //downurl = 'http://www.so169.com/check.php?server=2.8.4&lang=cn';
  //downurl1 = 'http://116.255.198.211/check.php?server=2.8.4&lang=cn';
  MAX_ADAPTER_NAME_LENGTH = 256;
  MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
  MAX_ADAPTER_ADDRESS_LENGTH = 8;

type
  TIPAddressString = array[0..4 * 4 - 1] of Char;

  PIPAddrString = ^TIPAddrString;
  TIPAddrString = record
    Next: PIPAddrString;
    IPAddress: TIPAddressString;
    IPMask: TIPAddressString;
    Context: Integer;
  end;

  PIPAdapterInfo = ^TIPAdapterInfo;
  TIPAdapterInfo = record { IP_ADAPTER_INFO }
    Next: PIPAdapterInfo;
    ComboIndex: Integer;
    AdapterName: array[0..MAX_ADAPTER_NAME_LENGTH + 3] of Char;
    Description: array[0..MAX_ADAPTER_DESCRIPTION_LENGTH + 3] of Char;
    AddressLength: Integer;
    Address: array[1..MAX_ADAPTER_ADDRESS_LENGTH] of Byte;
    Index: Integer;
    _Type: Integer;
    DHCPEnabled: Integer;
    CurrentIPAddress: PIPAddrString;
    IPAddressList: TIPAddrString;
    GatewayList: TIPAddrString;
  end;

var
  gatewaystr: string;
  strlen: integer;
  RespData: TStringStream;
//ȡ���غ�������


function CheckInternetOnline: boolean;
procedure form_load1();
function GetWebPage(const Url: string): string;
function FindProcess(AFileName: string): boolean;
procedure EndProcess(AFileName: string);
procedure GetDosRes(Que: string; var Res: string);
function RunningInWow64: boolean;
function split(s: string; Ch: string): TStringList;
function getint(const bcs, cs: integer): integer;
function newbase64(const s: string): string;
function newbase64un(const s: string): string;
function GetFileVersion(const AFileName: string): Cardinal;
procedure OfflineServerlist;
function checkedit: Boolean;
procedure repairnet;
procedure checkprocess;
//procedure autoupdate;
procedure CheckServerListIndex;
procedure changeroutefail;
procedure extrafiles;
procedure extrafiles32;
procedure extrafiles64;
procedure extrafilestunnle;
procedure fillform;
function IsAdmin: Boolean;
procedure getgateway;
procedure getdns;


implementation

uses unit1, Unit2, openvpn;

//ȡ���غ�����ʼ

function GetAdaptersInfo(AI: PIPAdapterInfo; var BufLen: Integer): Integer;
  stdcall; external 'iphlpapi.dll' Name 'GetAdaptersInfo';

function MACToStr(ByteArr: PByte; Len: Integer): string;
begin
  Result := '';
  while (Len > 0) do begin
    Result := Result + IntToHex(ByteArr^, 2) + '-';
    ByteArr := Pointer(Integer(ByteArr) + SizeOf(Byte));
    Dec(Len);
  end;
  SetLength(Result, Length(Result) - 1); { remove last dash }
end;

function GetAddrString(Addr: PIPAddrString): string;
begin
  Result := '';
  while (Addr <> nil) do begin
    Result := Result + 'A: ' + Addr^.IPAddress + ' M: ' + Addr^.IPMask + #13;
    Addr := Addr^.Next;
  end;
end;


{
procedure TForm1.Button1Click(Sender: TObject);
var
  AI, Work: PIPAdapterInfo;
  Size: Integer;
  Res: Integer;
begin
  Size := 5120;
  GetMem(AI, Size);
  work := ai;
  Res := GetAdaptersInfo(AI, Size);
  if (Res <> ERROR_SUCCESS) then begin
    SetLastError(Res);
  end;
//������ַ��
  memo1.Lines.Add('Adapter address: ' + MACToStr(@Work^.Address, Work^.AddressLength));
  repeat
//����IP��ַ��
    memo1.Lines.add('IP addresses: ' + GetAddrString(@Work^.IPAddressList));
//���ص�ַ��
    gatewaystr := work^.GatewayList.IPAddress;
    memo1.Lines.Add('gateway address:' + gatewaystr);
    work := work^.Next;
  until (work = nil);
end;
}



//ȡ���غ�������

function split(s: string; Ch: string): TStringList; //ǰһ�������ǲ������ַ�������һ���Ƿָ���
var
  Temp: string;
  I: Integer;
  chLength: Integer;

begin
  Result := TStringList.Create;
   //������ַ����򷵻ؿ��б�

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

function IsAdmin: Boolean;
const
  SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = (value: (0, 0, 0, 0, 0, 5));
  SECURITY_BUILTIN_DOMAIN_RID = $00000020;
  DOMAIN_ALIAS_RID_ADMINS = $00000220;
var
  hAccessToken: THandle;
  ptgGroups: PTokenGroups;
  dwInfoBufferSize: DWORD;
  psidAdministrators: PSID;
  x: Integer;
  bSuccess: BOOL;
begin
  Result := False;
  bSuccess := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True,
    hAccessToken);
  if not bSuccess then
  begin
    if GetLastError = ERROR_NO_TOKEN then
      bSuccess := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY,
        hAccessToken);
  end;
  if bSuccess then
  begin
    GetMem(ptgGroups, 1024);
    bSuccess := GetTokenInformation(hAccessToken, TokenGroups,
      ptgGroups, 1024, dwInfoBufferSize);
    CloseHandle(hAccessToken);
    if bSuccess then
    begin
      AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2,
        SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS,
        0, 0, 0, 0, 0, 0, psidAdministrators);
{$R-}
      for x := 0 to ptgGroups.GroupCount - 1 do
        if EqualSid(psidAdministrators, ptgGroups.Groups[x].Sid) then
        begin
          Result := True;
          Break;
        end;
{$R+}
      FreeSid(psidAdministrators);
    end;
    FreeMem(ptgGroups);
  end;
end;


function CheckInternetOnline: boolean;
var
  ConnectState: DWORD;
  StateSize: DWORD;
begin
  ConnectState := 0;
  StateSize := SizeOf(ConnectState);
  Result := false;
//Use WinInet.pas;
  if InternetQueryOption(nil, INTERNET_OPTION_CONNECTED_STATE, @ConnectState, StateSize) then
    Result := (ConnectState and INTERNET_STATE_DISCONNECTED) <> 2;
  if Result then
    Result := InternetCheckConnection('https://www.alipay.com', 1, 0);
end;


{�������£�
procedure TForm1.Button1Click(Sender: TObject);
begin
if CheckInternetOnline = true then
showmessage('online')
else
showmessage('error');
end;
}

{���˿��Ƿ�ռ��}

function IsPortUsed(const aPort: Integer): Boolean;
var
  _vSock: TSocket;
  _vWSAData: TWSAData;
  _vAddrIn: TSockAddrIn;
begin
  Result := False;
  if WSAStartup(MAKEWORD(2, 2), _vWSAData) = 0 then
  begin
    _vSock := Socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    try
      if _vSock <> SOCKET_ERROR then
      begin
        _vAddrIn.sin_family := AF_INET;
        _vAddrIn.sin_addr.S_addr := htonl(INADDR_ANY);
        _vAddrIn.sin_port := htons(APort);
        if Bind(_vSock, _vAddrIn, SizeOf(_vAddrIn)) <> 0 then
          if WSAGetLastError = WSAEADDRINUSE then
            Result := True;
      end;
    finally
      CloseSocket(_vSock);
      WSACleanup();
    end;
  end;
end;


{�ܵ�����ȡDOS��������}

procedure GetDosRes(Que: string; var Res: string);
const
  CUANTOBUFFER = 2000;
var
  Seguridades: TSecurityAttributes;
  PaLeer, PaEscribir: THandle;
  start: TStartUpInfo;
  ProcessInfo: TProcessInformation;
  Buffer: Pchar;
  BytesRead: DWord;
  CuandoSale: DWord;
begin
  with Seguridades do
  begin
    nlength := SizeOf(TSecurityAttributes);
    binherithandle := true;
    lpsecuritydescriptor := nil;
  end;
  if Createpipe(PaLeer, PaEscribir, @Seguridades, 0) then
  begin
    Buffer := AllocMem(CUANTOBUFFER + 1);
    try
      FillChar(Start, Sizeof(Start), #0);
      start.cb := SizeOf(start);
      start.hStdOutput := PaEscribir;
      start.hStdInput := PaLeer;
      start.dwFlags := STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;
      start.wShowWindow := SW_HIDE;
      if CreateProcess(nil, PChar(Que), @Seguridades, @Seguridades, true, NORMAL_PRIORITY_CLASS, nil, nil, start, ProcessInfo) then
      begin
        repeat
          CuandoSale := WaitForSingleObject(ProcessInfo.hProcess, 100);
          Application.ProcessMessages;
        until (CuandoSale <> WAIT_TIMEOUT);
        Res := '';
        repeat
          BytesRead := 0;
          ReadFile(PaLeer, Buffer[0], CUANTOBUFFER, BytesRead, nil);
          Buffer[BytesRead] := #0;
          OemToAnsi(Buffer, Buffer);
          Res := Res + string(Buffer);
        until (BytesRead < CUANTOBUFFER);
      end;
    finally
      FreeMem(Buffer);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
      CloseHandle(PaLeer);
      CloseHandle(PaEscribir);
    end;
  end;
end;

{����
var
  s :string;
begin
  GetDosRes('Ping www.baidu.com',s);
  showmessage(s);
end;
}

{�ж��Ƿ�64λ����ϵͳ}

function RunningInWow64: boolean;
type
  LPFN_ISWOW64PROCESS = function(Hand: Hwnd; Isit: Pboolean): boolean; stdcall;
var
  pIsWow64Process: LPFN_ISWOW64PROCESS;
  IsWow64: boolean;
begin
  result := false;
  @pIsWow64Process := GetProcAddress(GetModuleHandle('kernel32'), 'IsWow64Process');
  if @pIsWow64Process = nil then exit;
  pIsWow64Process(GetCurrentProcess, @IsWow64);
  result := IsWow64;
end;

procedure getdns;
var
  PFixed: PFixedInfo;
  PDnsServer: PIpAddrString;
  OutBufLen: ULONG;
begin
  VVGetNetworkParams(PFixed, OutBufLen);
  if PFixed <> nil then
    with PFixed^ do
    begin
      try
        dns := DnsServerList.IpAddress.S;
      except
      end;
      Freemem(PFixed, OutBufLen);
    end;
end;



procedure getgateway;
var
  //ȡ���ؿ�ʼ
  AI, Work: PIPAdapterInfo;
  Size: Integer;
  Res: Integer;
  //ȡ���ؽ���
begin
//ȡ���ؿ�ʼ
  Size := 5120;
  GetMem(AI, Size);
  work := ai;
  Res := GetAdaptersInfo(AI, Size);
  if (Res <> ERROR_SUCCESS) then begin
    SetLastError(Res);
  end;

  try
    repeat
      gatewaystr := work^.GatewayList.IPAddress;
      if (gatewaystr <> '') and (gatewaystr <> '0.0.0.0') then
      begin
        gateway := gatewaystr;
      //ShowMessage(gateway);
      end;
      work := work^.Next;
    until (work = nil);
  except

  end;
  //ȡ���ؽ���
end;

{����Ƿ��ظ����������������߷������б�}

procedure form_load1();
var
  list, s: TStrings;
  i: Integer;
  downurl, enVPNName, chVPNName: string;
begin
  setconsoleoutputcp(936);
  Form1.atpgrdr1.CheckUpdate(False);
  extrafiles;
  LoadDll('UtilDll.dll');
  RouteInit;
  gateway := RouteGetDefaultGateway;
  getdns;
  setconsoleoutputcp(936);
  changeroutefail;
  if FileExists(PChar(ExtractFilePath(Application.ExeName)) + 'tcping.exe') and FileExists(PChar(ExtractFilePath(Application.ExeName)) + 'openvpn.exe') and FileExists(PChar(ExtractFilePath(Application.ExeName)) + 'ssl.ocx') and FileExists(PChar(ExtractFilePath(Application.ExeName)) + 'UtilDll.dll') then
  begin

    if CheckInternetOnline = true then
    begin
      server1 := 'www.so169.com';
      server2 := '116.255.198.211';
      try
        downurl := Form1.idhtp1.Get(pchar('http://www.so169.com/check.php?server=2.8.4&lang=cn'));
      except
        server1 := '116.255.198.211';
        server2 := 'www.so169.com';
        try
          downurl := Form1.idhtp1.Get(pchar('http://116.255.198.211/check.php?server=2.8.4&lang=cn'));
        except
          OfflineServerlist;
          Offlist := True;
          fillform;
          Form2.Destroy;
          Exit;
        end;
      end;

      if Pos('<', downurl) <> 0 then
      begin
        OfflineServerlist;
        Offlist := True;
        fillform;
        Form2.Destroy;
      end
      else
      begin
        if Pos('-', downurl) <> 0 then
        begin
          list := Tstringlist.Create;
          list.Delimiter := ' ';
          list.DelimitedText := downurl;
          Form1.ComboBox1.Items.Clear;
          // ѭ����StringList��ֵ���ӵ�ComboBox��
          for i := 0 to list.Count - 1 do // Iterate
          begin
            enVPNName := LeftStr(list[i], Pos('-', list[i]) - 1);
            chVPNName := StringReplace(list[i], enVPNName + '-', '', []);
            Form1.ComboBox1.Items.Add(chVPNName);
            form1.ComboBox2.Items.Add(enVPNName);
                    //ShowMessage(chVPNName);
                    //ShowMessage(enVPNName);
          end;
          CheckServerListIndex;
      //��Ȼ��������ͨ�ĵ���IE�����˴���Ĵ�������������������ԭ�����б�ȡ��ʧ��
        end
        else
        begin
          if Pos('-', downurl) = 0 then
          begin //����������������վ���ˣ��޷�ȡ�ط������б���
            reg := TRegistry.Create;
            reg.RootKey := HKEY_CURRENT_USER;
            reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Internet Settings', True);
            if reg.ReadInteger('ProxyEnable') = 1 then
            begin
              Application.MessageBox('��IE���HTTP�������ô��ˣ�' + #13#10 +
                '�����Զ�����ȥ��HTTP�������ã�����������������', '�������������',
                MB_OK + MB_ICONINFORMATION);
              reg.WriteInteger('ProxyEnable', 0);
              Application.Terminate;
            end
            else
            begin
              OfflineServerlist;
            end;
            //reg.CloseKey;
            //reg.Free;
          end;
        end;
      end;
    end
    else
    begin
      reg := TRegistry.Create;
      reg.RootKey := HKEY_CURRENT_USER;
      reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Internet Settings', True);
      nEnable := reg.ReadInteger('ProxyEnable');
      reg.CloseKey;
      reg.Free;
      if nEnable = 1 then
      begin
        reg := TRegistry.Create;
        reg.RootKey := HKEY_CURRENT_USER;
        reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Internet Settings', True);
        regproxy := reg.ReadString('ProxyServer');
        s := split(regproxy, ':');
        regproxyaddress := LeftStr(regproxy, Pos(':', regproxy) - 1);
        p := strtoint(s[1]);
        reg.CloseKey;
        reg.Free;
        with Form1.idhtp1.ProxyParams do
        begin
          Form1.idhtp1.ProxyParams.ProxyServer := regproxyaddress;
          Form1.idhtp1.ProxyParams.ProxyPort := p;
          reg := TRegistry.Create;
          reg.RootKey := HKEY_CURRENT_USER;
          reg.OpenKey('Software\JFVPN\', True);
          if Reg.ReadString('ProxyUser') <> '' then
          begin
            with Form1.idhtp1.ProxyParams do
            begin
              Form1.idhtp1.ProxyParams.BasicAuthentication := True;
              Form1.idhtp1.ProxyParams.ProxyUsername := reg.ReadString('ProxyUser');
              Form1.idhtp1.ProxyParams.ProxyPassword := newbase64un(Reg.ReadString('ProxyPass'));
            end;
          end;
          reg.CloseKey;
          reg.Free;
        end;
        list := Tstringlist.Create;
        list.Delimiter := ' ';
        server1 := 'www.so169.com';
        server2 := '116.255.198.211';
        try
          downurl := Form1.idhtp1.Get(pchar('http://www.so169.com/check.php?server=2.8.4&lang=cn'));
        except
          server1 := '116.255.198.211';
          server2 := 'www.so169.com';
          try
            downurl := Form1.idhtp1.Get(pchar('http://116.255.198.211/check.php?server=2.8.4&lang=cn'));
          except
            Offlineserverlist;
            {Form2.Destroy;
            offlist := True;
            Exit;
            }
            fillform;
            Form2.Destroy;
            Exit;
          end;
        end;
        list.DelimitedText := downurl;
        Form1.ComboBox1.Items.Clear;
        if regproxy = '10.0.0.172:80' then
        begin
          cmwap := True;
          for i := 0 to list.Count - 1 do // Iterate
          begin
            enVPNName := LeftStr(list[i], Pos('-', list[i]) - 1);
            chVPNName := StringReplace(list[i], enVPNName + '-', '', []);
            Form1.ComboBox1.Items.Add(Utf8ToAnsi(chVPNName));
            form1.ComboBox2.Items.Add(enVPNName);
                    //ShowMessage(chVPNName);
                    //ShowMessage(enVPNName);
          end;
        end
        else
          if regproxy = '10.0.0.200:80' then
          begin
            cmwap := True;
            for i := 0 to list.Count - 1 do // Iterate
            begin
              enVPNName := LeftStr(list[i], Pos('-', list[i]) - 1);
              chVPNName := StringReplace(list[i], enVPNName + '-', '', []);
              Form1.ComboBox1.Items.Add(Utf8ToAnsi(chVPNName));
              form1.ComboBox2.Items.Add(enVPNName);
                    //ShowMessage(chVPNName);
                    //ShowMessage(enVPNName);
            end;
          end
          else
          begin
          // ѭ����StringList��ֵ���ӵ�ComboBox��
            for i := 0 to list.Count - 1 do // Iterate
            begin
              enVPNName := LeftStr(list[i], Pos('-', list[i]) - 1);
              chVPNName := StringReplace(list[i], enVPNName + '-', '', []);
              Form1.ComboBox1.Items.Add(chVPNName);
              form1.ComboBox2.Items.Add(enVPNName);
                    //ShowMessage(chVPNName);
                    //ShowMessage(enVPNName);
            end;
          end;
          // ComboBoxĬ����ʾ��һ�� \

        CheckServerListIndex;
        Form1.useie.Checked := True;
        //��������ͨ����IE�����˴���Ĵ�������������������ԭ�����б�ȡ��ʧ��
        if Pos('-', downurl) = 0 then
        begin
          OfflineServerlist;
        end;
      end
      else
      begin
        OfflineServerlist;
      end;
    end;

    fillform;

  end
  else
  begin
    Application.MessageBox('�ļ������������򽫻��˳���', '�������������', MB_OK +
      MB_ICONINFORMATION);
    application.Terminate;
  end;
  Form2.Destroy;
  //autoupdate;
end;

{ȡ��ҳ����}

function GetWebPage(const Url: string): string;
var
  Session,
    HttpFile: HINTERNET;
  szSizeBuffer: Pointer;
  dwLengthSizeBuffer: DWord;
  dwReserved: DWord;
  dwFileSize: DWord;
  dwBytesRead: DWord;
  Contents: PChar;
begin
  Session := InternetOpen('', 0, nil, nil, 0);
  HttpFile := InternetOpenUrl(Session, PChar(Url), nil, 0, 0, 0);
  dwLengthSizeBuffer := 1024;
  HttpQueryInfo(HttpFile, 5, szSizeBuffer, dwLengthSizeBuffer, dwReserved);
  GetMem(Contents, dwFileSize);
  InternetReadFile(HttpFile, Contents, dwFileSize, dwBytesRead);
  InternetCloseHandle(HttpFile);
  InternetCloseHandle(Session);
  Result := StrPas(Contents);
  FreeMem(Contents);
end;

{���÷���
procedure TForm1.FormCreate(Sender: TObject);
var
downurl:string;
begin
  downurl:=GetWebPage(pchar('http://' + server1 + '/check.php?server=2.8.4&lang=cn'));
end;
}


{���ҽ����Ƿ����}

function FindProcess(AFileName: string): boolean;
var
  hSnapshot: THandle; //���ڻ�ý����б�
  lppe: TProcessEntry32; //���ڲ��ҽ���
  Found: Boolean; //�����жϽ��̱����Ƿ����
  KillHandle: THandle; //����ɱ������
begin
  Result := False;
  hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0); //���ϵͳ�����б�
  lppe.dwSize := SizeOf(TProcessEntry32); //�ڵ���Process32First API֮ǰ����Ҫ��ʼ��lppe��¼�Ĵ�С
  Found := Process32First(hSnapshot, lppe); //�������б��ĵ�һ��������Ϣ����ppe��¼��
  while Found do
  begin
    if ((UpperCase(ExtractFileName(lppe.szExeFile)) = UpperCase(AFileName)) or (UpperCase(lppe.szExeFile) = UpperCase(AFileName))) then
    begin
      {if MsShow('���ִ�Excel,�Ƿ���ر�?',2)=6 then
      begin
      //�����ҵĲ���ϵͳ��xp�������ڵ���TerminateProcess API֮ǰ
      //�ұ����Ȼ�ùرս��̵�Ȩ��,�������ϵͳ��NT���¿���ֱ����ֹ����
      KillHandle := OpenProcess(PROCESS_TERMINATE, False, lppe.th32ProcessID);
      TerminateProcess(KillHandle, 0);//ǿ�ƹرս���
      CloseHandle(KillHandle);
      end;}
      Result := True;
    end;
    Found := Process32Next(hSnapshot, lppe); //�������б�����һ��������Ϣ����lppe��¼��
  end;
end;

procedure EndProcess(AFileName: string);
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapShotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  FSnapShotHandle := CreateToolhelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(AFileName)) or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(AFileName))) then
      TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), FProcessEntry32.th32ProcessID), 0);
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
end;


//�ַ������ܽ��ܲ���
const base64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';

function getint(const bcs, cs: integer): integer; //ȡ���ĺ��� �磺9/3=3,   8/3=2.66=3,     7/3=2.33=3
begin
  if (bcs mod cs) = 0 then
    result := bcs div cs
  else
    result := bcs div cs + 1;

end;

function newbase64(const s: string): string; // ���ַ�������ĺ���
var i, j: integer;
  ss, resu: string;
begin
  resu := '';
  for i := 0 to getint(length(s), 3) - 1 do
  begin
    ss := copy(s, i * 3 + 1, 3);
    j := length(ss);
    if j = 1 then ss := ss + '00';
    if j = 2 then ss := ss + '0';
    resu := resu + base64[(ord(ss[1]) and 192) shr 2 + (ord(ss[2]) and 192) shr 4 + (ord(ss[3]) shr 6) + 1]; //192�Ķ�����Ϊ11000000
    resu := resu + base64[(ord(ss[1]) and 48) + (ord(ss[2]) and 48) shr 2 + (ord(ss[3]) and 48) shr 4 + 1]; //48��                 00110000
    resu := resu + base64[(ord(ss[1]) and 12) shl 2 + (ord(ss[2]) and 12) + (ord(ss[3]) and 12) shr 2 + 1]; //12��                 00001100
    resu := resu + base64[(ord(ss[1]) and 3) shl 4 + (ord(ss[2]) and 3) shl 2 + (ord(ss[3]) and 3) + 1]; //3��                  00000011
  end;
  case j of
    1: result := resu + base64[65] + base64[65];
    2: result := resu + base64[65];
  else result := resu;
  end;
end;

function newbase64un(const s: string): string; // ���뺯��
var i, j: integer;
  ss, sss, resu: ansistring;
begin
  resu := '';
  ss := '';
  for i := 1 to length(s) do
  begin
    if ((pos(s[i], base64) < 1)) then begin messagebox(0, '���Ϸ���base64�ַ���', '����', mb_ok or mb_iconerror); exit; end;
    if pos(s[i], base64) <> 65 then
      ss := ss + s[i];
  end;
  j := length(ss);
  if (j mod 4) > 0 then begin messagebox(0, '���Ϸ���base64�ַ���', '����', mb_ok or mb_iconerror); exit; end;
  for I := 0 to j div 4 - 1 do
  begin
    sss := copy(ss, i * 4 + 1, 4);
    resu := resu + chr(((pos(sss[1], base64) - 1) and 48) shl 2 + (pos(sss[2], base64) - 1) and 48 +
      ((pos(sss[3], base64) - 1) and 48) shr 2 + ((pos(sss[4], base64) - 1) and 48) shr 4);
    resu := resu + chr(((pos(sss[1], base64) - 1) and 12) shl 4 + ((pos(sss[2], base64) - 1) and 12) shl 2 +
      (pos(sss[3], base64) - 1) and 12 + ((pos(sss[4], base64) - 1) and 12) shr 2);
    resu := resu + chr(((pos(sss[1], base64) - 1) and 3) shl 6 + ((pos(sss[2], base64) - 1) and 3) shl 4 +
      ((pos(sss[3], base64) - 1) and 3) shl 2 + (pos(sss[4], base64) - 1) and 3);
  end;
  result := copy(resu, 1, length(resu) - length(s) + j);
end;
//�ַ������ܽ��ܲ���



procedure OfflineServerlist;
begin
  Form1.ComboBox1.Items.Add('������1(�����)');
  Form1.ComboBox1.Items.Add('������2(�����)');
  Form1.ComboBox1.Items.Add('������3(�����)');
  Form1.ComboBox1.Items.Add('������4(�����)');
  Form1.ComboBox1.Items.Add('����˫����·1');
  Form1.ComboBox1.Items.Add('����˫����·2');
  Form1.ComboBox1.Items.Add('������ͨ��·1');
  Form1.ComboBox1.Items.Add('������ͨ��·2');
  Form1.ComboBox1.Items.Add('������ͨ��·3');
  form1.ComboBox2.Items.Add('221.123.162.106');
  form1.ComboBox2.Items.Add('221.123.133.237');
  form1.ComboBox2.Items.Add('221.123.143.108');
  form1.ComboBox2.Items.Add('106.2.191.102');
  form1.ComboBox2.Items.Add('221.123.162.118');
  form1.ComboBox2.Items.Add('221.123.143.61');
  form1.ComboBox2.Items.Add('ros.mrface.com');
  form1.ComboBox2.Items.Add('ditan.mrface.com');
  form1.ComboBox2.Items.Add('marcozy.mrface.com');
  CheckServerListIndex;
  offline := True;
end;

function checkedit: Boolean;
begin
  Uname := Form1.Edit1.Text;
  Pword := Form1.Edit2.Text;
  server := Form1.ComboBox2.Text;
  if (Uname = '') or (Uname = '�����û���') then
  begin
    Application.MessageBox('��û�������û�����', '�������������', MB_OK +
      MB_ICONINFORMATION);
    Result := True
  end
  else
  begin
    if (Pword = '') or (Pword = '��������') then
    begin
      Application.MessageBox('��û���������룡', '�������������', MB_OK +
        MB_ICONINFORMATION);
      Result := True
    end
    else
    begin
      if Form1.httpproxy.Checked = True then
      begin
        if Form1.chk1.Checked = True then
        begin
          if (Form1.proxyadd.Text = '') or (Form1.proxyadd.Text = '������������ַ') then
          begin
            Application.MessageBox('��û�����������������ַ��', '�������������', MB_OK +
              MB_ICONINFORMATION);
            Result := True
          end
          else
          begin
            if (Form1.proxyport.text = '') or (Form1.proxyport.text = '�����˿�') then
            begin
              Application.MessageBox('��û����������������˿ڣ�', '�������������', MB_OK +
                MB_ICONINFORMATION);
              Result := True
            end
            else
            begin
              if (Form1.puser.Text = '') or (Form1.puser.Text = '�����û���') then
              begin
                Application.MessageBox('��û����������������û�����', '�������������', MB_OK +
                  MB_ICONINFORMATION);
                Result := True
              end
              else
              begin
                if (Form1.ppass.Text = '') or (Form1.ppass.Text = '��������') then
                begin
                  Application.MessageBox('��û������������������룡', '�������������', MB_OK +
                    MB_ICONINFORMATION);
                  Result := True
                end
                else
                begin
                  Result := False;
                end;
              end;
            end;
          end;
        end
        else
        begin
          if (Form1.proxyadd.Text = '') or (Form1.proxyadd.Text = '������������ַ') then
          begin
            Application.MessageBox('��û�����������������ַ��', '�������������', MB_OK +
              MB_ICONINFORMATION);
            Result := True
          end
          else
          begin
            if (Form1.proxyport.text = '') or (Form1.proxyport.text = '�����˿�') then
            begin
              Application.MessageBox('��û����������������˿ڣ�', '�������������', MB_OK +
                MB_ICONINFORMATION);
              Result := True
            end
            else
            begin
              Result := False;
            end;
          end;
        end;
      end
      else
        if Form1.Socksproxy.Checked = True then
        begin
          if (Form1.proxyadd.Text = '') or (Form1.proxyadd.Text = '������������ַ') then
          begin
            Application.MessageBox('��û�����������������ַ��', '�������������', MB_OK +
              MB_ICONINFORMATION);
            Result := True
          end
          else
          begin
            if (Form1.proxyport.text = '') or (Form1.proxyport.text = '�����˿�') then
            begin
              Application.MessageBox('��û����������������˿ڣ�', '�������������', MB_OK +
                MB_ICONINFORMATION);
              Result := True
            end
            else
            begin
              Result := False;
            end;
          end;
        end
        else
        begin
          Result := False;
        end;
    end;
  end;
end;


procedure repairnet;
begin
  WinExec('ipconfig.exe /release', SW_HIDE);
  WinExec('ipconfig.exe /renew', SW_HIDE);
  WinExec('ipconfig.exe /registerdns', SW_HIDE);
  WinExec('arp -d', SW_HIDE);
  WinExec('nbtstat -R', SW_HIDE);
  WinExec('nbtstat -RR', SW_HIDE);
  WinExec('nbtstat -RR', SW_HIDE);
  WinExec('ipconfig.exe /flushdns', SW_HIDE);
  WinExec('ipconfig.exe /renew', SW_HIDE);
end;
//ȡ��·�ɱ����ֿ�ʼ
//ȡ��·�ɱ����ֽ���

procedure checkprocess;
var
  errno: integer;
  hmutex: hwnd;
begin
    //changehosts;
  //�������Ƿ��ظ�������ʼ
  hmutex := createmutex(nil, false, pchar(application.Title));
  errno := getlasterror;
  if errno = error_already_exists then
  begin
    Application.MessageBox('��������������ͻ����Ѿ��������ˣ�', '���������', MB_OK +
      MB_ICONINFORMATION);
    Application.Terminate;
  end
  else
    if Findprocess('node32.exe') then
    begin
      Application.MessageBox('����node32�����У�node32����ɼ������Ӻ��޷�ʹ�ã����˳�node32��������м��磡', '���������', MB_OK +
        MB_ICONINFORMATION);
      Application.Terminate;

    end
    else
      if Findprocess('openvpn.exe') then
      begin
        if Application.MessageBox('��������openvpn���̣��Ƿ�ǿ���˳���', '�������������',
          MB_YESNO + MB_ICONQUESTION) = IDYES then
        begin
          EndProcess('openvpn.exe');
          repairnet;
        end
        else
        begin
          Application.MessageBox('���������汾��openvpn�������У�������������������Զ��˳���', '���������PNPN', MB_OK +
            MB_ICONINFORMATION);
          Application.Terminate;
        end;
      end
      else
        if Findprocess('tapinstall.exe') or FindProcess('devcon.exe') then
        begin
          Application.MessageBox('����������δ��װ��ϣ���ȴ���װ��������������������', '�������������', MB_OK +
            MB_ICONINFORMATION);
          Application.Terminate;
        end
        else
          if Findprocess('xlacc.exe') then
          begin
            Application.MessageBox('Ѹ�λ�Ӱ�켲�������������', '�������������', MB_OK +
              MB_ICONINFORMATION);
            Application.Terminate;
          end;
end;


function GetFileVersion(const AFileName: string): Cardinal;
var
  FileName: string;
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  FI: PVSFixedFileInfo;
  VerSize: DWORD;
begin
  Result := Cardinal(-1);
// GetFileVersionInfo modifies the filename parameter data while parsing.
// Copy the string const into a local variable to create a writeable copy.
  FileName := AFileName;
  UniqueString(FileName);
  InfoSize := GetFileVersionInfoSize(PChar(FileName), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(FileName), Wnd, InfoSize, VerBuf) then
        if VerQueryValue(VerBuf, '\', Pointer(FI), VerSize) then
          Result := FI.dwFileVersionMS;
    finally
      FreeMem(VerBuf);
    end;
  end;
end;


{
//��ȡ��ǰ�ļ��İ汾�� GetFileVersion
var
s: string;
i: Integer;
begin
s := "'ExtractFilePath(Application.ExeName)+'�������������.exe'";
i := GetFileVersion(s); //���û�а汾�ŷ��� -1
ShowMessage(IntToStr(i)); //327681 ���ǵ�ǰ���±��İ汾��(��Ӧ����ת��һ��)
end;
}



{
procedure autoupdate;
var
  s: string;
  i: Integer;
  DownLoadFile: TFileStream;
begin
  if offline = True then
  begin

  end
  else
  begin
    try
      version := Form1.idhtp1.Get(pchar('http://www.so169.com/update.php'));
    except
      try
        version := Form1.idhtp1.Get(pchar('http://116.255.198.211/update.php'));
      except
        Application.MessageBox('�Զ���������ļ�ʧ�ܣ�',
          '�������������', MB_OK + MB_ICONWARNING);
        update := True;
        Exit;
      end;
    end;

    if update = True then
    begin
      Form1.idhtp1.ProxyParams.ProxyServer := '';
      Form1.idhtp1.ProxyParams.ProxyPort := 0;
    end;

    if FileExists(ExtractFilePath(Application.ExeName) + 'Project1.exe') then
    begin
      s := ExtractFilePath(Application.ExeName) + 'Project1.exe';
    end;

    if FileExists(ExtractFilePath(Application.ExeName) + '�������������.exe') then
    begin
      s := ExtractFilePath(Application.ExeName) + '�������������.exe';
    end;

    i := GetFileVersion(s); //���û�а汾�ŷ��� -1
  //ShowMessage(IntToStr(i)); //327681 ���ǵ�ǰ���±��İ汾��(��Ӧ����ת��һ��)
  //ShowMessage(updateaddress);
  //ShowMessage(IntToStr(i));    //���������������ǰ�汾131073
    if i <> -1 then
    begin
    //ShowMessage(IntToStr(i));
      if i < StrToInt(version) then
      begin
        case
          Application.MessageBox('��⵽���°汾��Ϊ�˲�Ӱ��ʹ�ã�����������Ҫ�����ˣ��Ƿ�����������',
          '����OpenVPN', MB_OKCANCEL + MB_ICONWARNING) of
          IDOK:
            begin
              if FileExists(PChar(ExtractFilePath(Application.ExeName)) + 'update.exe') and FileExists(PChar(ExtractFilePath(Application.ExeName)) + 'newversion.exe') then
              begin
                Application.MessageBox('ִ���������򣬼���������������Զ��رգ�',
                  '�������������', MB_OK + MB_ICONINFORMATION);
                ShellExecute(0, 'open', 'update.exe', '', '', SW_SHOW);
                Application.Terminate;
              end
              else
              begin
                DownLoadFile := TFileStream.Create(PChar(ExtractFilePath(Application.ExeName)) + 'update.exe', fmCreate);
                try
                  Form1.idhtp1.Get('http://www.so169.com/update.exe', DownLoadFile);
                except
                  try
                    Form1.idhtp1.Get('http://116.255.198.211/update.exe', DownLoadFile);
                  except
                    Application.MessageBox('�Զ������ļ�����ʧ�ܣ�', '�������������', MB_OK
                      + MB_ICONINFORMATION);
                  end;
                end;
                DownLoadFile.Free;

                DownLoadFile := TFileStream.Create(PChar(ExtractFilePath(Application.ExeName)) + 'newversion.exe', fmCreate);
                try
                  Form1.idhtp1.Get('http://www.so169.com/newversion.exe', DownLoadFile);
                except
                  try
                    Form1.idhtp1.Get('http://116.255.198.211/newversion.exe', DownLoadFile);
                  except
                    Application.MessageBox('�Զ������ļ�����ʧ�ܣ�', '�������������', MB_OK
                      + MB_ICONINFORMATION);
                  end;
                end;
                DownLoadFile.Free;

                if FileExists(PChar(ExtractFilePath(Application.ExeName)) + 'update.exe') and FileExists(PChar(ExtractFilePath(Application.ExeName)) + 'newversion.exe') then
                begin
                  cvpn;
                  ShellExecute(0, 'open', 'update.exe', '', '', SW_SHOW);
                  Application.Terminate;
                end;

              end;
            end;
          IDCANCEL:
            begin

            end;
        end;
      end
      else
        if i = StrToInt(version) then
        begin
          DeleteFile(PChar(ExtractFilePath(Application.ExeName)) + 'update.exe');
          DeleteFile(PChar(ExtractFilePath(Application.ExeName)) + 'newversion.exe');
        end;
    end
    else
    begin
      Application.MessageBox('�޷���ȷ��ȡ�ļ��汾�ţ�',
        '�������������', MB_OK + MB_ICONWARNING);
    end;
  end;
end;
}

procedure CheckServerListIndex;

begin
        //��ס�û����һ��ʹ�õķ������б�
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CURRENT_USER;
  reg.OpenKey('Software\JFVPN\', True);
  if reg.ReadString('ListIndex') <> '' then
  begin
    if reg.ReadString('ListIndex') <= IntToStr(Form1.ComboBox1.Items.Count) then
    begin
      Form1.ComboBox1.ItemIndex := StrToInt(reg.ReadString('ListIndex'));
      Form1.ComboBox2.ItemIndex := StrToInt(reg.ReadString('ListIndex'));
    end
    else
    begin
      Form1.ComboBox1.ItemIndex := 0;
      Form1.ComboBox2.ItemIndex := 0;
    end;
  end
  else
  begin
    Form1.ComboBox1.ItemIndex := 0;
    Form1.ComboBox2.ItemIndex := 0;
  end;
  reg.CloseKey;
  reg.Free;
end;


procedure changeroutefail;
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CURRENT_USER;
  reg.OpenKey('Software\JFVPN\', True);

  if reg.ValueExists('NIC') = True then
  begin
    if reg.ReadString('NIC') = '1' then
    begin
      // do nothing
    end
    else
    begin
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
  end
  else
  begin
    if RunningInWow64 then
    begin
      formload.extrafiles64;
    end
    else
    begin
      formload.extrafiles32;
    end;
    //uninstall nic
    winexec(PChar('tapinstall.exe remove tap0901'), SW_HIDE);
  end;

  if reg.ValueExists('RouteType') = True then
  begin
    //ShowMessage('��ֵ����');
    if reg.ReadString('RouteType') = '1' then
    begin
      goodroute := False;
    end;
    if reg.ReadString('RouteType') = '0' then
    begin
      goodroute := True;
    end
    else
    begin
      goodroute := True;
    end;
  end
  else
  begin
    //ShowMessage('��ֵ������');
    goodroute := True;
  end;
  reg.CloseKey;
  reg.Free;
end;

function ExtractRes(ResName, ResType, ResNewName: string): boolean;
var
  Res: TResourceStream;
begin
  try
    Res := TResourceStream.Create(Hinstance, Resname, Pchar(ResType));
    try
      Res.SavetoFile(ResNewName);
      Result := true;
    finally
      Res.Free;
    end;
  except
    Result := false;
  end;
end;



procedure extrafiles;
begin
  ExtractRes('tcping', 'exe', PChar(ExtractFilePath(Application.ExeName) + 'tcping.exe'));
  Filesetattr('tcping.exe', FAHIDDEN);
  ExtractRes('openvpn', 'exe', PChar(ExtractFilePath(Application.ExeName) + 'openvpn.exe'));
  Filesetattr('openvpn.exe', FAHIDDEN);
  ExtractRes('ssl', 'exe', PChar(ExtractFilePath(Application.ExeName) + 'ssl.ocx'));
  Filesetattr('ssl.ocx', FAHIDDEN);
  ExtractRes('UtilDll', 'exe', PChar(ExtractFilePath(Application.ExeName) + 'UtilDll.dll'));
  Filesetattr('UtilDll.dll', FAHIDDEN);
end;

procedure extrafiles32;
begin
  ExtractRes('32OemWin2k', 'exe', PChar(ExtractFilePath(Application.ExeName) + 'OemWin2k.inf'));
  Filesetattr('OemWin2k.inf', FAHIDDEN);
  ExtractRes('32tap0901cat', 'exe', PChar(ExtractFilePath(Application.ExeName) + 'tap0901.cat'));
  Filesetattr('tap0901.cat', FAHIDDEN);
  ExtractRes('32tap0901sys', 'exe', PChar(ExtractFilePath(Application.ExeName) + 'tap0901.sys'));
  Filesetattr('tap0901.sys', FAHIDDEN);
  ExtractRes('32tapinstall', 'exe', PChar(ExtractFilePath(Application.ExeName) + 'tapinstall.exe'));
  Filesetattr('tapinstall.exe', FAHIDDEN);
end;

procedure extrafiles64;
begin
  ExtractRes('64OemWin2k', 'exe', PChar(ExtractFilePath(Application.ExeName) + 'OemWin2k.inf'));
  Filesetattr('OemWin2k.inf', FAHIDDEN);
  ExtractRes('64tap0901cat', 'exe', PChar(ExtractFilePath(Application.ExeName) + 'tap0901.cat'));
  Filesetattr('tap0901.cat', FAHIDDEN);
  ExtractRes('64tap0901sys', 'exe', PChar(ExtractFilePath(Application.ExeName) + 'tap0901.sys'));
  Filesetattr('tap0901.sys', FAHIDDEN);
  ExtractRes('64tapinstall', 'exe', PChar(ExtractFilePath(Application.ExeName) + 'tapinstall.exe'));
  Filesetattr('tapinstall.exe', FAHIDDEN);
end;

procedure extrafilestunnle;
begin
  ExtractRes('srvp', 'exe', PChar(ExtractFilePath(Application.ExeName) + 'srvp.exe'));
  Filesetattr('srvp.exe', FAHIDDEN);
end;

procedure fillform;
begin

  reg := TRegistry.Create;
  reg.RootKey := HKEY_CURRENT_USER;
  Reg.OpenKey('\Software\JFVPN', True);

  if reg.ReadString('NTLM') = '1' then
  begin
    Form1.httpproxy.Checked := True;
    Form1.chk2.Checked := True;
    Form1.chk1.Checked := True;
    Form1.proxyadd.Text := reg.ReadString('ProxyAddr');
    Form1.proxyport.Text := reg.ReadString('ProxyPort');
    Form1.puser.Text := reg.ReadString('ProxyUser');
    Form1.ppass.Text := newbase64un(reg.ReadString('ProxyPass'));
    Form1.ppass.PasswordChar := '*';
  end
  else
    if nEnable <> 1 then
    begin

      if reg.ReadString('Proxy') <> '' then
      begin
        if reg.ReadString('Proxy') = 'HTTP' then
        begin
          if reg.ReadString('ProxyUser') <> '' then
          begin
            Form1.httpproxy.Checked := True;
            Form1.chk1.Checked := True;
            Form1.proxyadd.Text := reg.ReadString('ProxyAddr');
            Form1.proxyport.Text := reg.ReadString('ProxyPort');
            Form1.puser.Text := reg.ReadString('ProxyUser');
            Form1.ppass.Text := newbase64un(reg.ReadString('ProxyPass'));
            Form1.ppass.PasswordChar := '*';
            Form1.Edit1.Text := reg.ReadString('User');
            Form1.Edit2.Text := newbase64un(reg.ReadString('Pass'));
            Form1.Edit2.PasswordChar := '*';
            Form1.CheckBox1.Checked := True;
          end
          else
          begin
            if reg.ReadString('ProxyAddr') <> '' then
            begin
              Form1.httpproxy.Checked := True;
              Form1.proxyadd.Text := reg.ReadString('ProxyAddr');
              Form1.proxyport.Text := reg.ReadString('ProxyPort');
              Form1.Edit1.Text := reg.ReadString('User');
              Form1.Edit2.Text := newbase64un(reg.ReadString('Pass'));
              Form1.Edit2.PasswordChar := '*';
              Form1.CheckBox1.Checked := True;
            end
            else
            begin
              Form1.Edit1.Text := reg.ReadString('User');
              Form1.Edit2.Text := newbase64un(reg.ReadString('Pass'));
              Form1.Edit2.PasswordChar := '*';
              Form1.CheckBox1.Checked := True;
              //Form1.useie.Checked := True;
            end;
          end;
        end
        else
          if reg.ReadString('Proxy') = 'Socks' then
          begin
            Form1.proxyadd.Text := reg.ReadString('ProxyAddr');
            Form1.proxyport.Text := reg.ReadString('ProxyPort');
            Form1.Socksproxy.Checked := True;
            Form1.Edit1.Text := reg.ReadString('User');
            Form1.Edit2.Text := newbase64un(reg.ReadString('Pass'));
            Form1.Edit2.PasswordChar := '*';
            Form1.CheckBox1.Checked := True;
          end;

      end
      else
      begin //proxy = ''
        if reg.ReadString('User') <> '' then
        begin
          Form1.noproxy.Checked := True;
          Form1.Edit1.Text := reg.ReadString('User');
          Form1.Edit2.Text := newbase64un(reg.ReadString('Pass'));
          Form1.Edit2.PasswordChar := '*';
          Form1.CheckBox1.Checked := True;
        end;
      end;

    end
    else //���IEʹ�ô���������
    begin
      if reg.ReadString('ProxyUser') <> '' then
      begin
        Form1.httpproxy.Checked := True;
        Form1.chk1.Checked := True;
        Form1.proxyadd.Text := reg.ReadString('ProxyAddr');
        Form1.proxyport.Text := reg.ReadString('ProxyPort');
        Form1.puser.Text := reg.ReadString('ProxyUser');
        Form1.ppass.Text := newbase64un(reg.ReadString('ProxyPass'));
        Form1.ppass.PasswordChar := '*';
        Form1.Edit1.Text := reg.ReadString('User');
        Form1.Edit2.Text := newbase64un(reg.ReadString('Pass'));
        Form1.Edit2.PasswordChar := '*';
        Form1.CheckBox1.Checked := True;
      end
      else
        if reg.ReadString('User') <> '' then
        begin
          Form1.Edit1.Text := reg.ReadString('User');
          Form1.Edit2.Text := newbase64un(reg.ReadString('Pass'));
          Form1.Edit2.PasswordChar := '*';
          Form1.CheckBox1.Checked := True;
          Form1.useie.Checked := True;
        end;
    end;
  //reg.CloseKey;
  //reg.Free;

end;

end.
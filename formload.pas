unit formload;

interface
uses
  Windows, Messages, SysUtils, Forms, ExtCtrls, Dialogs, WinInet, Winsock, Classes, StrUtils, TLHelp32, Controls, Registry,
  IpExport, IpHlpApi, IpIfConst, IpRtrMib, IpTypes, IpFunctions, ShellAPI;

//取网关函数开始
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
//取网关函数结束


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

//取网关函数开始

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
//网卡地址：
  memo1.Lines.Add('Adapter address: ' + MACToStr(@Work^.Address, Work^.AddressLength));
  repeat
//本机IP地址：
    memo1.Lines.add('IP addresses: ' + GetAddrString(@Work^.IPAddressList));
//网关地址：
    gatewaystr := work^.GatewayList.IPAddress;
    memo1.Lines.Add('gateway address:' + gatewaystr);
    work := work^.Next;
  until (work = nil);
end;
}



//取网关函数结束

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


{调用如下：
procedure TForm1.Button1Click(Sender: TObject);
begin
if CheckInternetOnline = true then
showmessage('online')
else
showmessage('error');
end;
}

{检测端口是否占用}

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


{管道技术取DOS窗口内容}

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

{调用
var
  s :string;
begin
  GetDosRes('Ping www.baidu.com',s);
  showmessage(s);
end;
}

{判断是否64位操作系统}

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
  //取网关开始
  AI, Work: PIPAdapterInfo;
  Size: Integer;
  Res: Integer;
  //取网关结束
begin
//取网关开始
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
  //取网关结束
end;

{检查是否重复启动程序；添加在线服务器列表}

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
          // 循环将StringList中值添加到ComboBox中
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
      //虽然互联网是通的但是IE设置了错误的代理服务器，或者其他原因导致列表取回失败
        end
        else
        begin
          if Pos('-', downurl) = 0 then
          begin //下面继续分析如果网站坏了，无法取回服务器列表。
            reg := TRegistry.Create;
            reg.RootKey := HKEY_CURRENT_USER;
            reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Internet Settings', True);
            if reg.ReadInteger('ProxyEnable') = 1 then
            begin
              Application.MessageBox('你IE里的HTTP代理设置错了！' + #13#10 +
                '程序将自动帮你去掉HTTP代理设置，请重新运行软件！', '疾风网络加速器',
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
          // 循环将StringList中值添加到ComboBox中
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
          // ComboBox默认显示第一项 \

        CheckServerListIndex;
        Form1.useie.Checked := True;
        //互联网不通但是IE设置了错误的代理服务器，或者其他原因导致列表取回失败
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
    Application.MessageBox('文件不完整，程序将会退出！', '疾风网络加速器', MB_OK +
      MB_ICONINFORMATION);
    application.Terminate;
  end;
  Form2.Destroy;
  //autoupdate;
end;

{取网页内容}

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

{调用方法
procedure TForm1.FormCreate(Sender: TObject);
var
downurl:string;
begin
  downurl:=GetWebPage(pchar('http://' + server1 + '/check.php?server=2.8.4&lang=cn'));
end;
}


{查找进程是否存在}

function FindProcess(AFileName: string): boolean;
var
  hSnapshot: THandle; //用于获得进程列表
  lppe: TProcessEntry32; //用于查找进程
  Found: Boolean; //用于判断进程遍历是否完成
  KillHandle: THandle; //用于杀死进程
begin
  Result := False;
  hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0); //获得系统进程列表
  lppe.dwSize := SizeOf(TProcessEntry32); //在调用Process32First API之前，需要初始化lppe记录的大小
  Found := Process32First(hSnapshot, lppe); //将进程列表的第一个进程信息读入ppe记录中
  while Found do
  begin
    if ((UpperCase(ExtractFileName(lppe.szExeFile)) = UpperCase(AFileName)) or (UpperCase(lppe.szExeFile) = UpperCase(AFileName))) then
    begin
      {if MsShow('发现打开Excel,是否将其关闭?',2)=6 then
      begin
      //由于我的操作系统是xp，所以在调用TerminateProcess API之前
      //我必须先获得关闭进程的权限,如果操作系统是NT以下可以直接中止进程
      KillHandle := OpenProcess(PROCESS_TERMINATE, False, lppe.th32ProcessID);
      TerminateProcess(KillHandle, 0);//强制关闭进程
      CloseHandle(KillHandle);
      end;}
      Result := True;
    end;
    Found := Process32Next(hSnapshot, lppe); //将进程列表的下一个进程信息读入lppe记录中
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


//字符串加密解密部分
const base64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';

function getint(const bcs, cs: integer): integer; //取整的函数 如：9/3=3,   8/3=2.66=3,     7/3=2.33=3
begin
  if (bcs mod cs) = 0 then
    result := bcs div cs
  else
    result := bcs div cs + 1;

end;

function newbase64(const s: string): string; // 对字符串编码的函数
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
    resu := resu + base64[(ord(ss[1]) and 192) shr 2 + (ord(ss[2]) and 192) shr 4 + (ord(ss[3]) shr 6) + 1]; //192的二进制为11000000
    resu := resu + base64[(ord(ss[1]) and 48) + (ord(ss[2]) and 48) shr 2 + (ord(ss[3]) and 48) shr 4 + 1]; //48的                 00110000
    resu := resu + base64[(ord(ss[1]) and 12) shl 2 + (ord(ss[2]) and 12) + (ord(ss[3]) and 12) shr 2 + 1]; //12的                 00001100
    resu := resu + base64[(ord(ss[1]) and 3) shl 4 + (ord(ss[2]) and 3) shl 2 + (ord(ss[3]) and 3) + 1]; //3的                  00000011
  end;
  case j of
    1: result := resu + base64[65] + base64[65];
    2: result := resu + base64[65];
  else result := resu;
  end;
end;

function newbase64un(const s: string): string; // 解码函数
var i, j: integer;
  ss, sss, resu: ansistring;
begin
  resu := '';
  ss := '';
  for i := 1 to length(s) do
  begin
    if ((pos(s[i], base64) < 1)) then begin messagebox(0, '不合法的base64字符串', '错误', mb_ok or mb_iconerror); exit; end;
    if pos(s[i], base64) <> 65 then
      ss := ss + s[i];
  end;
  j := length(ss);
  if (j mod 4) > 0 then begin messagebox(0, '不合法的base64字符串', '错误', mb_ok or mb_iconerror); exit; end;
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
//字符串加密解密部分



procedure OfflineServerlist;
begin
  Form1.ComboBox1.Items.Add('国内线1(非免费)');
  Form1.ComboBox1.Items.Add('国内线2(非免费)');
  Form1.ComboBox1.Items.Add('国内线3(非免费)');
  Form1.ComboBox1.Items.Add('国内线4(非免费)');
  Form1.ComboBox1.Items.Add('国内双线线路1');
  Form1.ComboBox1.Items.Add('国内双线线路2');
  Form1.ComboBox1.Items.Add('国内网通线路1');
  Form1.ComboBox1.Items.Add('国内网通线路2');
  Form1.ComboBox1.Items.Add('国内网通线路3');
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
  if (Uname = '') or (Uname = '输入用户名') then
  begin
    Application.MessageBox('您没有输入用户名！', '疾风网络加速器', MB_OK +
      MB_ICONINFORMATION);
    Result := True
  end
  else
  begin
    if (Pword = '') or (Pword = '输入密码') then
    begin
      Application.MessageBox('您没有输入密码！', '疾风网络加速器', MB_OK +
        MB_ICONINFORMATION);
      Result := True
    end
    else
    begin
      if Form1.httpproxy.Checked = True then
      begin
        if Form1.chk1.Checked = True then
        begin
          if (Form1.proxyadd.Text = '') or (Form1.proxyadd.Text = '代理服务器地址') then
          begin
            Application.MessageBox('您没有输入代理服务器地址！', '疾风网络加速器', MB_OK +
              MB_ICONINFORMATION);
            Result := True
          end
          else
          begin
            if (Form1.proxyport.text = '') or (Form1.proxyport.text = '代理端口') then
            begin
              Application.MessageBox('您没有输入代理服务器端口！', '疾风网络加速器', MB_OK +
                MB_ICONINFORMATION);
              Result := True
            end
            else
            begin
              if (Form1.puser.Text = '') or (Form1.puser.Text = '代理用户名') then
              begin
                Application.MessageBox('您没有输入代理服务器用户名！', '疾风网络加速器', MB_OK +
                  MB_ICONINFORMATION);
                Result := True
              end
              else
              begin
                if (Form1.ppass.Text = '') or (Form1.ppass.Text = '代理密码') then
                begin
                  Application.MessageBox('您没有输入代理服务器密码！', '疾风网络加速器', MB_OK +
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
          if (Form1.proxyadd.Text = '') or (Form1.proxyadd.Text = '代理服务器地址') then
          begin
            Application.MessageBox('您没有输入代理服务器地址！', '疾风网络加速器', MB_OK +
              MB_ICONINFORMATION);
            Result := True
          end
          else
          begin
            if (Form1.proxyport.text = '') or (Form1.proxyport.text = '代理端口') then
            begin
              Application.MessageBox('您没有输入代理服务器端口！', '疾风网络加速器', MB_OK +
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
          if (Form1.proxyadd.Text = '') or (Form1.proxyadd.Text = '代理服务器地址') then
          begin
            Application.MessageBox('您没有输入代理服务器地址！', '疾风网络加速器', MB_OK +
              MB_ICONINFORMATION);
            Result := True
          end
          else
          begin
            if (Form1.proxyport.text = '') or (Form1.proxyport.text = '代理端口') then
            begin
              Application.MessageBox('您没有输入代理服务器端口！', '疾风网络加速器', MB_OK +
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
//取得路由表部分开始
//取得路由表部分结束

procedure checkprocess;
var
  errno: integer;
  hmutex: hwnd;
begin
    //changehosts;
  //检查程序是否重复启动开始
  hmutex := createmutex(nil, false, pchar(application.Title));
  errno := getlasterror;
  if errno = error_already_exists then
  begin
    Application.MessageBox('疾风网络加速器客户端已经在运行了！', '网络加速器', MB_OK +
      MB_ICONINFORMATION);
    Application.Terminate;
  end
  else
    if Findprocess('node32.exe') then
    begin
      Application.MessageBox('发现node32在运行，node32会造成疾风连接后无法使用，请退出node32后继续运行疾风！', '网络加速器', MB_OK +
        MB_ICONINFORMATION);
      Application.Terminate;

    end
    else
      if Findprocess('openvpn.exe') then
      begin
        if Application.MessageBox('发现其他openvpn进程，是否强制退出？', '疾风网络加速器',
          MB_YESNO + MB_ICONQUESTION) = IDYES then
        begin
          EndProcess('openvpn.exe');
          repairnet;
        end
        else
        begin
          Application.MessageBox('发现其他版本的openvpn正在运行，疾风网络加速器将会自动退出！', '网络加速器PNPN', MB_OK +
            MB_ICONINFORMATION);
          Application.Terminate;
        end;
      end
      else
        if Findprocess('tapinstall.exe') or FindProcess('devcon.exe') then
        begin
          Application.MessageBox('虚拟网卡还未安装完毕，请等待安装完毕再运行网络加速器！', '疾风网络加速器', MB_OK +
            MB_ICONINFORMATION);
          Application.Terminate;
        end
        else
          if Findprocess('xlacc.exe') then
          begin
            Application.MessageBox('迅游会影响疾风网络加速器！', '疾风网络加速器', MB_OK +
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
//获取当前文件的版本号 GetFileVersion
var
s: string;
i: Integer;
begin
s := "'ExtractFilePath(Application.ExeName)+'疾风网络加速器.exe'";
i := GetFileVersion(s); //如果没有版本号返回 -1
ShowMessage(IntToStr(i)); //327681 这是当前记事本的版本号(还应该再转换一下)
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
        Application.MessageBox('自动检测升级文件失败！',
          '疾风网络加速器', MB_OK + MB_ICONWARNING);
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

    if FileExists(ExtractFilePath(Application.ExeName) + '疾风网络加速器.exe') then
    begin
      s := ExtractFilePath(Application.ExeName) + '疾风网络加速器.exe';
    end;

    i := GetFileVersion(s); //如果没有版本号返回 -1
  //ShowMessage(IntToStr(i)); //327681 这是当前记事本的版本号(还应该再转换一下)
  //ShowMessage(updateaddress);
  //ShowMessage(IntToStr(i));    //疾风网络加速器当前版本131073
    if i <> -1 then
    begin
    //ShowMessage(IntToStr(i));
      if i < StrToInt(version) then
      begin
        case
          Application.MessageBox('检测到有新版本，为了不影响使用，您的软件需要升级了！是否现在升级？',
          '疾风OpenVPN', MB_OKCANCEL + MB_ICONWARNING) of
          IDOK:
            begin
              if FileExists(PChar(ExtractFilePath(Application.ExeName)) + 'update.exe') and FileExists(PChar(ExtractFilePath(Application.ExeName)) + 'newversion.exe') then
              begin
                Application.MessageBox('执行升级程序，疾风网络加速器将自动关闭！',
                  '疾风网络加速器', MB_OK + MB_ICONINFORMATION);
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
                    Application.MessageBox('自动升级文件下载失败！', '疾风网络加速器', MB_OK
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
                    Application.MessageBox('自动升级文件下载失败！', '疾风网络加速器', MB_OK
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
      Application.MessageBox('无法正确读取文件版本号！',
        '疾风网络加速器', MB_OK + MB_ICONWARNING);
    end;
  end;
end;
}

procedure CheckServerListIndex;

begin
        //记住用户最近一次使用的服务器列表
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
    //ShowMessage('键值存在');
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
    //ShowMessage('键值不存在');
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
    else //如果IE使用代理服务器
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

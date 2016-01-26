unit DialVpn;

interface

uses
  Windows, SysUtils, Forms, DialUp;

type
  GUID = record
    Data1: Integer;
    Data2: ShortInt;
    Data3: ShortInt;
    Data4: array[0..7] of Byte;
  end;

  TRasIPAddr = record
    a: byte;
    b: byte;
    c: byte;
    d: byte;
  end;

  TRasEntry = record
    dwSize,
      dwfOptions,
      dwCountryID,
      dwCountryCode: Longint;
    szAreaCode: array[0..10] of Byte;
    szLocalPhoneNumber: array[0..128] of Byte;
    dwAlternatesOffset: Longint;
    ipaddr,
      ipaddrDns,
      ipaddrDnsAlt,
      ipaddrWins,
      ipaddrWinsAlt: TRasIPAddr;
    dwFrameSize,
      dwfNetProtocols,
      dwFramingProtocol: Longint;
    szScript: array[0..259] of Byte;
    szAutodialDll: array[0..259] of Byte;
    szAutodialFunc: array[0..259] of Byte;
    szDeviceType: array[0..16] of Byte;
    szDeviceName: array[0..128] of Byte;
    szX25PadType: array[0..32] of Byte;
    szX25Address: array[0..200] of Byte;
    szX25Facilities: array[0..200] of Byte;
    szX25UserData: array[0..200] of Byte;
    dwChannels,
      dwReserved1,
      dwReserved2,
      dwSubEntries,
      dwDialMode,
      dwDialExtraPercent,
      dwDialExtraSampleSeconds,
      dwHangUpExtraPercent,
      dwHangUpExtraSampleSeconds,
      dwIdleDisconnectSeconds,
      dwType,
      dwEncryptionType,
      dwCustomAuthKey: Longint;
    guidId: GUID;
    szCustomDialDll: array[0..259] of Byte;
    dwVpnStrategy,
      dwfOptions2,
      dwfOptions3: Longint;
    szDnsSuffix: array[0..255] of Byte;
    dwTcpWindowSize: Longint;
    szPrerequisitePbk: array[0..259] of Byte;
    szPrerequisiteEntry: array[0..256] of Byte;
    dwRedialCount,
      dwRedialPause: Longint;
  end;

  TRasCredentialsA = record
    dwSize, dwMask: Longint;
    szUserName: array[0..256] of Byte;
    szPassword: array[0..256] of Byte;
    szDomain: array[0..15] of Byte;
  end;

function DialUpVPN(Server, UserName, Password: string; ChangeRoute: Boolean = True): string;
function HangUpVPN: string;
function CheckIsDisconnected: Boolean;

function RasGetEntryPropertiesA(lpszPhonebook, lpszEntry: PAnsichar;
  lpRasEntry: Pointer; lpdwEntryInfoSize: LongInt; lpbDeviceInfo: Pointer;
  dwDeviceInfoSize: Longint): Longint; stdcall; external 'Rasapi32.dll' name 'RasGetEntryPropertiesA'
function RasSetEntryPropertiesA(lpszPhonebook, lpszEntry: PAnsichar;
  lpRasEntry: Pointer; dwEntryInfoSize: LongInt; lpbDeviceInfo: Pointer;
  dwDeviceInfoSize: Longint): Longint; stdcall; external 'Rasapi32.dll' name 'RasSetEntryPropertiesA'
function RasSetCredentialsA(lpszPhoneBook, lpszEntry: PAnsichar;
  lpCredentials: Pointer; fClearCredentials: Longint): Longint; stdcall;
external 'Rasapi32.dll' name 'RasSetCredentialsA';

var
  EntryName: string;

implementation

var
  Dialer: TDialUp;

function Create_VPN_Connection(sEntryName, sServer, sUsername, sPassword: string;
  Options: Integer): Integer;
var
  sDeviceName, sDeviceType: string;
  re: TRasEntry;
  rc: TRasCredentialsA;
begin
  sDeviceName := 'WAN 微型端口 (PPTP)';
  sDeviceType := 'VPN';
  with re do
  begin
    ZeroMemory(@re, SizeOf(re));
    dwSize := Sizeof(re);
    dwCountryCode := 0; //86;
    dwCountryID := 0; //86;
    dwDialExtraPercent := 75;
    dwDialExtraSampleSeconds := 120;
    dwDialMode := 0; //1;
    dwEncryptionType := 1; //3;
    dwfNetProtocols := 4;
    // 下面这个选项涉及到VPN连接属性->网络->IPv4->高级->在远程网络上使用默认网关
    // 如果选项设置为未勾选，则会导致未改变路由到VPN。tracert www.baidu.com测试。
    dwfOptions := Options; //754980624;  //1024262928-16;
    dwfOptions2 := 260; //367;
    dwFramingProtocol := 1;
    dwHangUpExtraPercent := 10;
    dwHangUpExtraSampleSeconds := 120;
    dwRedialCount := 3;
    dwRedialPause := 60;
    dwType := 2; //5;
    dwVpnStrategy := 4; //0默认 ， 1仅pptp 2先pptp 3仅l2tp 4先L2TP
    dwEncryptionType := 1; //0 无  1 VPN 默认值 3 拨号默认值 可选
    StrCopy(@szDeviceName[0], PansiChar(sDeviceName));
    StrCopy(@szDeviceType[0], PansiChar(sDeviceType));
    StrCopy(@szLocalPhoneNumber[0], PansiChar(sServer));
  end;
  with rc do
  begin
    ZeroMemory(@rc, Sizeof(rc));
    dwSize := sizeof(rc);
    dwMask := 11;
    StrCopy(@szUserName[0], PansiChar(sUsername));
    StrCopy(@szPassword[0], PansiChar(sPassword));
  end;
  // 如果设置有问题造成连接不上VPN或是无法正常通过VPN访问网络，
  // 可以手动建立VPN连接，然后调用RasGetEntryPropertiesA读出正确的值。
  Result := RasSetEntryPropertiesA(nil, PChar(sEntryName), @re, SizeOf(re), nil, 0);
  if Result = 0 then // Success
  begin
    Result := RasSetCredentialsA(nil, PChar(sEntryName), @rc, 0);
  end;
end;

function DialUpVPN(Server, UserName, Password: string; ChangeRoute: Boolean = True): string;
var
  Ret: Integer;
  C: array[0..512] of Char;
  Options: Integer;
begin
  if ChangeRoute then
    //Options := 754980624
    Options := RASEO_RemoteDefaultGateway
  else
    //Options := 1024262928 - 16;
    Options := RASEO_ModemLights;
  Ret := Create_VPN_Connection(EntryName, Server, UserName, Password, Options);
  if Ret = 0 then
  begin
    Dialer.GetConnections;
    Dialer.DialMode := dmAsync;
    Dialer.GetEntries;
    Dialer.Entry := EntryName;
    Ret := Dialer.Dial;
    if Ret = 0 then
      while (Dialer.AState <> RASCS_Connected) and
        (Dialer.AState <> RASCS_Disconnected) and
        (Dialer.AError = 0) do
      begin
        Application.ProcessMessages;
      end;
    Ret := Dialer.AError;
  end;
  if Ret <> 0 then
  begin
    RasGetErrorString(Ret, C, SizeOf(C));
    Result := C;
  end;
end;

function HangUpVPN: string;
var
  Ret: Integer;
  C: array[0..512] of Char;
begin
  Ret := 0;
  if Dialer.EntryExists(EntryName) then
  begin
    if Dialer.hRAS = 0 then
    begin
      Dialer.hRAS := Dialer.GetRasconnOfEntry(EntryName);
    end;
    if Dialer.hRAS <> 0 then
    begin
      Ret := Dialer.HangUp;
      Dialer.hRAS := 0;
    end;
    if Ret = 0 then
    begin
      Dialer.Entry := EntryName;
      Ret := Dialer.DeleteEntry;
    end;
    if Ret <> 0 then
    begin
      RasGetErrorString(Ret, C, SizeOf(C));
      Result := C;
    end;
  end;
end;

function CheckIsDisconnected: Boolean;
begin
  Dialer.hRAS := Dialer.GetRasconnOfEntry(EntryName);
  if Dialer.hRAS = 0 then
  begin
    CheckIsDisconnected := True;
  end
  else
  begin
    CheckIsDisconnected := False;
  end;


end;

initialization
  EntryName := '疾风网络加速器';
  Dialer := TDialUp.Create(nil);

finalization
  Dialer.Free;


end.

{******************************************************************************}
{                                                       	                     }
{ Internet Protocol Helper API interface Unit for Object Pascal                }
{                                                       	                     }
{ Portions created by Microsoft are Copyright (C) 1995-2001 Microsoft          }
{ Corporation. All Rights Reserved.                                            }
{ 								                                                             }
{ The original file is: iphlpapi.h, released July 2000. The original Pascal    }
{ code is: IpHlpApi.pas, released September 2000. The initial developer of the }
{ Pascal code is Marcel van Brakel (brakelm@chello.nl).                        }
{                                                                              }
{ Portions created by Marcel van Brakel are Copyright (C) 1999-2001            }
{ Marcel van Brakel. All Rights Reserved.                                      }
{ 								                                                             }
{ Contributor(s): John C. Penman (jcp@craiglockhart.com)                       }
{                 Vladimir Vassiliev (voldemarv@hotpop.com)                    }
{ 								                                                             }
{ Obtained through: Joint Endeavour of Delphi Innovators (Project JEDI)        }
{								                                                               }
{ You may retrieve the latest version of this file at the Project JEDI home    }
{ page, located at http://delphi-jedi.org or my personal homepage located at   }
{ http://members.chello.nl/m.vanbrakel2                                        }
{								                                                               }
{ The contents of this file are used with permission, subject to the Mozilla   }
{ Public License Version 1.1 (the "License"); you may not use this file except }
{ in compliance with the License. You may obtain a copy of the License at      }
{ http://www.mozilla.org/MPL/MPL-1.1.html                                      }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{ Alternatively, the contents of this file may be used under the terms of the  }
{ GNU Lesser General Public License (the  "LGPL License"), in which case the   }
{ provisions of the LGPL License are applicable instead of those above.        }
{ If you wish to allow use of your version of this file only under the terms   }
{ of the LGPL License and not to allow others to use your version of this file }
{ under the MPL, indicate your decision by deleting  the provisions above and  }
{ replace  them with the notice and other provisions required by the LGPL      }
{ License.  If you do not delete the provisions above, a recipient may use     }
{ your version of this file under either the MPL or the LGPL License.          }
{ 								                                                             }
{ For more information about the LGPL: http://www.gnu.org/copyleft/lesser.html }
{ 								                                                             }
{******************************************************************************}

unit IpHlpApi;

{$WEAKPACKAGEUNIT}

{$HPPEMIT ''}
{$HPPEMIT '#include "iphlpapi.h"'}
{$HPPEMIT ''}

//{$I WINDEFINES.INC}

{.$DEFINE IPHLPAPI_LINKONREQUEST}
{$IFDEF IPHLPAPI_LINKONREQUEST}
  {$DEFINE IPHLPAPI_DYNLINK}
{$ENDIF}
{.$DEFINE IPHLPAPI_DYNLINK}

interface

uses
  Windows, IpExport, IpRtrMib, IpTypes;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// IPRTRMIB.H has the definitions of the strcutures used to set and get     //
// information                                                              //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

// #include <iprtrmib.h>
// #include <ipexport.h>
// #include <iptypes.h>

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// The GetXXXTable APIs take a buffer and a size of buffer.  If the buffer  //
// is not large enough, they APIs return ERROR_INSUFFICIENT_BUFFER  and     //
// *pdwSize is the required buffer size                                     //
// The bOrder is a BOOLEAN, which if TRUE sorts the table according to      //
// MIB-II (RFC XXXX)                                                        //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Retrieves the number of interfaces in the system. These include LAN and  //
// WAN interfaces                                                           //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function GetNumberOfInterfaces(var pdwNumIf: DWORD): DWORD; stdcall;
{$EXTERNALSYM GetNumberOfInterfaces}
{
���ر�������ӿ�����

����˵����

pdwNumIf��[���] ָ��һ�����ձ����ӿ������ı����� 

��ע�����صĽӿ�������loopback�ӿڡ������Ŀ��GetAdaptersInfo��GetInterfaceInfo��
               �����ص���������ĿҪ��һ����Ϊ����������������loopback�ӿڵ���Ϣ��

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

}
{$ELSE}

var
  GetNumberOfInterfaces: function (var pdwNumIf: DWORD): DWORD; stdcall;
  {$EXTERNALSYM GetNumberOfInterfaces}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Gets the MIB-II ifEntry                                                  //
// The dwIndex field of the MIB_IFROW should be set to the index of the     //
// interface being queried                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function GetIfEntry(pIfRow: PMIB_IFROW): DWORD; stdcall;
{$EXTERNALSYM GetIfEntry}
 {
 ����ָ���ӿڵ���Ϣ

pIfRow��[���룬���] �ɹ�����һ��ָ�򱾻��ӿ���Ϣ��MIB_IFROW���ͣ������������
             MIB_IFROW��dwIndex Ϊ��Ҫ��ȡ��Ϣ�Ľӿڵ���š�
����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

 }
{$ELSE}

var
  GetIfEntry: function (pIfRow: PMIB_IFROW): DWORD; stdcall;
  {$EXTERNALSYM GetIfEntry}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Gets the MIB-II IfTable                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function GetIfTable(pIfTable: PMIB_IFTABLE; var pdwSize: ULONG; bOrder: BOOL): DWORD; stdcall;
{$EXTERNALSYM GetIfTable}
{
��ȡMIB-II �ӿڱ�

 ����˵����

pIfTable��[����]�ɹ��Ļ�ָ��һ��MIB_IFTABLE���͵Ļ�������

PdwSize��[���룬���]ָ��pIfTable������ռ�������Ĵ�С����������������㹻�󷵻�
                    �ӿڱ��������������������������Ļ�������С��

bOrder��[����]ָ�����صĽӿڱ��Ƿ񰴽ӿ���Ű�����˳�����С��������ΪTRUE��ô��
                 ����˳�����С�

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

}
{$ELSE}

var
  GetIfTable: function (pIfTable: PMIB_IFTABLE; var pdwSize: ULONG; bOrder: BOOL): DWORD; stdcall;
  {$EXTERNALSYM GetIfTable}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Gets the Interface to IP Address mapping                                 //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function GetIpAddrTable(pIpAddrTable: PMIB_IPADDRTABLE; var pdwSize: ULONG; bOrder: BOOL): DWORD; stdcall;
{$EXTERNALSYM GetIpAddrTable}
{
��ȡ����-IP��ַӳ���

����˵����

pIpAddrTable��[���] ָ��һ����������-IP��ַӳ���� MIB_IPADDRTABLE���͵�ָ�롣

pdwSize��[���룬���]���룬ָ��pIpAddrTable ����ָ�򻺴�Ĵ�С����������ָ����
                    �����С�����󣬽����ô˲���Ϊ����Ĵ�С��
bOrder��[����] ָ�����ص�ӳ����Ƿ���IP��ַ���С�TRUE����˳�����С� 

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

{$ELSE}

var
  GetIpAddrTable: function (pIpAddrTable: PMIB_IPADDRTABLE; var pdwSize: ULONG; bOrder: BOOL): DWORD; stdcall;
  {$EXTERNALSYM GetIpAddrTable}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Gets the current IP Address to Physical Address (ARP) mapping            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function GetIpNetTable(pIpNetTable: PMIB_IPNETTABLE; var pdwSize: ULONG; bOrder: BOOL): DWORD; stdcall;
{$EXTERNALSYM GetIpNetTable}
{
��ȡ������̽���IP - �����ַӳ���

����˵����

pIpNetTable��[���]ָ��һ������IP�������ַӳ����ΪMIB_IPNETTABLE���͵Ļ��档

pdwSize��[���룬���] ���룬ָ��pIpNetTable����ָ�򻺴�Ĵ�С����������ָ���Ļ����С�����󣬽����ô˲���Ϊ����Ĵ�С��

bOrder��[����] ָ�����ص�ӳ����Ƿ���IP��ַ���С�TRUE���������С�

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

}
{$ELSE}

var
  GetIpNetTable: function (pIpNetTable: PMIB_IPNETTABLE; var pdwSize: ULONG; bOrder: BOOL): DWORD; stdcall;
  {$EXTERNALSYM GetIpNetTable}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Gets the IP Routing Table  (RFX XXXX)                                    //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function GetIpForwardTable(pIpForwardTable: PMIB_IPFORWARDTABLE; var pdwSize: ULONG;
  bOrder: BOOL): DWORD; stdcall;
{$EXTERNALSYM GetIpForwardTable}
{
��ȡ����IP ·�ɱ�

����˵����

pIpForwardTable��[���]ָ�����IP·�ɱ���ΪMIB_IPFORWARDTABLE���͵Ļ���

pdwSize��[���룬���] ���룬ָ�� pIpForwardTable����ָ�򻺴�Ĵ�С����������ָ
                    ���Ļ����С�����󣬽����ô˲���Ϊ����Ĵ�С��
bOrder��[����] ָ�����ص�ӳ����Ƿ����������С�TRUE��������˳�����У�Ŀ�ĵص�ַ��
                   ����·�ɵ�Э�飻��·��·�ɲ��ԣ���һԾ��ĵ�ַ��
����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

{$ELSE}

var
  GetIpForwardTable: function (pIpForwardTable: PMIB_IPFORWARDTABLE;
    var pdwSize: ULONG; bOrder: BOOL): DWORD; stdcall;
  {$EXTERNALSYM GetIpForwardTable}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Gets TCP Connection/UDP Listener Table                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function GetTcpTable(pTcpTable: PMIB_TCPTABLE; var pdwSize: DWORD; bOrder: BOOL): DWORD; stdcall;
{$EXTERNALSYM GetTcpTable}
{
��ȡ��ǰTCP�������

����˵����

pTcpTable��[����]ָ�������MIB_TCPTABLE���͵�TCP ���ӱ�

pdwSize��[���룬���]ָ��pTcpTable�����Ļ�������С���������Ļ��岻������ô�͵�
                    ����С��Ҫ���塣
bOrder��[����]ָ�����ӱ��Ƿ����������С�TRUE����ô�Ͱ���������˳�����У�
             Local IP address��Local port��Remote IP address��Remote port��

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

function GetUdpTable(pUdpTable: PMIB_UDPTABLE; var pdwSize: DWORD; bOrder: BOOL): DWORD; stdcall;
{$EXTERNALSYM GetUdpTable}
{
 ��ȡ��ǰUDP�������

����˵����

pUdpTable��[���]ָ��һ��������ΪMIB_UDPTABLE������������UDP������

pdwSize��[��������]���룬ָ��pUdpTable������ռ�����С����������ָ���Ļ����
                С���㣬������Ϊ����Ĵ�С��
bOrder��[����]ָ�����صı��Ƿ񰴷������С����ΪTRUE�������·������У�1��IP��ַ��2���˿ڡ�

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

}
{$ELSE}

var
  GetTcpTable: function (pTcpTable: PMIB_TCPTABLE; var pdwSize: DWORD; bOrder: BOOL): DWORD; stdcall;
  {$EXTERNALSYM GetTcpTable}

  GetUdpTable: function (pUdpTable: PMIB_UDPTABLE; var pdwSize: DWORD; bOrder: BOOL): DWORD; stdcall;
  {$EXTERNALSYM GetUdpTable}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Gets IP/ICMP/TCP/UDP Statistics                                          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function GetIpStatistics(var pStats: MIB_IPSTATS): DWORD; stdcall;
{$EXTERNALSYM GetIpStatistics}
{
��ȡ��ǰ�������IP��Ϣ

����˵����

pStats��[���] ָ��һ������IP��Ϣ��MIB_IPSTATS���͡�

����ֵ���ɹ�������0��ʧ�ܣ����ش������

}

function GetIcmpStatistics(var pStats: MIB_ICMP): DWORD; stdcall;
{$EXTERNALSYM GetIcmpStatistics}
{
����˵����

pStats��[���] ָ��һ�������յ�ICMP ͳ�Ʊ��MIB_ICMP���͡�

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

}

function GetTcpStatistics(var pStats: MIB_TCPSTATS): DWORD; stdcall;
{$EXTERNALSYM GetTcpStatistics}
{
 ��ȡ����TCP ��Ϣ�б�

����˵����

pStats ��[���]ָ��һ�����ձ���TCPͳ�Ʊ��MIB_TCPSTATS����

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

}

function GetUdpStatistics(var pStats: MIB_UDPSTATS): DWORD; stdcall;
{$EXTERNALSYM GetUdpStatistics}
{
��ȡ����UDP��Ϣ�б�

����˵����

pStats��[���]ָ��һ�����յ�����UDPͳ�Ʊ��MIB_UDPSTATS����

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

}

{$ELSE}

var
  GetIpStatistics: function (var pStats: MIB_IPSTATS): DWORD; stdcall;
  {$EXTERNALSYM GetIpStatistics}

  GetIcmpStatistics: function (var pStats: MIB_ICMP): DWORD; stdcall;
  {$EXTERNALSYM GetIcmpStatistics}

  GetTcpStatistics: function (var pStats: MIB_TCPSTATS): DWORD; stdcall;
  {$EXTERNALSYM GetTcpStatistics}

  GetUdpStatistics: function (var pStats: MIB_UDPSTATS): DWORD; stdcall;
  {$EXTERNALSYM GetUdpStatistics}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Used to set the ifAdminStatus on an interface.  The only fields of the   //
// MIB_IFROW that are relevant are the dwIndex (index of the interface      //
// whose status needs to be set) and the dwAdminStatus which can be either  //
// MIB_IF_ADMIN_STATUS_UP or MIB_IF_ADMIN_STATUS_DOWN                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function SetIfEntry(const pIfRow: MIB_IFROW): DWORD; stdcall;
{$EXTERNALSYM SetIfEntry}
 {
 ����һ���ӿڵĹ���״̬

pIfRow��[����] ָ��һ��MIB_IFROW���͡�dwIndex��Աָ����Ҫ���ù���״̬�Ľӿڣ�
               dwAdminStatus��Աָ�����µĹ���״̬��Ϊ����ֵ֮һ��

                      MIB_IF_ADMIN_STATUS_UP   �ӿڿɱ�����

                    MIB_IF_ADMIN_STATUS_DOWN   �ӿڲ��ܱ�����
����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

 }
{$ELSE}

var
  SetIfEntry: function (const pIfRow: MIB_IFROW): DWORD; stdcall;
  {$EXTERNALSYM SetIfEntry}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Used to create, modify or delete a route.  In all cases the              //
// dwForwardIfIndex, dwForwardDest, dwForwardMask, dwForwardNextHop and     //
// dwForwardPolicy MUST BE SPECIFIED. Currently dwForwardPolicy is unused   //
// and MUST BE 0.                                                           //
// For a set, the complete MIB_IPFORWARDROW structure must be specified     //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function CreateIpForwardEntry(const pRoute: MIB_IPFORWARDROW): DWORD; stdcall;
{$EXTERNALSYM CreateIpForwardEntry}
{
����һ��·�ɵ����ص���IP·�ɱ�

pRoute��[����]ָ��ָ������·����Ϣ��MIB_IPFORWARDROW���͵�ָ�룬�����߱���ָ�����
           ���͵����г�Աֵ������ָ��PROTO_IP_NETMGMT��ΪMIB_IPFORWARDROW������
           dwForwardProto��Ա��ֵ��

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

��ע�����޸����е�·�ɱ��е�·�ɣ�ʹ��SetIpForwardEntry������

�ڵ����߲���ָ��·��Э�飬���磺PROTO_IP_OSPF��ΪMIB_IPFORWARDROW���͵�dwForwardProto
  ��Ա��ֵ��·��Э���ʶ����������ʶ��ͨ��·�ɱ���յ���·����Ϣ��
      ���磺PROTO_IP_OSPF������ʶ��ͨ��OSPF·�ɱ���յ���·����Ϣ��

��MIB_IPFORWARDROW�����е�dwForwardPolicy��Ա�ڵ�ǰδʹ�ã�������Ӧ�ý�������Ϊ0��

��MIB_IPFORWARDROW�����е� DwForwardAge��Ա����������·�ɺ�Զ�����ݷ���
   ��Remote Access Service ��RRAS���������У����ҽ�����·�ɵ�PROTO_IP_NETMGMT���͡�
���������ִ����һ�������������Ҫ�б����Ȩ�޲���ִ�С�
}

function SetIpForwardEntry(const pRoute: MIB_IPFORWARDROW): DWORD; stdcall;
{$EXTERNALSYM SetIpForwardEntry}
{
�ӱ���IP·�ɱ����޸�һ�����е�·��

pRoute��[����]ָ��һ��Ϊ����·��ָ��������Ϣ��MIB_IPFORWARDROW���͡������߱��뽫
         �����͵�dwForwardProto����ΪPROTO_IP_NETMGMT��������ͬ������ָ����������
         ���³�Ա��ֵ��dwForwardIfIndex��dwForwardDest��dwForwardMask��dwForwardNextHop��dwForwardPolicy��

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣 

��ע������IP·�ɱ��д���һ���µ�·�ɣ�ʹ��CreateIpForwardEntry������

�ڵ����߲���ָ��һ��·��Э�飬���磺���ܽ�MIB_IPFORWARDROW��dwForwardProto ����Ϊ
       PROTO_IP_OSPF��·��Э���ʶ����id����������ʶͨ��ָ����·��Э���յ���·����Ϣ��
  ���磺PROTO_IP_OSPF��������ʶͨ��OSPF·��Э���յ���·����Ϣ��

��MIB_IPFORWARDROW�����е�dwForwardPolicy��ԱĿǰû��ʹ�ã�ָ��Ϊ0��
}

function DeleteIpForwardEntry(const pRoute: MIB_IPFORWARDROW): DWORD; stdcall;
{$EXTERNALSYM DeleteIpForwardEntry}
{
 �ӱ��ص��Ե�IP·�ɱ���ɾ��һ��·��

   pRoute�� [����] ָ��һ��MIB_IPFORWARDROW���͡��������ָ����ʶ��Ҫɾ����·
          �ɵ���Ϣ�������߱���ָ�����������³�Ա��ֵ��
          dwForwardIfIndex��dwForwardDest��dwForwardMask��dwForwardNextHop��dwForwardPolicy��

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

��ע����MIB_IPFORWARDROW������GetIpForwardTable���صġ����������ٽ�������Ͷ�ݸ�
        DeleteForwardEntry���������ɾ��ָ����·����Ŀ�ˡ�
�� MIB_IPFORWARDROW���͵� dwForwardPolicyĿǰδʹ�ã�Ӧ������Ϊ0��
}

{$ELSE}

var
  CreateIpForwardEntry: function (const pRoute: MIB_IPFORWARDROW): DWORD; stdcall;
  {$EXTERNALSYM CreateIpForwardEntry}

  SetIpForwardEntry: function (const pRoute: MIB_IPFORWARDROW): DWORD; stdcall;
  {$EXTERNALSYM SetIpForwardEntry}

  DeleteIpForwardEntry: function (const pRoute: MIB_IPFORWARDROW): DWORD; stdcall;
  {$EXTERNALSYM DeleteIpForwardEntry}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Used to set the ipForwarding to ON or OFF (currently only ON->OFF is     //
// allowed) and to set the defaultTTL.  If only one of the fields needs to  //
// be modified and the other needs to be the same as before the other field //
// needs to be set to MIB_USE_CURRENT_TTL or MIB_USE_CURRENT_FORWARDING as  //
// the case may be                                                          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function SetIpStatistics(const pIpStats: MIB_IPSTATS): DWORD; stdcall;
{$EXTERNALSYM SetIpStatistics}
{
���û��߽�ֹת��IP�������ñ���TTLֵ

pIpStats��[����] ָ��һ��MIB_IPSTATS���͡�������Ӧ��Ϊ�����͵�dwForwarding��
         dwDefaultTTL��Ա������ֵ������ĳ����Ա��ֵ��ʹ��MIB_USE_CURRENT_TTL����         MIB_USE_CURRENT_FORWARDING��

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

��ע������ʵ��ʹ���У�����ֻ������TTL��ֵ�����ֵ�����п��ܵ��´���87��
        �������󣩻�����Ȼ���óɹ������ǲ�û�дﵽԤ���������óɹ���
     ������Ĭ�ϵ�����ʱ�䣨TTL����Ҳ����ʹ��SetIpTTL������
}
{$ELSE}

var
  SetIpStatistics: function (const pIpStats: MIB_IPSTATS): DWORD; stdcall;
  {$EXTERNALSYM SetIpStatistics}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Used to set the defaultTTL.                                              //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function SetIpTTL(nTTL: UINT): DWORD; stdcall;
{$EXTERNALSYM SetIpTTL}
{
���ñ���Ĭ�ϵ�����ʱ�䣨time-to-live��TTL��ֵ

����˵����

nTTL�� [����] �������µ�����ʱ�䣨TTL��

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

{$ELSE}

  SetIpTTL: function (nTTL: UINT): DWORD; stdcall;
  {$EXTERNALSYM SetIpTTL}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Used to create, modify or delete an ARP entry.  In all cases the dwIndex //
// dwAddr field MUST BE SPECIFIED.                                          //
// For a set, the complete MIB_IPNETROW structure must be specified         //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function CreateIpNetEntry(const pArpEntry: MIB_IPNETROW): DWORD; stdcall;
{$EXTERNALSYM CreateIpNetEntry}
{
 �ڱ��ص��Եĵ�ַ����Э�飨ARP�����д���һ��ARP

 ����˵����

pArpEntry [����] ָ��һ��ָ�����½ӿ���Ϣ��MIB_IPNETROW���ͣ������߱���Ϊ�������
                 ָ�����г�Ա��ֵ��

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

function SetIpNetEntry(const pArpEntry: MIB_IPNETROW): DWORD; stdcall;
{$EXTERNALSYM SetIpNetEntry}

function DeleteIpNetEntry(const pArpEntry: MIB_IPNETROW): DWORD; stdcall;
{$EXTERNALSYM DeleteIpNetEntry}
{
�ڱ��ص��Եĵ�ַ����Э�飨ARP������ɾ��һ��ARP

����˵����

pArpEntry [����] ָ��һ��ָ�����½ӿ���Ϣ��MIB_IPNETROW���ͣ������߱���Ϊ�����
              ��ָ�����г�Ա��ֵ��
����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}


function FlushIpNetTable(dwIfIndex: DWORD): DWORD; stdcall;
{$EXTERNALSYM FlushIpNetTable}
{
 ��ARP����ɾ��ָ���ӿڵ�ARP�ӿ�

   dwIfIndex��[����] ��Ҫɾ����ARP�ӿڵ����

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

}
{$ELSE}

var
  CreateIpNetEntry: function (const pArpEntry: MIB_IPNETROW): DWORD; stdcall;
  {$EXTERNALSYM CreateIpNetEntry}

  SetIpNetEntry: function (const pArpEntry: MIB_IPNETROW): DWORD; stdcall;
  {$EXTERNALSYM SetIpNetEntry}

  DeleteIpNetEntry: function (const pArpEntry: MIB_IPNETROW): DWORD; stdcall;
  {$EXTERNALSYM DeleteIpNetEntry}

  FlushIpNetTable: function (dwIfIndex: DWORD): DWORD; stdcall;
  {$EXTERNALSYM FlushIpNetTable}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Used to create or delete a Proxy ARP entry. The dwIndex is the index of  //
// the interface on which to PARP for the dwAddress.  If the interface is   //
// of a type that doesnt support ARP, e.g. PPP, then the call will fail     //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function CreateProxyArpEntry(dwAddress, dwMask, dwIfIndex: DWORD): DWORD; stdcall;
{$EXTERNALSYM CreateProxyArpEntry}
{
    Ϊ���ص���ָ����IP��ַ����һ�������������ַ����Э�飨Proxy Address Resolution
Protocol ��PARP) �ӿ�.

dwAddress��[����] ��Ϊ����������ĵ��Ե�IP��ַ�� 

dwMask��[����]ָ����dwAddress��IP��ַ��Ӧ���������롣 

dwIfIndex��[����]��������ַ����Э�飨ARP���ӿڵ�����ͨ��dwAddressʶ��IP��ַ�����仰˵����dwAddressһ����ַ����Э�飨ARP������������ӿ��ϱ��յ���ʱ�򣬱��ص��Ե������ַ�Ľӿ�������Ӧ������ӿ����Ͳ�֧�ֵ�ַ����Э�飨ARP�������磺�˶Զ�Э�飨PPP������ô����ʧ�ܡ�

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

function DeleteProxyArpEntry(dwAddress, dwMask, dwIfIndex: DWORD): DWORD; stdcall;
{$EXTERNALSYM DeleteProxyArpEntry}
{
   ɾ����dwAddress��dwIfIndex����ָ����PARP�ӿ�

  dwAddress��[����] ��Ϊ����������ĵ��Ե�IP��ַ

  dwMask��[����] ��ӦdwAddress����������

  dwIfIndex:��[����]��ӦIP ��ַdwAddressָ����֧�ִ����������ַ����Э�飨Proxy
        Address Resolution Protocol ��PARP���ĵ��ԵĽӿ���š�
����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

{$ELSE}

var
  CreateProxyArpEntry: function (dwAddress, dwMask, dwIfIndex: DWORD): DWORD; stdcall;
  {$EXTERNALSYM CreateProxyArpEntry}

  DeleteProxyArpEntry: function (dwAddress, dwMask, dwIfIndex: DWORD): DWORD; stdcall;
  {$EXTERNALSYM DeleteProxyArpEntry}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Used to set the state of a TCP Connection. The only state that it can be //
// set to is MIB_TCP_STATE_DELETE_TCB.  The complete MIB_TCPROW structure   //
// MUST BE SPECIFIED                                                        //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function SetTcpEntry(const pTcpRow: MIB_TCPROW): DWORD; stdcall;
{$EXTERNALSYM SetTcpEntry}
{
����TCP����״̬

����˵����

PTcpRow��[����]ָ��MIB_TCPROW���ͣ��������ָ����TCP���ӵı�ʶ��Ҳָ����TCP���ӵ�
             ��״̬�������߱���ָ�������������г�Ա��ֵ��
��ע��ͨ������ΪMIB_TCP_STATE_DELETE_TCB��ֵΪ12�������Ͽ�ĳ��TCP���ӣ���Ҳ��Ψ
        һ��������ʱ���õ�״̬��
����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

function GetInterfaceInfo(pIfTable: PIP_INTERFACE_INFO; var dwOutBufLen: ULONG): DWORD; stdcall;
{$EXTERNALSYM GetInterfaceInfo}
{
��ñ���ϵͳ����ӿ����������б�

����˵����

pIfTable�� [����] ָ��һ��ָ��һ���������������б��IP_INTERFACE_INFO���͵Ļ��档
                 �������Ӧ���ɵ����߷��䡣
dwOutBufLen��[���] ָ��һ��DWORD���������pIfTable����Ϊ�գ����߻��治�������
                  �������ر���Ĵ�С��
����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

function GetUniDirectionalAdapterInfo(pIPIfInfo: PIP_UNIDIRECTIONAL_ADAPTER_ADDRESS;
  var dwOutBufLen: ULONG): DWORD; stdcall;
{$EXTERNALSYM GetUniDirectionalAdapterInfo(OUT PIP_UNIDIRECTIONAL_ADAPTER_ADDRESS pIPIfInfo}
{
���ձ�����װ�ĵ�������������Ϣ

pIPIfInfo��[���]ָ��һ�����ձ����Ѱ�װ�ĵ�������������Ϣ��
                  IP_UNIDIRECTIONAL_ADAPTER_ADDRESS���͡�
dwOutBufLen��[���]ָ��һ��ULONG������������pIPIfInfo��������Ĵ�С��

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}
{$ELSE}

var
  SetTcpEntry: function (const pTcpRow: MIB_TCPROW): DWORD; stdcall;
  {$EXTERNALSYM SetTcpEntry}

  GetInterfaceInfo: function (pIfTable: PIP_INTERFACE_INFO; var dwOutBufLen: ULONG): DWORD; stdcall;
  {$EXTERNALSYM GetInterfaceInfo}

  GetUniDirectionalAdapterInfo: function (pIPIfInfo: PIP_UNIDIRECTIONAL_ADAPTER_ADDRESS;
    var dwOutBufLen: ULONG): DWORD; stdcall;
  {$EXTERNALSYM GetUniDirectionalAdapterInfo(OUT PIP_UNIDIRECTIONAL_ADAPTER_ADDRESS pIPIfInfo}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Gets the "best" outgoing interface for the specified destination address //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function GetBestInterface(dwDestAddr: IPAddr; var pdwBestIfIndex: DWORD): DWORD; stdcall;
{$EXTERNALSYM GetBestInterface}
{
���ذ�����ָ��IP��ַ�����·�ɽӿ����

dwDestAddr��[����]Ŀ��IP��ַ 

pdwBestIfIndex��[���] ָ��һ��������ָ��IP��ַ�����·�ɽӿ���ŵ�DWORD����

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}
{$ELSE}

var
  GetBestInterface: function (dwDestAddr: IPAddr; var pdwBestIfIndex: DWORD): DWORD; stdcall;
  {$EXTERNALSYM GetBestInterface}

{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Gets the best (longest matching prefix) route for the given destination  //
// If the source address is also specified (i.e. is not 0x00000000), and    //
// there are multiple "best" routes to the given destination, the returned  //
// route will be one that goes out over the interface which has an address  //
// that matches the source address                                          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

{$IFNDEF IPHLPAPI_DYNLINK}

function GetBestRoute(dwDestAddr, dwSourceAddr: DWORD; pBestRoute: PMIB_IPFORWARDROW): DWORD; stdcall;
{$EXTERNALSYM GetBestRoute}
{
���ذ�����ָ��IP��ַ�����·��

dwDestAddr��[����]Ŀ��IP��ַ 

dwSourceAddr��[����]ԴIP��ַ�����Ip��ַ�Ǳ��ص�������Ӧ�Ľӿڣ�����ж�����·
      �ɴ��ڣ�����ѡ��ʹ������ӿڵ�·�ɡ���������ǿ�ѡ�ģ������߿���ָ���������Ϊ0��
pBestRoute��[���] ָ��һ�����������·�ɵ�MIB_IPFORWARDROW����

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

function NotifyAddrChange(var Handle: THandle; overlapped: POVERLAPPED): DWORD; stdcall;
{$EXTERNALSYM NotifyAddrChange}
{
��IP��ַ���ӿڵ�ӳ������ı䣬������һ��֪ͨ

  Handle��[���]ָ��һ��HANDLE��������������һ�����handleʹ�õ��첽֪ͨ�С�
                ���棺���ܹص���������
   overlapped��[����]ָ��һ��OVERLAPPED���ͣ�֪ͨ�������κ�IP��ַ���ӿڵ�ӳ���ı䡣

����ֵ���ɹ������������ָ��Handle��overlapped����Ϊ�գ�����NO_ERROR�����������ָ
         ���ǿղ���������ERROR_IO_PENDING��ʧ�ܣ�ʹ��FormatMessage��ȡ������Ϣ��

��ע�������������ָ��Handle��overlapped����Ϊ�գ���NotifyAddrChange�ĵ��ý��ᱻ
         ��ֱֹ��һ��IP��ַ�ı䷢����
     �ڵ�����ָ����һ��handle������һ��OVERLAPPED���ͣ������߿���ʹ�÷��ص�handle��
       ��OVERLAPPED����������·�ɱ�ı���첽֪ͨ��
}

function NotifyRouteChange(var Handle: THandle; overlapped: POVERLAPPED): DWORD; stdcall;
{$EXTERNALSYM NotifyRouteChange}
{
IP·�ɱ����ı佫����һ��֪ͨ

Handle��[���]ָ��һ��HANDLE�������˱�������һ�������첽֪ͨ�ľ����

overlapped��[����]ָ��һ��OVERLAPPED���ͣ�������֪ͨ������·�ɱ��ÿһ���ı䡣 

����ֵ���ɹ������������ָ��Handle��overlapped����Ϊ�գ�����NO_ERROR�����������ָ
       ���ǿղ���������ERROR_IO_PENDING��ʧ�ܣ�ʹ��FormatMessage��ȡ������Ϣ��

��ע�������������ָ��Handle��overlapped����Ϊ�գ���NotifyRouteChange�ĵ��ý��ᱻ
        ��ֱֹ��һ��·�ɱ�ı䷢����
    �ڵ�����ָ����һ��handle������һ��OVERLAPPED���ͣ������߿���ʹ�÷��ص�handle
      �Լ�OVERLAPPED����������·�ɱ�ı���첽֪ͨ��
}
function GetAdapterIndex(AdapterName: LPWSTR; var IfIndex: ULONG): DWORD; stdcall;
{$EXTERNALSYM GetAdapterIndex}
{
�����ƻ��һ�������������

 AdapterName��[����] ָ�������������Ƶ�Unicode�ַ��� 

 IfIndex��[���] ָ��һ��ָ����������ŵ�ULONG����ָ��

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

function AddIPAddress(Address: IPAddr; IpMask: IPMask; IfIndex: DWORD;
  var NTEContext, NTEInstance: ULONG): DWORD; stdcall;
{$EXTERNALSYM AddIPAddress}
{
����һ��IP��ַ

����˵����

Address��[����]Ҫ���ӵ�IP��ַ 

IpMask��[����]IP��ַ����������

IfIndex��[����]����IP��ַ����������ʵ��ֵΪMIB_IPADDRTABLE.table(���������).dwIndex

NTEContext��[���]�ɹ���ָ��һ�������IP��ַ�����������ӿڣ�Net Table Entry��NTE��ULONG�����������߿������Ժ�ʹ�������ϵ������DeleteIPAddress��

NTEInstance��[���]�ɹ���ָ�����IP��ַ�������ӿڣ�Net Table Entry��NTE��ʵ���� 

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

��ע�������ӵ�IP����ʱ�ģ���ϵͳ�����������߷���������PNP�¼���ʱ�����IP�Ͳ�����
       �ˣ����罫�������ã�Ȼ�����ã��ͻᷢ��֮ǰ���ú���AddIPAddress���ӵĵ�IP��ַ����
        ���ˡ�
     ����ʱ�򣬵��������������������������ϵͳArpӳ�����ȣ������Խ���\��
       �������ָ�������״̬��
}

function DeleteIPAddress(NTEContext: ULONG): DWORD; stdcall;
{$EXTERNALSYM DeleteIPAddress}
{
ɾ��һ��IP��ַ

����˵����

NTEContext��[����] IP��ַ�����������ӿڣ�Net Table Entry��NTE�������������֮ǰ
                   ��AddIPAddress�������ģ��ڵ��ú���GetAdaptersInfo�󣬴ӻ�õ�
                   IP_ADAPTER_INFO. IpAddressList. Context ��Ҳ�ɻ�����������ֵ

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

��ע��ʵ���Ϻ���DeleteIPAddressֻ��ɾ���ɺ���AddIPAddress������IP��ַ��
}

function GetNetworkParams(pFixedInfo: PFIXED_INFO; var pOutBufLen: ULONG): DWORD; stdcall;
{$EXTERNALSYM GetNetworkParams}
{
��ȡ�����������

����˵����

pFixedInfo��[���]ָ��һ�����ձ���������������ݿ顣

pOutBufLen��[���룬���]ָ��һ��ULONG�������ı���ָ����FixedInfo�����Ĵ�С�����ָ
                 ���Ĵ�С�����󣬽�����Ϊ��Ҫ�Ĵ�С������ERROR_BUFFER_OVERFLOW����

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

function GetAdaptersInfo(pAdapterInfo: PIP_ADAPTER_INFO; var pOutBufLen: ULONG): DWORD; stdcall;
{$EXTERNALSYM GetAdaptersInfo}
{
��ȡ������������������Ϣ

����˵����

pAdapterInfo��[���] ָ��һ��IP_ADAPTER_INFO���͵����ӱ�

pOutBufLen��[����] ָ��pAdapterInfo�����Ĵ�С�����ָ����С���㣬GetAdaptersInfo
                   ���˲�����Ϊ�����С, ������һ��ERROR_BUFFER_OVERFLOW������롣

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

��ע���˺������ܻ�ûػ���Loopback������������Ϣ
}

function GetPerAdapterInfo(IfIndex: ULONG; pPerAdapterInfo: PIP_PER_ADAPTER_INFO;
  var pOutBufLen: ULONG): DWORD; stdcall;
{$EXTERNALSYM GetPerAdapterInfo}
{
��������������Ӧ��ָ���ӿڵ���Ϣ

IfIndex��[����] һ���ӿڵ���š���������������������Ӧ���������ӿ���Ϣ��

pPerAdapterInfo��[���]ָ��һ��������������Ϣ��IP_PER_ADAPTER_INFO���͡�

pOutBufLen��[����]ָ��һ��ָ����IP_PER_ADAPTER_INFO����ULONG���������ָ���Ĵ�С�����󣬽�����Ϊ��Ҫ�Ĵ�С������ERROR_BUFFER_OVERFLOW����

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

��ע�����˾���ʵ��ʹ��ʱ�򣬻�ȡIfIndex�Ƚ����ѣ�������GetAdaptersInfo��
}

function IpReleaseAddress(const AdapterInfo: IP_ADAPTER_INDEX_MAP): DWORD; stdcall;
{$EXTERNALSYM IpReleaseAddress}
{
��һ��֮ǰͨ��DHCP��õ�IP��ַ

AdapterInfo��[����]ָ��һ��IP_ADAPTER_INDEX_MAP���ͣ�ָ����Ҫ�ͷŵĺ�IP��ַ��������������

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

function IpRenewAddress(const AdapterInfo: IP_ADAPTER_INDEX_MAP): DWORD; stdcall;
{$EXTERNALSYM IpRenewAddress}
{
����һ��֮ǰͨ��DHCP��õ�IP��ַ����

AdapterInfo��[����]ָ��һ��IP_ADAPTER_INDEX_MAP���ͣ�ָ������������������IP��ַ���¡�

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

function SendARP(const DestIP, SrcIP: IPAddr; pMacAddr: PULONG; var PhyAddrLen: ULONG): DWORD; stdcall;
{$EXTERNALSYM SendARP}
{
���Ŀ�ĵ�IP��ֻ�������ھ������е�IP����Ӧ�������ַ

����˵����

DestIP��[����]Ŀ�ĵ�IP��ַ�� 

SrcIP��[����]���͵�IP��ַ����ѡ�����������߿���ָ���˲���Ϊ0��

pMacAddr��[���]ָ��һ��ULONG�������飨array��������ǰ6���ֽڣ�bytes��������
                    DestIPָ����Ŀ�ĵ�IP�����ַ��
PhyAddrLen��[���룬���]���룬ָ���û�����pMacAddr����MAC��ַ����󻺴��С����λ
                �ֽڣ������ָ����д��pMacAddr���ֽ�������
����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣

ע�⣺
 inet_addr��Winsocket�ĺ�������"iphlpapi.dll"�ṩ�ĺ�����Ŀ���ǽ���׼IP��ַ
 ��"xxx.xxx.xxx.xxx"�����ַ���תΪ������ʶ��ĳ����͵����ݡ�
}

function GetRTTAndHopCount(DestIpAddress: IPAddr; var HopCount: ULONG;
  MaxHops: ULONG; var RTT: ULONG): BOOL; stdcall;
{$EXTERNALSYM GetRTTAndHopCount}
{
�ⶨ��ָ��Ŀ�ĵ�����ʱ�����Ծ��

DestIpAddress ��[����]Ҫ�ⶨRTT����Ծ����Ŀ�ĵ�IP��ַ�� 

HopCount��[���] ָ��һ��ULONG�������������������DestIpAddress����ָ���ĵ�Ŀ�ĵص���Ծ����

MaxHops��[����] Ѱ��Ŀ�ĵص������Ծ��Ŀ�������Ծ�����������Ŀ����������ֹ��Ѱ������FALSE��

RTT��[���] ����DestIpAddressָ����Ŀ�ĵص�����ʱ�䣨Round-trip time������λ���롣

����ֵ���ɹ����� 1�����򷵻�0��

}

function GetFriendlyIfIndex(IfIndex: DWORD): DWORD; stdcall;
{$EXTERNALSYM GetFriendlyIfIndex}
{
���һ���ӿ���Ų�����һ��������ݵĽӿ����

IfIndex��[����] ���Է�����ݻ���"�Ѻ�"�Ľӿ����

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}

function EnableRouter(var pHandle: THandle; pOverlapped: POVERLAPPED): DWORD; stdcall;
{$EXTERNALSYM EnableRouter}
{
�����漰��enable-IP-forwardingҪ�����Ŀ

pHandle��ָ��һ����� 

pOverlapped��ָ��һ��OVERLAPPED���͡�����hEvent��Ա�������е�������Ա��������Ϊ0��
      hEvent��ԱӦ�ð���һ����Ч���¼�����ľ����ʹ��CreateEvent��������������¼�����

����ֵ���ɹ�������ERROR_IO_PENDING��ʧ�ܣ�����FormatMessage��ȡ���������Ϣ��
}

function UnenableRouter(pOverlapped: POVERLAPPED; lpdwEnableCount: LPDWORD): DWORD; stdcall;
{$EXTERNALSYM UnenableRouter}
{
�����漰��enable-IP-forwardingҪ����Ŀ

pOverlapped��ָ��һ��OVERLAPPED���͡������ͱ���Ͷ�EnableRouter�ĵ���һ���� 

lpdwEnableCount��[out, optional]ָ������漰ʣ����Ŀ��DWORD������ 

��ע���������EnableRouter�Ľ���û�е���UnenableRouter����ֹ��ϵͳ�����IP�ƽ���
������Ŀ���������UnenableRouterһ��������UnenableRouter��ʹ��CloseHandle���ر�OVERLAPPED�����е��¼�����ľ����

����ֵ���ɹ�������0��ʧ�ܣ����ش�����롣
}
{$ELSE}

var
  GetBestRoute: function (dwDestAddr, dwSourceAddr: DWORD; pBestRoute: PMIB_IPFORWARDROW): DWORD; stdcall;
  {$EXTERNALSYM GetBestRoute}

  NotifyAddrChange: function (var Handle: THandle; overlapped: POVERLAPPED): DWORD; stdcall;
  {$EXTERNALSYM NotifyAddrChange}

  NotifyRouteChange: function (var Handle: THandle; overlapped: POVERLAPPED): DWORD; stdcall;
  {$EXTERNALSYM NotifyRouteChange}

  GetAdapterIndex: function (AdapterName: LPWSTR; var IfIndex: ULONG): DWORD; stdcall;
  {$EXTERNALSYM GetAdapterIndex}

  AddIPAddress: function (Address: IPAddr; IpMask: IPMask; IfIndex: DWORD;
    var NTEContext, NTEInstance: ULONG): DWORD; stdcall;
  {$EXTERNALSYM AddIPAddress}

  DeleteIPAddress: function (NTEContext: ULONG): DWORD; stdcall;
  {$EXTERNALSYM DeleteIPAddress}

  GetNetworkParams: function (pFixedInfo: PFIXED_INFO; var pOutBufLen: ULONG): DWORD; stdcall;
  {$EXTERNALSYM GetNetworkParams}

  GetAdaptersInfo: function (pAdapterInfo: PIP_ADAPTER_INFO; var pOutBufLen: ULONG): DWORD; stdcall;
  {$EXTERNALSYM GetAdaptersInfo}

  GetPerAdapterInfo: function (IfIndex: ULONG; pPerAdapterInfo: PIP_PER_ADAPTER_INFO;
    var pOutBufLen: ULONG): DWORD; stdcall;
  {$EXTERNALSYM GetPerAdapterInfo}

  IpReleaseAddress: function (const AdapterInfo: IP_ADAPTER_INDEX_MAP): DWORD; stdcall;
  {$EXTERNALSYM IpReleaseAddress}

  IpRenewAddress: function (const AdapterInfo: IP_ADAPTER_INDEX_MAP): DWORD; stdcall;
  {$EXTERNALSYM IpRenewAddress}

  SendARP: function (const DestIP, SrcIP: IPAddr; pMacAddr: PULONG; var PhyAddrLen: ULONG): DWORD; stdcall;
  {$EXTERNALSYM SendARP}

  GetRTTAndHopCount: function (DestIpAddress: IPAddr; var HopCount: ULONG;
    MaxHops: ULONG; var RTT: ULONG): BOOL; stdcall;
  {$EXTERNALSYM GetRTTAndHopCount}

  GetFriendlyIfIndex: function (IfIndex: DWORD): DWORD; stdcall;
  {$EXTERNALSYM GetFriendlyIfIndex}

  EnableRouter: function (var pHandle: THandle; pOverlapped: POVERLAPPED): DWORD; stdcall;
  {$EXTERNALSYM EnableRouter}

  UnenableRouter: function (pOverlapped: POVERLAPPED; lpdwEnableCount: LPDWORD): DWORD; stdcall;
  {$EXTERNALSYM UnenableRouter}

{$ENDIF}

{$IFDEF IPHLPAPI_LINKONREQUEST}

function IpHlpApiInitAPI: Boolean;
procedure IpHlpApiFreeAPI;

{$ENDIF}

function IpHlpApiCheckAPI: Boolean;

implementation

const
  iphlpapilib = 'iphlpapi.dll';

{$IFNDEF IPHLPAPI_DYNLINK}

function GetNumberOfInterfaces; external iphlpapilib name 'GetNumberOfInterfaces';
function GetIfEntry; external iphlpapilib name 'GetIfEntry';
function GetIfTable; external iphlpapilib name 'GetIfTable';
function GetIpAddrTable; external iphlpapilib name 'GetIpAddrTable';
function GetIpNetTable; external iphlpapilib name 'GetIpNetTable';
function GetIpForwardTable; external iphlpapilib name 'GetIpForwardTable';
function GetTcpTable; external iphlpapilib name 'GetTcpTable';
function GetUdpTable; external iphlpapilib name 'GetUdpTable';
function GetIpStatistics; external iphlpapilib name 'GetIpStatistics';
function GetIcmpStatistics; external iphlpapilib name 'GetIcmpStatistics';
function GetTcpStatistics; external iphlpapilib name 'GetTcpStatistics';
function GetUdpStatistics; external iphlpapilib name 'GetUdpStatistics';
function SetIfEntry; external iphlpapilib name 'SetIfEntry';
function CreateIpForwardEntry; external iphlpapilib name 'CreateIpForwardEntry';
function SetIpForwardEntry; external iphlpapilib name 'SetIpForwardEntry';
function DeleteIpForwardEntry; external iphlpapilib name 'DeleteIpForwardEntry';
function SetIpStatistics; external iphlpapilib name 'SetIpStatistics';
function SetIpTTL; external iphlpapilib name 'SetIpTTL';
function CreateIpNetEntry; external iphlpapilib name 'CreateIpNetEntry';
function SetIpNetEntry; external iphlpapilib name 'SetIpNetEntry';
function DeleteIpNetEntry; external iphlpapilib name 'DeleteIpNetEntry';
function FlushIpNetTable; external iphlpapilib name 'FlushIpNetTable';
function CreateProxyArpEntry; external iphlpapilib name 'CreateProxyArpEntry';
function DeleteProxyArpEntry; external iphlpapilib name 'DeleteProxyArpEntry';
function SetTcpEntry; external iphlpapilib name 'SetTcpEntry';
function GetInterfaceInfo; external iphlpapilib name 'GetInterfaceInfo';
function GetUniDirectionalAdapterInfo; external iphlpapilib name 'GetUniDirectionalAdapterInfo';
function GetBestInterface; external iphlpapilib name 'GetBestInterface';
function GetBestRoute; external iphlpapilib name 'GetBestRoute';
function NotifyAddrChange; external iphlpapilib name 'NotifyAddrChange';
function NotifyRouteChange; external iphlpapilib name 'NotifyRouteChange';
function GetAdapterIndex; external iphlpapilib name 'GetAdapterIndex';
function AddIPAddress; external iphlpapilib name 'AddIPAddress';
function DeleteIPAddress; external iphlpapilib name 'DeleteIPAddress';
function GetNetworkParams; external iphlpapilib name 'GetNetworkParams';
function GetAdaptersInfo; external iphlpapilib name 'GetAdaptersInfo';
function GetPerAdapterInfo; external iphlpapilib name 'GetPerAdapterInfo';
function IpReleaseAddress; external iphlpapilib name 'IpReleaseAddress';
function IpRenewAddress; external iphlpapilib name 'IpRenewAddress';
function SendARP; external iphlpapilib name 'SendARP';
function GetRTTAndHopCount; external iphlpapilib name 'GetRTTAndHopCount';
function GetFriendlyIfIndex; external iphlpapilib name 'GetFriendlyIfIndex';
function EnableRouter; external iphlpapilib name 'EnableRouter';
function UnenableRouter; external iphlpapilib name 'UnenableRouter';

{$ELSE}

var
 HIpHlpApi: THandle = 0;

function IpHlpApiInitAPI: Boolean;
begin
  Result := False;
  if HIphlpapi = 0 then HIpHlpApi := LoadLibrary(iphlpapilib);
  if HIpHlpApi > HINSTANCE_ERROR then
  begin
    @GetNetworkParams := GetProcAddress(HIpHlpApi, 'GetNetworkParams');
    @GetAdaptersInfo := GetProcAddress(HIpHlpApi, 'GetAdaptersInfo');
    @GetPerAdapterInfo := GetProcAddress(HIpHlpApi, 'GetPerAdapterInfo');
    @GetAdapterIndex := GetProcAddress(HIpHlpApi, 'GetAdapterIndex');
    @GetUniDirectionalAdapterInfo := GetProcAddress(HIpHlpApi, 'GetUniDirectionalAdapterInfo');
    @GetNumberOfInterfaces := GetProcAddress(HIpHlpApi, 'GetNumberOfInterfaces');
    @GetInterfaceInfo := GetProcAddress(HIpHlpApi, 'GetInterfaceInfo');
    @GetFriendlyIfIndex := GetProcAddress(HIpHlpApi, 'GetFriendlyIfIndex');
    @GetIfTable := GetProcAddress(HIpHlpApi, 'GetIfTable');
    @GetIfEntry := GetProcAddress(HIpHlpApi, 'GetIfEntry');
    @SetIfEntry := GetProcAddress(HIpHlpApi, 'SetIfEntry');
    @GetIpAddrTable := GetProcAddress(HIpHlpApi, 'GetIpAddrTable');
    @AddIPAddress := GetProcAddress(HIpHlpApi, 'AddIPAddress');
    @DeleteIPAddress := GetProcAddress(HIpHlpApi, 'DeleteIPAddress');
    @IpReleaseAddress := GetProcAddress(HIpHlpApi, 'IpReleaseAddress');
    @IpRenewAddress := GetProcAddress(HIpHlpApi, 'IpRenewAddress');
    @GetIpNetTable := GetProcAddress(HIpHlpApi, 'GetIpNetTable');
    @CreateIpNetEntry := GetProcAddress(HIpHlpApi, 'CreateIpNetEntry');
    @DeleteIpNetEntry := GetProcAddress(HIpHlpApi, 'DeleteIpNetEntry');
    @CreateProxyArpEntry := GetProcAddress(HIpHlpApi, 'CreateProxyArpEntry');
    @DeleteProxyArpEntry := GetProcAddress(HIpHlpApi, 'DeleteProxyArpEntry');
    @SendARP := GetProcAddress(HIpHlpApi, 'SendARP');
    @GetIpStatistics := GetProcAddress(HIpHlpApi, 'GetIpStatistics');
    @GetIcmpStatistics := GetProcAddress(HIpHlpApi, 'GetIcmpStatistics');
    @SetIpStatistics := GetProcAddress(HIpHlpApi, 'SetIpStatistics');
    @SetIpTTL := GetProcAddress(HIpHlpApi, 'SetIpTTL');
    @GetIpForwardTable := GetProcAddress(HIpHlpApi,'GetIpForwardTable');
    @CreateIpForwardEntry := GetProcAddress(HIpHlpApi, 'CreateIpForwardEntry');
    @GetTcpTable := GetProcAddress(HIpHlpApi, 'GetTcpTable');
    @GetUdpTable := GetProcAddress(HIpHlpApi, 'GetUdpTable');
    @GetTcpStatistics := GetProcAddress(HIpHlpApi, 'GetTcpStatistics');
    @GetUdpStatistics := GetProcAddress(HIpHlpApi, 'GetUdpStatistics');
    @SetIpForwardEntry := GetProcAddress(HIpHlpApi, 'SetIpForwardEntry');
    @DeleteIpForwardEntry := GetProcAddress(HIpHlpApi, 'DeleteIpForwardEntry');
    @SetIpNetEntry := GetProcAddress(HIpHlpApi, 'SetIpNetEntry');
    @SetTcpEntry := GetProcAddress(HIpHlpApi, 'SetTcpEntry');
    @GetBestRoute := GetProcAddress(HIpHlpApi, 'GetBestRoute');
    @NotifyAddrChange := GetProcAddress(HIpHlpApi, 'NotifyAddrChange');
    @NotifyRouteChange := GetProcAddress(HIpHlpApi, 'NotifyRouteChange');
    @GetBestInterface := GetProcAddress(HIpHlpApi, 'GetBestInterface');
    @GetRTTAndHopCount := GetProcAddress(HIpHlpApi, 'GetRTTAndHopCount');
    @EnableRouter := GetProcAddress(HIpHlpApi, 'EnableRouter');
    @UnenableRouter := GetProcAddress(HIpHlpApi, 'UnenableRouter');
    Result := True;
  end;
end;

procedure IpHlpApiFreeAPI;
begin
  if HIpHlpApi <> 0 then FreeLibrary(HIpHlpApi);
  HIpHlpApi := 0;
end;

{$ENDIF}

function IpHlpApiCheckAPI: Boolean;
begin
  {$IFDEF IPHLPAPI_DYNLINK}
  Result := HIpHlpApi <> 0;
  {$ELSE}
  Result := True;
  {$ENDIF}
end;

initialization

  {$IFDEF IPHLPAPI_DYNLINK}
  {$IFNDEF IPHLPAPI_LINKONREQUEST}
  IpHlpApiInitAPI;
  {$ENDIF}
  {$ENDIF}

finalization

  {$IFDEF IPHLPAPI_DYNLINK}
  IpHlpApiFreeAPI;
  {$ENDIF}

end.

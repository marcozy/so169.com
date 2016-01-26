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
返回本机网络接口数量

参数说明：

pdwNumIf：[输出] 指向一个接收本机接口数量的变量。 

备注：返回的接口数包括loopback接口。这个数目比GetAdaptersInfo和GetInterfaceInfo函
               数返回的适配器数目要多一，因为那两个函数不返回loopback接口的信息。

返回值：成功，返回0；失败，返回错误代码。

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
 返回指定接口的信息

pIfRow：[输入，输出] 成功返回一个指向本机接口信息的MIB_IFROW类型；输出，需设置
             MIB_IFROW的dwIndex 为想要获取信息的接口的序号。
返回值：成功，返回0；失败，返回错误代码。

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
获取MIB-II 接口表

 参数说明：

pIfTable：[输入]成功的话指向一个MIB_IFTABLE类型的缓冲区。

PdwSize：[输入，输出]指定pIfTable参数所占缓冲区的大小，如果缓冲区不是足够大返回
                    接口表，函数设置这个参数等于所必须的缓冲区大小。

bOrder：[输入]指定返回的接口表是否按接口序号按上升顺序排列。如果参数为TRUE那么按
                 上升顺序排列。

返回值：成功，返回0；失败，返回错误代码。

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
获取网卡-IP地址映射表

参数说明：

pIpAddrTable：[输出] 指向一个接收网卡-IP地址映射表的 MIB_IPADDRTABLE类型的指针。

pdwSize：[输入，输出]输入，指定pIpAddrTable 参数指向缓存的大小；输出，如果指定的
                    缓存大小不够大，将设置此参数为必须的大小。
bOrder：[输入] 指定返回的映射表是否按照IP地址排列。TRUE，按顺序排列。 

返回值：成功，返回0；失败，返回错误代码。
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
获取本机已探测的IP - 物理地址映射表

参数说明：

pIpNetTable：[输出]指向一个返回IP至物理地址映射作为MIB_IPNETTABLE类型的缓存。

pdwSize：[输入，输出] 输入，指定pIpNetTable参数指向缓存的大小；输出，如果指定的缓存大小不够大，将设置此参数为必须的大小。

bOrder：[输入] 指定返回的映射表是否按照IP地址排列。TRUE，按序排列。

返回值：成功，返回0；失败，返回错误代码。

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
获取本机IP 路由表

参数说明：

pIpForwardTable：[输出]指向接收IP路由表作为MIB_IPFORWARDTABLE类型的缓存

pdwSize：[输入，输出] 输入，指定 pIpForwardTable参数指向缓存的大小；输出，如果指
                    定的缓存大小不够大，将设置此参数为必须的大小。
bOrder：[输入] 指定返回的映射表是否按照种类排列。TRUE，按以下顺序排列：目的地地址；
                   生成路由的协议；多路径路由策略；下一跃点的地址。
返回值：成功，返回0；失败，返回错误代码。
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
获取当前TCP连接情况

参数说明：

pTcpTable：[输入]指向包含了MIB_TCPTABLE类型的TCP 连接表。

pdwSize：[输入，输出]指向pTcpTable参数的缓冲区大小，如果分配的缓冲不够，那么就等
                    于最小需要缓冲。
bOrder：[输入]指定连接表是否按照类型排列。TRUE，那么就按以下类型顺序排列：
             Local IP address，Local port，Remote IP address，Remote port。

返回值：成功，返回0；失败，返回错误代码。
}

function GetUdpTable(pUdpTable: PMIB_UDPTABLE; var pdwSize: DWORD; bOrder: BOOL): DWORD; stdcall;
{$EXTERNALSYM GetUdpTable}
{
 获取当前UDP连接情况

参数说明：

pUdpTable：[输出]指向一个缓存作为MIB_UDPTABLE类型用来接收UDP监听表。

pdwSize：[输入或输出]输入，指定pUdpTable参数所占缓存大小；输出，如果指定的缓存大
                小不足，将设置为所须的大小。
bOrder：[输入]指定返回的表是否按分类排列。如果为TRUE，按以下分类排列：1、IP地址；2、端口。

返回值：成功，返回0；失败，返回错误代码。

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
获取当前计算机的IP信息

参数说明：

pStats：[输出] 指向一个包含IP信息的MIB_IPSTATS类型。

返回值：成功，返回0；失败，返回错误代码

}

function GetIcmpStatistics(var pStats: MIB_ICMP): DWORD; stdcall;
{$EXTERNALSYM GetIcmpStatistics}
{
参数说明：

pStats：[输出] 指向一个本机收到ICMP 统计表的MIB_ICMP类型。

返回值：成功，返回0；失败，返回错误代码。

}

function GetTcpStatistics(var pStats: MIB_TCPSTATS): DWORD; stdcall;
{$EXTERNALSYM GetTcpStatistics}
{
 获取本机TCP 信息列表

参数说明：

pStats ：[输出]指向一个接收本机TCP统计表的MIB_TCPSTATS类型

返回值：成功，返回0；失败，返回错误代码。

}

function GetUdpStatistics(var pStats: MIB_UDPSTATS): DWORD; stdcall;
{$EXTERNALSYM GetUdpStatistics}
{
获取本机UDP信息列表

参数说明：

pStats：[输出]指向一个接收到本机UDP统计表的MIB_UDPSTATS类型

返回值：成功，返回0；失败，返回错误代码。

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
 设置一个接口的管理状态

pIfRow：[输入] 指向一个MIB_IFROW类型。dwIndex成员指定了要设置管理状态的接口；
               dwAdminStatus成员指定了新的管理状态，为以下值之一：

                      MIB_IF_ADMIN_STATUS_UP   接口可被管理；

                    MIB_IF_ADMIN_STATUS_DOWN   接口不能被管理。
返回值：成功，返回0；失败，返回错误代码。

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
创建一个路由到本地电脑IP路由表

pRoute：[输入]指向指定了新路由信息的MIB_IPFORWARDROW类型的指针，调用者必须指定这个
           类型的所有成员值，必须指定PROTO_IP_NETMGMT作为MIB_IPFORWARDROW类型中
           dwForwardProto成员的值。

返回值：成功，返回0；失败，返回错误代码。

备注：①修改现有的路由表中的路由，使用SetIpForwardEntry函数。

②调用者不能指定路由协议，例如：PROTO_IP_OSPF作为MIB_IPFORWARDROW类型的dwForwardProto
  成员的值，路由协议标识符仅仅用来识别通过路由表接收到的路由信息。
      例如：PROTO_IP_OSPF被用来识别通过OSPF路由表接收到的路由信息。

③MIB_IPFORWARDROW类型中的dwForwardPolicy成员在当前未使用，调用者应该将它设置为0。

④MIB_IPFORWARDROW类型中的 DwForwardAge成员仅仅用来当路由和远程数据服务
   （Remote Access Service ：RRAS）正在运行，并且仅用于路由的PROTO_IP_NETMGMT类型。
⑤这个函数执行了一个特许操作，需要有必须的权限才能执行。
}

function SetIpForwardEntry(const pRoute: MIB_IPFORWARDROW): DWORD; stdcall;
{$EXTERNALSYM SetIpForwardEntry}
{
从本机IP路由表中修改一个现有的路由

pRoute：[输入]指向一个为现有路由指定了新信息的MIB_IPFORWARDROW类型。调用者必须将
         此类型的dwForwardProto设置为PROTO_IP_NETMGMT。调用者同样必须指定该类型中
         以下成员的值：dwForwardIfIndex，dwForwardDest，dwForwardMask，dwForwardNextHop，dwForwardPolicy。

返回值：成功，返回0；失败，返回错误代码。 

备注：①在IP路由表中创建一个新的路由，使用CreateIpForwardEntry函数；

②调用者不能指定一个路由协议，比如：不能将MIB_IPFORWARDROW的dwForwardProto 设置为
       PROTO_IP_OSPF。路由协议标识符（id）是用来标识通过指定的路由协议收到的路由信息。
  例如：PROTO_IP_OSPF是用来标识通过OSPF路有协议收到的路由信息；

③MIB_IPFORWARDROW类型中的dwForwardPolicy成员目前没有使用，指定为0。
}

function DeleteIpForwardEntry(const pRoute: MIB_IPFORWARDROW): DWORD; stdcall;
{$EXTERNALSYM DeleteIpForwardEntry}
{
 从本地电脑的IP路由表中删除一个路由

   pRoute： [输入] 指向一个MIB_IPFORWARDROW类型。这个类型指定了识别将要删除的路
          由的信息。调用者必须指定类型中以下成员的值：
          dwForwardIfIndex；dwForwardDest；dwForwardMask；dwForwardNextHop；dwForwardPolicy。

返回值：成功，返回0；失败，返回错误代码。

备注：①MIB_IPFORWARDROW类型是GetIpForwardTable返回的。接下来，再将此类型投递给
        DeleteForwardEntry函数，便可删除指定的路由条目了。
② MIB_IPFORWARDROW类型的 dwForwardPolicy目前未使用，应该设置为0。
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
启用或者禁止转发IP包或设置本机TTL值

pIpStats：[输入] 指向一个MIB_IPSTATS类型。调用者应该为此类型的dwForwarding和
         dwDefaultTTL成员设置新值。保持某个成员的值，使用MIB_USE_CURRENT_TTL或者         MIB_USE_CURRENT_FORWARDING。

返回值：成功，返回0；失败，返回错误代码。

备注：①在实际使用中，好像只能设置TTL的值，别的值设置有可能导致错误87（
        参数错误）或者虽然调用成功，但是并没有达到预期那样设置成功；
     ②设置默认的生存时间（TTL），也可以使用SetIpTTL函数。
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
设置本机默认的生存时间（time-to-live：TTL）值

参数说明：

nTTL： [输入] 本机的新的生存时间（TTL）

返回值：成功，返回0；失败，返回错误代码。
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
 在本地电脑的地址解析协议（ARP）表中创建一个ARP

 参数说明：

pArpEntry [输入] 指向一个指定了新接口信息的MIB_IPNETROW类型，调用者必须为这个类型
                 指定所有成员的值。

返回值：成功，返回0；失败，返回错误代码。
}

function SetIpNetEntry(const pArpEntry: MIB_IPNETROW): DWORD; stdcall;
{$EXTERNALSYM SetIpNetEntry}

function DeleteIpNetEntry(const pArpEntry: MIB_IPNETROW): DWORD; stdcall;
{$EXTERNALSYM DeleteIpNetEntry}
{
在本地电脑的地址解析协议（ARP）表中删除一个ARP

参数说明：

pArpEntry [输入] 指向一个指定了新接口信息的MIB_IPNETROW类型，调用者必须为这个类
              型指定所有成员的值。
返回值：成功，返回0；失败，返回错误代码。
}


function FlushIpNetTable(dwIfIndex: DWORD): DWORD; stdcall;
{$EXTERNALSYM FlushIpNetTable}
{
 从ARP表中删除指定接口的ARP接口

   dwIfIndex：[输入] 将要删除的ARP接口的序号

返回值：成功，返回0；失败，返回错误代码。

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
    为本地电脑指定的IP地址创建一个代理服务器地址解析协议（Proxy Address Resolution
Protocol ：PARP) 接口.

dwAddress：[输入] 作为代理服务器的电脑的IP地址。 

dwMask：[输入]指定了dwAddress的IP地址对应的子网掩码。 

dwIfIndex：[输入]代理服务地址解析协议（ARP）接口的索引通过dwAddress识别IP地址。换句话说，当dwAddress一个地址解析协议（ARP）请求在这个接口上被收到的时候，本地电脑的物理地址的接口作出响应。如果接口类型不支持地址解析协议（ARP），比如：端对端协议（PPP），那么调用失败。

返回值：成功，返回0；失败，返回错误代码。
}

function DeleteProxyArpEntry(dwAddress, dwMask, dwIfIndex: DWORD): DWORD; stdcall;
{$EXTERNALSYM DeleteProxyArpEntry}
{
   删除由dwAddress和dwIfIndex参数指定的PARP接口

  dwAddress：[输入] 作为代理服务器的电脑的IP地址

  dwMask：[输入] 对应dwAddress的子网掩码

  dwIfIndex:：[输入]对应IP 地址dwAddress指定的支持代理服务器地址解析协议（Proxy
        Address Resolution Protocol ：PARP）的电脑的接口序号。
返回值：成功，返回0；失败，返回错误代码。
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
设置TCP连接状态

参数说明：

PTcpRow：[输入]指向MIB_TCPROW类型，这个类型指定了TCP连接的标识，也指定了TCP连接的
             新状态。调用者必须指定此类型中所有成员的值。
备注：通常设置为MIB_TCP_STATE_DELETE_TCB（值为12）用来断开某个TCP连接，这也是唯
        一可在运行时设置的状态。
返回值：成功，返回0；失败，返回错误代码。
}

function GetInterfaceInfo(pIfTable: PIP_INTERFACE_INFO; var dwOutBufLen: ULONG): DWORD; stdcall;
{$EXTERNALSYM GetInterfaceInfo}
{
获得本机系统网络接口适配器的列表

参数说明：

pIfTable： [输入] 指向一个指定一个包含了适配器列表的IP_INTERFACE_INFO类型的缓存。
                 这个缓存应当由调用者分配。
dwOutBufLen：[输出] 指向一个DWORD变量。如果pIfTable参数为空，或者缓存不够大，这个
                  参数返回必须的大小。
返回值：成功，返回0；失败，返回错误代码。
}

function GetUniDirectionalAdapterInfo(pIPIfInfo: PIP_UNIDIRECTIONAL_ADAPTER_ADDRESS;
  var dwOutBufLen: ULONG): DWORD; stdcall;
{$EXTERNALSYM GetUniDirectionalAdapterInfo(OUT PIP_UNIDIRECTIONAL_ADAPTER_ADDRESS pIPIfInfo}
{
接收本机安装的单向适配器的信息

pIPIfInfo：[输出]指向一个接收本机已安装的单向适配器的信息的
                  IP_UNIDIRECTIONAL_ADAPTER_ADDRESS类型。
dwOutBufLen：[输出]指向一个ULONG变量用来保存pIPIfInfo参数缓存的大小。

返回值：成功，返回0；失败，返回错误代码。
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
返回包含到指定IP地址的最佳路由接口序号

dwDestAddr：[输入]目标IP地址 

pdwBestIfIndex：[输出] 指向一个包含到指定IP地址的最佳路由接口序号的DWORD变量

返回值：成功，返回0；失败，返回错误代码。
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
返回包含到指定IP地址的最佳路由

dwDestAddr：[输入]目标IP地址 

dwSourceAddr：[输入]源IP地址。这个Ip地址是本地电脑上相应的接口，如果有多个最佳路
      由存在，函数选择使用这个接口的路由。这个参数是可选的，调用者可以指定这个参数为0。
pBestRoute：[输出] 指向一个包含了最佳路由的MIB_IPFORWARDROW类型

返回值：成功，返回0；失败，返回错误代码。
}

function NotifyAddrChange(var Handle: THandle; overlapped: POVERLAPPED): DWORD; stdcall;
{$EXTERNALSYM NotifyAddrChange}
{
当IP地址到接口的映射表发生改变，将引发一个通知

  Handle：[输出]指向一个HANDLE变量，用来接收一个句柄handle使用到异步通知中。
                警告：不能关掉这个句柄。
   overlapped：[输入]指向一个OVERLAPPED类型，通知调用者任何IP地址到接口的映射表改变。

返回值：成功，如果调用者指定Handle和overlapped参数为空，返回NO_ERROR；如果调用者指
         定非空参数，返回ERROR_IO_PENDING。失败，使用FormatMessage获取错误信息。

备注：①如果调用者指定Handle和overlapped参数为空，对NotifyAddrChange的调用将会被
         阻止直到一个IP地址改变发生。
     ②调用者指定了一个handle变量和一个OVERLAPPED类型，调用者可以使用返回的handle以
       及OVERLAPPED类型来接收路由表改变的异步通知。
}

function NotifyRouteChange(var Handle: THandle; overlapped: POVERLAPPED): DWORD; stdcall;
{$EXTERNALSYM NotifyRouteChange}
{
IP路由表发生改变将引起一个通知

Handle：[输出]指向一个HANDLE变量，此变量接收一个用作异步通知的句柄。

overlapped：[输入]指向一个OVERLAPPED类型，此类型通知调用者路由表的每一个改变。 

返回值：成功，如果调用者指定Handle和overlapped参数为空，返回NO_ERROR；如果调用者指
       定非空参数，返回ERROR_IO_PENDING。失败，使用FormatMessage获取错误信息。

备注：①如果调用者指定Handle和overlapped参数为空，对NotifyRouteChange的调用将会被
        阻止直到一个路由表改变发生。
    ②调用者指定了一个handle变量和一个OVERLAPPED类型，调用者可以使用返回的handle
      以及OVERLAPPED类型来接收路由表改变的异步通知。
}
function GetAdapterIndex(AdapterName: LPWSTR; var IfIndex: ULONG): DWORD; stdcall;
{$EXTERNALSYM GetAdapterIndex}
{
从名称获得一个适配器的序号

 AdapterName：[输入] 指定了适配器名称的Unicode字符串 

 IfIndex：[输出] 指向一个指向适配器序号的ULONG变量指针

返回值：成功，返回0；失败，返回错误代码。
}

function AddIPAddress(Address: IPAddr; IpMask: IPMask; IfIndex: DWORD;
  var NTEContext, NTEInstance: ULONG): DWORD; stdcall;
{$EXTERNALSYM AddIPAddress}
{
增加一个IP地址

参数说明：

Address：[输入]要增加的IP地址 

IpMask：[输入]IP地址的子网掩码

IfIndex：[输入]增加IP地址的适配器，实际值为MIB_IPADDRTABLE.table(适配器编号).dwIndex

NTEContext：[输出]成功则指向一个与这个IP地址关联的网络表接口（Net Table Entry：NTE）ULONG变量。调用者可以在稍后使用这个关系到调用DeleteIPAddress。

NTEInstance：[输出]成功则指向这个IP地址的网络表接口（Net Table Entry：NTE）实例。 

返回值：成功，返回0；失败，返回错误代码。

备注：①增加的IP是临时的，当系统重新启动或者发生其它的PNP事件的时候这个IP就不存在
       了，比如将网卡禁用，然后启用，就会发现之前调用函数AddIPAddress增加的的IP地址不存
        在了。
     ②有时候，调用这个函数，可能造成网络出错、系统Arp映射错误等，但可以禁用\启
       用网卡恢复成正常状态。
}

function DeleteIPAddress(NTEContext: ULONG): DWORD; stdcall;
{$EXTERNALSYM DeleteIPAddress}
{
删除一个IP地址

参数说明：

NTEContext：[输入] IP地址关联的网络表接口（Net Table Entry：NTE），这个关联是之前
                   用AddIPAddress所创建的，在调用函数GetAdaptersInfo后，从获得的
                   IP_ADAPTER_INFO. IpAddressList. Context 中也可获得这个参数的值

返回值：成功，返回0；失败，返回错误代码。

备注：实际上函数DeleteIPAddress只能删除由函数AddIPAddress创建的IP地址。
}

function GetNetworkParams(pFixedInfo: PFIXED_INFO; var pOutBufLen: ULONG): DWORD; stdcall;
{$EXTERNALSYM GetNetworkParams}
{
获取本机网络参数

参数说明：

pFixedInfo：[输出]指向一个接收本机网络参数的数据块。

pOutBufLen：[输入，输出]指向一个ULONG变量，改变量指定了FixedInfo参数的大小。如果指
                 定的大小不够大，将设置为须要的大小并返回ERROR_BUFFER_OVERFLOW错误。

返回值：成功，返回0；失败，返回错误代码。
}

function GetAdaptersInfo(pAdapterInfo: PIP_ADAPTER_INFO; var pOutBufLen: ULONG): DWORD; stdcall;
{$EXTERNALSYM GetAdaptersInfo}
{
获取本机网络适配器的信息

参数说明：

pAdapterInfo：[输出] 指向一个IP_ADAPTER_INFO类型的连接表；

pOutBufLen：[输入] 指定pAdapterInfo参数的大小，如果指定大小不足，GetAdaptersInfo
                   将此参数置为所需大小, 并返回一个ERROR_BUFFER_OVERFLOW错误代码。

返回值：成功，返回0；失败，返回错误代码。

备注：此函数不能获得回环（Loopback）适配器的信息
}

function GetPerAdapterInfo(IfIndex: ULONG; pPerAdapterInfo: PIP_PER_ADAPTER_INFO;
  var pOutBufLen: ULONG): DWORD; stdcall;
{$EXTERNALSYM GetPerAdapterInfo}
{
返回与适配器相应的指定接口的信息

IfIndex：[输入] 一个接口的序号。函数将返回与这个序号相应的适配器接口信息。

pPerAdapterInfo：[输出]指向一个接收适配器信息的IP_PER_ADAPTER_INFO类型。

pOutBufLen：[输入]指向一个指定了IP_PER_ADAPTER_INFO类型ULONG变量。如果指定的大小不够大，将设置为须要的大小并返回ERROR_BUFFER_OVERFLOW错误。

返回值：成功，返回0；失败，返回错误代码。

备注：个人觉得实际使用时候，获取IfIndex比较困难，不如用GetAdaptersInfo。
}

function IpReleaseAddress(const AdapterInfo: IP_ADAPTER_INDEX_MAP): DWORD; stdcall;
{$EXTERNALSYM IpReleaseAddress}
{
放一个之前通过DHCP获得的IP地址

AdapterInfo：[输入]指向一个IP_ADAPTER_INDEX_MAP类型，指定了要释放的和IP地址关联的适配器。

返回值：成功，返回0；失败，返回错误代码。
}

function IpRenewAddress(const AdapterInfo: IP_ADAPTER_INDEX_MAP): DWORD; stdcall;
{$EXTERNALSYM IpRenewAddress}
{
更新一个之前通过DHCP获得的IP地址租期

AdapterInfo：[输入]指向一个IP_ADAPTER_INDEX_MAP类型，指定了与适配器关联的IP地址更新。

返回值：成功，返回0；失败，返回错误代码。
}

function SendARP(const DestIP, SrcIP: IPAddr; pMacAddr: PULONG; var PhyAddrLen: ULONG): DWORD; stdcall;
{$EXTERNALSYM SendARP}
{
获得目的地IP（只能是所在局域网中的IP）对应的物理地址

参数说明：

DestIP：[输入]目的地IP地址。 

SrcIP：[输入]发送地IP地址。可选参数，调用者可以指定此参数为0。

pMacAddr：[输出]指向一个ULONG变量数组（array）。数组前6个字节（bytes）接收由
                    DestIP指定的目的地IP物理地址。
PhyAddrLen：[输入，输出]输入，指定用户设置pMacAddr接收MAC地址的最大缓存大小，单位
                字节；输出，指定了写入pMacAddr的字节数量。
返回值：成功，返回0；失败，返回错误代码。

注意：
 inet_addr是Winsocket的函数而非"iphlpapi.dll"提供的函数，目的是将标准IP地址
 （"xxx.xxx.xxx.xxx"）的字符串转为电脑能识别的长整型的数据。
}

function GetRTTAndHopCount(DestIpAddress: IPAddr; var HopCount: ULONG;
  MaxHops: ULONG; var RTT: ULONG): BOOL; stdcall;
{$EXTERNALSYM GetRTTAndHopCount}
{
测定到指定目的地往返时间和跳跃数

DestIpAddress ：[输入]要测定RTT和跳跃数的目的地IP地址。 

HopCount：[输出] 指向一个ULONG变量。这个变量接收由DestIpAddress参数指定的到目的地的跳跃数。

MaxHops：[输入] 寻找目的地的最大跳跃数目。如果跳跃数超过这个数目，函数将终止搜寻并返回FALSE。

RTT：[输出] 到达DestIpAddress指定的目的地的往返时间（Round-trip time），单位毫秒。

返回值：成功返回 1，否则返回0。

}

function GetFriendlyIfIndex(IfIndex: DWORD): DWORD; stdcall;
{$EXTERNALSYM GetFriendlyIfIndex}
{
获得一个接口序号并返回一个反向兼容的接口序号

IfIndex：[输入] 来自反向兼容或者"友好"的接口序号

返回值：成功，返回0；失败，返回错误代码。
}

function EnableRouter(var pHandle: THandle; pOverlapped: POVERLAPPED): DWORD; stdcall;
{$EXTERNALSYM EnableRouter}
{
增加涉及的enable-IP-forwarding要求的数目

pHandle：指向一个句柄 

pOverlapped：指向一个OVERLAPPED类型。除了hEvent成员，类型中的其它成员必须设置为0。
      hEvent成员应该包含一个有效的事件对象的句柄。使用CreateEvent函数来创建这个事件对象。

返回值：成功，返回ERROR_IO_PENDING；失败，调用FormatMessage获取更多错误信息。
}

function UnenableRouter(pOverlapped: POVERLAPPED; lpdwEnableCount: LPDWORD): DWORD; stdcall;
{$EXTERNALSYM UnenableRouter}
{
减少涉及的enable-IP-forwarding要求数目

pOverlapped：指向一个OVERLAPPED类型。此类型必须和对EnableRouter的调用一样。 

lpdwEnableCount：[out, optional]指向接收涉及剩余数目的DWORD变量。 

备注：如果调用EnableRouter的进程没有调用UnenableRouter而终止，系统会减少IP推进涉
及的数目就象调用了UnenableRouter一样。调用UnenableRouter后，使用CloseHandle来关闭OVERLAPPED类型中的事件对象的句柄。

返回值：成功，返回0；失败，返回错误代码。
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

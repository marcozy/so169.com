{******************************************************************************}
{                                                       	                     }
{ Management Information Base API interface Unit for Object Pascal             }
{                                                       	                     }
{ Portions created by Microsoft are Copyright (C) 1995-2001 Microsoft          }
{ Corporation. All Rights Reserved.                                            }
{ 								                                                             }
{ The original file is: iprtrmib.h, released July 2000. The original Pascal    }
{ code is: IpRtrMib.pas, released September 2000. The initial developer of the }
{ Pascal code is Marcel van Brakel (brakelm@chello.nl).                        }
{                                                                              }
{ Portions created by Marcel van Brakel are Copyright (C) 1999-2001            }
{ Marcel van Brakel. All Rights Reserved.                                      }
{ 								               }
{ Contributor(s): John C. Penman (jcp@craiglockhart.com)                       }
{                 Vladimir Vassiliev (voldemarv@hotpop.com)                    }
{ 								               }
{ Obtained through: Joint Endeavour of Delphi Innovators (Project JEDI)        }
{								               }
{ You may retrieve the latest version of this file at the Project JEDI home    }
{ page, located at http://delphi-jedi.org or my personal homepage located at   }
{ http://members.chello.nl/m.vanbrakel2                                        }
{								               }
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
{ 								               }
{ For more information about the LGPL: http://www.gnu.org/copyleft/lesser.html }
{ 								               }
{******************************************************************************}

unit IpRtrMib;

{$WEAKPACKAGEUNIT}

{$HPPEMIT ''}
{$HPPEMIT '#include "iprtrmib.h"'}
{$HPPEMIT ''}

//{$I WINDEFINES.INC}

interface

uses
  Windows;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Included to get the value of MAX_INTERFACE_NAME_LEN                      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

// #include <mprapi.h>

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Included to get the necessary constants                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

// #include <ipifcons.h>

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// This is the Id for IP Router Manager.  The Router Manager handles        //
// MIB-II, Forwarding MIB and some enterprise specific information.         //
// Calls made with any other ID are passed on to the corresponding protocol //
// For example, an MprAdminMIBXXX call with a protocol ID of PID_IP and    //
// a routing Id of 0xD will be sent to the IP Router Manager and then       //
// forwarded to OSPF                                                        //
// This lives in the same number space as the protocol Ids of RIP, OSPF     //
// etc, so any change made to it should be done keeping this in mind        //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

const
  MAX_INTERFACE_NAME_LEN = 256; // MPRAPI.H
  {$EXTERNALSYM MAX_INTERFACE_NAME_LEN}
  
  IPRTRMGR_PID = 10000;
  {$EXTERNALSYM IPRTRMGR_PID}

  ANY_SIZE = 1;
  {$EXTERNALSYM ANY_SIZE}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// The following #defines are the Ids of the MIB variables made accessible  //
// to the user via MprAdminMIBXXX Apis.  It will be noticed that these are  //
// not the same as RFC 1213, since the MprAdminMIBXXX APIs work on rows and //
// groups instead of scalar variables                                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

  IF_NUMBER        = 0;
  {$EXTERNALSYM IF_NUMBER}
  IF_TABLE         = IF_NUMBER + 1;
  {$EXTERNALSYM IF_TABLE}
  IF_ROW           = IF_TABLE + 1;
  {$EXTERNALSYM IF_ROW}
  IP_STATS         = IF_ROW + 1;
  {$EXTERNALSYM IP_STATS}
  IP_ADDRTABLE     = IP_STATS + 1;
  {$EXTERNALSYM IP_ADDRTABLE}
  IP_ADDRROW       = IP_ADDRTABLE + 1;
  {$EXTERNALSYM IP_ADDRROW}
  IP_FORWARDNUMBER = IP_ADDRROW + 1;
  {$EXTERNALSYM IP_FORWARDNUMBER}
  IP_FORWARDTABLE  = IP_FORWARDNUMBER + 1;
  {$EXTERNALSYM IP_FORWARDTABLE}
  IP_FORWARDROW    = IP_FORWARDTABLE + 1;
  {$EXTERNALSYM IP_FORWARDROW}
  IP_NETTABLE      = IP_FORWARDROW + 1;
  {$EXTERNALSYM IP_NETTABLE}
  IP_NETROW        = IP_NETTABLE + 1;
  {$EXTERNALSYM IP_NETROW}
  ICMP_STATS       = IP_NETROW + 1;
  {$EXTERNALSYM ICMP_STATS}
  TCP_STATS        = ICMP_STATS + 1;
  {$EXTERNALSYM TCP_STATS}
  TCP_TABLE        = TCP_STATS + 1;
  {$EXTERNALSYM TCP_TABLE}
  TCP_ROW          = TCP_TABLE + 1;
  {$EXTERNALSYM TCP_ROW}
  UDP_STATS        = TCP_ROW + 1;
  {$EXTERNALSYM UDP_STATS}
  UDP_TABLE        = UDP_STATS + 1;
  {$EXTERNALSYM UDP_TABLE}
  UDP_ROW          = UDP_TABLE + 1;
  {$EXTERNALSYM UDP_ROW}
  MCAST_MFE        = UDP_ROW + 1;
  {$EXTERNALSYM MCAST_MFE}
  MCAST_MFE_STATS  = MCAST_MFE + 1;
  {$EXTERNALSYM MCAST_MFE_STATS}
  BEST_IF          = MCAST_MFE_STATS + 1;
  {$EXTERNALSYM BEST_IF}
  BEST_ROUTE       = BEST_IF + 1;
  {$EXTERNALSYM BEST_ROUTE}
  PROXY_ARP        = BEST_ROUTE + 1;
  {$EXTERNALSYM PROXY_ARP}
  MCAST_IF_ENTRY   = PROXY_ARP + 1;
  {$EXTERNALSYM MCAST_IF_ENTRY}
  MCAST_GLOBAL     = MCAST_IF_ENTRY + 1;
  {$EXTERNALSYM MCAST_GLOBAL}
  IF_STATUS        = MCAST_GLOBAL + 1;
  {$EXTERNALSYM IF_STATUS}
  MCAST_BOUNDARY   = IF_STATUS + 1;
  {$EXTERNALSYM MCAST_BOUNDARY}
  MCAST_SCOPE      = MCAST_BOUNDARY + 1;
  {$EXTERNALSYM MCAST_SCOPE}
  DEST_MATCHING    = MCAST_SCOPE + 1;
  {$EXTERNALSYM DEST_MATCHING}
  DEST_LONGER      = DEST_MATCHING + 1;
  {$EXTERNALSYM DEST_LONGER}
  DEST_SHORTER     = DEST_LONGER + 1;
  {$EXTERNALSYM DEST_SHORTER}
  ROUTE_MATCHING   = DEST_SHORTER + 1;
  {$EXTERNALSYM ROUTE_MATCHING}
  ROUTE_LONGER     = ROUTE_MATCHING + 1;
  {$EXTERNALSYM ROUTE_LONGER}
  ROUTE_SHORTER    = ROUTE_LONGER + 1;
  {$EXTERNALSYM ROUTE_SHORTER}
  ROUTE_STATE      = ROUTE_SHORTER + 1;
  {$EXTERNALSYM ROUTE_STATE}

  NUMBER_OF_EXPORTED_VARIABLES = ROUTE_STATE + 1;
  {$EXTERNALSYM NUMBER_OF_EXPORTED_VARIABLES}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MIB_OPAQUE_QUERY is the structure filled in by the user to identify a    //
// MIB variable                                                             //
//                                                                          //
//  dwVarId     ID of MIB Variable (One of the Ids #defined above)          //
//  dwVarIndex  Variable sized array containing the indices needed to       //
//              identify a variable. NOTE: Unlike SNMP we dont require that //
//              a scalar variable be indexed by 0                           //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

type
  PMIB_OPAQUE_QUERY = ^MIB_OPAQUE_QUERY;
  {$EXTERNALSYM PMIB_OPAQUE_QUERY}
  _MIB_OPAQUE_QUERY = record
    dwVarId: DWORD;
    rgdwVarIndex: array [0..ANY_SIZE - 1] of DWORD;
  end;
  {$EXTERNALSYM _MIB_OPAQUE_QUERY}
  MIB_OPAQUE_QUERY = _MIB_OPAQUE_QUERY;
  {$EXTERNALSYM MIB_OPAQUE_QUERY}
  TMibOpaqueQuery = MIB_OPAQUE_QUERY;
  PMibOpaqueQuery = PMIB_OPAQUE_QUERY;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// The following are the structures which are filled in and returned to the //
// user when a query is made, OR  are filled in BY THE USER when a set is   //
// done                                                                     //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

type
  PMIB_IFNUMBER = ^MIB_IFNUMBER;
  {$EXTERNALSYM PMIB_IFNUMBER}
  _MIB_IFNUMBER = record
    dwValue: DWORD;
  end;
  {$EXTERNALSYM _MIB_IFNUMBER}
  MIB_IFNUMBER = _MIB_IFNUMBER;
  {$EXTERNALSYM MIB_IFNUMBER}
  TMibIfnumber = MIB_IFNUMBER;
  PMibIfnumber = PMIB_IFNUMBER;

const
  MAXLEN_IFDESCR  = 256;
  {$EXTERNALSYM MAXLEN_IFDESCR}
  MAXLEN_PHYSADDR = 8;
  {$EXTERNALSYM MAXLEN_PHYSADDR}

type
  PMIB_IFROW = ^MIB_IFROW;
  {$EXTERNALSYM PMIB_IFROW}
  _MIB_IFROW = record
    wszName: array [0..MAX_INTERFACE_NAME_LEN - 1] of WCHAR; //接口名称的Unicode字符串，必须为512字节
    dwIndex: DWORD; //接口编号
    dwType: DWORD; //接口类型，参看IP_ADAPTER_INFO类型的Type成员
    dwMtu: DWORD; // 最大传输单元
    dwSpeed: DWORD;//接口速度（字节）
    dwPhysAddrLen: DWORD; //由bPhysAddr获得的物理地址有效长度
    bPhysAddr: array [0..MAXLEN_PHYSADDR - 1] of BYTE;  //物理地址
    dwAdminStatus: DWORD; //接口管理状态
    dwOperStatus: DWORD;// 操作状态
    dwLastChange: DWORD;//操作状态最后改变的时间
    dwInOctets: DWORD;  //总共收到(字节)
    dwInUcastPkts: DWORD; //总共收到(unicast包)
    dwInNUcastPkts: DWORD; //总共收到(non-unicast包)，包括广播包和多点传送包
    dwInDiscards: DWORD;//收到后丢弃包总数（即使没有错误）
    dwInErrors: DWORD; // 收到出错包总数
    dwInUnknownProtos: DWORD; //收到后因协议不明而丢弃的包总数
    dwOutOctets: DWORD; //总共发送(字节)
    dwOutUcastPkts: DWORD;// 总共发送(unicast包)
    dwOutNUcastPkts: DWORD;//总共发送(non-unicast包)，包括广播包和多点传送包
    dwOutDiscards: DWORD;//发送丢弃包总数（即使没有错误）
    dwOutErrors: DWORD;// 发送出错包总数
    dwOutQLen: DWORD; // 发送队列长度
    dwDescrLen: DWORD;//  bDescr部分有效长度
    bDescr: array[0..MAXLEN_IFDESCR - 1] of BYTE; //接口描述
  end;
  {$EXTERNALSYM _MIB_IFROW}
  MIB_IFROW = _MIB_IFROW;
  {$EXTERNALSYM MIB_IFROW}
  TMibIfRow = MIB_IFROW;
  PMibIfRow = PMIB_IFROW;

  PMIB_IFTABLE = ^MIB_IFTABLE;
  {$EXTERNALSYM PMIB_IFTABLE}
  _MIB_IFTABLE = record
    dwNumEntries: DWORD;  //当前网络接口的总数
    table: array [0..ANY_SIZE - 1] of MIB_IFROW; //指向一个包含MIB_IFROW类型的指针
  end;
  {$EXTERNALSYM _MIB_IFTABLE}
  MIB_IFTABLE = _MIB_IFTABLE;
  {$EXTERNALSYM MIB_IFTABLE}
  TMibIftable = MIB_IFTABLE;
  PMibIftable = PMIB_IFTABLE;

// #define SIZEOF_IFTABLE(X) (FIELD_OFFSET(MIB_IFTABLE,table[0]) + ((X) * sizeof(MIB_IFROW)) + ALIGN_SIZE)

type
  PMibIcmpStats = ^TMibIcmpStats;
  _MIBICMPSTATS = record {包含ICMP (Internet Control Message Protocol)接收或发出的统计信息}
    dwMsgs: DWORD;//已收发多少消息
    dwErrors: DWORD;//已收发多少错误
    dwDestUnreachs: DWORD; //已收发多少"目标不可抵达"消息
    dwTimeExcds: DWORD;//已收发多少生存期已过消息
    dwParmProbs: DWORD; //已收发多少表明数据报内有错误IP信息的消息
    dwSrcQuenchs: DWORD;//已收发多少源结束消息
    dwRedirects: DWORD;//已收发多少重定向消息
    dwEchos: DWORD;//已收发多少ICMP响应请求
    dwEchoReps: DWORD;//已收发多少ICMP响应应答
    dwTimestamps: DWORD;//已收发多少时间戳请求
    dwTimestampReps: DWORD;//已收发多少时间戳响应
    dwAddrMasks: DWORD;//已收发多少地址掩码
    dwAddrMaskReps: DWORD; //已收发多少地址掩码响应
  end;
  {$EXTERNALSYM _MIBICMPSTATS}
  MIBICMPSTATS = _MIBICMPSTATS;
  {$EXTERNALSYM MIBICMPSTATS}
  TMibIcmpStats = _MIBICMPSTATS;

  PMibIcmpInfo = ^TMibIcmpInfo;
  _MIBICMPINFO = record {通过MIBICMPSTATS结构存储的接收或发出的ICMP信息。}
    icmpInStats: MIBICMPSTATS; //指向MIBICMPSTATS类型，包含接收数据
    icmpOutStats: MIBICMPSTATS;// 指向MIBICMPSTATS类型，包含发出数据
  end;
  {$EXTERNALSYM _MIBICMPINFO}
  MIBICMPINFO = _MIBICMPINFO;
  {$EXTERNALSYM MIBICMPINFO}
  TMibIcmpInfo = MIBICMPINFO;

  PMIB_ICMP = ^MIB_ICMP;
  {$EXTERNALSYM PMIB_ICMP}
  _MIB_ICMP = record //为特殊适配器包含网间控制报文协议（ICMP）统计表。
    stats: MIBICMPINFO;//指定MIBICMPINFO类型包含了电脑ICMP统计信息表
  end;
  {$EXTERNALSYM _MIB_ICMP}
  MIB_ICMP = _MIB_ICMP;
  {$EXTERNALSYM MIB_ICMP}
  TMibIcmp = MIB_ICMP;
  PMibIcmp = PMIB_ICMP;

  PMIB_UDPSTATS = ^MIB_UDPSTATS;
  {$EXTERNALSYM PMIB_UDPSTATS}
  _MIB_UDPSTATS = record {包含UDP (User Datagram Protocol) 运行信息}
    dwInDatagrams: DWORD; //已收到数据报数目
    dwNoPorts: DWORD; //因为端口号有误而丢弃的数据报数目
    dwInErrors: DWORD;//已收到多少错误数据报，不包括dwNoPorts中统计的数目
    dwOutDatagrams: DWORD; //已传输数据报数目
    dwNumAddrs: DWORD; //UDP监听者表中接口数目
  end;
  {$EXTERNALSYM _MIB_UDPSTATS}
  MIB_UDPSTATS = _MIB_UDPSTATS;
  {$EXTERNALSYM MIB_UDPSTATS}
  TMibUdpStats = MIB_UDPSTATS;
  PMibUdpStats = PMIB_UDPSTATS;

  PMIB_UDPROW = ^MIB_UDPROW;
  {$EXTERNALSYM PMIB_UDPROW}
  _MIB_UDPROW = record {包含发送和接收UDP数据包的地址信息}
    dwLocalAddr: DWORD;//本地IP
    dwLocalPort: DWORD; //本地端口
  end;
  {$EXTERNALSYM _MIB_UDPROW}
  MIB_UDPROW = _MIB_UDPROW;
  {$EXTERNALSYM MIB_UDPROW}
  TMibUdpRow = MIB_UDPROW;
  PMibUdpRow = PMIB_UDPROW;

  PMIB_UDPTABLE = ^MIB_UDPTABLE;
  {$EXTERNALSYM PMIB_UDPTABLE}
  _MIB_UDPTABLE = record
    dwNumEntries: DWORD; //当前 UDP连接的总数
    table: array [0..ANY_SIZE - 1] of MIB_UDPROW; //指向包含MIB_UDPROW类型的指针
  end;
  {$EXTERNALSYM _MIB_UDPTABLE}
  MIB_UDPTABLE = _MIB_UDPTABLE;
  {$EXTERNALSYM MIB_UDPTABLE}
  TMibUdpTable = MIB_UDPTABLE;
  PMibUdpTable = PMIB_UDPTABLE;

// #define SIZEOF_UDPTABLE(X) (FIELD_OFFSET(MIB_UDPTABLE, table[0]) + ((X) * sizeof(MIB_UDPROW)) + ALIGN_SIZE)

  PMIB_TCPSTATS = ^MIB_TCPSTATS;
  {$EXTERNALSYM PMIB_TCPSTATS}
  _MIB_TCPSTATS = record   {包含本机上正运行的TCP协议的统计表}
    dwRtoAlgorithm: DWORD;//指定重传输(RTO：retransmission time-out)算法
    dwRtoMin: DWORD;//重传输超时的最小值，毫秒
    dwRtoMax: DWORD;//重传输超时的最大值，毫秒
    dwMaxConn: DWORD; //连接最大数目，如果为-1，则连接的最大数目是可变的
    dwActiveOpens: DWORD;//主动连接数目，即客户端正向服务器进行连接数目
    dwPassiveOpens: DWORD;//被动连接数目，即服务器监听连接客户端请求数目
    dwAttemptFails: DWORD;// 尝试连接失败的次数
    dwEstabResets: DWORD;//对已建立的连接实行重设的次数
    dwCurrEstab: DWORD; //目前已建立的连接
    dwInSegs: DWORD; //收到分段数据报的数目
    dwOutSegs: DWORD;//传输的分段数据报数目，不包括转发的数据包
    dwRetransSegs: DWORD;//转发的分段数据报数目
    dwInErrs: DWORD; //收到错误的数目
    dwOutRsts: DWORD;//重设标志设定后传输分段数据报数目
    dwNumConns: DWORD; //累计连接的总数
  end;
  {$EXTERNALSYM _MIB_TCPSTATS}
  MIB_TCPSTATS = _MIB_TCPSTATS;
  {$EXTERNALSYM MIB_TCPSTATS}
  TMibTcpStats = MIB_TCPSTATS;
  PMibTcpStats = PMIB_TCPSTATS;

const
  MIB_TCP_RTO_OTHER    = 1;
  {$EXTERNALSYM MIB_TCP_RTO_OTHER}
  MIB_TCP_RTO_CONSTANT = 2;
  {$EXTERNALSYM MIB_TCP_RTO_CONSTANT}
  MIB_TCP_RTO_RSRE     = 3;
  {$EXTERNALSYM MIB_TCP_RTO_RSRE}
  MIB_TCP_RTO_VANJ     = 4;
  {$EXTERNALSYM MIB_TCP_RTO_VANJ}

  MIB_TCP_MAXCONN_DYNAMIC = DWORD(-1);
  {$EXTERNALSYM MIB_TCP_MAXCONN_DYNAMIC}

type
  PMIB_TCPROW = ^MIB_TCPROW;
  {$EXTERNALSYM PMIB_TCPROW}
  _MIB_TCPROW = record
    dwState: DWORD;//CP连接状态
    dwLocalAddr: DWORD;//本地IP
    dwLocalPort: DWORD;//本地端口
    dwRemoteAddr: DWORD;//远程机器IP
    dwRemotePort: DWORD;//远程机器端口
  end;
  {$EXTERNALSYM _MIB_TCPROW}
  MIB_TCPROW = _MIB_TCPROW; {类型包含了TCP连接信息。}
  {$EXTERNALSYM MIB_TCPROW}
  TMibTcpRow = MIB_TCPROW;
  PMibTcpRow = PMIB_TCPROW;

const   {TCP连接状态}
  MIB_TCP_STATE_CLOSED     = 1; // 关闭
  {$EXTERNALSYM MIB_TCP_STATE_CLOSED}
  MIB_TCP_STATE_LISTEN     = 2; //监听
  {$EXTERNALSYM MIB_TCP_STATE_LISTEN}
  MIB_TCP_STATE_SYN_SENT   = 3; //同步发送
  {$EXTERNALSYM MIB_TCP_STATE_SYN_SENT}
  MIB_TCP_STATE_SYN_RCVD   = 4;//同步接收
  {$EXTERNALSYM MIB_TCP_STATE_SYN_RCVD}
  MIB_TCP_STATE_ESTAB      = 5; // 已建立
  {$EXTERNALSYM MIB_TCP_STATE_ESTAB}
  MIB_TCP_STATE_FIN_WAIT1  = 6; //FINWAIT 1
  {$EXTERNALSYM MIB_TCP_STATE_FIN_WAIT1}
  MIB_TCP_STATE_FIN_WAIT2  = 7; // FINWAIT 2
  {$EXTERNALSYM MIB_TCP_STATE_FIN_WAIT2}
  MIB_TCP_STATE_CLOSE_WAIT = 8; //关闭等待
  {$EXTERNALSYM MIB_TCP_STATE_CLOSE_WAIT}
  MIB_TCP_STATE_CLOSING    = 9; //正在关闭
  {$EXTERNALSYM MIB_TCP_STATE_CLOSING}
  MIB_TCP_STATE_LAST_ACK   = 10; //最后一次确认
  {$EXTERNALSYM MIB_TCP_STATE_LAST_ACK}
  MIB_TCP_STATE_TIME_WAIT  = 11;//时间等待
  {$EXTERNALSYM MIB_TCP_STATE_TIME_WAIT}
  MIB_TCP_STATE_DELETE_TCB = 12;// 删除连接
  {$EXTERNALSYM MIB_TCP_STATE_DELETE_TCB}

type
  PMIB_TCPTABLE = ^MIB_TCPTABLE;//类型包含Tcp连接表。
  {$EXTERNALSYM PMIB_TCPTABLE}
  _MIB_TCPTABLE = record
    dwNumEntries: DWORD; //当前包含MIB_TCPROW类型的总数
    table: array [0..ANY_SIZE - 1] of MIB_TCPROW; //指向包含MIB_TCPROW类型的指针????
  end;
  {$EXTERNALSYM _MIB_TCPTABLE}
  MIB_TCPTABLE = _MIB_TCPTABLE;
  {$EXTERNALSYM MIB_TCPTABLE}
  TMibTcpTable = MIB_TCPTABLE;
  PMibTcpTable = PMIB_TCPTABLE;

// #define SIZEOF_TCPTABLE(X) (FIELD_OFFSET(MIB_TCPTABLE,table[0]) + ((X) * sizeof(MIB_TCPROW)) + ALIGN_SIZE)

const
  MIB_USE_CURRENT_TTL        = DWORD(-1);
  {$EXTERNALSYM MIB_USE_CURRENT_TTL}
  MIB_USE_CURRENT_FORWARDING = DWORD(-1);
  {$EXTERNALSYM MIB_USE_CURRENT_FORWARDING}

type
  PMIB_IPSTATS = ^MIB_IPSTATS;
  {$EXTERNALSYM PMIB_IPSTATS}
  _MIB_IPSTATS = record  {存储于电脑的IP协议运行信息。}
    dwForwarding: DWORD;//启用或者禁止转发IP包（IP forwarding）
    dwDefaultTTL: DWORD;//指定默认初始化的生存时间（TTL）的值
    dwInReceives: DWORD;//已收到数据包数目
    dwInHdrErrors: DWORD;//已收到报头有误的数据包数目
    dwInAddrErrors: DWORD;//已收到地址有误的数据包数目/
    dwForwDatagrams: DWORD;//已转发数据报数目
    dwInUnknownProtos: DWORD;//已收到协议不明的数据报数目
    dwInDiscards: DWORD;//已收到多少已丢弃的数据报
    dwInDelivers: DWORD;//已收到多少已投递的数据报
    dwOutRequests: DWORD;//发送IP请求传输的数据报数目，不包括转发的数据包
    dwRoutingDiscards: DWORD;//已丢弃的发送数据报数目
    dwOutDiscards: DWORD;//丢弃的传输数据报数目
    dwOutNoRoutes: DWORD;//没有路由目标IP地址而被丢弃的数据报数目
    dwReasmTimeout: DWORD;//分段数据报完全到达的最长时间，再此时间之外数据将被丢弃
    dwReasmReqds: DWORD;//需要重组的数据报数目
    dwReasmOks: DWORD; //已成功重组的数据报数目
    dwReasmFails: DWORD;//不能进行重组的数据报数目
    dwFragOks: DWORD;//已成功进行分段的数据报数目
    dwFragFails: DWORD;//不能进行分段的数据报数目，这些数据包将被丢弃
    dwFragCreates: DWORD;//可被分段的数据报数目
    dwNumIf: DWORD;//接口数目
    dwNumAddr: DWORD;//与此计算机关联的IP地址数目
    dwNumRoutes: DWORD;//路由表中可用的路由数目
  end;
  {$EXTERNALSYM _MIB_IPSTATS}
  MIB_IPSTATS = _MIB_IPSTATS;
  {$EXTERNALSYM MIB_IPSTATS}
  TMibIpStats = MIB_IPSTATS;
  PMibIpStats = PMIB_IPSTATS;

const
  MIB_IP_FORWARDING     = 1;
  {$EXTERNALSYM MIB_IP_FORWARDING}
  MIB_IP_NOT_FORWARDING = 2;
  {$EXTERNALSYM MIB_IP_NOT_FORWARDING}

type
  PMIB_IPADDRROW = ^MIB_IPADDRROW;
  {$EXTERNALSYM PMIB_IPADDRROW}
  _MIB_IPADDRROW = record {指定特殊IP地址的信息}
    dwAddr: DWORD;// 接口的IP地址
    dwIndex: DWORD; //与IP地址关联的接口之索引
    dwMask: DWORD;// 子网掩码
    dwBCastAddr: DWORD;//广播地址
    dwReasmSize: DWORD;//已收到的数据报重装后的最大长度
    unused1: Word;//未使用
    unused2: Word;//未使用
  end;
  {$EXTERNALSYM _MIB_IPADDRROW}
  MIB_IPADDRROW = _MIB_IPADDRROW;
  {$EXTERNALSYM MIB_IPADDRROW}
  TMibIpAddrRow = MIB_IPADDRROW;
  PMibIpAddrRow = PMIB_IPADDRROW;

  PMIB_IPADDRTABLE = ^MIB_IPADDRTABLE; {包含IP地址入口表}
  {$EXTERNALSYM PMIB_IPADDRTABLE}
  _MIB_IPADDRTABLE = record
    dwNumEntries: DWORD;//表明table字段数组中有多少MIB_IPADDROW条目
    table: array [0..ANY_SIZE - 1] of MIB_IPADDRROW;//MIB_IPADDRROW类型
  end;
  {$EXTERNALSYM _MIB_IPADDRTABLE}
  MIB_IPADDRTABLE = _MIB_IPADDRTABLE;
  {$EXTERNALSYM MIB_IPADDRTABLE}
  TMibIpAddrTable = _MIB_IPADDRTABLE;
  PMibIpAddrTable = PMIB_IPADDRTABLE;

// #define SIZEOF_IPADDRTABLE(X) (FIELD_OFFSET(MIB_IPADDRTABLE,table[0]) + ((X) * sizeof(MIB_IPADDRROW)) + ALIGN_SIZE)

type
  PMIB_IPFORWARDNUMBER = ^MIB_IPFORWARDNUMBER;
  {$EXTERNALSYM PMIB_IPFORWARDNUMBER}
  _MIB_IPFORWARDNUMBER = record
    dwValue: DWORD;
  end;
  {$EXTERNALSYM _MIB_IPFORWARDNUMBER}
  MIB_IPFORWARDNUMBER = _MIB_IPFORWARDNUMBER;
  {$EXTERNALSYM MIB_IPFORWARDNUMBER}
  TMibIpForwardNumber = MIB_IPFORWARDNUMBER;
  PMibIpForwardNumber = PMIB_IPFORWARDNUMBER;

  PMIB_IPFORWARDROW = ^MIB_IPFORWARDROW;
  {$EXTERNALSYM PMIB_IPFORWARDROW}
  _MIB_IPFORWARDROW = record  {包含描述IP网络路由的信息}
    dwForwardDest: DWORD; //目的地IP地址
    dwForwardMask: DWORD;//目的地主机的子网掩码
    dwForwardPolicy: DWORD;//将会引起多通道路由选择的设置条件。参看RFC 1354。
    dwForwardNextHop: DWORD;//路由器中IP地址的下一个跃点
    dwForwardIfIndex: DWORD;//路由的接口序号
    dwForwardType: DWORD;// RFC 1354中路由的定义
    dwForwardProto: DWORD;//生成路由的协议，具体IPX协议值参看Routprot.h，而IP条目参看Iprtrmib.h
    dwForwardAge: DWORD;//路由持续时间，毫秒。仅用于路由远程访问服务（RRAS）运行时候，并且仅当路由类型为PROTO_IP_NETMGMT。
    dwForwardNextHopAS: DWORD;//下一跃点的自治系统编号
    dwForwardMetric1: DWORD;//路由协议专有的公制值。详情参见RFC 1354。
    dwForwardMetric2: DWORD;//路由协议专有的公制值。详情参见RFC 1354。
    dwForwardMetric3: DWORD;//路由协议专有的公制值。详情参见RFC 1354。/
    dwForwardMetric4: DWORD;//路由协议专有的公制值。详情参见RFC 1354。
    dwForwardMetric5: DWORD;//路由协议专有的公制值。详情参见RFC 1354。
  end;
  {$EXTERNALSYM _MIB_IPFORWARDROW}
  MIB_IPFORWARDROW = _MIB_IPFORWARDROW;
  {$EXTERNALSYM MIB_IPFORWARDROW}
  TMibIpForwardRow = MIB_IPFORWARDROW;
  PMibIpForwardRow = PMIB_IPFORWARDROW;

const {RFC 1354中路由的定义}
  MIB_IPROUTE_TYPE_OTHER    = 1;  //其他
  {$EXTERNALSYM MIB_IPROUTE_TYPE_OTHER}
  MIB_IPROUTE_TYPE_INVALID  = 2; //非法路由
  {$EXTERNALSYM MIB_IPROUTE_TYPE_INVALID}
  MIB_IPROUTE_TYPE_DIRECT   = 3;//下一个跃点是目的地(本地路由)
  {$EXTERNALSYM MIB_IPROUTE_TYPE_DIRECT}
  MIB_IPROUTE_TYPE_INDIRECT = 4; // 下一个跃点不是目的地 (远程路由)
  {$EXTERNALSYM MIB_IPROUTE_TYPE_INDIRECT}

  MIB_IPROUTE_METRIC_UNUSED = DWORD(-1);
  {$EXTERNALSYM MIB_IPROUTE_METRIC_UNUSED}

//
// THESE MUST MATCH the ids in routprot.h
//

const
  MIB_IPPROTO_OTHER   = 1;
  {$EXTERNALSYM MIB_IPPROTO_OTHER}
  MIB_IPPROTO_LOCAL   = 2;
  {$EXTERNALSYM MIB_IPPROTO_LOCAL}
  MIB_IPPROTO_NETMGMT = 3;
  {$EXTERNALSYM MIB_IPPROTO_NETMGMT}
  MIB_IPPROTO_ICMP    = 4;
  {$EXTERNALSYM MIB_IPPROTO_ICMP}
  MIB_IPPROTO_EGP     = 5;
  {$EXTERNALSYM MIB_IPPROTO_EGP}
  MIB_IPPROTO_GGP     = 6;
  {$EXTERNALSYM MIB_IPPROTO_GGP}
  MIB_IPPROTO_HELLO   = 7;
  {$EXTERNALSYM MIB_IPPROTO_HELLO}
  MIB_IPPROTO_RIP     = 8;
  {$EXTERNALSYM MIB_IPPROTO_RIP}
  MIB_IPPROTO_IS_IS   = 9;
  {$EXTERNALSYM MIB_IPPROTO_IS_IS}
  MIB_IPPROTO_ES_IS   = 10;
  {$EXTERNALSYM MIB_IPPROTO_ES_IS}
  MIB_IPPROTO_CISCO   = 11;
  {$EXTERNALSYM MIB_IPPROTO_CISCO}
  MIB_IPPROTO_BBN     = 12;
  {$EXTERNALSYM MIB_IPPROTO_BBN}
  MIB_IPPROTO_OSPF    = 13;
  {$EXTERNALSYM MIB_IPPROTO_OSPF}
  MIB_IPPROTO_BGP     = 14;
  {$EXTERNALSYM MIB_IPPROTO_BGP}

  MIB_IPPROTO_NT_AUTOSTATIC     = 10002;
  {$EXTERNALSYM MIB_IPPROTO_NT_AUTOSTATIC}
  MIB_IPPROTO_NT_STATIC         = 10006;
  {$EXTERNALSYM MIB_IPPROTO_NT_STATIC}
  MIB_IPPROTO_NT_STATIC_NON_DOD = 10007;
  {$EXTERNALSYM MIB_IPPROTO_NT_STATIC_NON_DOD}

type
  PMIB_IPFORWARDTABLE = ^MIB_IPFORWARDTABLE;
  {$EXTERNALSYM PMIB_IPFORWARDTABLE}
  _MIB_IPFORWARDTABLE = record  {包含了IP路由表接口}
    dwNumEntries: DWORD;// 表中路由接口数目
    table: array [0..ANY_SIZE - 1] of MIB_IPFORWARDROW;
  end;
  {$EXTERNALSYM _MIB_IPFORWARDTABLE}
  MIB_IPFORWARDTABLE = _MIB_IPFORWARDTABLE;
  {$EXTERNALSYM MIB_IPFORWARDTABLE}
  TMibIpForwardTable = MIB_IPFORWARDTABLE;
  PMibIpForwardTable = PMIB_IPFORWARDTABLE;

// #define SIZEOF_IPFORWARDTABLE(X) (FIELD_OFFSET(MIB_IPFORWARDTABLE,table[0]) + ((X) * sizeof(MIB_IPFORWARDROW)) + ALIGN_SIZE)

type
  PMIB_IPNETROW = ^MIB_IPNETROW;
  {$EXTERNALSYM PMIB_IPNETROW}
  _MIB_IPNETROW = record {包含地址解析协议（ARP ：Address Resolution Protocol）接口信息}
    dwIndex: DWORD;//指定适配器的索引
    dwPhysAddrLen: DWORD;//bPhysAddrs字段内包含的物理接口的长度(字节)，通常为6
    bPhysAddr: array [0..MAXLEN_PHYSADDR - 1] of BYTE;//字节数组，包含适配器的物理地址
    dwAddr: DWORD;//IP地址
    dwType: DWORD;//ARP接口的类型
  end;
  {$EXTERNALSYM _MIB_IPNETROW}
  MIB_IPNETROW = _MIB_IPNETROW;
  {$EXTERNALSYM MIB_IPNETROW}
  TMibIpNetRow = MIB_IPNETROW;
  PMibIpNetRow = PMIB_IPNETROW;

const {ARP接口的类型}
  MIB_IPNET_TYPE_OTHER   = 1; //其他条目
  {$EXTERNALSYM MIB_IPNET_TYPE_OTHER}
  MIB_IPNET_TYPE_INVALID = 2; //无效条目
  {$EXTERNALSYM MIB_IPNET_TYPE_INVALID}
  MIB_IPNET_TYPE_DYNAMIC = 3;//动态条目
  {$EXTERNALSYM MIB_IPNET_TYPE_DYNAMIC}
  MIB_IPNET_TYPE_STATIC  = 4; //静态条目
  {$EXTERNALSYM MIB_IPNET_TYPE_STATIC}

type
  PMIB_IPNETTABLE = ^MIB_IPNETTABLE;
  {$EXTERNALSYM PMIB_IPNETTABLE}
  _MIB_IPNETTABLE = record  {包含地址解析协议（ARP ：Address Resolution Protocol）接口入口表。}
    dwNumEntries: DWORD; //当前包含MIB_IPNETROW类型的总数
    table: array [0..ANY_SIZE - 1] of MIB_IPNETROW; //
  end;
  {$EXTERNALSYM _MIB_IPNETTABLE}
  MIB_IPNETTABLE = _MIB_IPNETTABLE;
  {$EXTERNALSYM MIB_IPNETTABLE}
  TMibIpNetTable = MIB_IPNETTABLE;
  PMibIpNetTable = PMIB_IPNETTABLE;

// #define SIZEOF_IPNETTABLE(X) (FIELD_OFFSET(MIB_IPNETTABLE, table[0]) + ((X) * sizeof(MIB_IPNETROW)) + ALIGN_SIZE)

type
  PMIB_IPMCAST_OIF = ^MIB_IPMCAST_OIF;
  {$EXTERNALSYM PMIB_IPMCAST_OIF}
  _MIB_IPMCAST_OIF = record
    dwOutIfIndex: DWORD;
    dwNextHopAddr: DWORD;
    pvReserved: Pointer;
    dwReserved: DWORD;
  end;
  {$EXTERNALSYM _MIB_IPMCAST_OIF}
  MIB_IPMCAST_OIF = _MIB_IPMCAST_OIF;
  {$EXTERNALSYM MIB_IPMCAST_OIF}
  TMibIpmCastOif = MIB_IPMCAST_OIF;
  PMibIpmCastOif = PMIB_IPMCAST_OIF;

  PMIB_IPMCAST_MFE = ^MIB_IPMCAST_MFE;
  {$EXTERNALSYM PMIB_IPMCAST_MFE}
  _MIB_IPMCAST_MFE = record
    dwGroup: DWORD;
    dwSource: DWORD;
    dwSrcMask: DWORD;
    dwUpStrmNgbr: DWORD;
    dwInIfIndex: DWORD;
    dwInIfProtocol: DWORD;
    dwRouteProtocol: DWORD;
    dwRouteNetwork: DWORD;
    dwRouteMask: DWORD;
    ulUpTime: ULONG;
    ulExpiryTime: ULONG;
    ulTimeOut: ULONG;
    ulNumOutIf: ULONG;
    fFlags: DWORD;
    dwReserved: DWORD;
    rgmioOutInfo: array [0..ANY_SIZE - 1] of MIB_IPMCAST_OIF;
  end;
  {$EXTERNALSYM _MIB_IPMCAST_MFE}
  MIB_IPMCAST_MFE = _MIB_IPMCAST_MFE;
  {$EXTERNALSYM MIB_IPMCAST_MFE}
  TMibIpmCastMfe = MIB_IPMCAST_MFE;
  PMibIpmCastMfe = PMIB_IPMCAST_MFE;

  PMIB_MFE_TABLE = ^MIB_MFE_TABLE;
  {$EXTERNALSYM PMIB_MFE_TABLE}
  _MIB_MFE_TABLE = record
    dwNumEntries: DWORD;
    table: array [0..ANY_SIZE - 1] of MIB_IPMCAST_MFE;
  end;
  {$EXTERNALSYM _MIB_MFE_TABLE}
  MIB_MFE_TABLE = _MIB_MFE_TABLE;
  {$EXTERNALSYM MIB_MFE_TABLE}
  TMibMfeTable = MIB_MFE_TABLE;
  PMibMfeTable = PMIB_MFE_TABLE;


// #define SIZEOF_BASIC_MIB_MFE          \
//    (ULONG)(FIELD_OFFSET(MIB_IPMCAST_MFE, rgmioOutInfo[0]))

// #define SIZEOF_MIB_MFE(X)             \
//    (SIZEOF_BASIC_MIB_MFE + ((X) * sizeof(MIB_IPMCAST_OIF)))

type
  PMIB_IPMCAST_OIF_STATS = ^MIB_IPMCAST_OIF_STATS;
  {$EXTERNALSYM PMIB_IPMCAST_OIF_STATS}
  _MIB_IPMCAST_OIF_STATS = record
    dwOutIfIndex: DWORD;
    dwNextHopAddr: DWORD;
    pvDialContext: Pointer;
    ulTtlTooLow: ULONG;
    ulFragNeeded: ULONG;
    ulOutPackets: ULONG;
    ulOutDiscards: ULONG;
  end;
  {$EXTERNALSYM _MIB_IPMCAST_OIF_STATS}
  MIB_IPMCAST_OIF_STATS = _MIB_IPMCAST_OIF_STATS;
  {$EXTERNALSYM MIB_IPMCAST_OIF_STATS}
  TMibIpmCastOifStats = MIB_IPMCAST_OIF_STATS;
  PMibIpmCastOifStats = PMIB_IPMCAST_OIF_STATS;

  PMIB_IPMCAST_MFE_STATS = ^MIB_IPMCAST_MFE_STATS;
  {$EXTERNALSYM PMIB_IPMCAST_MFE_STATS}
  _MIB_IPMCAST_MFE_STATS = record
    dwGroup: DWORD;
    dwSource: DWORD;
    dwSrcMask: DWORD;
    dwUpStrmNgbr: DWORD;
    dwInIfIndex: DWORD;
    dwInIfProtocol: DWORD;
    dwRouteProtocol: DWORD;
    dwRouteNetwork: DWORD;
    dwRouteMask: DWORD;
    ulUpTime: ULONG;
    ulExpiryTime: ULONG;
    ulNumOutIf: ULONG;
    ulInPkts: ULONG;
    ulInOctets: ULONG;
    ulPktsDifferentIf: ULONG;
    ulQueueOverflow: ULONG;
    rgmiosOutStats: array [0..ANY_SIZE - 1] of MIB_IPMCAST_OIF_STATS;
  end;
  {$EXTERNALSYM _MIB_IPMCAST_MFE_STATS}
  MIB_IPMCAST_MFE_STATS = _MIB_IPMCAST_MFE_STATS;
  {$EXTERNALSYM MIB_IPMCAST_MFE_STATS}
  TMibIpmCastMfeStats = MIB_IPMCAST_MFE_STATS;
  PMibIpmCastMfeStats = PMIB_IPMCAST_MFE_STATS;

  PMIB_MFE_STATS_TABLE = ^MIB_MFE_STATS_TABLE;
  {$EXTERNALSYM PMIB_MFE_STATS_TABLE}
  _MIB_MFE_STATS_TABLE = record
    dwNumEntries: DWORD;
    table: array [0..ANY_SIZE - 1] of MIB_IPMCAST_MFE_STATS;
  end;
  {$EXTERNALSYM _MIB_MFE_STATS_TABLE}
  MIB_MFE_STATS_TABLE = _MIB_MFE_STATS_TABLE;
  {$EXTERNALSYM MIB_MFE_STATS_TABLE}
  TMibMfeStatsTable = MIB_MFE_STATS_TABLE;
  PMibMfeStatsTable = PMIB_MFE_STATS_TABLE;

// #define SIZEOF_BASIC_MIB_MFE_STATS    \
//    (ULONG)(FIELD_OFFSET(MIB_IPMCAST_MFE_STATS, rgmiosOutStats[0]))

// #define SIZEOF_MIB_MFE_STATS(X)       \
//    (SIZEOF_BASIC_MIB_MFE_STATS + ((X) * sizeof(MIB_IPMCAST_OIF_STATS)))

type
  PMIB_IPMCAST_GLOBAL = ^MIB_IPMCAST_GLOBAL;
  {$EXTERNALSYM PMIB_IPMCAST_GLOBAL}
  _MIB_IPMCAST_GLOBAL = record
    dwEnable: DWORD;
  end;
  {$EXTERNALSYM _MIB_IPMCAST_GLOBAL}
  MIB_IPMCAST_GLOBAL = _MIB_IPMCAST_GLOBAL;
  {$EXTERNALSYM MIB_IPMCAST_GLOBAL}
  TMibIpmCastGlobal = MIB_IPMCAST_GLOBAL;
  PMibIpmCastGlobal = PMIB_IPMCAST_GLOBAL;

  PMIB_IPMCAST_IF_ENTRY = ^MIB_IPMCAST_IF_ENTRY;
  {$EXTERNALSYM PMIB_IPMCAST_IF_ENTRY}
  _MIB_IPMCAST_IF_ENTRY = record
    dwIfIndex: DWORD;
    dwTtl: DWORD;
    dwProtocol: DWORD;
    dwRateLimit: DWORD;
    ulInMcastOctets: ULONG;
    ulOutMcastOctets: ULONG;
  end;
  {$EXTERNALSYM _MIB_IPMCAST_IF_ENTRY}
  MIB_IPMCAST_IF_ENTRY = _MIB_IPMCAST_IF_ENTRY;
  {$EXTERNALSYM MIB_IPMCAST_IF_ENTRY}
  TMibIpmCastIfEntry = MIB_IPMCAST_IF_ENTRY;
  PMibIpmCastIfEntry = PMIB_IPMCAST_IF_ENTRY;

  PMIB_IPMCAST_IF_TABLE = ^MIB_IPMCAST_IF_TABLE;
  {$EXTERNALSYM PMIB_IPMCAST_IF_TABLE}
  _MIB_IPMCAST_IF_TABLE = record
    dwNumEntries: DWORD;
    table: array [0..ANY_SIZE - 1] of MIB_IPMCAST_IF_ENTRY;
  end;
  {$EXTERNALSYM _MIB_IPMCAST_IF_TABLE}
  MIB_IPMCAST_IF_TABLE = _MIB_IPMCAST_IF_TABLE;
  {$EXTERNALSYM MIB_IPMCAST_IF_TABLE}
  TMibIpmCastIfTable = MIB_IPMCAST_IF_TABLE;
  PMibIpmCastIfTable = PMIB_IPMCAST_IF_TABLE;

// #define SIZEOF_MCAST_IF_TABLE(X) (FIELD_OFFSET(MIB_IPMCAST_IF_TABLE,table[0]) + ((X) * sizeof(MIB_IPMCAST_IF_ENTRY)) + ALIGN_SIZE)

type
  PMIB_IPMCAST_BOUNDARY = ^MIB_IPMCAST_BOUNDARY;
  {$EXTERNALSYM PMIB_IPMCAST_BOUNDARY}
  _MIB_IPMCAST_BOUNDARY = record
    dwIfIndex: DWORD;
    dwGroupAddress: DWORD;
    dwGroupMask: DWORD;
    dwStatus: DWORD;
  end;
  {$EXTERNALSYM _MIB_IPMCAST_BOUNDARY}
  MIB_IPMCAST_BOUNDARY = _MIB_IPMCAST_BOUNDARY;
  {$EXTERNALSYM MIB_IPMCAST_BOUNDARY}
  TMibIpmCastBoundary = MIB_IPMCAST_BOUNDARY;
  PMibIpmCastBoundary = PMIB_IPMCAST_BOUNDARY;

  PMIB_IPMCAST_BOUNDARY_TABLE = ^MIB_IPMCAST_BOUNDARY_TABLE;
  {$EXTERNALSYM PMIB_IPMCAST_BOUNDARY_TABLE}
  _MIB_IPMCAST_BOUNDARY_TABLE = record
    dwNumEntries: DWORD;
    table: array [0..ANY_SIZE - 1] of MIB_IPMCAST_BOUNDARY;
  end;
  {$EXTERNALSYM _MIB_IPMCAST_BOUNDARY_TABLE}
  MIB_IPMCAST_BOUNDARY_TABLE = _MIB_IPMCAST_BOUNDARY_TABLE;
  {$EXTERNALSYM MIB_IPMCAST_BOUNDARY_TABLE}
  TMibIpmCastBoundaryTable = MIB_IPMCAST_BOUNDARY_TABLE;
  PMibIpmCastBoundaryTable = PMIB_IPMCAST_BOUNDARY_TABLE;

// #define SIZEOF_BOUNDARY_TABLE(X) (FIELD_OFFSET(MIB_IPMCAST_BOUNDARY_TABLE,table[0]) + ((X) * sizeof(MIB_IPMCAST_BOUNDARY)) + ALIGN_SIZE)

type
  PMIB_BOUNDARYROW = ^MIB_BOUNDARYROW;
  {$EXTERNALSYM PMIB_BOUNDARYROW}
  MIB_BOUNDARYROW = record
    dwGroupAddress: DWORD;
    dwGroupMask: DWORD;
  end;
  {$EXTERNALSYM MIB_BOUNDARYROW}
  TMibBoundaryRow = MIB_BOUNDARYROW;
  PMibBoundaryRow = PMIB_BOUNDARYROW;

// Structure matching what goes in the registry in a block of type
// IP_MCAST_LIMIT_INFO.  This contains the fields of
// MIB_IPMCAST_IF_ENTRY which are configurable.

  PMIB_MCAST_LIMIT_ROW = ^MIB_MCAST_LIMIT_ROW;
  {$EXTERNALSYM PMIB_MCAST_LIMIT_ROW}
  MIB_MCAST_LIMIT_ROW = record
    dwTtl: DWORD;
    dwRateLimit: DWORD;
  end;
  {$EXTERNALSYM MIB_MCAST_LIMIT_ROW}
  TMibMcastLimitRow = MIB_MCAST_LIMIT_ROW;
  PMibMcastLimitRow = PMIB_MCAST_LIMIT_ROW;

const
  MAX_SCOPE_NAME_LEN = 255;
  {$EXTERNALSYM MAX_SCOPE_NAME_LEN}

//
// Scope names are unicode.  SNMP and MZAP use UTF-8 encoding.
//

type
  SN_CHAR = WCHAR;
  {$EXTERNALSYM SN_CHAR}
  SCOPE_NAME_BUFFER = array [0..MAX_SCOPE_NAME_LEN] of SN_CHAR;
  {$EXTERNALSYM SCOPE_NAME_BUFFER}
  SCOPE_NAME = ^SN_CHAR;
  {$EXTERNALSYM SCOPE_NAME}

  PMIB_IPMCAST_SCOPE = ^MIB_IPMCAST_SCOPE;
  {$EXTERNALSYM PMIB_IPMCAST_SCOPE}
  _MIB_IPMCAST_SCOPE = record
    dwGroupAddress: DWORD;
    dwGroupMask: DWORD;
    snNameBuffer: SCOPE_NAME_BUFFER;
    dwStatus: DWORD;
  end;
  {$EXTERNALSYM _MIB_IPMCAST_SCOPE}
  MIB_IPMCAST_SCOPE = _MIB_IPMCAST_SCOPE;
  {$EXTERNALSYM MIB_IPMCAST_SCOPE}
  TMibIpmCastScope = MIB_IPMCAST_SCOPE;
  PMibIpmCastScope = PMIB_IPMCAST_SCOPE;

  PMIB_IPDESTROW = ^MIB_IPDESTROW;
  {$EXTERNALSYM PMIB_IPDESTROW}
  _MIB_IPDESTROW = record
    ForwardRow: MIB_IPFORWARDROW;
    dwForwardPreference: DWORD;
    dwForwardViewSet: DWORD;
  end;
  {$EXTERNALSYM _MIB_IPDESTROW}
  MIB_IPDESTROW = _MIB_IPDESTROW;
  {$EXTERNALSYM MIB_IPDESTROW}
  TMibIpDestRow = MIB_IPDESTROW;
  PMibIpDestRow = PMIB_IPDESTROW;

  PMIB_IPDESTTABLE = ^MIB_IPDESTTABLE;
  {$EXTERNALSYM PMIB_IPDESTTABLE}
  _MIB_IPDESTTABLE = record
    dwNumEntries: DWORD;
    table: array [0..ANY_SIZE - 1] of MIB_IPDESTROW;
  end;
  {$EXTERNALSYM _MIB_IPDESTTABLE}
  MIB_IPDESTTABLE = _MIB_IPDESTTABLE;
  {$EXTERNALSYM MIB_IPDESTTABLE}
  TMibIpDestTable = MIB_IPDESTTABLE;
  PMibIpDestTable = PMIB_IPDESTTABLE;

  PMIB_BEST_IF = ^MIB_BEST_IF;
  {$EXTERNALSYM PMIB_BEST_IF}
  _MIB_BEST_IF = record
    dwDestAddr: DWORD;
    dwIfIndex: DWORD;
  end;
  {$EXTERNALSYM _MIB_BEST_IF}
  MIB_BEST_IF = _MIB_BEST_IF;
  {$EXTERNALSYM MIB_BEST_IF}
  TMibBestIf = MIB_BEST_IF;
  PMibBestIf = PMIB_BEST_IF;

  PMIB_PROXYARP = ^MIB_PROXYARP;
  {$EXTERNALSYM PMIB_PROXYARP}
  _MIB_PROXYARP = record
    dwAddress: DWORD;
    dwMask: DWORD;
    dwIfIndex: DWORD;
  end;
  {$EXTERNALSYM _MIB_PROXYARP}
  MIB_PROXYARP = _MIB_PROXYARP;
  {$EXTERNALSYM MIB_PROXYARP}
  TMibProxyArp = MIB_PROXYARP;
  PMibProxyArp = PMIB_PROXYARP;

  PMIB_IFSTATUS = ^MIB_IFSTATUS;
  {$EXTERNALSYM PMIB_IFSTATUS}
  _MIB_IFSTATUS = record
    dwIfIndex: DWORD;
    dwAdminStatus: DWORD;
    dwOperationalStatus: DWORD;
    bMHbeatActive: BOOL;
    bMHbeatAlive: BOOL;
  end;
  {$EXTERNALSYM _MIB_IFSTATUS}
  MIB_IFSTATUS = _MIB_IFSTATUS;
  {$EXTERNALSYM MIB_IFSTATUS}
  TMibIfStatus = MIB_IFSTATUS;
  PMibIfStatus = PMIB_IFSTATUS;

  PMIB_ROUTESTATE = ^MIB_ROUTESTATE;
  {$EXTERNALSYM PMIB_ROUTESTATE}
  _MIB_ROUTESTATE = record
    bRoutesSetToStack: BOOL;
  end;
  {$EXTERNALSYM _MIB_ROUTESTATE}
  MIB_ROUTESTATE = _MIB_ROUTESTATE;
  {$EXTERNALSYM MIB_ROUTESTATE}
  TMibRouteState = MIB_ROUTESTATE;
  PMibRouteState = PMIB_ROUTESTATE;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// All the info passed to (SET/CREATE) and from (GET/GETNEXT/GETFIRST)      //
// IP Router Manager is encapsulated in the following "discriminated"       //
// union.  To pass, say MIB_IFROW, use the following code                   //
//                                                                          //
//  PMIB_OPAQUE_INFO    pInfo;                                              //
//  PMIB_IFROW          pIfRow;                                             //
//  DWORD rgdwBuff[(MAX_MIB_OFFSET + sizeof(MIB_IFROW))/sizeof(DWORD) + 1]; //
//                                                                          //
//  pInfo   = (PMIB_OPAQUE_INFO)rgdwBuffer;                                 //
//  pIfRow  = (MIB_IFROW *)(pInfo->rgbyData);                               //
//                                                                          //
//  This can also be accomplished by using the following macro              //
//                                                                          //
//  DEFINE_MIB_BUFFER(pInfo,MIB_IFROW, pIfRow);                             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

type
  PMibOpaqueInfo = ^TMibOpaqueInfo;
  _MIB_OPAQUE_INFO = record
    dwId: DWORD;
    case Integer of
      0: (ullAlign: Int64); // ULONGLONG (unsigned!)
      1: (rgbyData: array [0..0] of BYTE);
  end;
  {$EXTERNALSYM _MIB_OPAQUE_INFO}
  MIB_OPAQUE_INFO = _MIB_OPAQUE_INFO;
  {$EXTERNALSYM MIB_OPAQUE_INFO}
  TMibOpaqueInfo = MIB_OPAQUE_INFO;

const
  MAX_MIB_OFFSET = 8;
  {$EXTERNALSYM MAX_MIB_OFFSET}

// #define MIB_INFO_SIZE(S)    (MAX_MIB_OFFSET + sizeof(S))

// #define MIB_INFO_SIZE_IN_DWORDS(S)      \
//    ((MIB_INFO_SIZE(S))/sizeof(DWORD) + 1)

// #define DEFINE_MIB_BUFFER(X,Y,Z)                                        \
//    DWORD		__rgdwBuff[MIB_INFO_SIZE_IN_DWORDS(Y)]; \
//    PMIB_OPAQUE_INFO    X = (PMIB_OPAQUE_INFO)__rgdwBuff;               \
//    Y *                 Z = (Y *)(X->rgbyData)

// #define CAST_MIB_INFO(X,Y,Z)    Z = (Y)(X->rgbyData)

implementation

end.

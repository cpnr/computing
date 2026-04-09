# HEP-KHU Data Analysis Farm
## System 구성요소
현재 system은 다음과 같이 구성되어 있습니다.

| 노드명 | CPU GHz/RAM GB | 세부 정보 | 주 용도 | 도입 시기 |
|---|---|---|---|---|
| hep | 40x2.4GHz<br/>128GB | Dell PowerEdge R540<br/>Intel Xeon Silver 4210R | Main services<br/>slurm control daemon<br/>login UI machine<br/>RAID 86TB+146TB | 2021.06 |
| lugia | 256x2.0GHz<br/>384GB | Dell PowerEdge R7525<br/>AMD EPYC 7702 64-Core | User login, terminal<br/>multithread-intensive tasks | 2020.10 |
| mewtwo | 12x3.2GHz<br/>128GB | MX-612D8A<br/>Intel(R) Xeon(R) CPU E5-1650 v4<br/>Xilinx Alveo U200 | JBOD disk pool 44TB<br/>System backup<br/>FPGA | 2018.06 |
| lapras | 128x2.9GHz<br/>256GB | YJ Workstation Custom liquid cooling<br/>AMD Ryzen Threadripper 3990X 64-Core<br/>4xGPU nvidia GTX-5090 | Deep learning, many-core jobs | 2020.04<br/>(2026.03 GPU업그레이드) |
| ho-oh | 64x3.0GHz<br/>128GB | Dell PowerEdge R7525<br/>AMD EPYC 7302 16-Core | slurm worker node | 2020.10 |
| raikou | 128x2.7GHz<br/>512GB | Dell PowerEdge R7625<br/>AMD EPYC 9334 32-Core | slurm worker node | 2023.12 |
| entei | 128x2.7GHz<br/>512GB | Dell PowerEdge R7625<br/>AMD EPYC 9334 32-Core | slurm worker node | 2023.12 |
| suicune | 128x2.7GHz<br/>512GB | Dell PowerEdge R7625<br/>AMD EPYC 9334 32-Core | slurm worker node | 2023.12 |
| jammanbo | 24x2.4GHz<br/>64GB | Dasan 파일서버<br/>Intel Xeon Silver 4510 | RAID 140TB | 2025.06 |
| naong | 8x3.8GHz<br/>64GB | 조립 데스크탑<br/>AMD Ryzen 3 4350G 4-Core<br/>GPU nvidia GTX-1080Ti | Legacy GPU | 2020 <br/>(2026.01 재배치) | 
| yabuon | 4x1.2GHz<br/>1GB | Raspberry Pi 3B 1.2<br/>ARM Cortex-A53 | Monitor environment<br/>temperature: DS18B20 | 2026.03 |
| mew | 4x3.5GHz<br/>16GB | 조립 데스크탑<br/>AMD Ryzen 3 2200G 4-Core | JBOD disk pool 18TB<br/>Cold storage | 2020 <br/>(2026.04 재배치) |

- 2026년 1월 자원 재분배를 진행했습니다.
  - ho-oh의 alveo카드를 mewtwo로 이전
  - mewtwo의 1080ti를 데스크탑으로 이전
  - mewtwo에 HDD 추가하고 SW raid 대신 jbod+mergerfs 구성
- 2026년 3월 GPU 업그레이드
  - lapras의 4x2080ti 고장과 수냉펌프 이상으로 4x5090으로 업그레이드 및 수리
- 2026년 4월 Cold storage 추가, lapras 10G 연결
 
## 저장공간 구성
파일서버들 별 용도에 따라 nfs로 저장 공간을 공유합니다. 편의상 동일한 물리적 디스크이지만 디렉토리별로 각각 마운트해 사용하기도 합니다.
- hep.lo
  - Raid (86TB) -> `/users/hep`, `/store/hep`, `/store/sw`
  - Raid (146TB) -> `/users/cpnr`, `/store/cpnr`
- jammanbo.lo
  - Raid (140TB) -> `/store/cpnr-data`
- mewtwo.lo
  - JBOD disk pool (44T) -> `/store/mewtwo`
  - archive disk (3.7T): NFS공유하지 않음. 전체 시스템의 중요한 파일들 백업 (indico자료, 웹서버 자료, 중요 설정 등)
- mew.lo
  - JBOD disk pool (18T) -> `/store/mew` (RENE data cold storage)

## 네트워크 구성
내부 네트워크는 데이터 전송 전용 10G, 일반 사용 및 관리용 1G로 연결했습니다.
- 10G: Dell EMC X4012 12SFP&SFP+
- 1G: HPE 1420-24G JG708B

```
HEP 네트워크 구성도

KREONET hep.khu.ac.kr ┐
                 eno1 │
      210.117.211.131 │
   GW:210.117.211.129 │     ┌───────────────┐
                      └─────┤ hep           │
               enp59s0f0 ┌──┤  /users/hep   ├──┐ enp1s0f0
      hep.lo 192.168.0.1 │  │  /users/cpnr  │  │ hep.mgmt 192.168.100.101
                         │  │  /store/hep   │  │ hep.idrac 192.168.0.101
                 ┌───────┘  │  /store/cpnr  │  └───────────────┐
      ┌─ ─ ─ ─ ─ ┴ ─ ┐      └───────────────┘               ┌─ ┴ ─ ─ ─ ─┐
   ┌──┤ Dell-10G HUB ├─[SFP+→RJ45]──────────────────────────┤ HP-1G HUB ├────────────────┐
   │  └─ ─ ─ ─ ─ ─ ┬ ┘                                      └─ ─ ─ ─ ─ ─┘                │
   │               └──────────────────────────┐                                          │
   │                ┌────────────────┐        │              ┌─────────┐                 │
   ├─ mewtwo.lo    ─┤ mewtwo (FPGA)  │        ├─ lugia.lo   ─┤ lugia   ├─ lugia.idrac   ─┤
   │  192.168.0.2   │  /store/mewtwo │        │  192.168.0.4 └─────────┘  192.168.0.104  │
   │                └────────────────┘        │              ┌─────────┐                 │
   │                ┌───────────────────┐     ├─ ho-oh.lo   ─┤ ho-oh   ├─ ho-oh.idrac   ─┤
   ├─ jammanbo.lo  ─┤ jammanbo          │     │  192.168.0.3 └─────────┘  192.168.0.103  │
   │  192.168.0.10  │  /store/cpnr-data │     │                                          │
   │                └───────────────────┘     │              ┌─────────┐                 │
[SFP+→RJ45]         ┌───────────────┐         ├─ raikou.lo  ─┤ raikou  ├─ raikou.idrac  ─┤
   └─ lapras.lo    ─┤ lapras (5090) │         │  192.168.0.6 └─────────┘  192.168.0.106  │
      192.168.0.5   └───────────────┘         │              ┌─────────┐                 │
                                              ├─ entei.lo   ─┤ entei   ├─ entei.idrac   ─┤
                    ┌───────────────┐         │  192.168.0.7 └─────────┘  192.168.0.107  │
   ┌─ naong.lo     ─┤ naong (1080)  │         │              ┌─────────┐                 │
   │  192.168.0.9   └───────────────┘         └─ suicune.lo ─┤ suicune ├─ suicune.idrac ─┤
   │                ┌───────────────┐            192.168.0.8 └─────────┘  192.168.0.108  │
   ├─ yabuon.lo    ─┤ mew           │                                                    │
   │  192.168.0.11  │  /store/mew   │                                                    │
   │                └───────────────┘                                                    │
   │                ┌───────────────┐                                                    │
   ├─ yabuon.lo    ─┤ yabuon (RP3)  │                                                    │
   │  192.168.0.201 └───────────────┘                                                    │
   └─────────────────────────────────────────────────────────────────────────────────────┘
```

## 도입 및 확장, 유지보수 재원
- 2018.06 / mewtwo 도입 / KHU-20180930(경희대) "기계 학습 방법을 응용한 탑 쿼크 재구성"
- 2020.04 / lapras 도입 / 2020R1C1C1008082(한국연구재단) "딥러닝 기반 중성미자를 포함하는 사건 재구성"
- 2020.10 / lugia, ho-oh 도입 / 2020R1C1C1008082(한국연구재단) "딥러닝 기반 중성미자를 포함하는 사건 재구성"
- 2021.01 / lugia 메모리 확장 / 1711133571(한국연구재단) "유럽핵입자물리연구소의 대형강입자가속기를 이용한 CMS실험"
- 2021.06 / hep 도입 / 2020R1C1C1008082(한국연구재단) "딥러닝 기반 중성미자를 포함하는 사건 재구성"
- 2021.09 / hep 서버 스토리지 확장 / 1711133571(한국연구재단) "유럽핵입자물리연구소의 대형강입자가속기를 이용한 CMS실험"
- 2022.08 / lapras 메모리 확장 / 2022R1A5A1030700(한국연구재단) "중성미자정밀연구센터"
- 2023.02 / ME1400 192TB storage 도입 / 2022R1A5A1030700(한국연구재단) "중성미자정밀연구센터"
- 2023.12 / raikou,entei,suicune 도입 / 2022R1A5A1030700(한국연구재단) "중성미자정밀연구센터"
- 2025.06 / jammanbo 스토리지서버 도입 / 2022R1A5A1030700(한국연구재단) "중성미자정밀연구센터"
- 2025.12 / lapras 5090 도입 / 2022R1A5A1030700(한국연구재단) "중성미자정밀연구센터"
- 2026.04 / mew 스토리지 도입, 확장 / 2022R1A5A1030700(한국연구재단) "중성미자정밀연구센터"

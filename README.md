# Computing for CPNR
경희대 입자실험연구실/중성미자정밀연구센터 컴퓨팅과 관련된 각종 이슈를 관리합니다.
사용중 문제나 제안사항이 있다면 본 repository의 issue를 만들어 관리합니다.

- 경희대 입자실험 서버와 겸용으로 사용하고 있습니다.
- Main web service: https://hep.khu.ac.kr
- Monitoring: https://hep.khu.ac.kr/observability
- CPNR indico: https://indico.neutrino.or.kr
- KHU-HEP/CPNR cluster: `ssh hep.khu.ac.kr -p 2222`

# Data Analysis Farm
## System구성
현재 system은 다음과 같이 구성되어 있습니다.

| 노드명 | CPU GHz/RAM GB | 세부 정보 | 주 용도 | 도입 시기 |
|---|---|---|---|---|
| hep | 40x2.4GHz<br/>128GB | Dell PowerEdge R540<br/>Intel Xeon Silver 4210R<br/>2.4-3.2GHz | Main services<br/>slurm control daemon<br/>login UI machine<br/>Storage 86TB(users), 146TB(cpnr) | 2021.06 |
| lugia | 256x2.0GHz<br/>384GB | Dell PowerEdge R7525<br/>AMD EPYC 7702 64-Core<br/>2.0-3.35GHz | User login, terminal<br/>multithread-intensive tasks | 2020.10 |
| mewtwo | 12x3.2GHz<br/>128GB | MX-612D8A<br/>Intel(R) Xeon(R) CPU E5-1650 v4<br/>3.2-3.8GHz<br/>GPU nvidia GTX-1080Ti | SW raid 21TB<br/>Deep learning test | 2018.06 |
| lapras | 128x2.9GHz<br/>256GB | YJ Workstation Custom liquid cooling<br/>AMD Ryzen Threadripper 3990X 64-Core<br/>2.9-4.3GHz<br/>4xGPU nvidia GTX-2080Ti | Deep learning, many-core jobs | 2020.04 |
| ho-oh | 64x3.0GHz<br/>128GB | Dell PowerEdge R7525<br/>AMD EPYC 7302 16-Core<br/>3.0-3.3GHz | FPGA Xilinx Alveo U200 | 2020.10 |
| raikou | 128x2.7GHz<br/>512GB | Dell PowerEdge R7625<br/>AMD EPYC 9334 32-Core<br/>2.7-3.9GHz | slurm worker node | 2023.12 |
| entei | 128x2.7GHz<br/>512GB | Dell PowerEdge R7625<br/>AMD EPYC 9334 32-Core<br/>2.7-3.9GHz | slurm worker node | 2023.12 |
| suicune | 128x2.7GHz<br/>512GB | Dell PowerEdge R7625<br/>AMD EPYC 9334 32-Core<br/>2.7-3.9GHz | slurm worker node | 2023.12 |

네트워크 구성은 아래와 같습니다.
```
HEP 네트워크 구성도

KREONET hep.khu.ac.kr ┐
                 eno1 │
      210.117.211.131 │
   GW:210.117.211.129 │     ┌─────────────┐
                      └─────┤ hep         │
                enp1s0f0 ┌──┤ /users      ├──┐ enp59s0f0
hep.mgmt 192.168.100.101 │  │ /store/sw   │  │ hep.lo 192.168.0.1
 hep.idrac 192.168.0.101 │  │ /store/hep  │  │ 
                         │  │ /store/cpnr │  │
          ┌──────────────┘  └─────────────┘  │ 
┌ ─ ─ ─ ─ ┴ ─ ┐                      ┌ ─ ─ ─ ┴ ─ ─ ─ ┐
│  HP-1G HUB  ├─────────────[gender]─┤ Dell-10G HUB  │ 
└ ┬ ─ ─ ─ ─ ─ ┘   ┌────────────────┐ └ ┬ ─ ─ ─ ─ ─ ─ ┘               
  ╞═ mewtwo.lo   ═╡ mewtwo (1080)  │   │              ┌─────────┐  
  │  192.168.0.2  │ /store/mewtwo  │   ├─ lugia.lo   ─┤ lugia   ├─ lugia.idrac   ─┐
  │               └────────────────┘   │  192.168.0.4 └─────────┘  192.168.0.104  │
  │               ┌────────────────┐   │              ┌─────────┐                 │
  ╞═ lapras.lo   ═╡ lapras (2080)  │   ├─ ho-oh.lo   ─┤ lugia   ├─ ho-oh.idrac   ─┤
  │  192.168.0.5  └────────────────┘   │  192.168.0.3 └─────────┘  192.168.0.103  │
  │                                    │                                          │
  │                                    │              ┌─────────┐                 │
  │                                    ├─ raikou.lo  ─┤ raikou  ├─ raikou.idrac  ─┤
  │                                    │  192.168.0.6 └─────────┘  192.168.0.106  │
  │                                    │              ┌─────────┐                 │
  │                                    ├─ entei.lo   ─┤ entei   ├─ entei.idrac   ─┤
  │                                    │  192.168.0.7 └─────────┘  192.168.0.107  │
  │                                    │              ┌─────────┐                 │
  │                                    ├─ suicune.lo ─┤ suicune ├─ suicune.idrac ─┤
  │                                    │  192.168.0.8 └─────────┘  192.168.0.108  │
  │                                                                               │
  └───────────────────────────────────────────────────────────────────────────────┘
```

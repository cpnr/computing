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

| 노드명 | CPU | RAM | 주 용도 | 도입년도 |
|---|---|---|---|---|
| hep | Intel Xeon Silver 4210R<br/>max 2.4-3.2GHz, 40 threads | 128GB | Main services<br/>slurm control daemon<br/>login UI machine<br/>Storage 86TB(users), 146TB(cpnr) | 2021.06 |
| mewtwo | Intel(R) Xeon(R) CPU E5-1650 v4<br/>3.2-3.8GHz, 12 threads | 128GB | GPU nvidia GTX-1080Ti<br/>SW raid 21TB | 2018.06 |
| lapras | AMD Ryzen Threadripper 3990X 64-Core<br/>2.9-4.3GHz, 128 threads | 256GB | GPU nvidia GTX-2080Ti<br/>liquid cooling | 2020.04 |
| lugia | AMD EPYC 7702 64-Core<br/>2.0-3.35GHz, 256 threads | 384GB | multithread-intensive tasks | 2020.10 |
| ho-oh | AMD EPYC 7302 16-Core<br/>3.0-3.3GHz, 64 threads | 128GB | FPGA Xilinx Alveo U200 | 2020.10 |
| raikou | AMD EPYC 9334 32-Core<br/>2.7-3.9GHz, 128 threads | 512GB | slurm worker node | 2023.12 |
| entei | AMD EPYC 9334 32-Core<br/>2.7-3.9GHz, 128 threads | 512GB | slurm worker node | 2023.12 |
| suicune | AMD EPYC 9334 32-Core<br/>2.7-3.9GHz, 128 threads | 512GB | slurm worker node | 2023.12 |

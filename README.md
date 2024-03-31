# Computing for CPNR
경희대 입자실험연구실/중성미자정밀연구센터 컴퓨팅과 관련된 각종 이슈를 관리합니다.
사용중 문제나 제안사항이 있다면 본 repository의 issue를 만들어 관리합니다.

- 경희대 입자실험 서버와 겸용으로 사용하고 있습니다.
- Main web service: https://hep.khu.ac.kr
- Monitoring: https://hep.khu.ac.kr/observability
- CPNR indico: https://indico.neutrino.or.kr
- KHU-HEP/CPNR cluster: `ssh hep.khu.ac.kr -p 2222`

## 컴퓨팅 자원 사용을 위한 기본 정보
본 서버는 경희대 입자실험연구실에서 구축, 관리하고 있습니다. 중성미자정밀연구센터, 한국CMS연구팀을 포함한
관련 연구자분들이 컴퓨팅 자원을 활용할 수 있도록 운영하고 있습니다.

- 네트워크 연결은 KISTI의 Kreonet(1G)망을 통해 연결됩니다.
- 중성미자정밀연구센터 이용자의 대용량 파일은 `/store/cpnr`을 이용해 주세요
- 시뮬레이션 샘플 생성, 대용량 데이터 분석 등은 `slurm` 배치 환경을 이용해 주세요.
- 컴퓨팅 자원에 대한 세부 정보는 [[여기]](https://github.com/cpnr/computing/blob/main/Resources.md)에서 확인할 수 있습니다.

## 계정 생성하기
경희대 고정환 교수에게 다음 정보와 함께 계정 생성 요청 해 주시면 됩니다.
- 이름, 소속기관
- 희망하는 로그인 아이디

## 사용 방법
### 서버 접속하기
서버 접속을 위해 ssh를 이용합니다. 아래의 `<USER_ID>`부분은 계정 신청했던 로그인 아이디입니다.
```
$ ssh hep.khu.ac.kr -p 2222 -l <USER_ID>
```

접속하면 아래 예시와 같은 화면이 나타납니다.
```
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-97-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

  System information as of Sun Mar 31 03:37:32 PM UTC 2024

  System load:  0.00537109375      Processes:                2318
  Usage of /:   2.5% of 422.46GB   Users logged in:          2
  Memory usage: 3%                 IPv4 address for docker0: 172.17.0.1
  Swap usage:   0%                 IPv4 address for eno33:   192.168.0.4

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

29 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

17 additional security updates can be applied with ESM Apps.
Learn more about enabling ESM Apps service at https://ubuntu.com/esm


*** System restart required ***
Last login: Sun Mar 31 13:59:58 2024 from 194.12.146.87
<USER_ID>@lugia:~$ 
```


# Computing KHU-HEP/CPNR
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

- 로그인 노드는 CPU 256 threads, Memory 384GB 환경입니다.
- 시뮬레이션 샘플 생성, 대용량 데이터 분석과 같은 작업 `slurm` 배치 환경을 이용해 주세요.
- 네트워크 연결은 KISTI 서울 홍릉분원의 Kreonet(1G)망을 통해 연결됩니다.
- 중성미자정밀연구센터 이용자의 대용량 파일은 `/store/cpnr`을 이용해 주세요.
- 컴퓨팅 자원에 대한 세부 정보는 [[여기]](https://github.com/cpnr/computing/blob/main/Resources.md)에서 확인할 수 있습니다.

## 계정 생성하기
경희대 고정환 교수에게 이메일로 계정 생성 요청 해 주시면 됩니다. 다음 정보를 함께 알려주세요.
- 이름, 소속기관
- 희망하는 로그인 아이디

계정 생성 후 사용 관련 추가 정보를 안내 해 드립니다.

## 사용 방법
### 서버 접속하기
서버 접속을 위해 ssh를 이용합니다. 아래의 `<USER_ID>`부분은 계정 신청했던 로그인 아이디입니다.
```bash
$ ssh hep.khu.ac.kr -p 2222 -l <USER_ID>
```

접속하면 아래 예시와 같은 화면이 나타납니다.
```
...
Last login: Sun Mar 31 13:59:58 2024 from 194.12.146.87
<USER_ID>@lugia:~$ 
```

### 소프트웨어 사용하기
#### anaconda 환경 사용하기
데이터 분석을 위한 환경으로 anaconda를 사용할 수 있습니다. 
anaconda를 사용하기 위해 아래 명령어를 실행해 기본 환경변수를 설정할 수 있습니다. 아래 내용을 `~/.bashrc`에 추가하시면 로그인할 때 자동으로 적용됩니다.
```bash
source /store/sw/anaconda3/etc/profile.d/conda.sh
```

python이나 root를 사용할 수 있는 anaconda 환경을 미리 만들어 두었습니다. 
아래 명령어를 이용해 활성화 할 수 있습니다.
```bash
conda activate ds4hep
```

필요하다면 개인별 환경을 설치해 활용할 수 있습니다. 
아래 예시의 `<MY_ENVIRONMENT>` 부분을 본인이 원하는 대로 바꿔 사용하시면 됩니다. 예시 중 `conda install` 부분도 본인이 필요한 패키지들을 찾아 바꿔 사용하시면 됩니다.
```bash
conda create -p ~/<MY_ENVIRONMENT>
conda activate <MY_ENVIRONMENT>
conda install -c conda-forge root
conda install -c conda-forge uproot matplotlib scipy numpy yaml
conda install -c conda-forge jupyter-notebook
```

공용으로 사용할만한 패키지들이 있으면 관리자 (고정환 교수)에게 알려주시거나, [[github issue]](https://github.com/cpnr/computing/issues)를 생성해 주세요.

#### apptiainer/singularity 컨테이너 환경 사용하기
다른 Linux배포판을 사용하는 경우, anaconda에 환경이 제공되지 않는 경우 일종의 가상화 환경인 singularity를 사용할 수 있습니다. 
singularity image파일을 만들어 배포하는 방식으로 일반 유저가 가상화 환경을 사용할 수 있어 편리합니다. 또한, docker 환경을 그대로 가져와서 사용할 수도 있습니다.

예를 들어, 아래와 같은 방식으로 pythia8의 docker환경을 가져와 사용할 수 있습니다.
```bash
apptainer run docker://mcnetschool/tutorial:pythia-1.0.0
```

미리 만들어 둔 singularity image파일들을 아래와 같은 방식으로 사용할 수 있습니다. `-B` 옵션을 이용해 시스템 내의 특정 디렉토리를 가상환경 내에서의 디렉토리로 보일 수 있도록 바인딩 합니다.
```bash
apptainer run -B /store/sw/hep/geant4-data:/hep-sw/geant4/share/Geant4-9.6.4/data /store/sw/singularity/geant4/geant4-9.6.4.sif
```

### slurm을 이용해 자원을 할당받아 사용하기
간단한 작업은 ssh접속 직후 로그인 환경에서 할 수 있지만, 계산량이나 메모리 사용량이 많은 작업은 slurm을 이용해 계산 노드로 작업을 제출해 사용해야 합니다. 
- 자세한 내용은 slurm 공식 문서 [[Slurm Quick Start]](https://slurm.schedmd.com/quickstart.html)나, [[공식 매뉴얼]](https://slurm.schedmd.com/documentation.html)을 참고 해 주세요.
- slurm사용중 문제가 있으면 관리자 (고정환 교수)에게 알려주시거나, [[github issue]](https://github.com/cpnr/computing/issues)를 생성해 주세요.

아래 예시와 같이 실행용 스크립트 작성 후 `sbatch` 명령어를 이용해 작업을 제출하시면 됩니다. (공식 매뉴얼 등을 참고해 다른 방법들을 이용하셔도 됩니다)
- 연구 수행을 위한 메인 프로그램 개발 (예시: pi값을 계산하는 python script, `compute_pi.py`)
```python
#!/usr/bin/env python
import numpy as np
import pandas as pd
import sys, os

def getenv(var, default=''):
    if var not in os.environ: return str(default)
    return os.environ[var]

jobId = int(getenv('SLURM_JOB_ID', 0))
jobSection = int(getenv('SLURM_ARRAY_TASK_ID', 0))
np.random.seed(jobId*1000+jobSection)

n = 100000
rx = np.random.uniform(-1, 1, n)
ry = np.random.uniform(-1, 1, n)
r2 = rx*rx + ry*ry
nIn = (r2<1).sum()

print(nIn, n, nIn/n*4)
```

- 실행용 bash script 작성 (예시: `run.sh`)
```bash
#SBATCH -J MYTESTJOB
#SBATCH -p normal
#SBATCH -o OUTPUT_%A_%a.log
#SBATCH -e OUTPUT_%A_%a.err

hostname

source /store/sw/anaconda3/etc/profile.d/conda.sh
conda activate ds4hep

python compute_pi.py
```

- 로그인 환경에서 job submit하기 (예시: slurm의 array 기능을 이용해 한번에 10개 job을 제출)
```bash
sbatch -a [0-9] run.sh
```

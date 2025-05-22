# 🐾 Light Western Food

Flutter 기반의 To-do list 앱입니다.  
해야하는 일들을 완료하고, 경양식을 키워보세요!



## ✨ 주요 기능

- ✅ 구글 로그인  
- 📋 할 일 작성 및 체크  
- 🐱 반려동물 캐릭터 성장  
- 💰 포인트 적립 및 아이템 구매  
- 🛋 배경/장난감/장식 아이템 장착  
- 🗓 날짜별 투두 기록 (자정마다 리셋)  



## 🗂 프로젝트 구조

```bash
lib/
├── config/ # 앱 전체 설정 관련 (예: 라우팅)
│ └── app_routes.dart
├── features/ # 기능(feature) 단위 화면 구조
│ ├── auth/ # 로그인 관련 (LoginScreen)
│ ├── splash/ # 앱 시작 시 보여지는 스플래시 화면
│ ├── home/ # 메인 투두 및 캐릭터 화면
│ └── store/ # 아이템 구매 화면
├── main.dart # 앱 진입점
assets/
└── images/
├── splash_screen.png # 스플래시 배경
├── login_screen_ver2.png # 로그인 배경
└── (추후 추가될 캐릭터/아이템 이미지 등)
```



## 🧭 라우트 구조
경로	화면
/	SplashScreen
/login	LoginScreen
/home	HomeScreen
/store	StoreScreen



## 🧩 향후 확장 예정 구조
```
features/
├── todo/                    # 할 일 CRUD + 날짜 분류
├── pet/                     # 캐릭터 성장 및 상태 관리
├── inventory/               # 아이템 소유, 착용 상태
```


## 🛠 사용 기술 스택

- Flutter
- Firebase Authentication (구글 로그인)
- Firebase Firestore (데이터 저장 예정)
- Provider or Riverpod (상태 관리 예정)
- Figma (UI 설계 도구)




본 문서는 계속 업데이트될 예정입니다.
구조 변경이나 기능 추가 시 함께 수정해 주세요.

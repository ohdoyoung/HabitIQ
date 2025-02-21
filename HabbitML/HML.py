import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder, StandardScaler
import coremltools as ct

# 샘플 사용자 습관 데이터 생성
data = {
    'habit_name': ['명상', '운동', '독서', '물 마시기', '일기 쓰기', '요가', '감사일기', '달리기', '요리', '청소'],
    'completed_count': [5, 10, 3, 8, 4, 2, 7, 6, 9, 1],
    'average_time_spent': [10, 45, 20, 5, 15, 30, 12, 50, 40, 8],  # 분 단위
    'preferred_time_of_day': ['아침', '저녁', '아침', '오후', '저녁', '오전', '오전', '오후', '저녁', '아침'],
    'habit_category': ['건강', '운동', '지식', '건강', '마음', '운동', '마음', '운동', '생활', '생활'],
    'recommended': [1, 1, 0, 1, 0, 0, 1, 1, 1, 0]
}

df = pd.DataFrame(data)

# 문자열 데이터를 숫자로 변환
label_encoders = {}
for col in ['preferred_time_of_day', 'habit_category']:
    le = LabelEncoder()
    df[col] = le.fit_transform(df[col])
    label_encoders[col] = le

# 특성과 라벨 분리
X = df[['completed_count', 'average_time_spent', 'preferred_time_of_day', 'habit_category']]
y = df['recommended']

# 데이터 정규화
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# 훈련 데이터와 테스트 데이터 분리
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2, random_state=42)

# 랜덤 포레스트 모델 학습
model = RandomForestClassifier(n_estimators=100, max_depth=10, random_state=42, n_jobs=-1)
model.fit(X_train, y_train)

# Core ML 모델 변환
mlmodel = ct.converters.sklearn.convert(model)
mlmodel.save("HabitiQ.mlmodel")

print("✅ 최신 Core ML 모델 변환 완료! HabitiQ.mlmodel 저장됨.")
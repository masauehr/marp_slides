---
marp: true
theme: ml-forecast
paginate: false
---

<!-- style: section { font-size: 20px; } -->

# 天気別 予測精度サマリー（2026-09-04）

<div class="cols" style="grid-template-columns: 3fr 2fr;">
<div>

**前日予測（lead=1）／実況天気別**

| 天気 | v3 MAE | v3b MAE | GSR MAE | SSD MAE |
|------|------|------|------|------|
| 快晴 | 3.02 kWh | **2.09 kWh** | 2.71 | 5.30 h |
| 晴れ | 3.06 kWh | 3.15 kWh | 3.41 | 2.05 h |
| 薄曇り〜曇り | 2.02 kWh | 2.72 kWh | 2.52 | 2.74 h |
| 曇り・雨 | 5.15 kWh | 5.41 kWh | 5.41 | 2.60 h |
| **全体** | **3.85 kWh** | **3.87 kWh** | 4.07 | 2.92 h |

*GSR単位: MJ/m² ／ n=120（kWh）・n=606/621（天気分類付与率97.6%）*

</div>
<div>

**わかったこと**

- ☀️ **快晴日はSSD予報が-5.3hの過小評価**。発電量予測はv3b（SSDなし）が明確に優位（bias -0.94 vs v3の-2.18kWh）
- ☁️ **曇り・雨日は誤差最大＆過大評価**：GSR予報がMAE5.41・bias+1.69と「崩れを読み切れない」傾向
- 📉 全体MAEはv3/v3bほぼ互角だが、**天気別に見ると使い分けの余地あり**
- 前日予測（ld=1）は当日予測（ld=0）より全体的に精度低下、特に曇り・雨で顕著

</div>
</div>

<div style="text-align:right; font-size:16px; color:#726f7d;">

詳細: WEATHER_ACCURACY_VALIDATION.md（ml_forecastリポジトリ）

</div>

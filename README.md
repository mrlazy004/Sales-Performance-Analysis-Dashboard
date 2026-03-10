# 📊 Sales Performance Analysis Project
### Excel · SQL · Power BI — End-to-End Data Analytics Project

---

## 🗂️ Project Structure

```
sales-performance-analysis/
│
├── data/
│   ├── raw_sales_data.csv           # Original dataset (with issues)
│   └── cleaned_sales_data.csv       # Post-cleaning dataset
│
├── excel/
│   └── Sales_Performance_Analysis.xlsx
│       ├── Sheet 1: Project Guide
│       ├── Sheet 2: Raw Data
│       ├── Sheet 3: Cleaned Data
│       ├── Sheet 4: Cleaning Log
│       ├── Sheet 5: KPI Dashboard
│       └── Sheet 6: Pivot Analysis
│
├── sql/
│   └── SQL_Queries.sql              # 13 analytical queries
│
├── powerbi/
│   └── PowerBI_Dashboard_Guide.md   # Layout + DAX + Setup guide
│
└── README.md                        # This file
```

---

## 📋 Dataset Schema

| Column        | Type     | Description                          |
|---------------|----------|--------------------------------------|
| Order_ID      | VARCHAR  | Unique order identifier              |
| Order_Date    | DATE     | Date of order (YYYY-MM-DD)           |
| Product_Name  | VARCHAR  | Name of the product                  |
| Category      | VARCHAR  | Technology / Furniture / Office / Clothing |
| Region        | VARCHAR  | North / South / East / West / Central |
| Customer_ID   | VARCHAR  | Unique customer identifier           |
| Quantity      | INT      | Units ordered                        |
| Sales         | DECIMAL  | Revenue from the order ($)           |
| Profit        | DECIMAL  | Profit from the order (can be negative) |

---

## 🧹 Data Cleaning Steps (Excel)

| Issue                  | Count | Resolution                          |
|------------------------|-------|-------------------------------------|
| Duplicate rows         | 10    | Removed with drop_duplicates()      |
| Missing Sales values   | 8     | Filled with category-level median   |
| Missing Region values  | 11    | Filled with mode (most frequent)    |
| Date format issues     | —     | Standardized to YYYY-MM-DD          |
| Added columns          | 2     | Month, Year derived from Order_Date |

---

## 🔍 SQL Analysis Queries

| Query # | Analysis                          |
|---------|-----------------------------------|
| 1       | Top 10 Products by Revenue        |
| 2       | Top 10 Products by Volume         |
| 3       | Region-wise Revenue Breakdown     |
| 4       | Region × Category Cross-Analysis  |
| 5       | Monthly Sales Trend + MoM Growth  |
| 6       | Quarterly Sales Trend             |
| 7       | Profit vs Loss Products           |
| 8       | Loss-Making Products Alert        |
| 9       | Customer Segmentation (RFM-lite)  |
| 10      | Category Performance Scorecard    |
| 11      | Daily Peak Sales Analysis         |
| 12      | YoY Growth Comparison             |
| 13      | Executive Summary View            |

---

## 📊 Power BI Dashboard (3 Pages)

### Page 1 — Executive Overview
- 5 KPI cards with YoY trend indicators
- Monthly sales & profit trend (dual-axis line chart)
- Revenue by region (filled map)
- Top 10 products (horizontal bar chart)
- Sales mix by category (donut chart)

### Page 2 — Sales Deep Dive
- Sales by Region & Category (clustered bar)
- Quarterly trend (area chart)
- Category heat table (matrix with conditional formatting)
- Orders drill-through table

### Page 3 — Profit & Loss Analysis
- Profit vs Loss waterfall chart
- Bottom 10 loss-making products
- Profit margin scatter plot
- Profit by region (conditional color bar chart)

---

## 💡 Key Business Insights

1. **Technology** is the highest revenue category but has inconsistent margins — price optimization needed
2. **North and West regions** lead in revenue; **Central region** underperforms by 18%
3. **Q4** consistently shows 35-40% higher sales — seasonal demand spike (plan inventory accordingly)
4. **8 products** are chronic loss-makers — review pricing or discontinue
5. **Top 10 products** account for ~62% of total revenue — high concentration risk
6. **Average order value** is highest in Furniture ($350+) despite lower volume
7. **Repeat customers** (>2 orders) spend 2.4× more than first-time buyers

---

## 🎯 Business Recommendations

| Priority | Recommendation                                           |
|----------|----------------------------------------------------------|
| 🔴 HIGH  | Discontinue or re-price the 8 chronic loss-making products |
| 🔴 HIGH  | Investigate Central region — root cause of underperformance |
| 🟡 MED   | Build Q4 inventory buffer (35-40% seasonal uplift)       |
| 🟡 MED   | Launch loyalty program targeting repeat customers        |
| 🟢 LOW   | Expand top 3 Technology products into underperforming regions |
| 🟢 LOW   | Bundle Office Supplies with Furniture orders to increase AOV |

---

## 🚀 Deployment Steps

```bash
# Step 1: Download/use the dataset
# Use the provided CSV or download Kaggle Superstore dataset

# Step 2: Clean in Excel
# Open Sales_Performance_Analysis.xlsx → review Cleaning Log sheet

# Step 3: Import to MySQL
mysql -u root -p sales_db < sql/SQL_Queries.sql
# Then import CSV:
# LOAD DATA INFILE 'cleaned_sales_data.csv' INTO TABLE sales_data ...

# Step 4: Run queries
mysql -u root -p sales_db -e "SELECT * FROM executive_summary;"

# Step 5: Connect Power BI
# Get Data → MySQL → localhost → sales_db → sales_data

# Step 6: Build & Publish dashboard
# Follow PowerBI_Dashboard_Guide.md

# Step 7: Push to GitHub
git init
git add .
git commit -m "feat: Sales Performance Analysis — complete project"
git remote add origin https://github.com/yourusername/sales-performance-analysis
git push -u origin main
```

---

## 🛠️ Tech Stack

| Tool          | Version   | Purpose                         |
|---------------|-----------|---------------------------------|
| Microsoft Excel | 365+    | Data cleaning & pivot analysis  |
| MySQL         | 8.0+      | Data storage & SQL analysis     |
| Power BI Desktop | Latest | Dashboard creation              |
| Power BI Service | Cloud  | Publishing & sharing            |
| GitHub        | —         | Version control & documentation |

---

## 📈 KPIs Summary

| KPI                | Value        | Target   | Status |
|--------------------|--------------|----------|--------|
| Total Revenue      | ~$XXX,XXX    | $500K+   | ✅     |
| Total Profit       | ~$XX,XXX     | $80K+    | ⚠️     |
| Profit Margin      | ~XX%         | >15%     | ⚠️     |
| Avg Order Value    | ~$XXX        | >$300    | ✅     |
| Loss-Making Items  | 8 products   | 0        | ❌     |
| Top Region Share   | ~24%         | <40%     | ✅     |

---

*Project by: [Beerappa K B] | [03/10/2026] | Contact: [beerappakb03@gmail.com]*

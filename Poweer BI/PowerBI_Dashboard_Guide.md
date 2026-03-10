# Power BI Dashboard Layout & Setup Guide
## Sales Performance Analysis Dashboard

---

## 1. Dashboard Architecture (3 Pages)

### PAGE 1 — EXECUTIVE OVERVIEW
**Purpose:** C-suite KPI snapshot — at-a-glance health of the business

```
┌─────────────────────────────────────────────────────────────────────┐
│  🔷  SALES PERFORMANCE DASHBOARD  │  Slicer: Year  │  Slicer: Region│
├───────────┬───────────┬───────────┬───────────┬────────────────────┤
│ TOTAL     │  TOTAL    │  TOTAL    │  PROFIT   │  AVG ORDER         │
│ REVENUE   │  PROFIT   │  ORDERS   │  MARGIN   │  VALUE             │
│ $XXX,XXX  │  $XX,XXX  │  XXX      │  XX.X%    │  $XXX              │
│ ▲ +X% YoY │ ▲ +X% YoY │ ▲ +X YoY  │ ▲ +X pts │  ▲ +X% YoY        │
├───────────────────────────────────┬─────────────────────────────────┤
│  📈 MONTHLY SALES & PROFIT TREND  │   🗺️ REVENUE BY REGION (MAP)    │
│  (Line Chart — dual axis)         │   (Filled Map Visual)           │
│  X: Month  Y1: Sales  Y2: Profit  │   Color intensity = Revenue     │
│                                   │   Tooltip: Sales, Profit, Orders│
│  [24-month rolling window]        │                                 │
├───────────────────────────────────┴─────────────────────────────────┤
│  🏆 TOP 10 PRODUCTS BY REVENUE    │   🥧 SALES MIX BY CATEGORY      │
│  (Horizontal Bar Chart)           │   (Donut Chart)                 │
│  Sorted DESC, color by category   │   4 segments, legend right      │
└───────────────────────────────────┴─────────────────────────────────┘
```

---

### PAGE 2 — SALES DEEP DIVE
**Purpose:** Granular analysis for sales managers

```
┌─────────────────────────────────────────────────────────────────────┐
│  Slicers: Category | Region | Date Range (between)                  │
├─────────────────────────────────────────────────────────────────────┤
│  📊 SALES BY REGION & CATEGORY                                      │
│  (Clustered Bar Chart — Region on X, grouped by Category)           │
│  Height = Revenue, Color = Category                                 │
├───────────────────────────┬─────────────────────────────────────────┤
│  📅 QUARTERLY TREND        │  🔥 CATEGORY HEAT TABLE                │
│  (Area Chart)              │  (Matrix Visual)                       │
│  Q1-Q4 per year            │  Rows: Region  Cols: Category          │
│  Shaded area = Sales       │  Values: Revenue, conditional format   │
│  Line = Profit             │  Green (high) → Red (low)              │
├───────────────────────────┴─────────────────────────────────────────┤
│  📋 ORDERS TABLE (Drill-through enabled)                            │
│  Columns: Order_ID | Date | Product | Region | Sales | Profit | %   │
│  Row-level conditional formatting: Red rows = Loss                  │
└─────────────────────────────────────────────────────────────────────┘
```

---

### PAGE 3 — PROFIT & LOSS ANALYSIS
**Purpose:** Profitability deep-dive; identify loss-makers

```
┌─────────────────────────────────────────────────────────────────────┐
│  KPI: Profitable Products (count)  │  Loss-Making Products (count)   │
│  KPI: Total Profit                 │  KPI: Worst Loss Product        │
├───────────────────────────┬─────────────────────────────────────────┤
│  ✅❌ PROFIT vs LOSS       │  📉 BOTTOM 10 PRODUCTS (Loss-Makers)   │
│  (Waterfall Chart)         │  (Horizontal Bar — red bars)           │
│  Cumulative profit build   │  Sorted by Profit ASC                  │
│  Green = profit            │  Tooltip: Category, Region, Orders     │
│  Red = loss items          │                                        │
├───────────────────────────┴─────────────────────────────────────────┤
│  🎯 PROFIT MARGIN SCATTER PLOT                                      │
│  X: Total Revenue  Y: Profit Margin %  Size: Order Count           │
│  Color by Category  Reference lines at 0% and 15% margin           │
├─────────────────────────────────────────────────────────────────────┤
│  📊 PROFIT BY REGION (Column Chart with target line at 0)           │
│  Conditional formatting: bars above 0 = Green, below 0 = Red       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. DAX Measures

```dax
-- ── Core Measures ─────────────────────────────────────────────────
Total Revenue = SUM(sales_data[Sales])

Total Profit = SUM(sales_data[Profit])

Total Orders = DISTINCTCOUNT(sales_data[Order_ID])

Total Customers = DISTINCTCOUNT(sales_data[Customer_ID])

Avg Order Value = DIVIDE([Total Revenue], [Total Orders])

Profit Margin % = DIVIDE([Total Profit], [Total Revenue], 0)

-- ── YoY Comparison ────────────────────────────────────────────────
Revenue LY = 
CALCULATE([Total Revenue],
    DATEADD(sales_data[Order_Date], -1, YEAR))

Revenue YoY Growth = 
DIVIDE([Total Revenue] - [Revenue LY], [Revenue LY])

-- ── Conditional KPI ───────────────────────────────────────────────
Profit Status = 
IF([Total Profit] > 0, "✅ Profitable", "❌ Loss-Making")

-- ── Rolling 3-Month Average ────────────────────────────────────────
Sales 3M Rolling Avg = 
AVERAGEX(
    DATESINPERIOD(sales_data[Order_Date], LASTDATE(sales_data[Order_Date]), -3, MONTH),
    [Total Revenue]
)

-- ── Top N Products ─────────────────────────────────────────────────
IsTop10Product = 
VAR ProductRank = RANKX(ALL(sales_data[Product_Name]), [Total Revenue], , DESC)
RETURN IF(ProductRank <= 10, 1, 0)

-- ── Region Share ───────────────────────────────────────────────────
Region Revenue Share = 
DIVIDE(
    [Total Revenue],
    CALCULATE([Total Revenue], ALL(sales_data[Region]))
)
```

---

## 3. Connecting Power BI to SQL

### MySQL Connection:
1. Power BI Desktop → **Get Data** → **MySQL Database**
2. Server: `localhost` (or your server IP)
3. Database: `sales_db`
4. Table: `sales_data`
5. Import mode (for small datasets) or DirectQuery (for large)

### PostgreSQL Connection:
1. Power BI Desktop → **Get Data** → **PostgreSQL Database**
2. Enter server and database details
3. Use credentials configured during DB setup

### Recommended Import Settings:
- Import mode for <1M rows
- Scheduled refresh: Daily at 6 AM
- Row-level security: By Region (for regional managers)

---

## 4. Theme & Design Standards

| Element          | Specification                          |
|------------------|----------------------------------------|
| Background       | #F5F7FA (light gray)                   |
| Primary Color    | #1B3A6B (navy)                         |
| Accent Color     | #0097A7 (teal)                         |
| Positive/Profit  | #43A047 (green)                        |
| Negative/Loss    | #E53935 (red)                          |
| Font             | Segoe UI, 12pt body, 18pt headers      |
| Canvas Size      | 1366 × 768 (16:9)                      |
| Logo Placement   | Top-left corner                        |

---

## 5. Power BI Service Publishing

### Steps to Publish:
```
1. Power BI Desktop → File → Publish → "My Workspace"
2. Set up Scheduled Refresh:
   Power BI Service → Dataset → Settings → Scheduled Refresh
   → Connect via On-premises Data Gateway (for SQL on local machine)
3. Create Dashboard from Report → Pin key visuals
4. Share: Workspace → Share Dashboard → Enter email addresses
5. Embed: File → Embed Report → Publish to Web (public link)
```

### Row-Level Security (RLS):
```dax
-- In Power BI Desktop → Modeling → Manage Roles
-- Role: "RegionManager"
[Region] = USERNAME()
-- Assign users to roles in Power BI Service → Dataset → Security
```

---

## 6. Key Performance Indicators (KPIs) to Include

| KPI                   | Formula                         | Target        | Alert Color |
|-----------------------|---------------------------------|---------------|-------------|
| Total Revenue         | SUM(Sales)                      | > $500K/year  | Green       |
| Total Profit          | SUM(Profit)                     | > $80K/year   | Green       |
| Profit Margin         | Profit / Revenue                | > 15%         | Red if < 10%|
| Avg Order Value       | Revenue / Orders                | > $300        | Amber < $200|
| MoM Growth            | (Curr - Prev) / Prev            | > 5%/month    | Red if < 0% |
| Orders per Month      | COUNT(Order_ID)                 | > 40/month    | —           |
| Loss-Making Products  | COUNT where Profit < 0          | 0             | Red if > 0  |
| Top Region Share      | Max Region Revenue / Total      | < 40%         | Amber > 50% |
| Customer Retention    | Repeat Customers / Total        | > 30%         | —           |
| YoY Revenue Growth    | (CY - PY) / PY                  | > 10%         | Red if < 0% |

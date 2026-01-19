import pandas as pd
from sqlalchemy import create_engine
import seaborn as sns
import matplotlib.pyplot as plt



# DATABASE CONNECTION
# NOTE:
# The connection string below uses PLACEHOLDERS.
# Replace with your own credentials or use environment variables.

connection_string = "postgresql://username:password@host:port/database_name"
engine = create_engine(connection_string)

try:
    with engine.connect():
        print("Connected to Olist PostgreSQL database")
except Exception as e:
    raise SystemExit(f"Database connection failed: {e}")



# 2. DATA EXTRACTION (SQL → PYTHON)

query = """
SELECT 
    c.customer_unique_id,
    o.order_id,
    o.order_purchase_timestamp,
    p.payment_value
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
JOIN order_payments p 
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered';
"""

df = pd.read_sql(query, engine)
print(f"Extracted {len(df)} rows")

# 3. DATA CLEANING & VALIDATION

# Convert timestamp
df['order_purchase_timestamp'] = pd.to_datetime(df['order_purchase_timestamp'])

# Remove invalid payments
df = df[df['payment_value'] > 0]

# Remove duplicates
df = df.drop_duplicates()

print(" Data cleaning complete")
print(df.isnull().sum())

# 4. RFM BASE TABLE
snapshot_date = df['order_purchase_timestamp'].max() + pd.Timedelta(days=1)

rfm = df.groupby('customer_unique_id').agg({
    'order_purchase_timestamp': lambda x: (snapshot_date - x.max()).days,
    'order_id': 'nunique',
    'payment_value': 'sum'
}).reset_index()

rfm.columns = ['Customer_ID', 'Recency', 'Frequency', 'Monetary']

print(" RFM base table created")
print(rfm.head())

# 5. RFM SCORING (QUINTILES)
rfm['R_Score'] = pd.qcut(rfm['Recency'], 5, labels=[5,4,3,2,1])
rfm['F_Score'] = pd.qcut(rfm['Frequency'].rank(method='first'), 5, labels=[1,2,3,4,5])
rfm['M_Score'] = pd.qcut(rfm['Monetary'], 5, labels=[1,2,3,4,5])

rfm['RFM_Score'] = (
    rfm['R_Score'].astype(str) +
    rfm['F_Score'].astype(str) +
    rfm['M_Score'].astype(str)
)

# 6. CUSTOMER SEGMENTATION
def assign_segment(rfm_score):
    if rfm_score.startswith('5'):
        return 'Champions'
    elif rfm_score.startswith('4'):
        return 'Loyal Customers'
    elif rfm_score.startswith('3'):
        return 'Potential Loyalists'
    elif rfm_score.startswith('2'):
        return 'At Risk'
    else:
        return 'Lost Customers'

rfm['Segment'] = rfm['RFM_Score'].apply(assign_segment)

print(" Customer segmentation completed")
print(rfm['Segment'].value_counts())


# 7. SEGMENT INSIGHTS
segment_summary = rfm.groupby('Segment').agg(
    Customer_Count=('Customer_ID', 'count'),
    Total_Revenue=('Monetary', 'sum'),
    Avg_Spend=('Monetary', 'mean'),
    Avg_Recency=('Recency', 'mean')
).reset_index()

segment_summary['Revenue_Share_%'] = (
    segment_summary['Total_Revenue'] /
    segment_summary['Total_Revenue'].sum() * 100
)

print(" Segment financial summary")
print(segment_summary)

# 8. EXPORT FOR POWER BI
rfm.to_csv("rfm_customers.csv", index=False)
segment_summary.to_csv("rfm_segment_summary.csv", index=False)

print("CSV files exported for Power BI")

##sales_summary
query_sales = """
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    SUM(p.payment_value) AS total_revenue,
    AVG(p.payment_value) AS avg_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;
"""

df_sales = pd.read_sql(query_sales, engine)
df_sales.to_csv("sales_summary.csv", index=False)

# 9. VISUALIZATION 
plt.figure(figsize=(10,6))
sns.barplot(
    data=segment_summary,
    x='Customer_Count',
    y='Segment'
)
plt.title('Customer Distribution by RFM Segment')
plt.tight_layout()
plt.show()

print("✅ RFM analysis completed successfully")

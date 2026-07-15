import streamlit as st
import altair as alt
from snowflake.snowpark.context import get_active_session

session = get_active_session()

st.set_page_config(page_title="Barclays Payments Health Monitor", layout="wide")

# Dark theme
st.markdown("""
<style>
    [data-testid="stAppViewContainer"] { background-color: #0f172a; }
    [data-testid="stHeader"] { background-color: #0f172a; }
    [data-testid="stSidebar"] { background-color: #1e293b; }
    .stApp { background-color: #0f172a; }
    h1, h2, h3, p, span, label, .stMarkdown { color: #e2e8f0 !important; }
    [data-testid="stMetricValue"] { color: #29B5E8 !important; }
    [data-testid="stMetricLabel"] { color: #94a3b8 !important; }
    [data-testid="stCaption"] { color: #64748b !important; }
    div[data-testid="stMetric"] {
        background-color: #1e293b; border: 1px solid #334155;
        border-radius: 8px; padding: 12px 16px;
    }
</style>
""", unsafe_allow_html=True)

st.title("Barclays Payments Health Monitor")
st.caption("Real-time operational dashboard — powered by Dynamic Tables and Cortex AI enrichment")

# Filters
col_f1, col_f2 = st.columns(2)
with col_f1:
    payment_types = session.sql("SELECT DISTINCT PAYMENT_TYPE FROM BARCLAYS_DEMO.PREPARED.DAILY_SUMMARY ORDER BY 1").to_pandas()
    selected_type = st.selectbox("Payment Type", ["ALL"] + payment_types["PAYMENT_TYPE"].tolist())
with col_f2:
    days_back = st.slider("Days to show", min_value=7, max_value=365, value=60)

# Query
where_clause = f"AND PAYMENT_TYPE = '{selected_type}'" if selected_type != "ALL" else ""
df = session.sql(f"""
    SELECT PAYMENT_DAY, PAYMENT_TYPE, REGION, TXN_COUNT, TOTAL_VALUE, FAIL_RATE_PCT, AVG_PROCESSING_MS
    FROM BARCLAYS_DEMO.PREPARED.DAILY_SUMMARY
    WHERE PAYMENT_DAY >= DATEADD(DAY, -{days_back}, (SELECT MAX(PAYMENT_DAY) FROM BARCLAYS_DEMO.PREPARED.DAILY_SUMMARY))
    {where_clause}
    ORDER BY PAYMENT_DAY
""").to_pandas()

if not df.empty:
    # KPIs
    col1, col2, col3, col4 = st.columns(4)
    col1.metric("Total Transactions", f"{df['TXN_COUNT'].sum():,}")
    col2.metric("Total Value", f"\u00a3{df['TOTAL_VALUE'].sum():,.0f}")
    col3.metric("Avg Fail Rate", f"{df['FAIL_RATE_PCT'].mean():.2f}%")
    col4.metric("Avg Processing", f"{df['AVG_PROCESSING_MS'].mean():,.0f}ms")

    st.markdown("---")

    # Failure Rate Chart
    st.subheader("Failure Rate Over Time")
    daily_fail = df.groupby("PAYMENT_DAY", as_index=False).agg({"FAIL_RATE_PCT": "mean"})
    fail_chart = alt.Chart(daily_fail).mark_area(
        line={"color": "#ef4444"},
        color=alt.Gradient(gradient="linear",
            stops=[alt.GradientStop(color="rgba(239,68,68,0.4)", offset=0),
                   alt.GradientStop(color="rgba(239,68,68,0.05)", offset=1)],
            x1=1, x2=1, y1=1, y2=0)
    ).encode(
        x=alt.X("PAYMENT_DAY:T", title="Date", axis=alt.Axis(labelColor="#94a3b8", titleColor="#94a3b8", gridColor="#1e293b")),
        y=alt.Y("FAIL_RATE_PCT:Q", title="Fail Rate %", axis=alt.Axis(labelColor="#94a3b8", titleColor="#94a3b8", gridColor="#1e293b")),
        tooltip=[alt.Tooltip("PAYMENT_DAY:T", title="Date"), alt.Tooltip("FAIL_RATE_PCT:Q", title="Fail %", format=".1f")]
    ).properties(height=250).configure_view(strokeWidth=0, fill="#0f172a").configure(background="#0f172a")
    st.altair_chart(fail_chart, use_container_width=True)

    # Volume Chart
    st.subheader("Transaction Volume by Day")
    daily_vol = df.groupby("PAYMENT_DAY", as_index=False).agg({"TXN_COUNT": "sum"})
    vol_chart = alt.Chart(daily_vol).mark_bar(
        cornerRadiusTopLeft=3, cornerRadiusTopRight=3, color="#29B5E8"
    ).encode(
        x=alt.X("PAYMENT_DAY:T", title="Date", axis=alt.Axis(labelColor="#94a3b8", titleColor="#94a3b8", gridColor="#1e293b")),
        y=alt.Y("TXN_COUNT:Q", title="Transactions", axis=alt.Axis(labelColor="#94a3b8", titleColor="#94a3b8", gridColor="#1e293b")),
        tooltip=[alt.Tooltip("PAYMENT_DAY:T", title="Date"), alt.Tooltip("TXN_COUNT:Q", title="Txns")]
    ).properties(height=250).configure_view(strokeWidth=0, fill="#0f172a").configure(background="#0f172a")
    st.altair_chart(vol_chart, use_container_width=True)

    # Sentiment Summary (from AI Dynamic Table)
    st.subheader("Sentiment by Payment Type (AI-Enriched)")
    try:
        sentiment_df = session.sql("SELECT * FROM BARCLAYS_DEMO.PREPARED.DT_SENTIMENT_OPS_SUMMARY ORDER BY NEGATIVE_PCT DESC").to_pandas()
        if not sentiment_df.empty:
            donut = alt.Chart(sentiment_df).mark_arc(innerRadius=50, outerRadius=100).encode(
                theta=alt.Theta("NEGATIVE_COUNT:Q"),
                color=alt.Color("PAYMENT_TYPE:N",
                    scale=alt.Scale(range=["#29B5E8", "#06b6d4", "#8b5cf6", "#f59e0b", "#ef4444", "#10b981"]),
                    legend=alt.Legend(labelColor="#94a3b8", titleColor="#94a3b8")),
                tooltip=[alt.Tooltip("PAYMENT_TYPE:N"), alt.Tooltip("NEGATIVE_COUNT:Q"), alt.Tooltip("AVG_SENTIMENT:Q", format=".3f")]
            ).properties(height=300).configure_view(strokeWidth=0, fill="#0f172a").configure(background="#0f172a")
            st.altair_chart(donut, use_container_width=True)
    except Exception:
        st.info("Run Step 4 (Cortex AI) to enable sentiment analysis.")

    # Data table
    with st.expander("View raw data"):
        st.dataframe(df, use_container_width=True)
else:
    st.warning("No data for the selected filters.")

st.divider()
st.caption("Data sources: BARCLAYS_DEMO.PREPARED.DAILY_SUMMARY + BARCLAYS_DEMO.PREPARED.DT_SENTIMENT_OPS_SUMMARY (Dynamic Tables)")

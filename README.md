# 📊 Telecom Customer Churn Risk & Revenue Protection Analysis

## 📌 Project Overview

Customer churn is one of the most critical revenue risks in the telecom industry.

In this project, I performed an end-to-end churn analysis to:

- Identify high-risk customer segments
- Quantify revenue exposure
- Build a predictive churn model
- Simulate retention strategies to protect revenue

The analysis combines **SQL, Python (Logistic Regression), and Power BI** to transform raw customer data into actionable business insights.

---

## 🎯 Business Problem

A telecom company is experiencing significant customer churn, leading to substantial annual revenue loss.

Key questions:

- Which customer segments are most likely to churn?
- What behavioral factors drive attrition?
- How much revenue is at risk?
- What targeted strategy can reduce churn effectively?

---

## 🗂 Dataset Overview

The dataset includes ~20,000 telecom customers with:

- Customer demographics
- Contract type (Monthly, 1-Year, 2-Year)
- Plan type (Basic, Premium, Unlimited)
- Tenure (in months)
- Service downtime hours
- Late payment count
- Support ticket history
- Monthly revenue
- Churn flag (Target Variable)

---

## 🛠 Tools & Technologies

- **SQL Server** – Data extraction & segmentation
- **Python** – Data cleaning, modeling, and evaluation
- **Scikit-learn** – Logistic Regression model
- **Power BI** – Executive dashboard & revenue simulation
- **DAX** – Revenue-at-risk calculations

---

## 📊 Key Findings

- Overall churn rate: **18.43%**
- Monthly contract churn: **25.97%**
- First-year Monthly churn: **34%**
- Service downtime and late payments strongly increase churn probability
- Behavioral friction is a stronger driver than pricing

---

## 🤖 Predictive Modeling

Built a Logistic Regression model with class balancing.

**Model Performance:**
- Recall (Churn Class): **70%**
- Focused on identifying high-risk customers rather than maximizing overall accuracy

Top churn drivers:
1. Monthly Contract
2. Service Downtime
3. Late Payment Count
4. Low Tenure

---

## 💰 Revenue Impact Analysis

- Top 1,000 high-risk customers represent ~$75K in monthly revenue
- Estimated annual revenue exposure: **$3.43M**
- With 40% retention success, potential revenue protection: **$1.37M**

---

## 📈 Dashboard Structure
![Dashboard Preview](images/blob/main/Screenshot%202024-07-23%20163757.png)
### Page 1 — Executive Overview
- Churn KPIs
- Contract & Tenure Risk Analysis
- Revenue Exposure

### Page 2 — Behavioral Risk Drivers
- Downtime impact
- Payment behavior analysis
- Risk segmentation

### Page 3 — Predictive & Strategic Layer
- Model performance
- Feature importance
- Revenue protection simulation

---

## 🧠 Strategic Recommendations

- Prioritize first-year Monthly contract customers
- Improve service reliability during onboarding
- Trigger proactive retention outreach after 2 missed payments
- Use predictive risk scoring for targeted intervention

---

## 🚀 Business Impact

This analysis demonstrates how combining segmentation, predictive modeling, and financial simulation can:

- Reduce churn strategically
- Avoid blanket discounting
- Protect multi-million-dollar revenue exposure

---

## 📬 Connect

If you're interested in discussing churn analytics, predictive modeling, or business intelligence projects, feel free to connect.

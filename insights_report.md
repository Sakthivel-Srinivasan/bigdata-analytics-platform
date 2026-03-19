# Insights report

**Project:** Big Data Analytics Platform  
**Author:** Sakthivel Srinivasan  
**Domains:** Retail Sales, Telecom CRM, E-Commerce Catalog Quality

---

## Table of Contents

- [Executive Summary](#executive-summary)
- [Retail Insights](#retail-insights)
- [Telecom Insights](#telecom-insights)
- [Catalog Quality Insights](#catalog-quality-insights)
- [Cross-Domain Observations](#cross-domain-observations)
- [Recommended Actions](#recommended-actions)

---

## Executive summary

This report consolidates KPI findings and analytical observations across three operational domains. Findings are structured around the most actionable signals — areas where data directly points to a business decision, a process change, or a coaching intervention.

| Domain | Headline Metric | Status |
|---|---|---|
| Retail | Avg profit margin: 44.9% | Stable, with category-level variance |
| Telecom | Conversion rate: 55.9% | 15-20pp agent gap — coaching opportunity |
| Catalog | Approval rate: 51.6% | High rework rate, preventable error patterns |

---

## Retail insights

### Revenue and margin

Total simulated revenue for 2024 stands at $7,004,086 across 1,200 orders. Electronics accounts for the highest revenue share, but Apparel delivers a consistently higher average profit margin. This points to a portfolio imbalance — high marketing and operational effort may be directed at lower-margin products.

**Recommendation:** Re-evaluate the category investment mix. If Apparel margins are structurally higher, expanding Apparel SKU range and shelf space before Electronics could improve blended margin without increasing costs.

### Discount strategy

Orders with zero discount carry an average profit margin approximately 12 percentage points higher than orders with discounts above 20%. Revenue volume from heavily discounted orders does not compensate for the margin compression.

**Recommendation:** Introduce discount guardrails. No order should cross the 20% discount threshold without manager approval and a documented justification tied to volume or customer retention.

### Seasonal patterns

Q3 and Q4 consistently outperform Q1 and Q2 across all four regions. Revenue in Q4 is approximately 28% higher than Q1 on average. The pattern is stable enough to be modelled for inventory planning.

**Recommendation:** Front-load stock procurement and staffing decisions by Q2 to absorb Q3 and Q4 demand without fulfillment delays or stockouts.

### Return rate

The overall return rate is 9.9%. Toys and Electronics carry the highest return rates by category. Returns in these categories tend to cluster around Q4, suggesting post-holiday product dissatisfaction.

**Recommendation:** Investigate product description quality and customer expectation setting for high-return categories. Better pre-purchase information can reduce mismatched purchases.

---

## Telecom insights

### Conversion rate

The platform-level conversion rate is 55.9% among eligible leads. At the agent level, the gap between top and bottom performers is 15 to 20 percentage points. The top three agents consistently convert above 68%, while the bottom three sit below 45%.

**Recommendation:** Establish a structured peer-coaching programme. Pair high-converting agents with underperformers for shadow sessions focused on objection handling and product positioning.

### ARPU and channel mix

Phone channel interactions produce 23% higher average ARPU than Chat, despite averaging 4 additional minutes of handling time. The incremental revenue per interaction comfortably offsets the AHT difference.

**Recommendation:** Shift complex product conversations — Business Bundle and Premium Plan in particular — toward the Phone channel. Chat works well for plan queries and basic plan changes but is less effective for high-ARPU closes.

### Error rate and order success

The platform error rate is 9.1%. Three agents account for approximately 60% of all errors flagged. High error rates at the agent level are directly correlated with lower order success rates — meaning these errors are not just data quality issues, they are causing lost sales.

**Recommendation:** Run a targeted root-cause audit for the three flagged agents. Identify whether errors stem from CRM navigation, product knowledge gaps, or process shortcuts. Address through targeted retraining within 30 days.

### Upsell performance

The overall upsell rate is 35.8% of conversions. Upsell rates vary significantly by product — Business Bundle and Premium Plan customers accept upsells at nearly double the rate of Starter Plan customers.

**Recommendation:** Deprioritise upsell attempts on Starter Plan customers mid-call. Resurface upsell offers post-conversion via follow-up email or the next interaction, where receptiveness tends to be higher.

---

## Catalog quality insights

### Overall quality

The catalog approval rate stands at 51.6%, with a rework rate of 48.4%. Nearly half of all items reviewed require correction before they can be uploaded. This represents a significant volume of re-work that adds cost and delays catalog refresh cycles.

### Error distribution

Wrong price and bad description together account for approximately 43% of all errors. Both error types are preventable at the point of data entry with structured validation rules rather than manual QA review.

**Recommendation:** Build upstream validation logic — a pre-submission form or template with mandatory fields, price range checks, and character limits on descriptions. This shifts error prevention to the source and reduces QA burden.

### Analyst productivity

Review time and accuracy are not correlated. Three analysts with above-average review times (above 28 minutes per item) still produce error rates above 40%. Slower review does not mean better QA.

**Recommendation:** Investigate review process consistency. Develop a standardised QA checklist so all analysts follow the same review steps regardless of experience level. This reduces individual variation and makes errors easier to catch quickly.

### Category-level risk

Toys and Electronics carry error rates approximately 2x the platform average. Both categories have more complex attribute requirements — compatibility specs, safety certifications, age ratings — that increase the likelihood of incomplete or incorrect data.

**Recommendation:** Create category-specific QA checklists for Toys and Electronics with required attribute lists. Flag items missing mandatory fields before they reach the analyst queue.

---

## Cross-domain observations

- The Ontario and BC regions produce both the highest retail revenue and the highest telecom ARPU. This geographic overlap suggests a consistent high-value customer profile across both business lines that could be leveraged for cross-sell campaigns.
- Seasonal peaks in retail (Q3 and Q4) coincide with above-average telecom conversion rates in the same months. Coordinated promotions across both business lines during peak periods could amplify both conversion and basket size.
- The catalog rework rate in Toys mirrors the high return rate for the same category in retail. This suggests that poor catalog data quality — wrong descriptions, missing attributes — is contributing directly to mismatched purchases and returns.

---

## Recommended actions

| Priority | Action | Domain | Owner |
|---|---|---|---|
| 1 | Introduce discount guardrails above 20% | Retail | Sales Ops |
| 2 | Launch agent peer-coaching programme | Telecom | QA and Training |
| 3 | Retrain three flagged high-error agents within 30 days | Telecom | Team Lead |
| 4 | Build pre-submission validation for catalog data entry | Catalog | Product and Tech |
| 5 | Create category QA checklists for Toys and Electronics | Catalog | QA Lead |
| 6 | Shift Business Bundle and Premium Plan conversations to Phone | Telecom | Sales Strategy |
| 7 | Front-load Q3 and Q4 inventory procurement by Q2 | Retail | Supply Chain |
| 8 | Investigate Toys and Electronics return rate drivers | Retail and Catalog | Product and QA |

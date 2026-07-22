# Verified Findings

The following results were calculated from all 1,067,371 source rows. Completed
sales exclude cancellation invoices, negative quantities, and nonpositive unit
prices.

| Finding | Verified result |
|---|---:|
| Completed revenue | £20,972,594.57 |
| Completed orders | 40,077 |
| Average order value | £523.31 |
| Units sold | 11,420,305 |
| Active identified customers | 5,878 |
| Cancelled orders | 11,685 |
| Cancellation rate | 22.57% |
| Rows missing customer ID | 243,007 (22.77%) |
| Exact duplicate rows | 34,335 (3.22%) |
| Peak completed-revenue month | November 2011 (£1,509,496.33) |
| Top international market | EIRE (£664,431.78) |
| Top merchandise product | REGENCY CAKESTAND 3 TIER (£344,563.25) |
| Highest-revenue weekday | Thursday (£4,306,392.17) |
| Highest-revenue hour | 12:00 (£2,910,225.35) |

## Interpretation

- November 2011 was the strongest completed-revenue month in the source period.
- Customer-level reporting has a material coverage limitation because 22.77% of
  source rows do not contain a customer identifier.
- Exact duplicates affect 3.22% of source rows and should be investigated before
  using transaction counts for operational decisions.
- EIRE was the largest non-UK market by completed revenue.
- Product reporting excludes adjustment and non-merchandise codes such as
  postage, manual entries, bank charges, and Amazon fees.

## Important limitation

December 2011 contains data only through December 9. Its revenue should not be
compared directly with complete months.


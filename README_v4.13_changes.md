# Lucky Delivery v4.13 changes

- Admin System Rules & Settings now controls customer payment methods:
  - Cash
  - Direct UPI
  - App Payment
- Backend rejects a payment method when Admin has disabled it.
- Admin cannot accidentally disable every payment method; at least one must remain enabled.
- Payment-method availability is captured on the order at final acceptance for clear customer UI.
- Existing Razorpay platform-fee verification and webhook security from v4.12 are preserved.
- No order live-photo proof requirement was reintroduced.
